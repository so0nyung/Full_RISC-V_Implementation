test3_memory:
    addi x1, x0, 123    # x1 = 123
    nop
    nop
    nop
    nop
    addi x2, x0, 200    # x2 = 200 (base address)
    nop
    nop
    nop
    nop
    sw   x1, 0(x2)      # Memory[200] = 123
    nop
    nop
    nop
    nop
    addi x3, x0, 654    # x3 = 654
    nop
    nop
    nop
    nop
    sw   x3, 4(x2)      # Memory[204] = 654
    nop
    nop
    nop
    nop
    lw   x4, 0(x2)      # x4 = Memory[200] = 123
    nop
    nop
    nop
    nop
    lw   x5, 4(x2)      # x5 = Memory[204] = 654
    nop
    nop
    nop
    nop
    add  x6, x4, x5     # x6 = 123 + 654 = 777
    nop
    nop
    nop
    nop
    sw   x6, 8(x2)      # Memory[208] = 777
    nop
    nop
    nop
    nop
    lw   x7, 8(x2)      # x7 = Memory[208] = 777
    nop
    nop
    nop
    nop
    add  x10, x7, x0    # a0 = x7 = 777 (RESULT)
    nop
    nop
    nop
    nop
    beq  x0, x0, end3   # Loop forever
    nop
    nop
    nop

end3:
    beq  x0, x0, end3
    nop
    nop
    nop

#Expected a0 = 777
