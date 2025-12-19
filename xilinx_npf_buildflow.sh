#!/bin/bash
set -e

# create build directories
mkdir -p "$BUILD_DIR"
mkdir -p "$IMG_DIR"
mkdir -p "$LOG_DIR"

# Source config from the script directory
source "$TARGET_DIR/cfg.sh"

# Collect version info
"$NPF_DIR/configuration_managment.sh" | tee "$LOG_DIR/configuration_management.log"

# Read files and run synthesis
"$NPF_DIR/synthesis.sh" | tee "$LOG_DIR/synthesis.log"
mv "$TARGET_DIR/*.dcp" "$BUILD_DIR/" || true

# Implementation & Bitgen
"$NPF_DIR/implement.sh" | tee "$TARGET_DIR/logs/implement.log"
mv "$TARGET_DIR"/*.dcp "$BUILD_DIR" || true
mv "$TARGET_DIR"/*.mcs "$BUILD_DIR" || true
mv "$TARGET_DIR"/*.rpt "$LOG_DIR" || true
mv "$TARGET_DIR"/*.txt "$LOG_DIR" || true
mv "$TARGET_DIR"/*.bit "$IMG_DIR" || true
mv "$TARGET_DIR"/*.bin "$IMG_DIR" || true

# Format output files
