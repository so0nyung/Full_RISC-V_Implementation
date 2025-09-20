main:
    addi    t0, zero, 0x1
    jal     ra, subroutine
    # Program should end here - remove the ret or add proper exit
    # For testing, we can just loop infinitely:
    loop:
        beq     zero, zero, loop    # Infinite loop to end program

subroutine:
    addi    a0, zero, 0x1
    addi    a0, zero, 0x3
    addi    a0, zero, 0x7
    addi    a0, zero, 0xf
    addi    a0, zero, 0x1f
    addi    a0, zero, 0x3f
    addi    a0, zero, 0x7f
    addi    a0, zero, 0xff
    # REMOVED: li a0, 0x0  <- This was zeroing out a0!
    ret                     # Return to caller