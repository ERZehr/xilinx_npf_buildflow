######################### SETUP #############################
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


######################### LINK STAGE #########################
# Read in Synth dcp
read_checkpoint ../../make/${design_name}/spnr/synthesized_${design_name}.dcp

# Run Link design
puts "Running link design for design: $design_name"
link_design -top $top_module -part $part

# Write_link_checkpoint
write_checkpoint -force "linked_${design_name}.dcp"


######################### OPT STAGE ##########################
# Run opt design
puts "Running opt design for design: $design_name"
opt_design -directive Explore

# Run power opt design
puts "Running power opt design for design: $design_name"
power_opt_design

# Write_post_synth_opt_checkpoint
write_checkpoint -force "post_synth_opt_${design_name}.dcp"


################### POST SYNTH CONSTRAINTS ##################
set all_src_files { ../../top/hdl/scripts/src.tcl }
set all_post_synth {}

# -----------------------------
# Helper: rewrite relative paths
# -----------------------------
proc rewrite_relative {abs_target top_module} {
    set abs_target [file normalize $abs_target]
    puts $abs_target
    set repo_root [file normalize "../../.."]
    puts $repo_root
    if {[string first $repo_root $abs_target] == 0} {
        set rel_tail [string range $abs_target [string length $repo_root] end]
        return "../../$rel_tail"
    } else {
        return $abs_target
    }
}

foreach src $all_src_files {
    set src_filepath [file dirname [file dirname [file dirname $src]]]
    set fh [open $src r]
    set file_content [read $fh]
    eval $file_content

    # SRC 
    foreach file $submodule_src_files {
        puts "Processing: $file"
        set new_filepath [string cat $src_filepath "/scripts/" [file tail [lindex $file 0]]]
        puts "Processing: $new_filepath"
        lappend all_src_files $new_filepath
    }

    # Pre Synth XDC
    foreach file $pre_synth_constraints {
        set new_filepath [string cat $src_filepath "/constraints/" [file tail [lindex $file 0]]]
        puts "Processing: $new_filepath"
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
set deduped_post_synth  [dedup_sources $all_post_synth]

# -----------------------------
# Print summary
# -----------------------------
puts ""
puts "\nPost-Synth XDCs:    $deduped_post_synth"
puts ""

foreach constraint_file $deduped_post_synth {
    if {[file exists $constraint_file]} {
        puts "Reading post-synthesis constraint file: $constraint_file"
        read_xdc $constraint_file
    } else {
        puts "Warning: Post-synthesis constraint file not found: $constraint_file"
    }
}


####################### PLACE STAGE #########################
# Run place design
puts "Running place design for design: $design_name"
place_design


################## POST PLACE OPT ####################
# Run phys opt design
puts "Running phys opt design for design: $design_name"
phys_opt_design

# Write_place_checkpoint
write_checkpoint -force "placed_${design_name}.dcp"


################# POST PLACE CONSTRAINTS ####################
set all_src_files { ../../top/hdl/scripts/src.tcl }
set all_post_place {}

foreach src $all_src_files {
    set src_filepath [file dirname [file dirname [file dirname $src]]]
    set fh [open $src r]
    set file_content [read $fh]
    eval $file_content

    # SRC 
    foreach file $submodule_src_files {
        puts "Processing: $file"
        set new_filepath [string cat $src_filepath "/scripts/" [file tail [lindex $file 0]]]
        puts "Processing: $new_filepath"
        lappend all_src_files $new_filepath
    }

    # Post Place XDC
    foreach file $post_place_constraints {
        set new_filepath [string cat $src_filepath "/constraints/" [file tail [lindex $file 0]]]
        puts "Processing: $new_filepath"
        lappend all_post_place $new_filepath
    }
}

# -----------------------------
# Deduplicate final lists
# -----------------------------
set deduped_post_place  [dedup_sources $all_post_place]

# -----------------------------
# Print summary
# -----------------------------
puts ""
puts "\nPost-Place XDCs:    $deduped_post_place"
puts ""

foreach constraint_file $deduped_post_place {
    if {[file exists $constraint_file]} {
        puts "Reading post-placement constraint file: $constraint_file"
        read_xdc $constraint_file
    } else {
        puts "Warning: Post-placement constraint file not found: $constraint_file"
    }
}


################### ROUTE DESIGN #####################
# Run route design
puts "Running route design for design: $design_name"
route_design

################## POST PLACE OPT ####################
# Run phys opt design
puts "Running phys opt design for design: $design_name"
phys_opt_design

# Write_route_checkpoint
write_checkpoint -force "routed_${design_name}.dcp"


####################### REPORTS STAGE ########################
report_timing_summary  -file "timing_summary.rpt"
report_utilization     -file "utilization.rpt"
report_route_status    -file "route_status.rpt"
report_bus_skew        -file "bus_skew.rpt"
report_drc             -file "drc.rpt"


##################### WRITE IMAGES #######################
source ../../modules/xilinx_npf_buildflow/run_write_images.tcl


