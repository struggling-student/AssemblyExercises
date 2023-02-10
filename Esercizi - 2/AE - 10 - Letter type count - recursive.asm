.globl main

.data
String: .asciiz "A B C, easy as 1, 2, 3 / Are simple as do re mi!"
Comma: .asciiz ", "

.text
main:
la $a0,string

jal CountLettersByType

move $s0,$v0

lw $a0,($s0)
li $v0,1
syscall

la $a0,comma
li $v0,4
syscall

subi $s0,$s0,4
lw $a0,($s0)
li $v0,1
syscall

la $a0,comma
li $v0,4
syscall

subi $s0,$s0,4
lw $a0,($s0)
li $v0,1
syscall

li $v0,10
syscall

# CountLettersByType($a0: *char): ($v0: *int)
#  Returns the location in memory from where 3 integers are saved:
#    the number of non-alphanumeric characters, the number of letters, the number of digits
CountLettersByType:
  subi $sp,$sp,16
  addi $fp,$sp,12
  #   ($fp) = 12($sp) → digits
  # -4($fp) =  8($sp) → letters
  # -8($fp) =  4($sp) → other characters
  #            0($sp) ← $ra
  sw $ra,0($sp)

  jal CountLettersByTypeRec

  lw $ra,0($sp)
  addi $sp,$sp,16

  move $v0,$fp

  jr $ra

CountLettersByTypeRec:
  lb $t0,($a0)            # Load the character pointed by $a0 in $t0
  beq $t0,$zero,BaseCase  # Go to base case if $a0 is a \0 (end-of-string) character

  RecursiveStep:
    subi $sp,$sp,12       # Prepare the call to CheckType
    sw $ra,8($sp)
    sw $v0,4($sp)
    sw $a0,0($sp)

    addi $a0,$a0,1        # Go to the next character
    jal CountLettersByTypeRec

    lw $a0,0($sp)         # Reload $a0 before the last increment
                          #   (the base case would point at the \0 character)
    lb $a0,($a0)          # Load the character pointed by $a0 in $a0
    jal CheckType

    sll $t0,$v0,2         # IF $v0 is 0, 1, or 2, add the value of $v1 on $fp decremented by 0, 4, or 8, resp.
    sub $t1,$fp,$t0       # Load $fp shifted by -$v0×4 onto $t1
    lw $t2,($t1)          # Load the value of ($fp-$v0×4) onto $t2
    add $t2,$t2,$v1       # Add $v1 to $t2
    sw $t2,($t1)          # Save the value in memory

    lw $a0,0($sp)         # Reload the original state
    lw $v0,4($sp)
    lw $ra,8($sp)
    addi $sp,$sp,12

    jr $ra

  BaseCase:
  sw $zero,($fp)
  sw $zero,-4($fp)
  sw $zero,-8($fp)
  jr $ra

CheckType:
  add $v0,$zero,$zero           # Let us initialise $v0 as if it was a digit (in case, we can change our mind)
  and $v1,$zero,$zero

  CheckDigit:
  slti $t0,$a0,0x30             # 0x30 is '0'
  bgt $t0,$zero,ExitNoAlNum     # If $a0 is less than 0x30, it is neither a digit nor an alph. letter
  slti $t0,$a0,0x39             # 0x39 us '9'
  beq $t0,$zero,CkeckUppercase  # If $a0 is higher than 0x39, it could be an alph. letter
  j ExitNum                     # If 0x30 <= $a0 <= 0x39, it is a digit

  CkeckUppercase:
  slti $t0,$a0,0x41             # 0x41 is 'A'
  bgt $t0,$zero,ExitNoAlNum     # If $a0 is less than 0x41, it is not an alph. letter
  slti $t0,$a0,0x5B             # 0x5A is 'Z'
  beq $t0,$zero,CheckLowercase  # If $a0 is higher than 0x5A, it could be a lowercase alph. letter
  j ExitAlph                    # If 0x41 <= $a0 <= 0x5A, it is an alph. letter (uppercase)

  CheckLowercase:
  slti $t0,$a0,0x61             # 0x61 is 'a'
  bgt $t0,$zero,ExitNoAlNum     # If $a0 is less than 0x61 but higher than 0x5A, it is no alph. letter
  slti $t0,$a0,0x7B             # 0x7A is 'z'
  beqz $t0,CheckIfCharAtAll     # If $a0 is higher than 0x7A, check if it is an ASCII character at all
  j ExitAlph                    # If 0x61 <= $a0 <= 0x7A, it is an alph. letter (lowercase)

  CheckIfCharAtAll:
  slti $t0,$a0,0x80             # 0x7F is the last ASCII character (0111 1111)
  beqz $t0,ExitNoASCII          # If $a0 > 0x7F, it is not an ASCII character at all

  ExitNum:
# add $v0,$zero,$zero           # By default (see line after CheckType)
  j Exit
  ExitAlph:
  addi $v0,$zero,1
  j Exit
  ExitNoAlNum:
  addi $v0,$zero,2
# j Exit

  Exit:
  li $v1,1
  ExitNoASCII:
  jr $ra
