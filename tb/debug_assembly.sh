#!/bin/bash

echo "=== DEBUGGING ASSEMBLY PROCESS ==="

# Check current directory
echo "Current directory: $(pwd)"
echo "Contents:"
ls -la

echo ""
echo "=== CHECKING ASSEMBLE.SH ==="
if [ -f "./assemble.sh" ]; then
    echo "✓ assemble.sh found"
    echo "Contents of assemble.sh:"
    cat ./assemble.sh
    echo ""
    
    # Check if it's executable
    if [ -x "./assemble.sh" ]; then
        echo "✓ assemble.sh is executable"
    else
        echo "✗ assemble.sh is not executable - fixing..."
        chmod +x ./assemble.sh
    fi
    
else
    echo "✗ assemble.sh NOT FOUND"
    echo "Looking for assembler scripts:"
    find . -name "*assemble*" -o -name "*asm*" 2>/dev/null
fi

echo ""
echo "=== CHECKING ASM DIRECTORY ==="
if [ -d "asm" ]; then
    echo "✓ asm directory found"
    echo "Assembly files:"
    ls -la asm/
    
    if [ -f "asm/1_addi_bne.s" ]; then
        echo ""
        echo "Contents of 1_addi_bne.s:"
        echo "----------------------------------------"
        cat asm/1_addi_bne.s
        echo "----------------------------------------"
    else
        echo "✗ asm/1_addi_bne.s not found"
    fi
else
    echo "✗ asm directory not found"
fi

echo ""
echo "=== MANUAL ASSEMBLY TEST ==="
if [ -f "./assemble.sh" ] && [ -f "asm/1_addi_bne.s" ]; then
    echo "Trying to assemble manually..."
    ./assemble.sh asm/1_addi_bne.s
    
    echo "After assembly:"
    ls -la program.hex 2>/dev/null || echo "✗ program.hex not created"
    
    if [ -f "program.hex" ]; then
        echo "✓ program.hex created!"
        echo "Size: $(wc -c < program.hex) bytes"
        echo "First few lines:"
        head -5 program.hex
    fi
else
    echo "Cannot test assembly - missing files"
fi