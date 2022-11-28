################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

.data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    	.word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
	.word 0xffff0000
	
# Convenient display constants. If you change one, check them all.
BITMAP_UNIT_SIZE:
	.word 8

BITMAP_PIXEL_WIDTH:
	.word 256
	
BITMAP_PIXEL_HEIGHT:
	.word 256	
	
.eqv BITMAP_UNITS_PER_ROW 32

BITMAP_UNITS_PER_COLUMN:
	.word 32
    
# Colours are fun!
PADDLE_COLOUR:
	.word 0x7851a9 # This is Royal Purple
	
MY_COLOURS:
	.word	0xff0000    # red
	.word	0x00ff00    # green
	.word	0x0000ff    # blue
	.word	0x808080    # gray
	
VOID_BLACK:
	.word 0
	
##############################################################################
# Mutable Data
##############################################################################

Ball:
	.word 16 # Ball X
	.word 24 # Ball Y
	.word 0  # Current X direction
	.word 1 # Current Y direction
	
Paddle:
	.word 14 # Paddle X
	.word 30 # Paddle Y
	.word 6 # Paddle Length
	

##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
    # Initialize the game
    
    # Draw a 'BALL' at 16, 16 in the paddle colour.
    lw $a0, Ball
    lw $a1, Ball + 4
    lw $a2 PADDLE_COLOUR
    jal draw_pixel
    
    
    # Draw a paddle at 14, 30 of length 6.
    lw $a0, Paddle
    lw $a1, Paddle + 4
    lw $a2, Paddle + 8
    lw $a3, PADDLE_COLOUR
    
    jal draw_paddle
   
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
    
    # third line 
    li $a0, 3
    li $a1, 9
    la $a2, MY_COLOURS
    lw $a2, 8($a2)
    jal draw_bricks 
   
    jal game_loop
    
    j exit
    
# Move the drawn 'paddle' 1 pixel horizontally (can be +1/-1) by drawing over it and then re-drawing it at the new position.
# move_paddle(x_shift). Note this calls draw_paddle so, all 4 argument registers get used. 
move_paddle:
	
	# Save arguments that we plan to use later, which is just the one. And the original $ra - before we need to use it.
	addi $sp $sp -8
	sw $a0 0($sp)
	sw $ra 4($sp)
	
	# Draw a black paddle at the current spot, current length.
	lw $a0 Paddle
	lw $a1 Paddle + 4
	lw $a2 Paddle + 8
	lw $a3 VOID_BLACK
	
	jal draw_paddle 
	
	# Restore saved $a0 to use...
	lw $a0 0($sp)
	addi $sp $sp 4
	
	
	# Move the X coordinate by 1... Load in the current Y and length and colour.
	lw $t0 Paddle
	add $a0 $t0 $a0
	lw $a1 Paddle + 4
	lw $a2 Paddle + 8
	lw $a3 PADDLE_COLOUR
	

	bge $a0 0 x_not_too_small
	# if body: reset X if the coordinate is somebow negative to avoid bleeding into a different row.
		li $t0 31
		sub $t0 $t0 $a2 # subtract length from max unit so that paddle will fit.
		addi $t0 $t0 1 # There's actually an off by 1 if we do that. So, add one back...
		add $a0 $0 $t0 # set A to the max on the right side.

x_not_too_small: 

	add $t0 $a0 $a2
	ble $t0 BITMAP_UNITS_PER_ROW x_is_ok
	# if body: reset X if the coordinate is over DISPLAY WIDTH to avoid bleeding into a different row.
		li $a0 0
	
x_is_ok: 
	# We plan to use this version of $a0 later, so save it.
	addi $sp $sp -4
	sw $a0 0($sp)
	
	jal draw_paddle 
	
	lw $a0 0($sp)
	addi $sp $sp 4
	
	
	# Update the new X-value.
	sw $a0 Paddle

	# Restore super original values. Note that $a0 has already be re-loaded where appropriate.
	lw $ra 0($sp)
	addi $sp $sp 4
	
	jr $ra
	
	

   
# Get the display address of a point at X, Y on the display grid, assuming above settings are observed.
# get_display_address(x, y) : Address (in $v0)
get_display_address:

	# Load the base address of the display.
	la $v0 ADDR_DSPL
	lw $v0, 0($v0)
	
	# Get the x and Y offsets
	sll $a0, $a0, 2
	sll $a1, $a1 7
	
	# Increment to the display address.
	add $v0 $v0 $a0
	add $v0 $v0 $a1
	
	jr $ra

# Draw a paddle starting at X, Y with a specific length, in the colour at colour_address.
# draw_paddle(x, y, length, colour_address)
draw_paddle:
	# Prologue - make space for our 1 local variables.
	addi $sp $sp -4
	sw $s1 0($sp)
	
	# Loop length times.
	li $s1 0 # $s1 = loop measure.
	
