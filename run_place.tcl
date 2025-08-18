# Run place design
puts "Running place design for design: $design_name"
place_design -top $top_module -part $part

# Write_synth_checkpoint
write_checkpoint -force "placed_${design_name}.dcp"