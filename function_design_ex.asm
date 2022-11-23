.data
    ADDR_DSPL:
    .word 0x10008000

.text
get_location_address:
    # PROLOGUE
    # saving to stack
    addi $sp, $sp, -12
    sw $s2, 8($sp) 
    sw $s1, 4($sp)
    sw $s0, 0($sp)
    
    # BODY
    sll $s0, $a0, 2	# x_bytes = x * 4 
    sll $s1, $a1, 7	# y_bytes = y * 128
    
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    add $t0, $s0, $t0
    add $t2, $s1, $t0	# loc_address = base_address + x_bytes + y_bytes
    
    # return loc_address'
    addi $v0, $s2, $0

    # EPILOGUE
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 12
    jr $ra 
    
optimized:
    sll $a0, $a0, 2
    sll $a1, $a1, 7
    
    la $v0, ADDR_DSPL
    lw $v0, 0($t0)
    add $v0, $a0, $v0 
    add $v0, $a1, $v0
    
    jr $ra 
    