draw_paddle_loop:
	bge $s1, $a2 fin_paddle_loop # While i < length;
	
	# Draw at a pixel (X + loop measure)
	addi $sp $sp -16
	sw $a0 0($sp)
	sw $a1 4($sp)
	sw $a2 8($sp)
	sw $ra 12($sp)
	
	# Pretty much pass X+i, Y, colour to draw_paddle
	add $a0 $a0 $s1
	# Y remains unchanged.
	add $a2 $0 $a3 # Shift colour over a little bit.
	jal draw_pixel
	
	lw $a0 0($sp)
	lw $a1 4($sp)
	lw $a2 8($sp)
	lw $ra 12($sp)
	addi $sp $sp 16
	
	# Increment the loop measure and start again.
	addi $s1 $s1 1
	j draw_paddle_loop
		
fin_paddle_loop:

	# Epilogue
	lw $s1 0($sp)
	addi $sp $sp 4
	jr $ra

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
    	jal get_display_address
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

#########################################################

game_loop:
    # Do the gravity.
    jal move_ball
    
    # Check for side collisions.
    jal check_ball_on_paddle
    jal check_ball_on_top
    jal check_ball_on_bottom
    jal check_ball_on_left
    jal check_ball_on_right
    
    # 1a. Check if key has been pressed. If not, keep checking until one has been.
    lw $t0, ADDR_KBRD          # Load the base address for the keyboard.
    lw $t1, 0($t0)             # Load the actual value at the keyboard's first word...
    bne $t1, 1, game_loop_cleanup  # If first word 1, key is pressed. Otberwise skip to the end of the loop.
    
    # 1b. Check which key has been pressed
    lw $t2 4($t0)
    
    # Now differentiate the keys and branch...
    beq $t2 97 key_press_a
    beq $t2 100 key_press_d
    
    # 2a. Check for collisions

    # 2b. Update locations (paddle, ball)

    # 3. Draw the screen
 
game_loop_cleanup:
    # 4. Sleep a second at the end so we aren't going at literal lightspeed.
    li $v0 32
    li $a0 200
    syscall

    # If for some reason there was an invalid key press, return to the loop.
    b game_loop

        
fin_game_loop:
    j exit
    

key_press_a:
	li $a0 -1
	jal move_paddle
	b game_loop
	
key_press_d:
	li $a0 1
	jal move_paddle
	b game_loop
    

# Conditionals based on what key is pressed on the keyboard.


	
	
 # Draw a particular colour (R, G, B) at a particular unit (X, Y) on the bitmap display.
 # Preconditions: X and Y are reasonable coordinates, e.g. (no X = 100 on a 32 unit display please!!).
 # 
 # draw_pixel(x, y, colour) : Unit 
draw_pixel:
	# Prologue
	
	# Save our initial arguments first, since we use them after.
	addi $sp $sp -12
	sw $a0, 8($sp)
	sw $a1, 4($sp)
	sw $ra, 0($sp)
	
	# Call get_address with our current x, y and put it in a temp register after restoring.
	jal get_display_address
	
	lw $a0, 8($sp)
	lw $a1, 4($sp)
	lw $ra, 0($sp)
	addi $sp $sp 12
	
	sw $a2, 0($v0)

	# Epilogue
	jr $ra
	
exit:
	li $v0, 10
	syscall
	
# This is code that should never be accessed iteratively, only through calls.

# Move the ball in the current X and Y direction. Mutate these dudes if you want to change it. 
# move_ball()
move_ball:
	
	addi $sp $sp -4
	sw $ra 0($sp)
	
	# Erase the ball at its current location with a black pixel.
	# Except IF the ball is on the paddle. In that case, draw a pixel in the paddle colour.

redraw_paddle_there:
	# Load ball X and Y. TODO: This isn't that efficient.
	lw $t0 Ball
	lw $t1 Ball + 4
	
	# Load Paddle X and calculate its end
	lw $t2 Paddle 
	lw $t3 Paddle + 8
	add $t3 $t2 $t3 # Start + length = end + 1.
	addi $t3 $t3 -1 # Correct off by 1.
	
	# Whoops, load paddle y.
	lw $t4 Paddle + 4
	
	
	# If ball Y != Paddle Y and Ball X < paddle Start OR X > Paddle end, then just do the normal. Otherwise do this. 
	bne $t1 $t4 kill_prev_pixel
	blt $t0 $t2 kill_prev_pixel
	bgt $t0 $t3 kill_prev_pixel
	lw $a0 Ball
	lw $a1 Ball + 4
	lw $a2 PADDLE_COLOUR
	
	# Once the previous pixel is cleaned, one way or another, redraw the ball in its new location.
	jal draw_pixel 
	j redraw_ball
	
kill_prev_pixel:
	lw $a0 Ball
	lw $a1 Ball + 4
	lw $a2 VOID_BLACK
	
	jal draw_pixel
	
