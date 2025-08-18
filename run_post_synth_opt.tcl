# Run opt design
puts "Running opt design for design: $design_name"
opt_design -top $top_module -part $part

# Run power opt design
puts "Running power opt design for design: $design_name"
power_opt_design -top $top_module -part $part