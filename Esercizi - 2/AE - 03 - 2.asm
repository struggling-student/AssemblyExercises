.globl main

.data
	vector: .word 1, -2, 3, -4, 5, -6, 7, -8, 9, 10, 11, 12
	n: .word 5


.text
main:
	la $s5, vector # registro base di vector in $5. Errore comune la vs lw
	la $s6, n # registro base della variabile n
	lw  $t0,24($s5) # $t0 = vector[6] (7)
	lw  $t1,($s6) # lw  $t1,0($s6) (5)

	add $t0,$t1,$t0
	sw  $t0,48($s5)

