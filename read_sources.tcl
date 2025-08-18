# Open the file in read mode
if {[file exists "../../top/hdl/scripts/src.tcl"]} {
    set top_level_src [open "../../top/hdl/scripts/src.tcl" r]
} else {
    error "File not found"
}

# Read the content of the file
set file_content [read $top_level_src]

# Close the file
close $top_level_src   

# Evaluate the content of the file to set variables
eval $file_content
# Now you can use the variables defined in src.tcl
# For example, print the design name    
puts "Design Name: $design_name"
puts "Part: $part"
puts "Top Module: $top_module"

# Deduplication of source files
# IP
set merged_ip_files [concat $this_vivado_ip_files $submodule_ip_files]
# BD
set merged_bd_files [concat $this_bd_files $submodule_bd_files]
# RTL
set merged_rtl_files [concat $this_rtl_files $submodule_rtl_files]

# Deduplicate by file+library key
proc dedup_file_list {file_list} {
    set dict {}
    foreach pair $file_list {
        if {[llength $pair] == 2} {
            lassign $pair file lib
            set key "$file|$lib"
            dict set dict $key $pair
        } else {
            set file $pair
            set lib ""
        }
        set file [file normalize $file]
        set key "$file|$lib"
        dict set dict $key $pair
    }
    return [dict values $dict]
}

puts "Deduplicated IP files: [llength $this_vivado_ip_files]"
puts "Deduplicated BD files: [llength $this_bd_files]"
puts "Deduplicated RTL files: [llength $this_rtl_files]"

# Deduplicate merged lists
set this_vivado_ip_files [dedup_file_list $merged_ip_files]
set this_bd_files       [dedup_file_list $merged_bd_files]
set this_rtl_files      [dedup_file_list $merged_rtl_files]


# read IP into the project
foreach ip_file $this_vivado_ip_files {
    set ip_path [lindex $ip_file 0]
    set ip_lib [lindex $ip_file 1]
    if {[file exists "$ip_path"]} {
        source "$ip_path"
    } else {
        error "IP file not found: $ip_path"
    }
}

# read BD into the project
foreach bd_file $this_bd_files {
    set bd_path [lindex $bd_file 0]
    set bd_lib [lindex $bd_file 1]
    if {[file exists "$bd_path"]} {
        source "$bd_path"
    } else {
        error "Block Diagram file not found: $bd_path"
    }
}

# read RTL into the project
foreach rtl_file $this_rtl_files {
    set rtl_path [lindex $rtl_file 0]
    set rtl_lib [lindex $rtl_file 1]
    if {[file exists "$rtl_path"]} {
        set file_type [file extension $rtl_path]
        puts "Reading RTL file: $rtl_path into library $rtl_lib"
        switch $file_type {
            ".vhd"  - [read_vhdl $rtl_path]
            ".vhdl" - [read_vhdl $rtl_path]
            ".v"    - [read_verilog $rtl_path]
            ".sv"   - [read_verilog $rtl_path]
            default { error "Unsupported RTL file type: $rtl_path" }
        }
    } else {
        error "RTL file not found: $rtl_path"
    }
}