#!/bin/sh
set -e
cmd.exe /c "${VIVADO} -mode batch -source $WINDOWS_PATH/$NPF_DIR/run_implement.tcl -nolog -nojournal -notrace"