redraw_ball: 
	# Add the direction to the Ball's X and Y.
	lw $t0 Ball
	lw $t1 Ball + 8
	add $t0 $t0 $t1
	sw $t0 Ball
	
	lw $t0 Ball + 4
	lw $t1 Ball + 12
	add $t0 $t0 $t1
	sw $t0 Ball + 4

	# Draw the ball again with the actual colour this time.
	
	lw $a0 Ball
	lw $a1 Ball + 4
	lw $a2 PADDLE_COLOUR
	
	jal draw_pixel
	
	lw $ra 0($sp)
	addi $sp $sp 4

done_moving_ball:
	jr $ra
	


# Checks whether the ball collides with the top edge. If so, makes the ball bounce down. Maintains the X for now.
check_ball_on_top:
	# Check the Y coordinate of the ball...
	lw $t0 Ball + 4
	
	# If Y == 0, (or somehow negative) we're at the top edge and should bounce. Overwrite the vertical direction.
	bgt $t0 1 ball_is_vertically_ok
	li $t0 1
	sw $t0 Ball + 12
	
ball_is_vertically_ok:
	jr $ra

check_ball_on_bottom:
	# Check the Y coordinate of the ball
	lw $t0 Ball + 4
	
	# If Y >= 32, we've gone off-screen and are dead D:. For now, just play a sound effect.
	blt $t0 32 ball_is_not_kill
	
	# Murder user with flatline sound
	li $a0 69
	li $a1 400
	li $a2 22
	li $a3 127
	li $v0 33
	syscall
	
	li $a0 69
	li $a1 400
	li $a2 22
	li $a3 127
	li $v0 33
	syscall
	
	li $a0 69
	li $a1 400
	li $a2 22
	li $a3 127
	li $v0 33
	syscall
	
death_loop:
	li $a0 69
	li $a1 5000
	li $a2 22
	li $a3 127
	li $v0 33
	syscall
	
	j exit
	
ball_is_not_kill:
	jr $ra
	
check_ball_on_left:
	# Load the X coordinate of the ball.
	lw $t0 Ball
	# If the X coordinate is 0 or somehow even less, Go right. Otherwise it should be fine.
	bgt $t0, 0 ball_ok_leftside
	li $t0 1 
	sw $t0 Ball + 8
	
ball_ok_leftside:
	jr $ra

check_ball_on_right:
	# Load the X coordinate of the ball.
	lw $t0 Ball
	# If the X coordinate is somehow larger or equal to 31, then bounce left. Otherwise it should be fine.
	blt $t0 31 ball_ok_rightside
	li $t0 -1
	sw $t0 Ball + 8
	
ball_ok_rightside:
	jr $ra
	
# Check whether the ball is on the paddle. If so, set its direction to UP. Then if its on the right side of the paddle, bounce it right. 
# If its on the left side, bounce it left. Easy... (hopefully).
check_ball_on_paddle:
	# We use quite a few preserved registers for variables here. Save them. 
	addi $sp $sp -24
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	sw $s5 20($sp)
	
	# Load the Ball's X and Y coordinates.
	lw $s0 Ball
	lw $s1 Ball + 4
	
	# Calculate the paddle start, end, and middle coordinates. Also gets its Y.
	
	lw $s2 Paddle     # Paddle X is basically paddle start.
	lw $s3 Paddle + 4 # Paddle Y 
	addi $s3 $s3 -1 # Do this so that the ball will bounce OFF the paddle instead of phasing into it.
	lw $s4 Paddle + 8 # Paddle length for a moment...
	add $s4 $s4 $s2 # Paddle end = start + length (off by 1). Fixed after.
	addi $s4 $s4 -1
	
	# To get the middle, take start + (length // 2) That gets the middle on the right side.  # 0 1 2 |3| 4 5 
	lw $s5 Paddle + 8
	sll $s5 $s5 1
	add $s5 $s5 $s2 # Now we have the middle, kind of.
		
	# Check if it's within the paddle's bounds (but on the right). (S
	# Check that Y is the same. 
	bne $s1 $s3 ball_not_on_paddle
	
	# Check that X is between paddle_middle and end. mid <= X <= End
	# If so, set the direction to (1, -1).
	bgt $s0 $s4 check_ball_on_paddle_left 
	blt $s0 $s5 check_ball_on_paddle_left # Strictly less since the 'middle' index is on the right.
	
	li $t6 1
	sw $t6 Ball + 8
	li $t6 -1
	sw $t6 Ball + 12
	
	
	

check_ball_on_paddle_left:
	# Check if it's within the paddle's bounds (but on the left - that X is between start and paddle middle. start <= X < mid
	# If so, set the direction to (-1, -1). Note < mid since middle is on the higher half.\
	bge $s0 $s4 ball_not_on_paddle
	blt $s0 $s2 ball_not_on_paddle
	li $t6 -1
	sw $t6 Ball + 8
	li $t6 -1
	sw $t6 Ball + 12

ball_not_on_paddle:
	# Load back the preserved registers.
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	addi $sp $sp 24
	
	jr $ra


	
	




# Subtract the direction from the current Y.







	