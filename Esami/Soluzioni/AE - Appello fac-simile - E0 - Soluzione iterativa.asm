.globl main

.data
A: .half 0x002A, 0xA5FF, 0x5BE1
L: .byte 3
# Ris.: $v0 = 0x5 = 0000 0000 … 0000 0101
#       $v1 = 0
## Altro test:
# A: .half 0x002A, 0x002B, 0x003B, 0xA5FF, 0x5BE1
# L: .byte 5
## # Ris.: $v0 = 0xA = 0000 0000 … 001 0101
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
  subi $sp, $sp, 20        # Carica stack
  sw   $ra, 16($sp)
  sw   $a3, 12($sp)
  sw   $a2,  8($sp)
  sw   $a0,  4($sp)
  sw   $t7,  0($sp)
  
  and  $v0, $v0, $0        # Inizializza risultato
  add  $t7, $zero, $0      # Counter
  addi $a3, $zero, 16      # Bit di una halfword

  arrayCycle:
    bge  $t7, $a1, parityOfV0 # L’array è scorso? Esci dal ciclo
    lh   $a2, ($a0)       # Carica halfword come argomento per computeParity
    jal  computeParity    # Calcola il parity bit della halfword (restituito in $v1)
    sllv $v1, $v1, $t7    # Sposta il parity bit nella giusta posizione
    or   $v0, $v1, $v0    # Salva il risultato corrente al bit indicato
    addi $t7, $t7, 1      # Aumenta di 1 il contatore
    addi $a0, $a0, 2      # Passa alla halfword successiva nell’array
    j    arrayCycle
  
  parityOfV0:             # Calcola il parity bit della parity word in $v0
    add  $a2, $zero, $v0  # Carica word come argomento per computeParity
    addi $a3, $zero, 32   # Bit di una word (attenzione: L può essere pari fino a 32)
    jal  computeParity    # Calcola il parity bit di $v0 (restituito in $v1)
    
  returnToMain:
    lw   $t7,  0($sp)     # Ricarica valori da stack
    sw   $a0,  4($sp)
    lw   $a2,  8($sp)
    lw   $a3, 12($sp)
    lw   $ra, 16($sp)
    addi $sp, $sp, 20
    jr   $ra              # Ritorna a main


# Input:
#   $a2: la stringa di bit
#   $a3: i-esimo bit da considerare nel calcolo del parity bit di $a2
# Output:
#   $v1: parity bit
computeParity:
  subi $sp, $sp, 12     # Carica stack
  sw   $t7, 8($sp)
  sw   $t2, 4($sp)
  sw   $s2, 0($sp)

  rol  $s2, $a2, 0      # Carica la stringa di bit in $s2 
  add  $v1, $zero, $0   # Inizializza risultato 
  addi $t7, $zero, 0    # Inizializza counter

  sixteenBitsCycle:
    andi $t2, $s2, 1    # Isola lo LSB
    xor  $v1, $v1, $t2  # Aggiorna il parity bit
    addi $t7, $t7, 1    # Aumenta di 1 il contatore
    bge  $t7, $a3, returnParity # Esci dal ciclo se tutti i bit sono scorsi   
    ror  $s2, $s2, 1    # Effettua il roll a destra di 1
    j    sixteenBitsCycle

  returnParity:
    lw   $s2, 0($sp)    # Ricarica valori da stack
    lw   $t2, 4($sp)
    lw   $t7, 8($sp)
    addi $sp, $sp, 12
    jr $ra              # Ritorna a parity
