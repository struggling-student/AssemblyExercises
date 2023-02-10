.data
################################################################
# Declaration of constants and variables in memory
################################################################
Array: .word 4, -1, 5, 500, 0, 10000, -256
N:     .word 7
#Array: .word 1, 2, 2, 4
#N:     .word 4
Sums:  .word 0, 0

.text
################################################################
# Initialisation and loading
################################################################
and  $t1, $t1, $zero # $t1: cursor 1ndex for the Array
add  $t2, $zero, $0  # $t2: temporary value loaded from Array[$t1]
addi $t3, $zero, 0   # $t3: a flag for 3ven elements
li   $t5, 0          # $t5: off5et
andi $s3, $s3, 0     # $s3: sum of 3ven elements in Array
xor  $s0, $s0, $s0   # $s0: sum of 0dd elements in Array

lw   $s7, N          # $s7: the length of Array ($s7 ← N)

################################################################
# Core business
################################################################
while:
  bge  $t1, $s7, whileEnd  # Exit the cycle if the cursor goes beyond the length of Array
# {
  nor  $t3, $t3, $0        # Switch the flag. When $t1 == 0, $t3 ← 11…1. When $t0 == 1, $t3 ← 00…0
  sll  $t5, $t1, 2         # offset = index × 4
  lw   $t2, Array($t5)     # load array value at Base + offset (indexed absolute)
  if:
    bnez $t3, else         # Is $t3 != 0 ?
  then:                    # If not, $t2 contains a value at an odd index
    add  $s0, $s0, $t2     # Add the content of Array[$t1] to $s0 (0dd)
    j    endIf             # Exit the if-then-else block
  else:                    # If $t2 contains a value at an even index
    add  $s3, $s3, $t2     # Add the content of Array[$t1] to $s3 (3ven)
  endIf:
    addi $t1, $t1, 1       # Increase the index

  j while
# }
whileEnd:
# Store the results in Sums
sw $s3, Sums     # Store the sum of 3even elements is Sums[0]
sw $s0, Sums+4   # Store the sum of 0dd elements is Sums[1] (again, remember we are considering 4-byte words)
