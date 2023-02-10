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
  while:
    beq   $a0, $a1, endWhile # $a0 == $a1 ? End of cycle.

    if:
      bgt  $a0, $a1, thenSub # $a0 > $a1 ?

    elseSwap:                # { # IF NOT, swap parameters
      move $t0, $a0          #     We use $t0 as an auxiliary variable here
      move $a0, $a1
      move $a1, $t0
      j endIf                # } # This could be spared to save a round

    thenSub:                 # { # IF SO, subtract $a1 to $a0
      sub $a0, $a0, $a1
      # j EndIf              # }

    endIf:                   # ENDIF
    j while

  endWhile:
  add $v0, $zero, $a0        # $a0 is the result to return

  jr $ra
