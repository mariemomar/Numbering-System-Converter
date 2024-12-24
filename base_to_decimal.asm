.data
prompt_number:  .asciiz "Enter the number to convert: "
prompt_base:    .asciiz "Enter the base of the number (2-16): "
newline:        .asciiz "\n"
result_msg:     .asciiz "The decimal value is: "
input_buffer: .space 32        
    
.text

main:
    # Print prompt for number
    li $v0, 4                  
    la $a0, prompt_number
    syscall

    # Read the number input
    li $v0, 8                
    la $a0, input_buffer       
    li $a1, 32               
    syscall

    # Print prompt for base
    li $v0, 4                  
    la $a0, prompt_base
    syscall

    # Read the base input
    li $v0, 5                  
    syscall
    move $t0, $v0              

    jal convert_to_decimal

    # Print the result message
    li $v0, 4                  
    la $a0, result_msg
    syscall

    # Print the decimal result
    li $v0, 1                  
    move $a0, $t1              
    syscall

    # Print a newline
    li $v0, 4                  
    la $a0, newline
    syscall

    # Exit the program
    li $v0, 10               
    syscall

# Conversion function
convert_to_decimal:
    li $t1, 0                  
    li $t2, 0                  

convert_loop:
    lb $t3, input_buffer($t2)  
    beqz $t3, done_conversion  

    li $t4, 48                 
    li $t5, 57                 
    blt $t3, $t4, check_alpha  
    bgt $t3, $t5, check_alpha  

    sub $t3, $t3, $t4          

    j process_digit

check_alpha:
    li $t4, 65                 
    li $t5, 70                 
    blt $t3, $t4, done_conversion  # If character < 'A', we're done
    bgt $t3, $t5, done_conversion  # If character > 'F', we're done

    # Convert letter ('A'-'F') to value
    sub $t3, $t3, $t4          
    addi $t3, $t3, 10

process_digit:
    mul $t1, $t1, $t0          # $t1 = $t1 * base
    add $t1, $t1, $t3          # $t1 = $t1 + digit value

    addi $t2, $t2, 1        
    j convert_loop

done_conversion:
    jr $ra                   