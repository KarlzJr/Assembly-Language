.data
	#This is the string that is presented to the user when the program first runs
	prompt:.asciiz "Enter the height of the pattern (must be greater than 0):\t"
	
	#This is the strinf that is presented to the user when an integer greater than 0 is inputted
	errorMessage: .asciiz "Invalid Entry!\n"
	
	#This is the astericks string that is used to create the pattern
	pattern: .asciiz "*\t"

.text

	patternHeight:
	li $v0 4 								#prompts for the user to enter the height
	la $a0 prompt							#loads the address to the register
	syscall
	
	li $v0 5								#syscall that allows for users input
	syscall 
	
	move $t0 $v0							#stores user input value in $t0
	j checkError 							#jumps to check error to see if input was valid
	
	error:	
		li $v0 4							#prep to display error message
		la $a0 errorMessage					#display error message
		syscall
		j patternHeight						#jump back to the prompt after error message was shown to get a new integer.
		
	checkError:
	blez $t0 error 							#only continue if value inputted was greater than 0, if not then jumps to error
	li $t1 0								#resetting the resgister to 0
	nop
		loopstart:							#beginning of loop to print output
			bge $t1 $t0 printingLoopEnd		#conditional statement that loops through the amount of times user indicated
			nop
			j printPattern					#jump to printPattern to begin astericks pattern
			nop
		
		printPattern:						#print pattern
			
			bge $t2 $s0 printPatternEnd		#loop that corresponds with printing the correct number of astericks 
			nop
			li $v0 4						#prep to display sting
			la $a0 pattern					#display string/pattern
			syscall      
			
			addi $t2 $t2 1      			#increment by 1 t1
			j printPattern         			# go back to the top
			nop
			
		printPatternEnd:					#end of 1st half of the pattern
		addi $s0 $t1 1						#increments $t1 for the pattern so it prints the correct integer
		li $v0 1							#syscall to v0 for printing 
		move $a0 $s0						#moving the integer to a0 to print
		syscall
		li $v0 11							#syscall to print character
		la $a0 9							#loading address to print new line
		syscall
		nop
		
		bge $s0 1 print2ndPattern			#checking if input number is greater than 1
			print2ndPattern:				#other half of the pattern
			blez $t2 print2ndPatternEnd		#loop through pattern like 'printPattern'
			li $v0 4						#prep to display string
			la $a0 pattern					#display string/pattern
			syscall      
			
			subi $t2 $t2 1      			#subtract by 1 t1 to finish the pattern
			j print2ndPattern         		# go back to the top
			nop
		print2ndPatternEnd:
		li $v0 11							#syscall to print character
		la $a0 10							#loading address to print new line
		syscall
		nop
		addi $t1 $t1 1						#incrementing the counter for the loop
		li $t2 0							#resetting inner loop counter
		j loopstart 						#jumping back to beginning of outer loop
		nop
		printingLoopEnd:					#ending of loops 
	li $v0 10								#syscall to terminate program
	syscall
