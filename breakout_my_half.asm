################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Matthew Liu, Student Number
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

.data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
MY_COLOURS:
	.word	0xff0000    # red
	.word	0x00ff00    # green
	.word	0x0000ff    # blue
	.word	0x808080    # gray
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
.text
.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game
    
    # draw borders
    # top border
    la $a1, MY_COLOURS
    lw $a1, 12($a1)	# grey
    la $a0, ADDR_DSPL
    lw $a0, 0($a0)
    li $a2, 4
    li $a3, 32
    jal draw_line
    
    # draw red horizontal line
    # left border
    la $a1, MY_COLOURS
    lw $a1, 12($a1)
    la $a0, ADDR_DSPL
    lw $a0, 0($a0)
    li $a2, 128
    li $a3, 32
    jal draw_line
    
    # draw blue vertical line
    # right border
    la $a1, MY_COLOURS
    lw $a1, 12($a1)
    la $a0, ADDR_DSPL
    lw $a0, 0($a0)
    addi $a0, $a0, 124	# 128 would actually be right off the screen 
    li $a2, 128
    li $a3, 32
    jal draw_line
    
    # draw bricks
    # first line
    li $a0, 3
    li $a1, 3
    la $a2, MY_COLOURS
    lw $a2, 0($a2)
    jal draw_bricks
    
    # second line 
    li $a0, 3
    li $a1, 6
    la $a2, MY_COLOURS
    lw $a2, 4($a2)
    jal draw_bricks
    
    # second line 
    li $a0, 3
    li $a1, 9
    la $a2, MY_COLOURS
    lw $a2, 8($a2)
    jal draw_bricks 
    
    # go to game loop
    b game_loop
    
# FUNCTIONS ################

b game_loop # if main ever gets to this point we don't want to start running functions, send to game loop

# function draw bricks draw a row of brick starting at ($a0, $a1) with colour $a2 
draw_bricks:
    # PROLOGUE
    addi $sp, $sp, -24
    
    sw $ra, 20($sp)
    
    sw $s4, 16($sp)	# colour
    move $s4, $a2
    
    sw $s3, 12($sp)	# y value
    move $s3, $a1
   
    sw $s2, 8($sp)	# x value 
    move $s2, $a0 
    
    sw $s1, 4($sp)	# iteration number 
    sw $s0, 0($sp)	# iteration max 
    
    
    li $s0, 7	# iteration max
    li $s1, 0   # iteration num
    
draw_bricks_loop:
    slt $t0, $s1, $s0
    beq $t0, $0, draw_bricks_end
    	
    	# using iteration to get next address
    	# number to increase initial address by
    	sll $t1, $s1, 2
    	add $a0, $s2, $t1	# add this value to initial coordinate
    	move $a1, $s3 
    	jal get_address
    	# at this point v0 should have the address of the starting unit
	
	move $a0, $v0
	move $a1, $s4 
	li $a2, 4	
    	li $a3, 3
    	
    	jal draw_line
    	
    addi $s1, $s1, 1
    b draw_bricks_loop
    
draw_bricks_end:
    
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    
    jr $ra 

# FUNCTION get memory address given x and y coordinates ($a0 - x coord, $a1 - y coord, $v0 - return)

get_address:
    sll $a0, $a0, 2	# multiply by 4
    sll $a1, $a1, 7	# multiply by 128
    
    la $v0, ADDR_DSPL
    lw $v0, 0($v0)
    add $v0, $a0, $v0 
    add $v0, $a1, $v0
    
    jr $ra

# FUNCTION draw line across screen ($a0 - start_address, $a1 - colour, 
					#$a2 memory increment (4 for horizontal, 128 for vertical), 
					#$a3 number of units drawn (32 for across screen)) return - void
draw_line:
    li $t1, 0   # iteration num

draw_line_loop:
    slt $t2, $t1, $a3
    beq $t2, $0, draw_line_end

        sw $a1, 0($a0)
        add $a0, $a0, $a2
    
    addi $t1, $t1, 1
    b draw_line_loop 

draw_line_end:
    jr $ra 
  

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop
    
