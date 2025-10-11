#!/bin/bash

# This script runs the testbench
# Usage: ./doit.sh [single|pipeline|cache|all] [test_files...]
# Examples:
#   ./doit.sh all                    # Run all tests on all CPUs
#   ./doit.sh cache                  # Run all tests on cache CPU
#   ./doit.sh single test1.cpp       # Run specific test on single CPU

# Constants
SCRIPT_DIR=$(dirname "$(realpath "$0")")
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests")
SINGLE_CPU=$(realpath "$SCRIPT_DIR/../rtl_Single")
PIPELINE_CPU=$(realpath "$SCRIPT_DIR/../rtl_Pipeline")
CACHE_CPU=$(realpath "$SCRIPT_DIR/../rtl_Cache")

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# Function to run tests for a specific CPU
run_tests() {
    local cpu_type=$1
    local cpu_path=$2
    shift 2
    local test_files=("$@")  
    
    echo ""
    echo "========================================="
    echo "Testing ${cpu_type^} CPU"
    echo "========================================="
    
    local passes=0
    local fails=0
    
    cd "$SCRIPT_DIR"
    
    # Wipe previous test output for this CPU
    rm -rf "test_out_${cpu_type}"
    mkdir -p "test_out_${cpu_type}"
    
    # Iterate through files
    for file in "${test_files[@]}"; do
        # Get the base filename and remove .cpp extension
        name=$(basename "$file" .cpp)
        # Remove _tb suffix if present
        name=${name%_tb}
        # Remove everything after first dash if present
        name=$(echo "$name" | cut -f1 -d\-)
        
        # If verify -> we are testing the top module
        if [ "$name" == "verify" ]; then
            name="top"
        fi
        
        echo ""
        echo "Running test: $(basename "$file") on ${cpu_type}..."
        
        # Translate Verilog -> C++ including testbench
        verilator   -Wall --trace \
                    -cc "${cpu_path}/${name}.sv" \
                    --exe "${file}" \
                    -y "${cpu_path}" \
                    --prefix "Vdut" \
                    -o Vdut \
                    -LDFLAGS "-lgtest -lgtest_main -lpthread"
        
        # Build C++ project with automatically generated Makefile
        make -j -C obj_dir/ -f Vdut.mk
        
        # Run executable simulation file
        ./obj_dir/Vdut
    
        
    done
    
    # Save obj_dir in test_out
    if [ -d obj_dir ]; then
        mv obj_dir "test_out_${cpu_type}/"
    fi
    
    # echo ""
    # echo "${cpu_type} Results: ${GREEN}${passes} passed${RESET}, ${RED}${fails} failed${RESET}"
    
    return $fails
}

# Main script logic
cd "$SCRIPT_DIR"

# Determine CPU type
if [[ $# -eq 0 ]]; then
    # Default: run all tests on all CPUs
    cpu_mode="all"
    files=("${TEST_FOLDER}"/*.cpp)
elif [[ "$1" =~ ^(single|pipeline|cache|all)$ ]]; then
    # First argument is CPU type
    cpu_mode="$1"
    shift
    if [[ $# -eq 0 ]]; then
        # No test files specified, run all
        files=("${TEST_FOLDER}"/*.cpp)
    else
        # Use specified test files
        files=("$@")
    fi
else
    # No CPU type specified, assume all CPUs with specified files
    cpu_mode="all"
    files=("$@")
fi

# Run tests based on mode
total_fails=0

case "$cpu_mode" in
    single)
        run_tests "single" "$SINGLE_CPU" "${files[@]}"
        total_fails=$?
        ;;
    pipeline)
        run_tests "pipeline" "$PIPELINE_CPU" "${files[@]}"
        total_fails=$?
        ;;
    cache)
        run_tests "cache" "$CACHE_CPU" "${files[@]}"
        total_fails=$?
        ;;
    all)
        run_tests "single" "$SINGLE_CPU" "${files[@]}"
        ((total_fails+=$?))
        
        run_tests "pipelined" "$PIPELINE_CPU" "${files[@]}"
        ((total_fails+=$?))
        
        run_tests "cache" "$CACHE_CPU" "${files[@]}"
        ((total_fails+=$?))
        ;;
esac

echo ""
echo "========================================="
echo "Overall Summary"
echo "========================================="
if [ $total_fails -eq 0 ]; then
    echo "${GREEN}All tests passed!${RESET}"
    exit 0
else
    echo "${RED}Some tests failed (total failures: ${total_fails})${RESET}"
    exit 1
fi