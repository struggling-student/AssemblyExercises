.globl main

.data
A: .half 0x002A, 0xA5FF, 0x5BE1
L: .byte 3
# Ris.: $v0 = 0x5 = 0000 0000 … 0000 0101
#       $v1 = 0
## Altro test:
## A: .half 0x002A, 0x002B, 0x003B, 0xA5FF, 0x5BE1
## L: .byte 5
## # Ris.: $v0 = 0xA = 0000 0000 … 0001 0101
## #       $v1 = 1

.text
main: 
#### Loading
########################
la   $a0, A         # Array di half-word
lb   $a1, L         # Lunghezza dell’array

#### Inizializzazione
########################
add $v0, $zero, $zero
sub $v1, $v0, $v0

#### Run
########################
jal parity

add  $a0, $v0, $zero  # Carica la stringa di bit per la stampa
addi $v0, $zero, 35   # Imposta stampa stringa di bit
syscall               # Stampa
  
addi $v0, $zero, 10   # Imposta uscita
syscall

#### Funzioni
########################

# Input:
#   $a0: indirizzo base dell’array di halfword
#   $a1: lunghezza dell’array in $a0
# Output:
#   $v0: risultato del calcolo della parity word per l’array in $a0
#   $v1: parity bit della parity word
parity:
  subi $sp, $sp, 16        # Carica stack
  sw   $ra, 12($sp)
  sw   $a3,  8($sp)
  sw   $a2,  4($sp)
  sw   $a1,  0($sp)

  addi $a3, $zero, 15     # Indice dell’ultimo bit di una halfword
  and  $v0, $v0, $0       # Inizializza risultato
  subi $a1, $a1, 1        # Trasformiamo $a1 nell’offset per la chiamata ricorsiva
  
  jal  parityRec
  
  parityOfV0:             # Calcola il parity bit della parity word in $v0
    add  $a2, $zero, $v0  # Carica word come argomento per computeParity
    addi $a3, $zero, 31   # Indice dell’ultimo bit di una word (attenzione: L può essere pari fino a 32)
    add  $v1, $zero, $0    # Inizializza risultato di computeParityRec
    jal  computeParityRec # Calcola il parity bit di $v0 (restituito in $v1)
  
  returnToMain:
    lw   $a1,  0($sp)     # Ricarica vaori da stack
    lw   $a2,  4($sp)
    lw   $a3,  8($sp)
    lw   $ra, 12($sp)  
    addi $sp, $sp, 16
    jr $ra                # Ritorna al main


# Input:
#   $a0: indirizzo base dell’array di halfword
#   $a1: offset dell’array puntato da $a0
# Output:
#   $v0: risultato del calcolo della parity word per l’array in $a0
parityRec:
  subi $sp, $sp, 24     # Carica stack
  sw   $ra, 20($sp)
  sw   $v1, 16($sp)
  sw   $a2,  8($sp)
  sw   $a1,  4($sp)
  sw   $t2,  0($sp)

  bltz $a1, baseCase    # L’array è scorso? Esci dalla ricorsione

  or   $t2, $zero, $a1  # Puntatore alla $a1-esima halfword puntata da $a0
  sll  $t2, $t2, 1      # L’offset deve valere per le halfword
  add  $t2, $t2, $a0    # Trasforma $t2 nell’indirizzo $a0 + ($a1 × 2)
  lh   $a2, ($t2)       # Carica halfword come argomento per computeParity
  add  $v1, $zero, $0    # Inizializza risultato di computeParityRec
  jal  computeParityRec # Calcola il parity bit della halfword (restituito in $v1)
  sllv $v1, $v1, $a1    # Sposta il parity bit nella giusta posizione
  or   $v0, $v1, $v0    # Salva il risultato corrente al bit indicato
  subi $a1, $a1, 1      # Passa all’elemento precedente nell’array
  jal  parityRec
    
  baseCase:
    lw   $t2,  0($sp)   # Ricarica vaori da stack
    lw   $a1,  4($sp)
    lw   $a2,  8($sp)
    lw   $v1, 16($sp)
    lw   $ra, 20($sp)
    addi $sp, $sp, 24
    jr   $ra            # Ritorna alla funzione parity


# Input:
#   $a2: la stringa di bit
#   $a3: i-esimo bit da considerare nel calcolo del parity bit di $a2
# Output:
#   $v1: parity bit
computeParityRec:
  subi $sp, $sp, 16      # Carica stack
  sw   $ra, 12($sp)  
  sw   $a3,  8($sp)
  sw   $t2,  4($sp)
  sw   $s2,  0($sp)

  bltz $a3, returnParity # L’array è scorso? Esci dalla ricorsione
    
  rol  $s2, $a2, 0       # Carica la stringa di bit in $s2
  ror  $s2, $s2, $a3     # Effettua il roll a destra di $a3 posizioni
  andi $t2, $s2, 1       # Isola lo LSB
  xor  $v1, $v1, $t2     # Aggiorna il parity bit
  subi $a3, $a3, 1       # Diminuisci di 1 il contatore/bit-offset 
  jal  computeParityRec

  returnParity:
    lw   $s2,  0($sp)     # Ricarica vaori da stack
    lw   $t2,  4($sp)
    lw   $a3,  8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra               # Ritorna a parityRec
