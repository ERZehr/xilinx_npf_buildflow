# For submodules, these are ignored
set design_name "my_design"
set part "xc7a35tcpg236-1 (your part number)"
set top_module "my_top_module"

# Any pure or altered vivado IPs used at this level in the design
set this_vivado_ip_files {
    {"relative_filepath/ip1.tcl" "library_name"}
    {"relative_filepath/ip2.tcl" "library_name"}
    {...... # Add any additional ip files and lib names here}
}

# Any block diagrams used at this level in the design
set this_vivado_bd_files {
    {"relative_filepath/block1.bd" "library_name"}
    {"relative_filepath/block1.bd" "library_name"}
    {...... # Add any additional bd files and lib names here}
}

# Any RTL files used at this level of the design
set this_rtl_files {
    {"relative_filepath/file.vhd" "library_name"}
    {"relative_filepath/file.v" "library_name"}
    {"relative_filepath/file.sv" "library_name"}
    {... # Add any additional rtl files and lib names here}
}

# src.tcl files for direct submodules
set submodule_src_files {
    "relative_filepath/submodule1/src.tcl"
    "relative_filepath/submodule2/src.tcl"
    ... # Add any additional submodule src files here
}

# ==== Pre-Synthesis Constraints ====
# Static: define clocks, input/output delays, false/multicycle paths, clock groups, case analysis, dont_touch/preserve, debug nets
# PR: define top-level clocks crossing into PR regions, case analysis for RM variants, global dont_touch/preserve on partition/interface pins
set pre_synth_constraints {
    "static_clocks_relative_filepath/file.xdc"
    "dynamic_clocks_relative_filepath/file.xdc"
    ... # Add any additional xdc files here
}

# ==== Pre-Place Constraints ====
# Static: pin LOCs, IO standards, package pin assignments, BUFG/MMCM/GT placement, Pblocks/area groups, SLR/CLOCK_REGION, prohibit sites
# PR: create Pblocks for each reconfigurable region, lock static logic outside PR regions, assign interface pins for static↔RM connections, prohibit placement/routing into PR regions
set pre_place_constraints {
    "static_pinout_relative_filepath.xdc"
    "static_pblocks_relative_filepath.xdc"
    "dynamic_clocks_relative_filepath.xdc"
    "dynamic_pblocks_relative_filepath.xdc"
    ... # Add any additional xdc files here
}

# ==== Post-Place Constraints ====
# Static: path-specific max/min delays, hold/setup adjustments, skew/fanout limits, clock uncertainty, retiming enable/disable, Pblock legality
# PR: enforce timing exceptions at static↔RM boundaries, legalize RM Pblocks, check interface timing for partition pins, DFX decoupler placement
set post_place_constraints {
    "static_fanout_relative_filepath.xdc"
    "static_max_delay_relative_filepath.xdc"
    "dynamic_fanout_relative_filepath.xdc"
    ... # Add any additional xdc files here
}

# ==== Post-Route Constraints ====
# Static: final timing exceptions, detailed hold/setup checks, CDC/DRC, bus skew reports, signal integrity (transition/load), bitstream/pr pin checks
# PR: enforce route containment (no static nets crossing into RM Pblocks), prohibit routing violations, validate isolation of static vs dynamic regions, final boundary timing checks
set post_route_constraints {
    "static_timing_exceptions_relative_filepath.xdc"
    "static_bus_skew_relative_filepath.xdc"
    "dynamic_timing_exceptions_relative_filepath.xdc"
    "dynamic_bus_skew_relative_filepath.xdc"
    ... # Add any additional xdc files here
}

set sim_files {
    "relative_filepath/sim/testbench.vhd"
    "relative_filepath/sim/stimulus_pkg.vhd"
    ... # Add any additional simulation files here
}
