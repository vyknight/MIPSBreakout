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
    

# draw horizontal line function ($a0 - start_address, $a1 - colour, $t9 - unit increment, $t8 return - void) 
draw_line:
    li $t0, 32  # loop runs 32 times
    li $t1, 0   # iteration num

draw_line_loop:
    slt $t2, $t1, $t0
    beq $t2, $0, end_draw_line

        sw $a1, 0($a0)
        addi $a0, $a0, 4
    
    addi $t1, $t1, 1
    b draw_line_loop 

draw_h_line_end:
    jr $ra 

# draw vertical line function ($a0 - start_address, $a1 - colour, return - void) 

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep

    #5. Go back to 1
    b game_loop
