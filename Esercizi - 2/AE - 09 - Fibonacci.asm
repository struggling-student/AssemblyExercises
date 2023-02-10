.globl main

.data
N: .half 7

.text
main:
lhu $a0,N                 # Load the parameter

jal Fibonacci             # Invoke the Fibonacci recursive function

add $a0,$v0,$zero         # Print the result
li $v0,1
syscall

li $v0,10                 # Exit
syscall

Fibonacci:
  beq $a0,$zero,BaseCase0 # IF $a0 = 0 GO TO base case for n = 0

  addi $t0,$zero,2
  blt $a0,$t0,BaseCase    # IF $a0 < 2 GO TO base case for n = 1

  RecursiveStep:
  subi $sp,$sp,8          # Save data on the stack
  sw $ra,0($sp)
  sw $a0,4($sp)

  subi $a0,$a0,1          # n' ← n - 1
  jal Fibonacci           # $v0 ← fibonacci(n')

  subi $a0,$a0,1          # n" ← n' - 1 = n - 2
  jal Fibonacci           # $v0 ← fibonacci(n")

  lw $a0,4($sp)           # Load data from the stack
  lw $ra,0($sp)
  addi $sp,$sp,8

  jr $ra                  # Return

  BaseCase:
  addi $v0,$v0,1          # $v0 += fibonacci(1)

  jr $ra                  # Return

  BaseCase0:
  addi $v0,$v0,0          # $v0 += fibonacci(0)

  jr $ra                  # Return
