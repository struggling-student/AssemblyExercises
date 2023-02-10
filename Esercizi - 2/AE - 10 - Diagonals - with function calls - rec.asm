.globl main
#### Data segment
################################################
.data
## A 3x3 matrix
# MATRIX: .word 1, 2, 3,  0xA, 0xB, 0xC,  7, 8, 9
##  1  2  3
## 10 11 12
##  7  8  9
# N: .byte 3

# A 4x4 matrix
MATRIX: .word 1, 2, 3, 4,   5, 6, 7, 8,   0x9, 0xA, 0xB, 0xC,   0xD, 0xE, 0xF, 0x10
##  1  2  3  4
##  5  6  7  8
##  9 10 11 12
## 13 14 15 16
N: .byte 4

ANNOUNCEMENT: .asciiz "The sum of the elements on the diagonals is: \n"

.text
main:
#### Loading
################################################
la   $a0, MATRIX       # $a0: Address of MATRIX[0][0]
lb   $a1, N            # $a1: N

#### Initialisation
################################################
li    $a2, 0           # Sum along the main diagonal
li    $a3, 1           # Include the element at the centre

#### Run
################################################
jal   sum_diagonal    # Invoke sum_diagonal
move  $s0, $v0        # Store the result

#### Initialisation
################################################
li   $a2, 1            # Sum along the secondary diagonal
li   $a3, 0            # Do not the element at the centre

#### Run
################################################
jal  sum_diagonal      # Invoke sum_diagonal
add  $s0, $s0, $v0     # Store the result

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


# sum_diagonal($a0: address, $a1: int, $a2: bool, $a3: bool): ($v0: int)
#   $a0: base address of the N×N matrix
#   $a1: N
#   $a2: 0 if the sum of values on the main diagonal is requested; 1 otherwise
#   $a3: 1 if the inclusion of the value at the centre of the matrix is requested; 0 otherwise
#   $v0: the value of the sum
sum_diagonal:               # WRAPPER function
  subi $sp, $sp, 20
  sw   $ra, 16($sp)
  sw   $a3, 12($sp)
  sw   $a2,  8($sp)
  sw   $a1,  4($sp)
  sw   $a0,  0($sp)
  
  move $v0, $a1             # Let us use $v0 as a temporary variable for the next-row offset
  sll  $v0, $v0, 2          # … in the matrix of words. Useful for the leap factor and start addr.
  
  # Centre check
  bgtz $a3, noCentrChk      # $a3: The address of the element at the centre of the matrix
    mul $a3, $a1, $a1       # $a3= N × N …
    srl $a3, $a3, 1         #      … / 2 
    sll $a3, $a3, 2         # Elements are words though, so $a3 ← $a3 × 4
    add $a3, $a3, $a0       #      + $a0 (base address)
    j continue
  noCentrChk:               # If we do not want to avoid central elements in the sum…
    move $a3, $zero         # … let $a3 point beyond the limits of the matrix
  continue:
  
  # Limit
  mul   $a1, $a1, $a1       # $a1: Address right after MATRIX[N-1][N-1]. It is equal to N × N …
  sll   $a1, $a1, 2         #      … × 4 (it is a matrix of words!) …
  add   $a1, $a1, $a0       #      … plus the base address of the matrix.
  beqz  $a2, limitSet       # Notice: if we are running on the secondary diagonal…
  setLimitForSecDg:         # … the latest increment would end on MATRIX[N-1][N-1]. Undersirable!
    subi $a1, $a1, 4        # So decrement the limit by 4.
  limitSet:
  
  # Starting address
  beqz $a2, startAddrSet
  setStartAddrSecDg:
    add  $a0, $a0, $v0      # $a0= MATRIX[0][N
    subi $a0, $a0, 4        #      -1]
  startAddrSet:

  # Leap factor
  beqz  $a2, setMainDgDist  # $a2: Leap factor to jump on the next element in the diagonal
  setSecDgDist:             # If we run over the secondary diagonal…
    move $a2, $v0           #   $a2= N × 4…
    subi $a2, $a2, 4        #      … - 4 # i.e., $a2 = (N - 1) × 4
    j dgDistSet
  setMainDgDist:            # If we run over the main diagonal… 
    move $a2, $v0           #   $a2= N × 4…
    addi $a2, $a2, 4        #      … + 4 # i.e., $a2 = (N - 1) × 4
  dgDistSet:

  andi $v0, $zero, 0        # Restoring $v0 to its role of result
  
  jal sum_diagonal_rec
  
  lw   $ra, 16($sp)
  lw   $a3, 12($sp)
  lw   $a2,  8($sp)
  lw   $a1,  4($sp)
  lw   $a0,  0($sp)
  addi $sp, $sp, 20
  
  jr   $ra


# sum_diagonal_rec($a0: address, $a1: address, $a2: int, $a3: address): ($v0: int)
#   $a0: pointer to the starting address
#   $a1: limit to the pointer's advancement
#   $a2: offset to move to the next element in the diagonal
#   $a3: address of the central element in the matrix
#   $v0: the value of the sum
sum_diagonal_rec:
  subi $sp, $sp, 8
  sw   $ra, 4($sp)
  sw   $a0, 0($sp)

  bge $a0, $a1, exit_rec    # If x goes beyond the reserved memory area for the matrix, exit
  if:      
    beq $a0, $a3, endIf     # If x points at the matrix centre we want to skip, then skip it
  then:  # {                # Otherwise…
    lw $t0, ($a0)           # … load the value at x in $t0…
    add $v0, $v0, $t0       # … and add it to the result
  endIf: # }
  add  $a0, $a0, $a2        # Advance x to the next element in the diagonal
  jal sum_diagonal_rec      # Recur!
  
  exit_rec:

  lw   $a0, 0($sp)
  lw   $ra, 4($sp)
  addi $sp, $sp, 8
  
  jr   $ra
