######################## CSC258H1F Testing Functions ##########################
.eqv PROBABLY_UNIQUE 0xFADEBEEF

.text
main:
    # Load PROBABLY_UNIQUE into every saved register
    li $s0, PROBABLY_UNIQUE
    li $s1, PROBABLY_UNIQUE
    li $s2, PROBABLY_UNIQUE
    li $s3, PROBABLY_UNIQUE
    li $s4, PROBABLY_UNIQUE
    li $s5, PROBABLY_UNIQUE
    li $s6, PROBABLY_UNIQUE
    li $s7, PROBABLY_UNIQUE

    # TODO: call a function to test it

    # Check that PROBABLY_UNIQUE is still in the saved registers
    li $t0, PROBABLY_UNIQUE
    bne $s0, $t0, oops
    bne $s1, $t0, oops
    bne $s2, $t0, oops
    bne $s3, $t0, oops
    bne $s4, $t0, oops
    bne $s5, $t0, oops
    bne $s6, $t0, oops
    bne $s7, $t0, oops

    # If we made it here, all saved registers equaled PROBABLY_UNIQUE
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # ALSO TEST FOR STACK POINTER 
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    j exit

oops:
    li $a0, PROBABLY_UNIQUE
    li $v0, 1
    syscall
exit:
	li 		$v0, 10
	syscall