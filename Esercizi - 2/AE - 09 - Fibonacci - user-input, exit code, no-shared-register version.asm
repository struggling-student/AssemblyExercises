.data
Question: .asciiz "Please insert a positive integer number or zero:\n"
Error: .asciiz "I said: a positive integer number or zero."

.text
li $v0,4                  # System call function selector: print string on screen
la $a0,Question           # System call parameter passage
syscall

li $v0,5                  # System call function selector: read integer
syscall

bgtz $v0,CallFibonacci    # IF $a0 >= 0 THEN continue
la $a0,Error              # ELSE display error…
li $v0,4                  
syscall

li $a0,33                 # EDOM 33 Numerical argument out of domain (look up "errno.h" on the web for more information)
li $v0,17                 # … and finish
syscall

CallFibonacci:
move $a0,$v0              # Load parameter
and $v0,$zero,$zero       # Set $v0 to 0

jal Fibonacci             # Invoke the Fibonacci recursive function

add $a0,$v0,$zero         # Print the result
li $v0,1
syscall

Exit:
li $v0,10                 # Exit
syscall

Fibonacci:
  beq $a0,$zero,BaseCase0 # IF $a0 = 0 GO TO base case for n = 0

  addi $t0,$zero,2
  blt $a0,$t0,BaseCase    # IF $a0 < 2 GO TO base case for n = 1

  RecursiveStep:
  subi $sp,$sp,12          # Save data on the stack
  sw $ra,0($sp)
  sw $a0,4($sp)
  sw $v1,8($sp)

  subi $a0,$a0,1          # n' ← n - 1
  jal Fibonacci           # $v0 ← fibonacci(n')
  add $v1,$zero,$v0

  subi $a0,$a0,1          # n" ← n' - 1 = n - 2
  jal Fibonacci           # $v0 ← fibonacci(n")
  add $v0,$v1,$v0

  lw $v1,8($sp)
  lw $a0,4($sp)           # Load data from the stack
  lw $ra,0($sp)
  addi $sp,$sp,12

  jr $ra                  # Return

  BaseCase:
  addi $v0,$zero,1        # $v0 ← fibonacci(1)=1

  jr $ra                  # Return

  BaseCase0:
  addi $v0,$zero,0        # $v0 ← fibonacci(0)=0

  jr $ra                  # Return
