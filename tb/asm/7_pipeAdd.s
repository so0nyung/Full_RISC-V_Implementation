# Expected: a0 = 100
test1_arithmetic:
    addi x1, x0, 10     # x1 = 10
    nop
    nop
    nop
    nop
    addi x2, x0, 20     # x2 = 20
    nop
    nop
    nop
    nop
    add  x3, x1, x2     # x3 = x1 + x2 = 30
    nop
    nop
    nop
    nop
    sub  x4, x3, x1     # x4 = x3 - x1 = 20
    nop
    nop
    nop
    nop
    add  x5, x3, x4     # x5 = x3 + x4 = 50
    nop
    nop
    nop
    nop
    add  x6, x5, x5     # x6 = x5 + x5 = 100
    nop
    nop
    nop
    nop
    add  x10, x6, x0    # a0 = x6 = 100 (RESULT)
    nop
    nop
    nop
    nop
    beq  x0, x0, end1   # Loop forever
    nop
    nop
    nop

end1:
    beq  x0, x0, end1
    nop
    nop
    nop

