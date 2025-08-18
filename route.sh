#!/bin/sh
# apply post place constraints
tclsh apply_post_place_constraints.tcl

# run phys opt design
vivado -mode batch -source run_route.tcl

# apply post route constraints
tclsh apply_post_route_constraints.tcl