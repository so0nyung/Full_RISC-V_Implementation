# Expected: a0 = 555
test4_branch:
    addi x1, x0, 10     # x1 = 10
    nop
    nop
    nop
    nop
    addi x2, x0, 5      # x2 = 5
    nop
    nop
    nop
    nop
    sub  x3, x1, x2     # x3 = 10 - 5 = 5
    nop
    nop
    nop
    nop
    beq  x3, x2, branch_taken  # if x3 == x2 (5), branch taken
    nop
    nop
    nop
    nop
    addi x10, x0, 999   # This shouldn't execute if branch works
    nop
    nop
    nop
    nop
    beq  x0, x0, end4   # Should never reach here
    nop
    nop
    nop

branch_taken:
    addi x4, x0, 111    # x4 = 111
    nop
    nop
    nop
    nop
    addi x5, x0, 444    # x5 = 444  
    nop
    nop
    nop
    nop
    add  x6, x4, x5     # x6 = 111 + 444 = 555
    nop
    nop
    nop
    nop
    add  x10, x6, x0    # a0 = x6 = 555 (RESULT)
    nop
    nop
    nop
    nop

end4:
    beq  x0, x0, end4
    nop
    nop
    nop

