test5_comprehensive:
    # Phase 1: Setup base values
    addi x1, x0, 6      # x1 = 6
    nop
    nop
    nop
    nop
    addi x2, x0, 7      # x2 = 7
    nop
    nop
    nop
    nop
    
    # Phase 2: Arithmetic operations
    add  x3, x1, x2     # x3 = 6 + 7 = 13
    nop
    nop
    nop
    nop
    sub  x4, x3, x1     # x4 = 13 - 6 = 7
    nop
    nop
    nop
    nop
    add  x5, x4, x2     # x5 = 7 + 7 = 14
    nop
    nop
    nop
    nop
    
    # Phase 3: Memory operations
    addi x6, x0, 300    # x6 = 300 (address)
    nop
    nop
    nop
    nop
    sw   x5, 0(x6)      # Memory[300] = 14
    nop
    nop
    nop
    nop
    addi x7, x0, 28     # x7 = 28
    nop
    nop
    nop
    nop
    sw   x7, 4(x6)      # Memory[304] = 28
    nop
    nop
    nop
    nop
    lw   x8, 0(x6)      # x8 = Memory[300] = 14
    nop
    nop
    nop
    nop
    lw   x9, 4(x6)      # x9 = Memory[304] = 28
    nop
    nop
    nop
    nop
    
    # Phase 4: Final calculation
    add  x11, x8, x9    # x11 = 14 + 28 = 42
    nop
    nop
    nop
    nop
    add  x10, x11, x0   # a0 = x11 = 42 (RESULT)
    nop
    nop
    nop
    nop
    
    # Phase 5: Verification with branch
    addi x12, x0, 42    # x12 = 42 (expected value)
    nop
    nop
    nop
    nop
    sub  x13, x10, x12  # x13 = a0 - 42 (should be 0)
    nop
    nop
    nop
    nop
    beq  x13, x0, success # if x13 == 0, test passed
    nop
    nop
    nop
    nop
    
    # Test failed - set a0 to error code
    addi x10, x0, 999   # a0 = 999 (ERROR)
    nop
    nop
    nop
    nop
    beq  x0, x0, end5
    nop
    nop
    nop

success:
    # Test passed - a0 already contains 42
    nop
    nop
    nop
    nop

end5:
    beq  x0, x0, end5
    nop
    nop
    nop

#Expected: a0 = 42
