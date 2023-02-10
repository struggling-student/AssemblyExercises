.globl main

.data
String: .asciiz "A B C, easy as 1, 2, 3 / Are simple as do re mi!"

.text
main:
la $a0,string

jal Strlen

move $a1,$v0

jal AlphBefore

move $a0,$v0
li $v0,4
syscall

li $v0,10
syscall

AlphBefore:
  subi $sp,$sp,12
  sw $ra,8($sp)
  sw $a1,4($sp)              # Save the original $a1…
  sw $a0,0($sp)              # … and $a0, because we will move them along the string

  add $a1,$a1,$a0            # Make $a1 the pointer to the last character
  subi $a1,$a1,1

  jal AlphBeforeIt

  lw $a0,0($sp)              # Reload the original parameters
  lw $a1,4($sp)
  lw $ra,8($sp)
  addi $sp,$sp,12


AlphBeforeIt:
  While:
    bge $a0,$a1,EndWhile      # Exit the cycle when head and tail pointers are equal

    subi $sp,$sp,8            # Prepare the call to CheckAlph
    sw $ra,4($sp)
    sw $a0,0($sp)

    lb $a0,($a0)              # Load the character pointed by $a0 in $a0
    jal CheckAlph             # Call CheckAlph

    lw $a0,0($sp)             # Restore the state
    lw $ra,4($sp)
    addi $sp,$sp,8

    If:                       # IF $v0 == 0 put the character at the end
      beq $v0,$zero,Switch
    Else:
      addi $a0,$a0,1
      j EndIf
    Switch:
      lb $t0,($a0)
      lb $t1,($a1)
      sb $t1,($a0)
      sb $t0,($a1)

      subi $a1,$a1,1          # We know ($a1) has no character now
    EndIf:
      j While

  EndWhile:
  move $v0,$a0                  # Return the string address

  jr $ra

Strlen:
  move $t1,$a0
  lb $t0,($t1)
  Count:
    beq $t0,$zero,EndCount  # Till the termination character (0x00)
    addi $t1,$t1,1          # Advance by one byte to the next character in the string
    lb $t0,($t1)            # Load the next character
    j Count
  EndCount:
    sub $v0,$t1,$a0         # $v0 = pointer to last char - pointer to first char
    jr $ra

CheckAlph:
#  CkeckUppercase:
  sge $t0,$a0,0x41 # 0x41 is 'A'
  sle $t1,$a0,0x5A # 0x5A is 'Z'
#  CheckLowercase:
  sge $t2,$a0,0x61 # 0x61 is 'a'
  sle $t3,$a0,0x7A # 0x7A is 'z'
#  CheckLetter:
  and $t0,$t0,$t1  # $t0 ← 1 if $a0 is an uppercase alph. letter
  and $t2,$t2,$t3  # $t2 ← 1 if $a0 is a lowercase alph. letter

  or $v0,$t0,$t2   # $v0 ← 1 if $a0 is an uppercase or lowercase alph. letter

  jr $ra
