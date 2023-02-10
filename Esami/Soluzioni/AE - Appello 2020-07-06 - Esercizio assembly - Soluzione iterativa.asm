.globl main

.data
# M: .half 0, 1, 2,   3, 4, 5,   6, 7, 8
# N: .byte 3
M: .half 5, 6, 4, 8,   2, 5, 2, 6,   1, 9, 8, 4,   7, 3, 2, 2
N: .byte 4

.text
main:
#### Caricamento
########################
la $a0, M             # $a0: Indirizzo base della matrice quadrata
lb $a1, N             # $a1: Lato della matrice quadrata

#### Inizializzazione
########################
and $v0, $zero, $zero # Inizializza $v0
xor $v1, $v1, $v1     # Inizializza $v1

#### Run
########################

jal sommaScacchiera

add  $a0, $v0, $zero  # Carica $v0 come argomento di stampa
addi $v0, $zero, 1    # Imposta stampa intero
syscall               # Stampa

li   $a0, '\n'        # Carica '\n' come argomento di stampa
addi $v0, $zero, 11   # Imposta stampa carattere
syscall               # Stampa

add  $a0, $v1, $zero  # Carica $v1 come argomento di stampa
addi $v0, $zero, 1    # Imposta stampa intero
syscall               # Stampa

addi $v0, $zero, 10   # Imposta uscita
syscall

#### Funzioni
########################

# Input:
#   $a0: indirizzo base della matrice quadrata
#   $a1: lato della matrice
# Output:
#   $v0: somma degli elementi su cella in posizione pari nelle righe pari
#   $v1: somma degli elementi su cella in posizione dispari nelle righe dispari
sommaScacchiera:
  subi $sp, $sp, 8            # Carica stack
  sw   $a3, 4($sp)
  sw   $a2, 0($sp)
  
  sub  $a2, $a2, $a2          # $a2: numero di riga
  add  $a3, $a2, $zero        # $a3: numero di colonna
  # Altre variabili temp.     # $t1: l’1ndirizzo in memoria della cella puntata ($t1ndice)
                              # $t4: il valore da 4ggiungere ($t4ddendo)
                              # $t5: vale 1 se un operando è di5pari ($tDi5pari)
  while:
    bge  $a2, $a1, endWhile   # Se siamo oltre i limiti della matrice, esci
  
    mul  $t1, $a2, $a1        # $t1: l’1ndirizzo in memoria della cella puntata
    add  $t1, $t1, $a3        # $t1= y·N + x = $a1·$a2 + $a3
    sll  $t1, $t1, 1          # Ogni cella consta di una half word, quindi 2 byte
    add  $t1, $a0, $t1
  
    lh   $t4, ($t1)           # $t4: il valore da 4ggiungere
  
    andi $t5, $a2, 0x1        # Siamo in una riga di5pari? Se sì, $t5 vale 1.
    bne  $t5, $zero, dispari
  
    add $v0, $v0, $t4         # In una riga pari, aggiungiamo $t4 a $v0
    j avanza
  
    dispari:
      add $v1, $v1, $t4       # In una riga dispari, aggiungiamo $t4 a $v1
  
    avanza:
      add  $a3, $a3, 2        # Per default, avanziamo di due celle
      blt  $a3, $a1, while    # Se siamo nei margini di riga, torniamo al ciclo
                              # Altrimenti…
      addi $a2, $a2, 1        # Aggiorniamo il numero di riga
      andi $t5, $a2, 0x1      # La nuova riga è dispari? Se sì, $t5 vale 1.
      beqz $t5, avanzaPari      
      addi $a3, $zero, 1      # In una riga dispari, si riparte dall’indice 1 di colonna
      j while
      
      avanzaPari:
        add $a3, $zero, $zero  # In una riga pari, si riparte dall’indice 0 di colonna
        j while
  
  endWhile:
    lw   $a2, 0($sp)           # Vuota stack
    lw   $a3, 4($sp)
    addi $sp, $sp, 8
    
    jr $ra
