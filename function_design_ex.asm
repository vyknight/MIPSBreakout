.data
    ADDR_DSPL:
    .word 0x10008000

.text
main:
    li $a0, 8
    li $a1, 10
    jal get_location_address
    addi $a0, $v0, 1
    
    
# PURE FUNCTIONS 
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

# draw_line(start, colour_address, width) -> void
#   Draw a line with width units horizontally across the display using the
#   colour at colour_address and starting from the start address.
#
#   Preconditions:
#       - The start address can "accommodate" a line of width units
draw_line:
    # Retrieve the colour
    lw $t0, 0($a1)              # colour = *colour_address

    # Iterate $a2 times, drawing each unit in the line
    li $t1, 0                   # i = 0
draw_line_loop:
    slt $t2, $t1, $a2           # i < width ?
    beq $t2, $0, draw_line_epi  # if not, then done

        sw $t0, 0($a0)          # Paint unit with colour
        addi $a0, $a0, 4        # Go to next unit

    addi $t1, $t1, 1            # i = i + 1
    j draw_line_loop

draw_line_epi:
    jr $ra
    
# NESTED FUNCTIONS AND RESERVED REGISTERS
# draw_square($a0 start, $a1 colour_address, size)
#   Draw a square that is size units wide and high on the display using the
#   colour at colour_address and starting from the start address
#
#   Preconditions:
#       - The start address can "accommodate" a size x size square
draw_square:
    # PROLOGUE
    # make space on the stack
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    # !!!!!!!!!!!!!!!!! $RA MUST BE STORED IN THE STACK EVERY SINGLE TIME YOU CALL ANOTHER FUNCTION 
    
    # a2 is the size
    li $s0, 0		# loop measure 
    addi $s2, $a0, 0	# store start address 
    
draw_square_loop:
    slt $s1, $s0, $a2 
    beq $s1, $0, draw_square_epi
    	
    	addi $a0, $s1, 0 
    	jal draw_line
    	addi $s2, $s2, 128
    
    addi $s0, $s0, 1
    j draw_square_loop
	
draw_square_epi:
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra 

exit:
    $v0 10
    syscall 