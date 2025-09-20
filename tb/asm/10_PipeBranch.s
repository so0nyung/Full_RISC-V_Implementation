# Expected: a0 = 555
Pipe_branch:
    addi x1, x0, 10     # x1 = 10
    addi x2, x0, 5      # x2 = 5
    sub  x3, x1, x2     # x3 = 10 - 5 = 5
    beq  x3, x2, branch  # if x3 == x2 (5), branch taken
    addi x10, x0, 999   # This shouldn't execute if branch works
    beq  x0, x0, end   # Should never reach here

branch:
    addi x4, x0, 111    # x4 = 111
    addi x5, x0, 444    # x5 = 444  
    add  x6, x4, x5     # x6 = 111 + 444 = 555
    add  x10, x6, x0    # a0 = x6 = 555 (RESULT)

end:
    beq  x0, x0, end

