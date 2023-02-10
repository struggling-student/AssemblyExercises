.globl main

.data
A:    .word   5
B:    .word   7
C:    .word  12
D:    .word -8

.text
main:
lw $a0, A             # Load parameters
lw $a1, B
lw $a2, C
lw $a3, D

jal avgOfSquareAbsSub # Call avgOfSquareAbsSub

add $s0, $v0, $zero   # Save result in $s0 ($v0 is used later)

li $v0,1              # System call function selector: print int
add $a0, $s0, $zero   # System call parameter passage
syscall

li $v0,10             # Exit
syscall

# function avgOfSquareAbsSub($a0: int, $a1: int, $a2: int, $a3: int): ($v0: int)
#   returns ( ( |$a0| - |$a1| ) ^ 2 + ( |$a2| - |$a3| ) ^ 2 ) / 2
avgOfSquareAbsSub:
  subi $sp, $sp, 20   # Move the stack pointer down
  sw $ra,  0($sp)     # First: save the return address
  sw $fp,  4($sp)     # Save the function pointer. Though not used, really.
  sw $a0,  8($sp)     # Save the parameters
  sw $a1, 12($sp)
  sw $s0, 16($sp)     # Save $s0, as it is also used locally

  jal squareAbsSub

  add $s0, $zero, $v0 # Save the temporary result in $s0

  add $a0, $zero, $a2 # Move $a2 in $a0 
  add $a1, $zero, $a3 # Move $a3 to $a1

  jal squareAbsSub

  add $s0, $s0, $v0   # Sum the temporary result to $s0
  srl $s0, $s0, 1     # $s0 = $s0 / 2

  add $v0, $zero, $s0 # Save the result in $v0

  lw $s0,  16($sp)    # Recover the registers, in reverse order
  lw $a1,  12($sp)
  lw $a0,  8($sp)
  lw $fp,  4($sp)
  lw $ra,  0($sp)
  addi $sp, $sp, 20   # Roll the stack pointer back up

  jr $ra              # Jump back to the invocation point

# function squareAbsSub($a0: int, $a1: int): ($v0: int)
#   returns ( |$a0| - |$a1| ) ^ 2
squareAbsSub:
  subi $sp, $sp, 8    # Move the stack pointer down
  sw $a0, 0($sp)      # Save the parameters
  sw $a1, 4($sp)      # Notice we do not need to save $ra here!
                      # This is because this is a sink node in the invocation graph
  abs $a0, $a0        # Take the absolute value of $a0
  abs $a1, $a1        # Take the absolute value of $a1

  sub $v0, $a0, $a1   # $v0 = $a0 - $a1
  mul $v0, $v0, $v0   # $v0 = ($v0)^2

  lw $a1, 4($sp)      # Recover the registers, in reverse order
  lw $a0, 0($sp)
  addi $sp, $sp, 8    # Roll the stack pointer back up

  jr $ra              # Jump back to the invocation point
