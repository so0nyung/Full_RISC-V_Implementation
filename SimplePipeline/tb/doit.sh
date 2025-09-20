#!/bin/bash

# This script runs the Verilator testbenches
# Usage: ./doit.sh [file1.cpp file2.cpp ...]

# Constants
SCRIPT_DIR=$(dirname "$(realpath "$0")")
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests")
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl-Pipeline")
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Variables
passes=0
fails=0

# Handle arguments
if [[ $# -eq 0 ]]; then
    # If no arguments provided, run all tests
    shopt -s nullglob
    files=(${TEST_FOLDER}/*.cpp)
    shopt -u nullglob
else
    # If arguments provided, use them as input files
    files=("$@")
fi

cd "$SCRIPT_DIR"

# Wipe previous test output
rm -rf test_out/*
mkdir -p test_out

# If no testbench files found
if [[ ${#files[@]} -eq 0 ]]; then
    echo "${RED}No testbench .cpp files found in $TEST_FOLDER${RESET}"
    exit 1
fi

# Iterate through testbenches
for file in "${files[@]}"; do
    tb_name=$(basename "$file" .cpp)

    echo "---------------------------------------"
    echo "Running testbench: $tb_name"
    echo "---------------------------------------"

    # Translate Verilog -> C++ including testbench
    verilator -Wall --trace \
              -cc ${RTL_FOLDER}/*.sv \
              --exe "$file" \
              -y ${RTL_FOLDER} \
              --prefix "Vdut" \
              --top-module top \
              -o Vdut \
              -LDFLAGS "-lgtest -lgtest_main -lpthread"

    # Build C++ project with automatically generated Makefile
    if make -j -C obj_dir/ -f Vdut.mk; then
        # Run executable simulation file
        ./obj_dir/Vdut
        if [[ $? -eq 0 ]]; then
            echo "${GREEN}[PASS]${RESET} $tb_name"
            ((passes++))
        else
            echo "${RED}[FAIL]${RESET} $tb_name"
            ((fails++))
        fi
    else
        echo "${RED}[BUILD FAIL]${RESET} $tb_name"
        ((fails++))
    fi

done

