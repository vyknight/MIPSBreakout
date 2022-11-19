#################### CSC258H1F Data in Memory Worksheet ######################
# This file contains a rough solution for the Data in Memory worksheet,
# Exercise 3, Question 4.
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000
##############################################################################
.data
# The address of the bitmap display. Don't forget to configure and connect it!
ADDR_DSPL:
    .word 0x10008000


# An array of colours (from prior question)
MY_COLOURS:
	.word	0xff0000    # red
	.word	0x00ff00    # green
	.word	0x0000ff    # blue


.text
main:
    # Let us start by getting the colour we want to draw with
    la $a1, MY_COLOURS          # temp = &MY_COLOURS
    lw $a1, 0($a1)              # colour = temp[0]

    # We also need to know where to write to the display
    la $a0, ADDR_DSPL           # temp = &ADDR_DSPL
    lw $a0, 0($a0)              # display = *temp
    jal draw_line

    # draw green line 
    la $a1, MY_COLOURS          # temp = &MY_COLOURS
    lw $a1, 4($a1)              # colour = temp[1]

    la $a0, ADDR_DSPL           # temp = &ADDR_DSPL
    lw $a0, 0($a0)              # display = *temp
    addi $a0, $a0, 128
    jal draw_line

    # draw blue line 
    la $a1, MY_COLOURS          # temp = &MY_COLOURS
    lw $a1, 8($a1)              # colour = temp[2]

    la $a0, ADDR_DSPL           # temp = &ADDR_DSPL
    lw $a0, 0($a0)              # display = *temp
    addi $a0, $a0, 256
    jal draw_line

exit:
    li $v0 10
    syscall

# draw_line($a0 start address, $a1 colour) 
draw_line:
    # Since the display is 256 pixels wide, and each unit is 8 pixels wide,
    # then a line is 32 units wide
    li $t2, 32                  # UNIT_COUNT = 32

    # Now let's iterate 32 times, drawing each unit in the line
    li $t3, 0                   # i = 0
draw_line_loop:
    slt $t4, $t3, $t2           # i < UNIT_COUNT ?
    beq $t4, $0, end_draw_line  # if not, then done

        sw $a1, 0($a0)          # Paint unit with colour
        addi $a0, $a0, 4        # Go to next unit

    addi $t3, $t3, 1            # i = i + 1
    b draw_line_loop

end_draw_line:
    jr $ra 