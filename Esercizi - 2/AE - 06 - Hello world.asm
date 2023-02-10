.globl hello

.data
string: .asciiz "Hello World!" #try with \n
number: .byte 0x02 

.text
hello:
li $v0, 4
la $a0, string
syscall

li $v0, 1
lb $a0, number
syscall

li $v0, 10
syscall #important for when we have multiple procedures in the file
        # and we want a real exit here
