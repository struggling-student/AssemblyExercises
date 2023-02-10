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
# ricordiamo che l'elemento è a $a0 + ((N*x) + y) *2
li $t0,0
li $t1,0

	ciclo:
		andi $t3,$t1,1 #controllo parità
		bge $t1,$a1,nuovaRiga
		mul $t2,$a1,$t0 # N*x
		add $t2,$t2,$t1 # N*x + y
		sll $t2,$t2,1
		add $t2,$t2,$a0
		
		lh $t4,($t2)
		beqz $t3,colonnaPari
		colonnaDispari:
			add $v1,$v1,$t4
			j endIfcolonnaPari
		colonnaPari:
			add $v0,$v0,$t4
		endIfcolonnaPari:
		addi $t1,$t1,2
		j ciclo
		
		nuovaRiga:
			addi $t0,$t0,1
			bge $t0,$a1,fineCiclo
			beqz $t3,rigaPari
			rigaDispari:
				li $t1,0				
				j endIfrigaPari
			rigaPari: #la prossima è dispari
				li $t1,1
			endIfrigaPari:
			j ciclo
	fineCiclo:
	jr $ra