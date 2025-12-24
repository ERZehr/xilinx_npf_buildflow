set_param general.maxThreads 8

set script_path [file normalize [info script]]
set SCRIPT_DIR [file dirname $script_path]
cd $SCRIPT_DIR

# Load top-level vars from src.tcl
if {[file exists "../../top/hdl/scripts/src.tcl"]} {
    set fh [open "../../top/hdl/scripts/src.tcl" r]
    set file_content [read $fh]
    close $fh
    eval $file_content
} else {
    error "File not found: ../../top/hdl/scripts/src.tcl"
}

puts "Design Name: $design_name"
puts "Part:        $part"
puts "Top Module:  $top_module"
puts ""

# Get all the src files from submodules
set all_src_files $submodule_src_files
foreach src $all_src_files {
    set src_filepath [file dirname [file dirname [file dirname $src]]]
    set fh [open $src r]
    set file_content [read $fh]
    eval $file_content

    # grab submodule src files and add them to the list we are iterating through
    foreach file $submodule_src_files {
        set new_filepath [string cat $src_filepath "/scripts/" [file tail [lindex $file 0]]]
        lappend all_src_files $new_filepath
    }
}

# Reverse the list to process in correct order (dependencies first)
# Add the top level src.tcl last
set all_src_files [lreverse $all_src_files]
lappend all_src_files "../../top/hdl/scripts/src.tcl"

puts "All Source Files to Process: $all_src_files"

set all_ip_files {}
set all_bd_files {}
set all_rtl_files {}
set all_pre_synth {}
# Read our source files and accumulate all files
foreach src $all_src_files {
    set src_filepath [file dirname [file dirname [file dirname $src]]]
    set fh [open $src r]
    set file_content [read $fh]
    eval $file_content

    # IP
    foreach file $this_vivado_ip_files {
        set new_filepath [string cat $src_filepath "/ip/" [file tail [lindex $file 0]]]
        lappend all_ip_files $new_filepath
    }
    # BD 
    foreach file $this_vivado_bd_files {
        set new_filepath [string cat $src_filepath "/bd/" [file tail [lindex $file 0]]]
        lappend all_bd_files $new_filepath
    }
    # RTL 
    foreach file $this_rtl_files {
        set new_filepath [string cat $src_filepath "/hdl/" [file tail [lindex $file 0]]]
        set lib [lindex $file 1]
        lappend all_rtl_files [list $new_filepath $lib]
    }
    # Pre Synth XDC
    foreach file $pre_synth_constraints {
        set new_filepath [string cat $src_filepath "/constraints/" [file tail [lindex $file 0]]]
        lappend all_pre_synth $new_filepath
    }
}


# -----------------------------
# Deduplicate list based on file path + library
# -----------------------------
proc dedup_sources {sources} {
    array set seen {}
    set unique {}
    foreach s $sources {
        set key "[lindex $s 0]::[lindex $s 1]"  ;# path + library
        if {![info exists seen($key)]} {
            set seen($key) 1
            lappend unique $s
        }
    }
    return $unique
}
# -----------------------------
# Deduplicate final lists
# -----------------------------
set deduped_ip_files   [dedup_sources $all_ip_files]
set deduped_bd_files   [dedup_sources $all_bd_files]
set deduped_rtl_files  [dedup_sources $all_rtl_files]
set deduped_pre_synth  [dedup_sources $all_pre_synth]


# -----------------------------
# Helper: rewrite relative paths
# -----------------------------
proc rewrite_relative {sources SCRIPT_DIR} {
    set rewritten {}
    set repo_root [file normalize "../../.."]
    foreach s $sources {
        set file [lindex $s 0]
        set lib  [lindex $s 1]
        set new_file $SCRIPT_DIR/$file
        lappend rewritten [list $new_file $lib]
    }
    return $rewritten
}
# -----------------------------
# Absolute File Paths
# -----------------------------
set deduped_ip_files   [rewrite_relative $deduped_ip_files $SCRIPT_DIR]
set deduped_bd_files   [rewrite_relative $deduped_bd_files $SCRIPT_DIR]
set deduped_rtl_files  [rewrite_relative $deduped_rtl_files $SCRIPT_DIR]
set deduped_pre_synth  [rewrite_relative $deduped_pre_synth $SCRIPT_DIR]

# -----------------------------
# Print summary
# -----------------------------
puts "\nDeduped IP Files:  $deduped_ip_files"
puts ""
puts "\nDeduped BD Files:  $deduped_bd_files"
puts ""
puts "\nDeduped RTL Files: $deduped_rtl_files"
puts ""
puts "\nPre-Synth XDCs:    $deduped_pre_synth"
puts ""

# -----------------------------
# Read files into Vivado
# -----------------------------
foreach ip_file $deduped_ip_files {
    set ip_path [lindex $ip_file 0]
    if {[file exists $ip_path]} {
        source $ip_path
    } else {
        error "IP file not found: $ip_path"
    }
}

foreach bd_file $deduped_bd_files {
    set bd_path [lindex $bd_file 0]
    if {[file exists $bd_path]} {
        source $bd_path
    } else {
        error "Block Diagram file not found: $bd_path"
    }
}

foreach rtl_file $deduped_rtl_files {
    set rtl_path [lindex $rtl_file 0]
    set rtl_lib  [lindex $rtl_file 1]
    if {[file exists $rtl_path]} {
        set file_type [file extension $rtl_path]
        puts "Reading RTL file: $rtl_path"
        switch $file_type {
            ".vhd"  - ".vhdl" { read_vhdl -library $rtl_lib -vhdl2008 $rtl_path }
            ".v"   - ".sv"    { read_verilog -library $rtl_lib $rtl_path }
            default { error "Unsupported RTL file type: $rtl_path" }
        }
    } else {
        error "RTL file not found: $rtl_path"
    }
}

foreach constraint_file $deduped_pre_synth {
    if {[file exists $constraint_file]} {
        puts "Reading pre-synthesis constraint file: $constraint_file"
        read_xdc $constraint_file
    } else {
        puts "Warning: Pre-synthesis constraint file not found: $constraint_file"
    }
}

# Run synthesis
puts "Running synthesis for design: $design_name"
synth_design -top $top_module -part $part

# Write_synth_checkpoint
write_checkpoint -force "synthesized_${design_name}.dcp"