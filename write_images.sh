#!/bin/sh
set -e
cmd.exe /c "${VIVADO} -mode batch -source ../../modules/xilinx_npf_buildflow/run_write_images.tcl -nolog -nojournal -notrace"