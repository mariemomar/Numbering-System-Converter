.data 
	prompt1: .asciiz "Enter the current base (2-16): "
	prompt2: .asciiz "Enter the number: "
	prompt3: .asciiz "Enter the new base (2-16):"
	invalid_base_message: .asciiz "Invalid base. Please enter a base between 2 and 16.\n"
	same_base_message: .asciiz "The number is already in the new base \n"
	input_buffer: .space 32
	output_buffer: .space 32
	reverse_temp: .space 32
	new_base_message : .asciiz "The number in the new base is : "
.text 

main: 
	li $v0 , 4
	la $a0 , prompt1
	syscall
	
	li $v0 , 5 
	syscall 
	move $t0 , $v0 # store the base 1 at t0
	
	li $v0 , 4
	la $a0 , prompt2
	syscall
	
	# Read the string from the user
    	li $v0, 8  
    	la $a0, input_buffer  # a0 has the location of the buffer 
    	li $a1, 32    # max char to read 
    	syscall
	
	li $v0 , 4
	la $a0 , prompt3
	syscall
	
	li $v0 , 5 
	syscall 
	move $t1 , $v0 # store the base 2 at t1
	
	# Ensure base1 (in $t0) is within 2–16
	blt $t0, 2, invalid_base
	bgt $t0, 16, invalid_base

	# Ensure base2 (in $t1) is within 2–16
	blt $t1, 2, invalid_base
	bgt $t1, 16, invalid_base

	# Continue normal processing
	b continue

	invalid_base:
	li $v0, 4
	la $a0, invalid_base_message 
	syscall
	li $v0, 10
	syscall

	continue:
	
	beq $t0 , $t1 , same_base
	
	b check_if_base1_10
	
	same_base: 
	
	li $v0 , 4
	la $a0, same_base_message
	syscall
	li $v0 , 10 
	syscall
	
	#----------------------------
	#the validation function here
	# ---------------------------
	
	check_if_base1_10:
	beq $t0 , 10 , showDecimal
	
	showDecimal: 
	
	la $a0, input_buffer  # string number
	move $a1, $t1         # pass base2
	la $a2 , output_buffer # the result
	jal decimalToAnyBase
	
	
	# Print the result
   	li $v0, 4
    	la $a0, new_base_message
    	syscall

    	li $v0, 4
    	la $a0, output_buffer
    	syscall

    	li $v0, 10
    	syscall
	
#####################################################################

decimalToAnyBase: 

	# a0 = number (string) , a1 = new base , a2 = result (string)
	
	li $t2, 0  # store value (decimal)
	li $t3 , 0 # index for the output buffer  i
	li $t4 , 10    # multiplier   
	
	convert_to_int:
	lb $t5 , 0($a0)   #load the first char at t5
	beq $t5 , 0 , converting_to_new_base
	
	addi $t5 , $t5 , -48 # subtract 48 to convert to int 
	mul $t2 , $t2 , $t4   # multiply each char by 10 
	add $t2 , $t2 , $t5  # add the value of the char
	
	addi $a0 , $a0 , 1  #increase the iterator of the string number
	
	j convert_to_int


	end_loop: 
	li $v0 , 10 
	syscall

	#converting to the new base
	converting_to_new_base:
	li $t6 , 0   #index on the result string i
	beq $t2 , 0 , zero_result
	
	b if_not_zero
	
	zero_result:
	sb $zero, 0($a2)  #a2 is the result make it = 0 and return 
	jr $ra
	
	if_not_zero:
	bgt $t2 , 0 , convert_to_new_base
	
	convert_to_new_base: 
	div $t2 , $a1
	mfhi $t7   #reminder
	
	# select the char for the reminder
    	blt $t7, 10, digit
    	addi $t7, $t7, -10
    	addi $t7, $t7, 'A'  
    	j store_char

	digit:
    	addi $t7, $t7, '0'  #  numbers from 0 to 9 remain the same but strings 
    	
    	store_char:
    	sb $t7, 0($a2)      # Store the character in the result buffer
    	addi $a2, $a2, 1     # Increment result buffer pointer
    	addi , $t6 , $t6 , 1 # keep the length of the string 

    	# Update decimal
    	mflo $t2            # decimal / base 
    	
    	bgtz $t2 , convert_to_new_base
    	
    	 b reverse_done
    	# Reverse the result string
    	reverse_result:
   	 sub $a2, $a2, $t6  # Adjust $a2 to point to the start of the buffer
    	jal reverse_string # Call reversal function
	


reverse_string:
    sub $t8, $t6, 1        # $t8 = size of the string - 1 (index of last char)
    add $t9, $a2, $t8      # $t9 = pointer to the last character (end pointer)

reverse_loop:
    bge $a2, $t9, reverse_done  # Stop if start pointer meets or crosses end pointer

    lb $t0, 0($a2)         # Load character at the start
    lb $t1, 0($t9)         # Load character at the end
    sb $t1, 0($a2)         # Swap: store end character at start
    sb $t0, 0($t9)         # Swap: store start character at end

    addi $a2, $a2, 1       # Move start pointer forward
    addi $t9, $t9, -1      # Move end pointer backward

    j reverse_loop         # Repeat until done

reverse_done:
    jr $ra                 # Return to caller



	