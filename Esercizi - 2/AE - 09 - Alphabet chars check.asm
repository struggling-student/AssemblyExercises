.globl main

.data
character: .ascii "z"

.text
main:
lhu $a0,character

jal CheckAlph

move $a0,$v0
li $v0,1
syscall

li $v0,10
syscall


CheckAlph:
  and $v0,$v0,$zero             # By default, we assume the half-word NOT to be a
                                #   a character of the standard alphabet
  CkeckUppercase:
  slti $t0,$a0,0x41             # 0x41 is 'A'
  bgt $t0,$zero,ExitNOK         # If $a0 is less than 0x41, it is not an alph. letter
  slti $t0,$a0,0x5B             # 0x5A is 'Z'
  beq $t0,$zero,CheckLowercase  # If $a0 is higher than 0x5A, it could be a lowercase alph. letter
  j ExitOK                      # If 0x41 <= $a0 <= 0x5A, it is an uppercase alph. letter

  CheckLowercase:
  slti $t0,$a0,0x61             # 0x61 is 'a'
  bgt $t0,$zero,ExitNOK         # If $a0 is less than 0x61 but higher than 0x5A, it is no alph. letter
  slti $t0,$a0,0x7B             # 0x7A is 'z'
  beq $t0,$zero,ExitNOK         # If $a0 is higher than 0x7A, it is no alph. letter
  j ExitOK                      # If 0x61 <= $a0 <= 0x7A, it is a lowercase alph. letter

  ExitOK:
  li $v0,1                      # $a0 is an alph. letter
  ExitNOK:
  jr $ra
