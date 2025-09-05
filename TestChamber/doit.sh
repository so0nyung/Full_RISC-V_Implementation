#!/bin/bash

# This script runs the testbench
# Usage: ./doit.sh <file1.cpp> <file2.cpp>

# Constants
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
TEST_FOLDER="$(realpath "$SCRIPT_DIR/tests")"
RTL_FOLDER="$(realpath "$SCRIPT_DIR/../rtl-Pipeline")"
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Variables
passes=0
fails=0
files=()

# Handle terminal arguments
if [[ $# -eq 0 ]]; then
    # If no arguments provided, run all tests
    files=("${TEST_FOLDER}"/*.cpp)
else
    # If arguments provided, use them as input files
    for arg in "$@"; do
        if [[ "$arg" != /* ]]; then
            files+=("${TEST_FOLDER}/${arg}")
        else
            files+=("$arg")
        fi
    done
fi

echo "Using files: ${files[@]}"

# Cleanup
rm -rf obj_dir

# Move to script directory
cd "$SCRIPT_DIR" || exit 1

# Iterate through files
for file in "${files[@]}"; do
    filename=$(basename "$file")
    name="${filename%%_tb.cpp}"

    # If verify.cpp -> we are testing the top module
    if [[ "$filename" == "verify.cpp" ]]; then
        name="top"
    fi

    # Translate Verilog -> C++ including testbench
    verilator -Wall --trace \
              -cc "${RTL_FOLDER}/${name}.sv" \
              --exe "$file" \
              -y "${RTL_FOLDER}" \
              --prefix "Vdut" \
              -o Vdut \
              -CFLAGS "-isystem /opt/homebrew/Cellar/googletest/1.15.2/include" \
              -LDFLAGS "-L/opt/homebrew/Cellar/googletest/1.15.2/lib -lgtest -lgtest_main -lpthread"

    # Build C++ project with automatically generated Makefile
    make -j -C obj_dir/ -f Vdut.mk

    # Run executable simulation file
    if ./obj_dir/Vdut; then
        ((passes++))
    else
        ((fails++))
    fi
done

# Exit as a pass or fail (for CI purposes)
total=$((passes + fails))
if [[ $fails -eq 0 ]]; then
    echo "${GREEN}Success! All ${passes} test(s) passed!${RESET}"
    exit 0
else
    echo "${RED}Failure! Only ${passes} test(s) passed out of ${total}.${RESET}"
    exit 1
fi
