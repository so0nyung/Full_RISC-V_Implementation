#!/bin/bash
set -e

# === CONFIG ===
ASM_FILE="f1_asm.s"              # Assembly file for this test
ASSEMBLER="./assemble.sh"        # Path to assembler
TOP_SV="../rtl/top.sv"           # Path to top-level SystemVerilog
TOP_MODULE="top"                 # Top module name
TESTBENCH_CPP="f1_tb.cpp"        # C++ testbench
TEST_NAME="f1_test"              # Test name (for RTL expectations)

# === COLORS ===
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"  # No Color / reset

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$SCRIPT_DIR/obj_dir"
RESULTS_DIR="$SCRIPT_DIR/results"

echo -e "${GREEN}=== F1 Lights Test ===${NC}"

# 1) Assemble program
echo -e "${GREEN}[1/4] Assembling $ASM_FILE...${NC}"
[ -f "$ASSEMBLER" ] || { echo -e "${RED}Error: Assembler not found at $ASSEMBLER${NC}"; exit 1; }
"$ASSEMBLER" "$ASM_FILE"
[ -f "program.hex" ] || { echo -e "${RED}Error: program.hex not created${NC}"; exit 1; }
echo -e "${GREEN}SUCCESS: program.hex created ($(wc -l < program.hex) lines)${NC}"

# 2) Create zeroed data memory
echo -e "${GREEN}[2/4] Creating data.hex...${NC}"
BYTES=$((64*1024))
yes 00 | head -n "$BYTES" > data.hex
echo -e "${GREEN}SUCCESS:  data.hex created ($BYTES bytes)${NC}"

# 3) Setup simulation directories and link hex files
echo -e "${GREEN}[3/4] Preparing simulation directories...${NC}"
mkdir -p "$OUT_DIR/test_out/$TEST_NAME"
ln -sf "$SCRIPT_DIR/program.hex" "$OUT_DIR/program.hex"
ln -sf "$SCRIPT_DIR/data.hex"    "$OUT_DIR/data.hex"
ln -sf "$SCRIPT_DIR/program.hex" "$OUT_DIR/test_out/$TEST_NAME/program.hex"
ln -sf "$SCRIPT_DIR/data.hex"    "$OUT_DIR/test_out/$TEST_NAME/data.hex"

# 4) Verilate, build, and run simulation
echo -e "${GREEN}[4/4] Running Verilator + simulation...${NC}"
verilator -Wall --cc "$TOP_SV" \
  -I../rtl \
  --top-module "$TOP_MODULE" \
  --trace --trace-depth 3 \
  --exe "$TESTBENCH_CPP" \
  -CFLAGS "-I../rtl -I$SCRIPT_DIR -std=c++14" \
  -LDFLAGS "-lgtest -lgtest_main -pthread"

make -C "$OUT_DIR" -f "V${TOP_MODULE}.mk"

(
  cd "$OUT_DIR"
  echo -e "${YELLOW}Running simulation from $(pwd)...${NC}"
  ./V${TOP_MODULE}
)

echo ""
echo -e "${GREEN}=== Test Complete ===${NC}"
