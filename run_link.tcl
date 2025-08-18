# Run link design
puts "Running link design for design: $design_name"
link_design -top $top_module -part $part

# Write_synth_checkpoint
write_checkpoint -force "linked_${design_name}.dcp"