######################### SETUP #############################
set_param general.maxThreads 8

# Load top-level vars from src.tcl
if {[file exists "../../top/hdl/scripts/src.tcl"]} {
    set fh [open "../../top/hdl/scripts/src.tcl" r]
    set file_content [read $fh]
    close $fh
    eval $file_content
} else {
    error "File not found: ../../top/hdl/scripts/src.tcl"
}


################ POST ROUTE CONSTRAINTS ####################
set all_src_files { ../../top/hdl/scripts/src.tcl }
set all_post_route {}

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

    # Post Route XDC
    foreach file $post_route_constraints {
        set new_filepath [string cat $src_filepath "/constraints/" [file tail [lindex $file 0]]]
        puts "Processing: $new_filepath"
        lappend all_post_route $new_filepath
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
set deduped_post_route  [dedup_sources $all_post_route]

# -----------------------------
# Print summary
# -----------------------------
puts ""
puts "\nPost-Route XDCs:    $deduped_post_route"
puts ""

# -----------------------------
# Read files into Vivado
# -----------------------------

foreach constraint_file $deduped_post_route {
    if {[file exists $constraint_file]} {
        puts "Reading post-route constraint file: $constraint_file"
        read_xdc $constraint_file
    } else {
        puts "Warning: Post-route constraint file not found: $constraint_file"
    }
}


##################### WRITE IMAGES #######################
# Write the bitstream
write_bitstream -force ./top.bit

