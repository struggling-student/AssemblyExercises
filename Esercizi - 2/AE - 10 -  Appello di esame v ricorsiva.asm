.globl main

.data
# M: .half 0, 1, 2, 3, 4, 5, 6, 7, 8
# N: .byte 3
M: .half 5, 6, 4, 8, 2, 5, 2, 6, 1, 9, 8, 4, 7, 3, 2, 2
N: .byte 4

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
  subi $sp, $sp, 4   # Carica stack
  sw $ra,0($sp)
  #sw $a3,4($sp)
  #sw $a2,0($sp)
  
  sub $a2, $a2, $a2   # Inizializza $a2  
  add $a3, $a2, $zero # Inizializza $a3
  
  jal sommaScacchieraRec
  
#  lw $a2,0($sp)       # Vuota stack
#  lw $a3,4($sp)
  lw $ra,0($sp)
  addi $sp, $sp, 4
  
  jr $ra

# Input:
#   $a0: indirizzo base della matrice
#   $a1: lato della matrice
#   $a2: numero di riga
#   $a3: numero di colonna
# Output:
#   $v0: somma degli elementi su cella in posizione pari nelle righe pari
#   $v1: somma degli elementi su cella in posizione dispari nelle righe dispari
sommaScacchieraRec:
  subi $sp, $sp, 12
  sw $ra,8($sp)
  sw $a3,4($sp)
  sw $a2,0($sp)
  
  bge $a2, $a1, casoBase   # Se siamo oltre i limiti della matrice, vai al caso base
  
  mul $t1, $a2, $a1        # $t1 è l’indirizzo in memoria della cella puntata
  add $t1, $t1, $a3
  sll $t1, $t1, 1          # Ogni cella consta di una half word, quindi 2 byte
  add $t1, $a0, $t1
  
  lh  $t0, ($t1)           # $t0 è il valore da aggiungere
  
  andi $t3, $a2, 0x1       # Siamo in una riga dispari? Se sì, $t3 vale 1.
  bne $t3, $zero, dispari
  
  add $v0, $v0, $t0        # In una riga pari, aggiungiamo $t0 a $v0
  j avanzamento
  
  dispari:
    add $v1, $v1, $t0      # In una riga dispari, aggiungiamo $t0 a $v1
  
  avanzamento:
    add $a3, $a3, 2           # Per default, avanziamo di due celle
    blt $a3, $a1, ricorsione  # Se siamo nei margini di riga, proseguiamo con la ricorsione
                              # Altrimenti…
    addi $a2, $a2, 1          # Aggiorniamo il numero di riga
    andi $t5, $a2, 0x1        # La nuova riga è dispari?
    beq  $t5, $zero, avanzaRigaPari      
    addi $a3, $zero, 1        # In una riga dispari, si riparte dall’indice 1 di colonna
    j ricorsione
      
    avanzaRigaPari:
      add $a3, $zero, $zero   # In una riga pari, si riparte dall’indice 0 di colonna

  ricorsione:
    jal sommaScacchieraRec
  
  casoBase:
    lw $a2,0($sp)
    lw $a3,4($sp)
    lw $ra,8($sp)
    addi $sp, $sp, 12
  
  jr $ra
