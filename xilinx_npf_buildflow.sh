#!/bin/bash
set -e

# create build directories
if ! [ -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi
if ! [ -d "$IMG_DIR" ]; then
    mkdir -p "$IMG_DIR"
fi
if ! [ -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

# Source config from the script directory
source "$TARGET_DIR/cfg.sh"

# Collect version info
"$NPF_DIR/configuration_managment.sh" | tee "$LOG_DIR/configuration_management.log"

# Read files and run synthesis
"$NPF_DIR/synthesis.sh" | tee "$LOG_DIR/synthesis.log"
mv ${NPF_DIR}/*.dcp "${BUILD_DIR}"

# Implementation & Bitgen
"$NPF_DIR/implement.sh" | tee "$LOG_DIR/implement.log"
mv ${NPF_DIR}/*.dcp "${BUILD_DIR}"
mv ${NPF_DIR}/*.mcs "${BUILD_DIR}"
mv ${NPF_DIR}/*.rpt "${LOG_DIR}"
mv ${NPF_DIR}/*.txt "${LOG_DIR}"
mv ${NPF_DIR}/*.bit "${IMG_DIR}"
mv ${NPF_DIR}/*.bin "${IMG_DIR}"
# Format output files
