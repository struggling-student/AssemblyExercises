.globl main

.data
M: .half 0, 1, 2, 3, 4, 5, 6, 7, 8
N: .byte 3
# M: .half 5, 6, 4, 8, 2, 5, 2, 6, 1, 9, 8, 4, 7, 3, 2, 2
# N: .byte 4

.text
main:
#### Loading
########################
la $a0, M        # $a0: Base address della matrice
lb $a1, N             # $a1: Lato della matrice quadrata

#### Inizializzazione
########################
and $v0, $zero, $zero # Inizializza $v0
xor $v1, $v1, $v1 # Inizializza $v1

#### Run
########################

jal sommaScacchiera

add $a0, $v0, $zero # Carica $v0 come argomento di stampa
addi $v0, $zero, 1  # Imposta stampa intero
syscall             # Stampa

add $a0, $v1, $zero # Carica $v1 come argomento di stampa
syscall

addi $v0, $zero, 10 # Imposta uscita
syscall

#### Funzioni
########################

# Input:
#   $a0: indirizzo base della matrice
#   $a1: lato della matrice
# Output:
#   $v0: somma degli elementi su cella in posizione pari nelle righe pari
#   $v1: somma degli elementi su cella in posizione dispari nelle righe dispari
sommaScacchiera:
  subi $sp, $sp, 8  # Carica stack
  sw $ra,4($sp)
  sw $a2,0($sp)
  
  sub $a2, $a2, $a2 # Inizializza $a2
  
  jal sommaScacchieraRec
  
  lw $a2,0($sp)     # Vuota stack
  lw $ra,4($sp)
  addi $sp, $sp, 8
  
  jr $ra

# Input:
#   $a0: indirizzo base della matrice
#   $a1: lato della matrice
#   $a2: offset in matrice (in half-word)
# Output:
#   $v0: somma degli elementi su cella in posizione pari nelle righe pari
#   $v1: somma degli elementi su cella in posizione dispari nelle righe dispari
sommaScacchieraRec:
  subi $sp, $sp, 8
  sw $ra,4($sp)
  sw $a2,0($sp)
  
  mul $t1, $a1, $a1       # $t1 rappresenta il numero totale di celle in matrice
  bge $a2, $t1, casoBase  # Se si è oltre il limite di celle della matrice, vai al caso base
  
  sll $t2, $a2, 1         # Le celle constano di half-word, quindi salva in $t2 il numero di byte dell’offset corretto
  add $t2, $a0, $t2       # Salva in $t2 l’indirizzo della cella della matrice puntata
  lh  $t0, ($t2)          # Carica da memoria il valore puntato da $t2 in $t0
    
                          # Verifica se ci si trovi in una riga pari o dispari
  div $t3, $a2, $a1       # Dividi l’offset di cella corrente per il lato e salva in $t3: è il numero di riga
  andi $t4, $t3, 0x1      # $t4 vale 1 se e solo se $t3 è dispari (ossia, se siamo in una riga dispari)
  
  bne $t4, $zero, dispari # Siamo in una riga dispari
  
  pari:
    add $v0, $v0, $t0
    j avanzamento
  
  dispari:
    add $v1, $v1, $t0
  
  avanzamento:
    addi $a2, $a2, 2              # Avanza di due celle (default)
                                  # Attenzione: se il lato è pari, al cambio di riga potrebbero esserci scostamenti dall’avanzamento di default
    andi $t5, $a1, 0x1            # $t5 verifica se il lato della matrice sia dispari
    
    bne $t5, $zero, ricorsione    # Se il lato è dispari, siamo in un contesto più semplice: lo scostamento di default vale sempre
                                  # Altrimenti…
    div $t6, $a2, $a1             # Dividi l’offset di cella corrente per il lato e salva in $t6: è il nuovo numero di riga
    beq $t6, $t3, ricorsione      # Se siamo nella stessa riga precedente ($t3), non c’è problema
    
    bne $t4, $zero, nuovaRigaPari # Se eravamo in una riga dispari, la nuova è pari
    
    addi $a2, $a2, 1              # Nel passaggio da riga pari a riga dispari, dobbiamo partire dalla cella successiva (v. esempio sul testo)
    j ricorsione
    
  nuovaRigaPari:
    subi $a2, $a2, 1              # Nel passaggio da riga dispari a riga pari, dobbiamo partire dalla cella precedente (v. esempio sul testo)

  ricorsione:
    jal sommaScacchieraRec      
    
  casoBase:
    lw $a2,0($sp)
    lw $ra,4($sp)
    addi $sp, $sp, 8
  
  jr $ra
