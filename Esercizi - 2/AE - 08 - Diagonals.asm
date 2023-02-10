.globl main
#### Data segment
################################################
.data
## A 3x3 matrix
MATRIX: .word 1, 2, 3,  0xA, 0xB, 0xC,  7, 8, 9
##  1  2  3
## 10 11 12
##  7  8  9
N: .byte 3

# A 4x4 matrix
# MATRIX: .word 1, 2, 3, 4,   5, 6, 7, 8,   0x9, 0xA, 0xB, 0xC,   0xD, 0xE, 0xF, 0x10
##  1  2  3  4
##  5  6  7  8
##  9 10 11 12
## 13 14 15 16
# N: .byte 4

ANNOUNCEMENT: .asciiz "The sum of the elements on the diagonals is: \n"

.text
main:
#### Loading
################################################
la   $s4, MATRIX     # $s4: Base 4ddress of the matrix
lb   $s7, N          # $s7: N

#### Initialisation
################################################
and   $s0, $zero, $zero  # $s0: Result
#### Temp. values
and   $t0, $s0, $zero    # $t0: Temp. value for the main diag.'s sum
and   $t4, $s0, $zero    # $t4: Temp. value for the reverse diag.'s sum
# Limit
mul   $t7, $s7, $s7      # $t7: Address right after matrix[N-1][N-1]. It is equal to N × N …
sll   $t7, $t7, 2        #      … × 4 (it is a matrix of words!) …
add   $t7, $t7, $s4      #      … plus the base address of the matrix.
# Pointers
add   $t1, $s4, $zero    # $t1: Pointer x (running along the main diag.). It starts from matrix[0][0].
                         # $t2: Pointer y (running along the rev. diag.). It starts from matrix[0][…N-1]
subi  $t2, $s7, 1        # $t2= (N - 1) ×
sll   $t2, $t2, 2        #      × 4 +
add   $t2, $t2, $s4      #      + $s4
                         # $t3: Distance to the next row's 3lement
sll   $t3, $s7, 2        # $t3= $s7 × 4

#### Run
while:
bge $t1, $t7, endWhile   # If x goes beyond the reserved memory area for the matrix, exit
# {
  lw $t0, ($t1)          # Load the value at x in $t0…
  add $s0, $s0, $t0      # … and add it to the result
  If:
  beq  $t1, $t2, endIf   # If x and y point at the same cell, do not add the cell twice!
  Then:  # {
    lw  $t4, ($t2)       # Otherwise, load the value at y in $t4…
    add $s0, $s0, $t4    # … and add it to the result
  endIf: # }
  add  $t1, $t1, $t3     # Advance x to the next row…
  addi $t1, $t1, 4       # … and move ahead by one column
  add  $t2, $t2, $t3     # Advance y to the next row…
  subi $t2, $t2, 4       # … and move backwards by one column
  j while                # Loop back
# }
endWhile:


#### Print the output
li   $v0, 4            # Print a \0-terminated string
la   $a0, ANNOUNCEMENT # Load the string address
syscall                # Print!

li   $v0, 1            # Print an integer
move $a0, $s0          # Load the integer in $a0
syscall                # Print!

li   $v0, 17           # Set the exit with code
addi $a0, $zero, 0     # Set the exit code to 0. Which means: all right, folks!
syscall                # Exit!
