# factorial N!

.data

N: .word 5
rez: .word 0

.text

lw $a0,N
jal factorial
li $v0, 10
syscall

factorial:
subi $sp,$sp,4
sw $a0,0($sp)

li $v0,1 # neutro per la moltiplicazione

While:
	beqz $a0,EndWhile
	mul $v0,$v0,$a0
	sub $a0,$a0,1
	j While
	
EndWhile:
sw $v0,rez

lw $a0,0($sp)
addi $sp,$sp,4 
jr $ra

