.globl main

.data
A: .word 420
B: .word 93

.text
main:
lw $a0, A
lw $a1, B

jal GCD

move $a0, $v0
li   $v0, 1
syscall

addi $v0,$zero,10
syscall

GCD:
  beq $a0, $a1, baseCase     # $a0 == $a1 ? Base case

  recursiveStep:
    subi $sp,$sp,12
    sw   $ra, 8($sp)
    sw   $a1, 4($sp)
    sw   $a0, 0($sp)

    if:
      bgt  $a0, $a1, thenSub # $a0 > $a1 ?

    elseSwap:                # { # IF NOT, swap parameters
      move $t0, $a0          #     We use $t0 as an auxiliary variable here
      move $a0, $a1
      move $a1, $t0
      j endIf                # }

    thenSub:                 # { # IF SO, subtract $a1 to $a0
      sub  $a0, $a0, $a1
      # j EndIf              # }

    endIf:                   # ENDIF
      jal GCD                # Do the recursive call

    restoreAndJumpBack:
      lw  $a0, 0($sp)
      lw  $a1, 4($sp)
      lw  $ra, 8($sp)
      addi $sp, $sp, 12

      jr $ra

  baseCase:
    add $v0, $zero, $a0      # $a0 is the result to return

    jr $ra
