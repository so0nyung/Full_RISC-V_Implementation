test6_loop:
    add  x1, x0, x0     # x1 = 0 (sum accumulator)
    nop
    nop
    nop
    nop
    addi x2, x0, 1      # x2 = 1 (counter)
    nop
    nop
    nop
    nop
    addi x3, x0, 10     # x3 = 10 (limit)
    nop
    nop
    nop
    nop

loop_start:
    add  x1, x1, x2     # sum += counter
    nop
    nop
    nop
    nop
    addi x2, x2, 1      # counter++
    nop
    nop
    nop
    nop
    sub  x4, x2, x3     # x4 = counter - limit
    nop
    nop
    nop
    nop
    # Check if counter <= limit (if x4 <= 1, continue loop)
    addi x5, x0, 11     # x5 = 11 (limit + 1)
    nop
    nop
    nop
    nop
    sub  x6, x2, x5     # x6 = counter - (limit + 1)
    nop
    nop
    nop
    nop
    bne  x6, x0, loop_start # if counter != 11, continue loop
    nop
    nop
    nop
    nop
    
    # Loop finished
    add  x10, x1, x0    # a0 = sum = 55 (1+2+...+10)
    nop
    nop
    nop
    nop

end6:
    beq  x0, x0, end6
    nop
    nop
    nop

#Expected:a0= 50
