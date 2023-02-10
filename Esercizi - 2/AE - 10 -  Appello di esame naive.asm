.globl main

.data
M: .half 5, 6, 4, 8, 2, 5, 2, 6, 1, 9, 8, 4, 7, 3, 2, 2  #matrice di 16 elementi, lungo le righe
N: .half 4 # lato della matrice

.text

main:
la $a0, M # carico l'indirizzo base della matrice
lh $a1, N # carico il lato della matrice

jal sommaScacchiera # chiama funzione principale f($a0: address, $a1: int) : ($v0: int, $v1: int)


move $s0, $v0 # sposto $v0 perché mi servirà per stampare a schermo
move $s1, $v1 # sposto $v1 

move $a0, $s0 # print a schermo 
li $v0, 1
syscall

li $a0, 10 # char newline
li $v0, 11 # print char
syscall

move $a0, $s1 # print a schermo
li $v0, 1
syscall

li $v0, 10 # esco
syscall


sommaScacchiera: #f($a0: address, $a1: int) : ($v0: int, $v1: int)
# usiamo 
# $t0 x
# $t1 y
# ricordiamo che M[x,y] = $a0 + (N*x + y) * 2
#subi $sp,$sp,? # * fix later
subi $sp,$sp,4
sw $ra,($sp)

# somma pari, cominciamo da x=y=0 e saltiamo una colonna per volta e una riga ogni volta
li $t0,0
li $t1,0
li $t4,0
jal CicloPari
move $t5,$v0

li $t0,1
li $t1,1
li $t4,1
li $v0,0
jal CicloPari
move $v1,$v0
move $v0,$t5
lw $ra,($sp)
addi $sp,$sp,4
jr $ra

CicloPari:
bge $t1,$a1,nextRigaPari
move $t2,$t1 # y
mul $t3,$t0,$a1 # N*x
add $t2,$t2,$t3 # (N*x + y)
sll $t2,$t2,1 #(N*x + y) * 2
add $t2,$t2,$a0  #$a0 + (N*x + y) * 2

lh $t3,($t2)
add $v0,$v0,$t3
add $t1,$t1,2
j CicloPari


nextRigaPari:
add $t0,$t0,2
move $t1,$t4
bge $t0,$a1,finePari
j CicloPari

finePari:
jr $ra

