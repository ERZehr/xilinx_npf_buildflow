# Run synthesis
puts "Running synthesis for design: $design_name"
synth_design -top $top_module -part $part

# Write_synth_checkpoint
write_checkpoint -force "synthesized_${design_name}.dcp"