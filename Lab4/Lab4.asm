##########################################################################
# Created by:  Sicairos, Alejandra
#              kasicair
#              24 February 2021
#
# Assignment:  Lab 4: Syntax Checker
#              CSE 12 /L, Computer Systems and Assembly Language
#              UC Santa Cruz, Winter 2021
# 
# Description: This program prints checks if the file has balanced braces.
# 
# Notes:       This program is intended to be run from the MARS IDE.
# Pseudo Code:
#				load userinput
#				print "You entered the file: "
#				print user input/file name

# 				check if file name is not an integer
#				check if file name is less than 20 characters
#				check if file exsits
#				if the (file meets conditions above):
#					open file as inputted
#					read what is inside the file
#    				save the number of characters to t0
#				else 
#					go to invalid arguemt

#				t5 = -1 // counts the index in which the character is at
#    			for every character in t0
#					s1 = character at t0
#					increment t5 +1
#					subtract from t0 1 // characters we have left
#					if s1 = ( '(',  '{', '[' )
#						push s1 into stack
#					if s1 = ( ')', '}', ']' )
#						pop the top value from the stack
#						if value == s1 pair
#							add to pair counter
#						else
#							print "there is a mismatch 's1' at 't5'
#							close file
#							break
#					if stack length == 0
#						print " there are 'numpair' pairs of braces
#						close file
#						break
#					else
#						print "there are still"
#						print what is still on the stack
#						close file
#						break
##########################################################################

.data
	file_message: .asciiz "You entered the file: \n"
	fileText: .space 128
	success_message0: .asciiz "\nSUCCESS: There are "
	success_message1: .asciiz " pairs of braces.\n"
	invalidProgram_message: .asciiz "\nERROR: Invalid program argument.\n"
	error_message1: .asciiz "\nERROR - There is a brace mismatch: "
	error_message2: .asciiz " at index "
	leftOver_error: .asciiz "\nERROR - Brace(s) still on stack: "
	new_line: .asciiz "\n"
.text

############## OPENING AND READING FILE ############## 	
openfile:
	lw $t0 ($a1)						#loads register a1 that holds program argument (file name) to memory
	
	### Prints 'You entered ...' Statement ###
	la $a0, file_message				#prep to print the string
	li $v0 4							#loading syscall 4 in order to print string
	syscall 
	nop
	
	### Prints File Name ###
	la $a0, ($t0)						#preps argument name to print 
	li $v0 4							#syscall to print string
	syscall
	
	la $a0, new_line					#preps register to print a new line
	li $v0 4							#syscall to print string
	syscall
		
checkForInt:
	lb $s3, ($t0)						#loads first byte
	ble $s3, 57, invalid_argument		#if the first byte is less or equal to 9 got to invalid argument
	nop
	
addi $t3, $t3, 0						#set t3 the character count
la $t4, ($t0)							#load file name to loop through
checkingLength:
	lb $s3, ($t0)						#loads first byte
	beqz $s3, checkValidArgument		#branch when it reaches the end of the file name
	nop
	addi $t0, $t0, 1 					#increment pointer 
	addi $t3, $t3, 1					#increment character count
	nop 
j checkingLength						#go to the top of the loop
nop

checkValidArgument:
	blt $t3 20 continue					#branch if the character counter is under 0
	nop
	j invalid_argument					#jumps to invalid if it is greater
	nop
	
continue:
	lw $t0 ($a1)						#loads program argument for it to prep to open
	### Finishes Opening File ###
	move $a0 $t0						#moving file name to a0
	li $a1 0							#assigning a1 to 0 so that it opens the file
	li $v0 13							#loads syscall to open file
	syscall
	beq $v0, -1, invalid_argument		#checks if file is valid
	move $s0 $v0						#saving the name of the file to a register in order to access it later
	nop
	
readfile:				
	move $a0 $s0						#moving the name of the file to a0 to prep it to open
	li $v0 14							#loading the syscall to read file
	la $a1 fileText						#loads the text from the file
	li $a2 128							#loads he maximun number of characters
	syscall 
	move $t0 $v0						#moving the number of characters to t0 
	beqz $t0 end 						#Goes to the end of the file if the file is empty or fully read
	nop			
	
main:
	### ITERATING THROUGH STING BY CHRACTER ###
	li $t5, -1							#index counter
	la $t1, fileText					#loads the text from the file to a register
	iterating_through_string:
		lb $s1, ($t1)					#loads first byte
		subi $t0 $t0 1					#character counter
		
		nop
		addi $t5, $t5, 1				#increment index counter
		nop
 
	Check_for_open_brace:
		beq $s1, 40 ,push				#branch to push if equal to open paranthesis
		nop
		beq $s1, 91 ,push				#branch to push if equal to open bracket
		nop
		beq $s1, 123 ,push				#branch to push if equal to open curly brace
		nop
	
	check_for_close_braces:
		beq $s1, 41 ,pop1				#branch to pop if equal to close paranthesis
		nop
		beq $s1, 93 ,pop2				#branch to pop if equal to close bracket
		nop
		beq $s1, 125 ,pop3				#branch to pop if equal to close curly brace
		nop	
	### back is where it comes back to once it pushes and pops from stack ###
	back:
		beqz $t0 readfile				#if amount of characters is 0 it will go back to readfile to check for more characters/ strings
		addi $t1, $t1, 1 				#increment byte pointer 
		j iterating_through_string		#jump back up tp the loop
		nop
	### end of loop that goes through each character so now it checks to see if the stack is empty ###		

