##########################################################################
# Created by:  Sicairos, Alejandra
#              kasicair
#              10 March 2021
#
# Assignment:  Lab 5: Functions and Graphics
#              CSE 12 /L, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
# 
# Description: This program prints vertical and horizontal lines from the test file
# 
# Notes:       This program is intended to be run from the MARS IDE.
# Pseudo Code:
#				load test file
#				as directed in the test file:
#					clear bitmap:
#						for every pixel
#							set desired color

#					draw pixel:
#						get the exact coordinates
#						get address
#						store color in address
#						return color

#					get pixel:
#						get the exact coordinates
#						get address
#						load color in address
#						return color at address

#					draw horizontal line
#						load coordiantes
#						store y coordinate

#						for every x coordinate <= 128:
#							draw desiered color pixel
#							x ++

#					draw vertical line
#						load coordiantes
#						store x coordinate

#						for every y coordinate <= 128:
#							draw desiered color pixel
#							y ++

#					draw crosshair:
#						get exact coordinates
#						get back ground color from getPixel
#						store color address in s4

#						draw a horizontal line

#						draw a vertical line

#						go back to vertex and place color pixel from s4
##########################################################################


# Winter 2021 CSE12 Lab5 Template
######################################################
# Macros for instructor use (you shouldn't need these)
######################################################

# Macro that stores the value in %reg on the stack 
# and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	andi %y, %input, 0x000000FF							#saves values of y
	andi %x, %input, 0x00FF0000							#saves values of x		
	srl %x, %input, 16									#does a right shift to make sure its all in the right place
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	sll %x, %x, 16										#left shift on to make room
	add %output, %x, %y									#add the coordinates in the right format
.end_macro 

# Macro that converts pixel coordinate to address
# 	output = origin + 4 * (x + 128 * y)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%origin: register containing address of (0, 0)
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y %origin)
	mul %output, %y, 128								#multiply y by 128
	add %output, %output, %x							#add the x to the previous total
	mul %output, %output, 4								#multiply everything by 4
	add %output, %output, %origin						#add the orgin adress to everything 
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main																																									
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
clear_bitmap: nop
	#YOUR CODE HERE, only use t registers (and a, v where appropriate)
	lw $t0, originAddress							#loads the origin adress to t0
	li $t1, 65536									#total amount of bits
	loop:
		sw $a0, ($t0) 								#stores the color 
		addi $t0, $t0, 4							#increaments orgin adress
		addi $t1, $t1, -4							#increments bit counter
		bgtz $t1, loop								#if the counter is not at total bits branch back
	jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
draw_pixel: nop
	#YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	getCoordinates($a0, $t2, $t3)					#gets exact coordinates needed and stores x in t2 and y in t3
	
	li $t4, 0xFFFF0000								#storing origin adress in t4
	getPixelAddress($t5, $t2, $t3, $t4)				#get pixel address
	
	sw $a1, ($t5)									#stors color in the pixel

	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	#YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	getCoordinates($a0, $t6, $t7)					#gets excat coordinates needed and stores x in t6 and y in t7
	
	#(doing it this way because calling from data had alot of bugs to it)
	li $t8, 0xFFFF0000								#storing origin adress in t8
	getPixelAddress($t9, $t6, $t7, $t8)				#get pixel address
	
	lw $v0, ($t9)									#gets color in the pixel
	
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	
	move $t5, $a0
	
	li $t4, 0										#counter
	li $t2, 0xFFFF0000								#storing origin adress in t2
	loop_start0:
		beq $t4, 128, loop_end0						#if counter equal to bit size end
		getPixelAddress($t3, $t4, $t5, $t2)			#get pixel address
		sw $a1, ($t3)								#store color in memory slot
	
		addi $t4 $t4, 1								#increment counter
		j loop_start0								#go back to top of loop
	loop_end0:
  	jr $ra


#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	move $t5, $a0
	
	li $t4, 0											#counter
	li $t2, 0xFFFF0000									#storing origin adress in t2
	loop_start1:
		beq $t4, 128, loop_end1							#if counter equal to bit size end
		getPixelAddress($t3, $t5, $t4, $t2)				#get pixel address
		sw $a1, ($t3)									#store color in memory slot
	
		addi $t4 $t4, 1									#increment counter
		j loop_start1									#go back to top of loop
	loop_end1:
  	jr $ra
#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_crosshair: nop
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	move $s5 $sp

	move $s0 $a0  # store 0x00XX00YY in s0
	move $s1 $a1  # store 0x00RRGGBB in s1
	getCoordinates($a0 $s2 $s3)  # store x and y in s2 and s3 respectively
	
	# get current color of pixel at the intersection, store it in s4
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	
	move $a0, $s0					#prep $a0 for get_pixel
	jal get_pixel					#jumps to get_pixel
	move $s4, $v0					#stores previous color in s4
	
	# draw horizontal line (by calling your `draw_horizontal_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0, $s3 					#prep $a0 for draw_horizontal_line
	move $a1, $s1					#prep $a1 for draw_horizontal_line
	jal draw_horizontal_line		#jumps to draw_horizontal_line
	
	# draw vertical line (by calling your `draw_vertical_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	
	move $a0, $s2 					#prep $a0 for draw_vertical_line
	move $a1, $s1					#prep $a1 for draw_vertical_line
	jal draw_vertical_line			#jumps to draw_vertical_line	
	
	# restore pixel at the intersection to its previous color
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)

	move $a0, $s0					#prep $a0 for draw_pixel
	move $a1, $s4					#prep $a1 for draw_pixel
	jal draw_pixel					#jumps to draw_pixel
	
	move $sp $s5
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)

	jr $ra
