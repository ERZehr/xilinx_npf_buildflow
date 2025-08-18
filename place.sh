#!/bin/sh

# apply pre-place constraints
tclsh apply_pre_place_constraints.tcl

# run place
vivado -mode batch -source run_place.tcl