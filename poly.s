###############################################################################
# Brennan Schmidt and Peter Collins
#
# Lecture section 2
#
# This program reads in a degree for a polynomial, then reads in coefficients
# for each degree of the polynomial, and prints the coefficients back out. If
# anything other than a number is entered for the degree, an error message will
# print. The degree needs to be an integer between 0 and 4
###############################################################################

.data
enter_degree: .asciiz "Enter degree: "
enter_coeff: .asciiz "Enter coefficient: "
x_power_of: .asciiz "x^"
coeff_is: .asciiz " coefficient is "
new_line: .byte '\n'
minus_sign: .byte '-'
err_msg: .asciiz "Bad input. Quitting."

.text
# $8 degree
# $9 temp 4 check value
# $10 coeffcient getter
# $11 ASCII minus sign check value
# $12 ASCII carriage return check value
# $13 temp 9 check value
# $14 coeffcient value
# $15 minus sign bool
# $16 ASCII representation of degree
# $17 coeffcient digit to print
# $18 divided coeffcient
# $19 temp powers of ten to subtract
# $20 ASCII coeffcient to print
# $21 count of chars inputted
# $22 temp counter for finding left most digit
# $23 boolean value for if the first nonzero digit has been entered
__start:
    puts enter_degree
    getc $8             # store the degree of the polynomial into $8
    sub $8, $8, 0x30    # convert from ASCII to integer
    bltz $8, input_err
    li $9, 4            # Check if not greater than 4
    bgt $8, $9, input_err
    putc new_line

coeff_loop:
    bltz $8, end_coeff_loop # If we have the coeffcients for all degrees, finish
    li $23, 0
	li $21, 0               # sets the digit count to 0
    puts enter_coeff
    getc $10
    li $11, 45 # ASCII minus sign
    beq $10, $11, set_minus_sign # if first char is '-' set minus sign to true
no_minus_sign:
    sub $10, $10, 0x30       # first digit
    bltz $10, input_err      # Validate int
    li $13, 9
    bgt $10, $13, input_err
    move $14, $10            # store first digit as integer    
    beqz $10, zero_digit1    # if the digit is a nonzero, set nonzero bool to true
    li $23, 1                # sets first nonzero digit to true
zero_digit1:
    beqz $23 no_incr1
	add $21, 1               # increment digit counter
no_incr1:
    li $15, 0                # set minus sign to false
    b get_int	
set_minus_sign:
    li $14, 0                # initialize integer as 0
    li $15, 1                # set minus sign to true
get_int:
    getc $10
    li $12, 10               # ASCII new line
    beq $10, $12 end_get_int # check for new line
    sub $10, $10, 0x30       # convert ASCII to integer
    bltz $10, input_err      # Validate int
	li $13, 9
    bgt $10, $13, input_err
    mul $14, $14, 10         # Multiply the current coefficient by 10
    add $14, $14, $10        # Add the int
    beqz $10, zero_digit2    # if digit is a nonzero, set nonzero bool to true
    li $23, 1
zero_digit2:
    beqz $23, no_incr2
    add $21, 1               # increment digit counter
no_incr2:
    b get_int
end_get_int:
    puts x_power_of
    add $16, $8, 0x30
    putc $16              # Print degree
    puts coeff_is
    beqz $15, print_coeff # goes to print coeff if integer is not negative
print_minus_sign:
    putc minus_sign
print_coeff:
    move $18, $14        # copy integer into temporary calculation register
    li $19, 1            # initialize power of ten to 1
	li $22, 0            # initialize left digit finder to 0
get_left_digit:
    rem $17, $18, 10     # find store what could be our left most digit
    div $18, $18, 10     # divide integer by ten
    mul $19, $19, 10     # multiply power of ten by ten
    add $22, 1
    blt $22, $21, get_left_digit # if we've have more left digits, loop & find more
    add $20, $17, 0x30   # we've found the digit, convert to ASCII
    putc $20
    div $19, $19, 10     # overcounted power of ten, divide by 10 once
    mul $19, $19, $17    # multiple power of ten by left most digit
    sub $14, $14, $19    # subtract from integer to delete left most digit
    sub $21, $21, 1      # decrement number of digits
    bgtz $21 print_coeff # more digits? print more!
end_print_coeff:
    putc new_line
    sub $8, $8, 1        # decrement degree
    bgez $8 coeff_loop   # loop back ask for next degree coeffcient
end_coeff_loop:
    b finish
input_err:
    putc new_line
    puts err_msg
finish:	
    done

