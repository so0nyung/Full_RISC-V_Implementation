#Expected: a0 = 15 (1111)
test2_logical:
    addi x1, x0, 12     # x1 = 12 (binary: 1100)
    nop
    nop
    nop
    nop
    addi x2, x0, 10     # x2 = 10 (binary: 1010)
    nop
    nop
    nop
    nop
    and  x3, x1, x2     # x3 = 12 & 10 = 8 (binary: 1000)
    nop
    nop
    nop
    nop
    or   x4, x1, x2     # x4 = 12 | 10 = 14 (binary: 1110)
    nop
    nop
    nop
    nop
    xor  x5, x1, x2     # x5 = 12 ^ 10 = 6 (binary: 0110)
    nop
    nop
    nop
    nop
    addi x6, x0, 1      # x6 = 1
    nop
    nop
    nop
    nop
    or   x7, x4, x6     # x7 = 14 | 1 = 15 (binary: 1111)
    nop
    nop
    nop
    nop
    add  x10, x7, x0    # a0 = x7 = 15 (RESULT)
    nop
    nop
    nop
    nop
    beq  x0, x0, end2   # Loop forever
    nop
    nop
    nop

end2:
    beq  x0, x0, end2
    nop
    nop
    nop

