#!/bin/bash
set -e
mkdir spnr img logs
source ./cfg.sh

# Collect version info
../../modules/xilinx_npf_buildflow/configuration_managment.sh | tee logs/configuration_management.log

# Read files and run synthesis
../../modules/xilinx_npf_buildflow/synthesis.sh | tee logs/synthesis.log
mv *.dcp spnr/

# Implementation & Bitgen
../../modules/xilinx_npf_buildflow/implement.sh | tee logs/implement.log
mv *.dcp spnr/
mv *.rpt logs/
mv *.txt logs/
mv *.bit spnr/
mv *.bin spnr/
mv *.mcs spnr/


# Format output files
