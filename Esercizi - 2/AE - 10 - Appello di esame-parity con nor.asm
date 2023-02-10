.globl main

.data

M: .half 5, 6, 4, 8, 2, 5, 2, 6, 1, 9, 8, 4, 7, 3, 2, 2  #matrice di 16 elementi, lungo le righe
N: .half 4
#M: .half 0, 1, 2, 3, 4, 5, 6, 7, 8
#N: .half 3 # lato della matrice

.text

main:

la $a0,M #carico M in $a0
lh $a1,N

jal sommaScacchiera

move $s0,$v0
move $s1,$v1

li $v0,1 # print int
move $a0,$s0 # di $a0
syscall # a schermo

li $v0,11 # print char
li $a0,10 #newline
syscall

li $v0,1 # print int
move $a0,$s1 # di $a0
syscall # a schermo

li $v0,10
syscall

sommaScacchiera: # f($a0: address, $a1: int) :($v0, $v1)
#usiamo
# $t0 x
# $t1 y
# M[x,y] = $a0 + ($a1*$t0 + $t1)*2  , ind_base+ 2*( N*x+y) 
# y & 1 = 0 -> pari lo mettiamo in $t3
	li $t0,0
	li $t1,0
	li $t2,0
	li $v0,0
	li $v1,0
	ciclo:
		andi $t3,$t1,1 # 0 se y è pari
		bge $t1,$a1,nextRiga
		mul $t2,$a1,$t0 # N*x
		add $t2,$t2,$t1 # ($a1*$t0 + $t1)
		sll $t2,$t2,1 # per 2
		add $t2,$t2,$a0 # pos mem M[x,y]
		lh $t2,($t2)
		beqz $t3,pari
			add $v1,$v1,$t2 #dispari
			j endIfPari
		pari:
			add $v0,$v0,$t2
		endIfPari:
		add $t1,$t1,2
		j ciclo
	nextRiga:
		add $t0,$t0,1
		bge $t0,$a1,fineCiclo
		nor $t3,$zero,$t3 #switch $t3
		andi $t3,$t3,1
		move $t1,$t3 # colonne pari
		j ciclo	
	
	fineCiclo:
	
	jr $ra

