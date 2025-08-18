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

# Post PLace constraints files
set post_place_constraints [$post_place_constraints]

for constraint_file $post_place_constraints {
    if {[file exists $constraint_file]} {
        puts "Reading post-place constraint file: $constraint_file"
        read_xdc $constraint_file
    } else {
        puts "Warning: Post-place constraint file not found: $constraint_file"
    }
}
