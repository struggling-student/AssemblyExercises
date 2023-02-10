.globl main

# Esempi:
# a) Input: $a0 è l’indirizzo in memoria di M definito come di seguito, con lunghezza $a1 che vale N = 5
# 1, 1 , 4, 2, 2
# Output: $v0 vale 1 + 2 = 3; $v1 vale 2.
# b) Input: $a0 è l’indirizzo in memoria di M definito come di seguito, con lunghezza $a1 che vale N = 7
# 0, 6, 7, 8, 8 , 8 , 6
# Output: $v0 vale 8 + 8 = 16; $v1 vale 2.

.data
M: .word 1, 1, 4, 2, 2
N: .word 5
## Ris.: $v0 = 1 + 2 = 3; $v1 = 2
# M: .word 0, 6, 7, 8, 8, 8, 6
# N: .word 7
## Ris.: $v0 = 8 + 8 = 16; $v1 = 2

.text
main: 
#### Caricamento
########################
la   $a0, M         # Array
lw   $a1, N         # Lunghezza dell’array

#### Inizializzazione
########################
add $v0, $zero, $zero
and $v1, $v0, $v0

#### Run
########################
jal sommaContaUgualiPrec

add  $a0, $v0, $zero  # Carica l’intero per la stampa (somma valori uguali al precedente)
addi $v0, $zero, 1    # Imposta stampa intero 
syscall               # Stampa

add  $a0, $0, '\n'    # Carica il carattere di invio a capo
addi $v0, $zero, 11   # Imposta stampa carattere 
syscall               # Stampa


add  $a0, $v1, $zero  # Carica l’intero per la stampa (conto valori uguali al precedente)
addi $v0, $zero, 1    # Imposta stampa intero 
syscall               # Stampa

addi $v0, $zero, 10 # Imposta uscita
syscall

#### Funzioni
########################

# Input:
#   $a0: indirizzo base dell’array
#   $a1: lunghezza dell’array
# Output:
#   $v0: somma degli elementi di valore uguale all’elemento precedente nell’array;
#   $v1: conteggio degli elementi di valore uguale all’elemento precedente dell’array
sommaContaUgualiPrec:
  subi $sp, $sp, 4    # Carica stack
  sw   $a2, 0($sp)    # $a2: puntatore in memoria all’elemento dell’array corrente
  
  or   $t0, $0, $0    # $t0: valore dell’elemento dell’array c0rrente ($tC0rrente)
  and  $t3, $t3, $0   # $t3: valore dell’elemento dell’array pre3cedente ($tPr3c) 
  
  sll  $a2, $a1, 2    # $a2 ← N × 4
  add  $a2, $a2, $a0  #       + $a0 # essendo l’array di lunghezza minima due, partiamo da M[1]
  
  while: # {
    ble $a2, $a0, endWhile # while ($a2 > $a0) {
    lw $t0, ($a2)          #   $t0 ← valore dell’elemento puntata da $a2
    lw $t3, -4($a2)        #   $t3 ← valore dell’elemento precedente a quella puntata da $a2
    if:
      bne $t0, $t3, endIf  #   if ($t0 == $t3) {
      add $v0, $v0, $t3    #     $v0 ← $v0 + $t3
      addi $v1, $v1, 1     #     $v1 ← $v1 + 1
    endIf:                 #   }
      subi $a2, $a2, 4     #   $a2 ← $a2 decrementato per puntare all’elemento precedente
      j while              # }
  endWhile: 

  lw   $a2, 0($sp)   # Ricarica vaori da stack
  addi $sp, $sp, 4

  jr   $ra           # Ritorna a main  
