# Expected: a0 = 100
Pipe_arithmetic:
    addi x1, x0, 10     # x1 = 10
    addi x2, x0, 20     # x2 = 20
    add  x3, x1, x2     # x3 = x1 + x2 = 30
    sub  x4, x3, x1     # x4 = x3 - x1 = 20
    add  x5, x3, x4     # x5 = x3 + x4 = 50
    add  x6, x5, x5     # x6 = x5 + x5 = 100
    add  x10, x6, x0    # a0 = x6 = 100 (RESULT)
    beq  x0, x0, end   # Loop forever
end:
    beq  x0, x0, end
