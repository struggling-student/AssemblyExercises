.globl main
#parte di DATA SEGMENT del programma
.data
	vector: 4, -1, 5, 500
	N: 4
	rez: 0
#parte di TEXT SEGMENT del programma (le istruzioni)
.text
main:
	#allora intanto carichiamo quanto e' grande il vettore
	lw $t0,N # N lo mettiamo in $t0; nota che lw $t0,N indica carica
	 				 # la word all'**indirizzo** specificato da N
	li $t1,1 # $t1 conterra' indice di scorrimento da 1...N compreso
	lw $t2,vector($zero) #t2 intanto contiene il primo elemento e anche il massimo
forloop:
	bge $t1,$t0,endloop #controlliamo subito se dobbiamo uscire dal forloop
	# ricordiamo che memora e' indirizzata al byte i dati sono in word: 1 word = 4 byte
	# questa nota e' importante perche' motiva istruzione successiva
	sll $t3,$t1,2 # moltiplico indice $t1 per 2**2 ogni volta cosi che indice scorre come 4 8 12
	lw $t4,vector($t3) # carico un nuovo dato scostandomi da **indirizzo** di vector + $t3
	bge $t2,$t4,incr # se condizione del massimo non e' violata salto ad incrementare i++
	move $t2,$t4     # se il nuovo valore in $t4 e' maggiore del max corrente,
									 # aggiorno il max e poi incremento
incr:
	addi $t1,$t1,1 #i++
	j forloop # dobbiamo "tornare ad eseguire" il forloop
endloop:
	sw $t2,rez	#alla fine $t2 contiene il massimo, lo salvo all'etichetta di rez
