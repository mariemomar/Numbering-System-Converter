.data 
    prompt1: .asciiz "Enter the current base (2-16): "
    prompt2: .asciiz "Enter the number: "
    prompt3: .asciiz "Enter the new base (2-16): "
    invalid_base_message: .asciiz "Invalid base. Please enter a base between 2 and 16.\n"
    same_base_message: .asciiz "The number is already in the new base.\n"
    invalid_number_message: .asciiz "The number is not valid for the specified base.\n"
    input_buffer: .space 32
    output_buffer: .space 32
    reverse_temp: .space 32
    new_base_message: .asciiz "The number in the new base is: "
    space: .asciiz " "
.text 

main: 
    # Prompt for base1
    li $v0, 4
    la $a0, prompt1
    syscall
    
    li $v0, 5 
    syscall 
    move $t0, $v0 # Store base1 in $t0
    
    # Prompt for the number
    li $v0, 4
    la $a0, prompt2
    syscall

    li $v0, 8
    la $a0, input_buffer  # $a0 points to the input buffer
    li $a1, 32            # Max chars to read
    syscall

    # Null-terminate the input string
    la $t2, input_buffer  # Pointer to start of buffer
null_terminate:
    lb $t3, 0($t2)        # Load current character
    beqz $t3, done_null   # Exit loop if null terminator found
    beq $t3, '\n', replace # Replace newline with null
    addi $t2, $t2, 1      # Move to the next character
    j null_terminate

replace:
    sb $zero, 0($t2)
    j done_null

done_null:

    # Prompt for base2
    li $v0, 4
    la $a0, prompt3
    syscall

    li $v0, 5
    syscall
    move $t1, $v0 # Store base2 in $t1

    # Ensure base1 (in $t0) is within 2–16
    blt $t0, 2, invalid_base
    bgt $t0, 16, invalid_base

    # Ensure base2 (in $t1) is within 2–16
    blt $t1, 2, invalid_base
    bgt $t1, 16, invalid_base

    b continue

invalid_base:
    li $v0, 4
    la $a0, invalid_base_message
    syscall
    li $v0, 10
    syscall
#   --------------------------------------------------------------------
continue:

    # Validate the number for base1
    la $a0, input_buffer   # Address of the number string
    move $a1, $t0          # Base1
    #jal validateNumber     # Call validateNumber
    j validateNumber
###
continue2:
	
	
	
    # Check if base1 == base2
    beq $t0, $t1, same_base
    b check_if_base1_10

same_base:
    li $v0, 4
    la $a0, same_base_message
    syscall
    li $v0, 10
    syscall

check_if_base1_10:
    beq $t0, 10, showDecimal

showDecimal:
    la $a0, input_buffer  # Number string
    move $a1, $t1         # New base
    la $a2, output_buffer # Result
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

# ---------------------------------
# Validation Function
# ---------------------------------
validateNumber:
    # a0 = number (string)
    # a1 = base

    la $t6, input_buffer  # Pointer to the number string
validate_loop:
    lb $t7, 0($t6)          # Load current character
    beqz $t7, validate_done # End of string, number is valid

    # Convert character to numeric value
    li $t2, '0'
    li $t3, '9'
    blt $t7, $t2, check_alpha
    bgt $t7, $t3, check_alpha
    sub $t4, $t7, $t2       # $t4 = digit - '0'
    b validate_value

check_alpha:
    li $t2, 'A'
    li $t3, 'F'
    blt $t7, $t2, invalid_number
    bgt $t7, $t3, invalid_number
    sub $t4, $t7, $t2       # $t4 = letter - 'A'
    addi $t4, $t4, 10       # Add 10 for A–F

validate_value:
    # Check if value is valid for the base
    bge $t4, $a1, invalid_number

    # Move to the next character
    addi $t6, $t6, 1
    j validate_loop

invalid_number:
    li $v0, 4
    la $a0, invalid_number_message
    syscall
    li $v0, 10
    syscall

validate_done:
    j continue2


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


	converting_to_new_base:
	li $t6 , 0   #index on the result string i
	beqz $t2  , zero_result

	b if_not_zero

	zero_result:
	li $t0  , '0'
	sb $t0 , 0($a2)
        addi $a2, $a2, 1     # Move result pointer forward
    	sb $zero, 0($a2)     # Null-terminate the result buffer
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
    	addi $t6 , $t6 , 1 # keep the length of the string

    	# Update decimal
    	mflo $t2            # decimal / base

    	bgtz $t2 , convert_to_new_base

    	# t6 the length of the string , a2 = the string


    	 b reverse_result
    	# Reverse the result string
    	reverse_result:
   	 sub $a2, $a2, $t6  # Adjust $a2 to point to the start of the buffer
    	b reverse_string # Call reversal function



	reverse_string:
    	sub $t8, $t6, 1        # $t8 = size of the string - 1 (index of last char)
    	add $t9, $a2, $t8      # $t9 = pointer to the last character (end pointer)

	reverse_loop:
    	bge $a2, $t9, reverse_done

    	lb $t0, 0($a2)
    	lb $t1, 0($t9)
    	sb $t1, 0($a2)
    	sb $t0, 0($t9)

    	addi $a2, $a2, 1
    	addi $t9, $t9, -1

    	j reverse_loop

	reverse_done:
    	jr $ra

######################################################################################
