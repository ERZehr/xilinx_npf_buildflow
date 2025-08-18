#!/bin/sh

# apply pre-synthesis constraints
tclsh apply_pre_synth_constraints.tcl

# run synthesis
vivado -mode batch -source run_synthesis.tcl