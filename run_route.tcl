# Run route design
puts "Running route design for design: $design_name"
route_design -top $top_module -part $part

# Write_synth_checkpoint
write_checkpoint -force "routed_${design_name}.dcp"