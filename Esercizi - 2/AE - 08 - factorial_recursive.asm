.data

N: .word 5
rez: .word 0

.text

lw $a0,N
jal factorial

sw $v0,rez # save result

li $v0,10 #exit
syscall

factorial: # factorial($a0: int) : ($v0: int) return the factorial of $a0
	beqz $a0,BaseCase
	
	RecursiveStep:
		subi $sp,$sp,8
		sw $ra,0($sp)
		sw $a0,4($sp)
		
		subi $a0,$a0,1
		jal factorial
		
		lw $a0,4($sp)
		lw $ra,0($sp)
		addi $sp,$sp,8
		
		mul $v0,$v0,$a0

		jr $ra

BaseCase:
	li $v0,1 # 0! is 1 by definition
	jr $ra	