end:
	j check_stack						#jumps to check stack before it all terminates
	nop
	exit:
		move $a0 $s0						#prep to move file name to close
		li $v0 16							#loading syscall 16 in order to close file
		syscall
	
		li $v0, 10							#end of program (syscall to terminate)
		syscall

############## Functions ############## 

#### Stack Function ### 
push:
	addi $sp, $sp, -4					#loads stack and preps it for new inputs
	sw $s1, ($sp)						#loads the current byte/character to the stack
	
	addi $t9, $t9, 1					#adds to counter of stack items to check how many are there
	j back								#jumps back to the loop
	nop
	
pop1:
	lw $s2, ($sp) 						#loads the stack and the top value
	addi $sp, $sp, 4					#loads stack and preps it for popping input
	subi $t9, $t9 1						#removes it from the stack counter
	
	beq $t9, -1, missmatchError			#if the stack ever goes lower than 0 it means theres an extra open brace which means a missMatchError
	nop
	beq $s2 40 incPair					#if the close parethesis mathces its counter part it goes to incPair 
	nop
	j missmatchError					#if none of the following conditions were met then it means that it is a missMatch
	nop
	
pop2:
	lw $s2, ($sp) 						#loads the stack and the top value
	addi $sp, $sp, 4					#loads stack and preps it for popping input
	subi $t9, $t9 1						#removes it from the stack counter
	
	beq $t9, -1, missmatchError			#if the stack ever goes lower than 0 it means theres an extra open brace which means a missMatchError
	nop
	beq $s2 91 incPair					#if the close parethesis mathces its counter part it goes to incPair 
	nop
	j missmatchError					#if none of the following conditions were met then it means that it is a missMatch
	nop
	
pop3:
	lw $s2, ($sp) 						#loads the stack and the top value
	addi $sp, $sp, 4					#loads stack and preps it for popping input  
	subi $t9, $t9 1						#removes it from the stack counter
	
	beq $t9, -1, missmatchError			#if the stack ever goes lower than 0 it means theres an extra open brace which means a missMatchError
	nop
	beq $s2 123 incPair					#if the close parethesis mathces its counter part it goes to incPair 
	nop
	j missmatchError					#if none of the following conditions were met then it means that it is a missMatch
	nop
	
### Counts the amount of brace pairs ###
incPair:
	addi $t8, $t8, 1					#t8 is the register that counts the amount of pairs that are in the string
	j back								#when it is done it returns to the loop
	nop
	
### Revisses the Stack at the end of the loop ###
check_stack:
	beq $t9 $zero success				#if the counter of the amount values in the stack is empty it jumps to success 
	nop				
		
	#if the past condition is not me it means there are braces left over				
	la $a0 leftOver_error				#loads error message to a0 to prep for printing
	li $v0 4							#loading syscall 4 in order to print string
	syscall
	
	#loop that prints the left over is any of the stack
	print_stack:
	beqz $t9 exit						#branch if the stack counter is 0 to exit
	nop
	lw $a0, ($sp) 						#loads the stack to print
	addi $sp, $sp, 4					#allocates word space
	li $v0 11							#syscall to print a single character
	syscall
	
	subi $t9 $t9 1						#subtract 1 from the counter so that it branches when 0
	j print_stack						#jump back to the top of the loop
	nop
	
success:
	la $a0, success_message0			#prep to print the beginning of the error message
	li $v0 4							#loading syscall 4 in order to print string
	syscall
	nop
	
	move $a0, $t8						#prep to print the amount of pairs of braces
	li $v0 1							#loading syscall 1 in order to print single integer
	syscall 
	nop
	la $a0, success_message1			#prep to print the 2nd half of the error message
	li $v0 4							#loading syscall 4 in order to print string
	syscall
	j exit								#jumps to close and terminate program
	nop
	
invalid_argument:
	la $a0 invalidProgram_message		#prep to print mesage
	li $v0 4							#loading syscall 4 in order to print string
	syscall
	nop
	j exit								#jump to the end to terminate the program
	nop
	
missmatchError:
	la $a0, error_message1				#prep to print the beginning of the error message
	li $v0 4							#loading syscall 4 in order to print string
	syscall
	nop
	
	move $a0, $s1						#prep to print the brace that is incorrect
	li $v0 11							#loading syscall 11 in order to print single character
	syscall 
	nop
	la $a0, error_message2				#prep to print the 2nd half of the error message
	li $v0 4							#loading syscall 4 in order to print string
	syscall
	
	move $a0 $t5						#prep to print the index in which the error happens
	li $v0 1							#loading syscall 1 in order to print integer
	syscall
	
	la $a0, new_line					#preps register to print a new line
	li $v0 4							#loading syscall 4 in order to print string
	syscall
	
	j exit								#jumping to the end to terminate the program and close file
	nop
