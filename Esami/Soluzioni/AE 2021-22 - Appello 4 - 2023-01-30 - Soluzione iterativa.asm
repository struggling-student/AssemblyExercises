##########################################
# INSERIRE I PROPRI DATI QUI
# Nome:
# Cognome:
# Matricola:
##########################################

# NON MODIFICARE IL CODICE DA QUI...
.data
    buffer: .space 26
    output: .byte  0,0,0,0,0,0,0,0,0  # Un carattere extra per la fine della stringa

.text

main:
    li $v0, 8       # Codice per input stringa
    la $a0, buffer  # Carica indirizzo base in $a0
    li $a1, 26      # Alloca al massimo 24 caratteri + \n + \0
    syscall         # $a0 contiene l'indirizzo base della stringa
    la $a2, output
# ... A QUI

##########################################
## INSERIRE IL PROPRIO CODICE QUI

#### Inizializzazione
########################
add $v0, $zero, $zero
add $v1, $zero, $zero

#### Run
########################
jal codificaOttale

add  $t0, $0, $v0     # Salva il valore di $v0 per dopo

addi $v0, $zero, 4    # Imposta stampa stringa
add  $a0, $a2, $zero  # Carica il risultato per la stampa
syscall               # Stampa

li $a0, '\n'
li $v0, 11            # Imposta stampa carattere
syscall               # Stampa

add  $a0, $t0, $zero  # Carica il risultato per la stampa
li   $v0, 1           # Imposta stampa intero
syscall               # Stampa

li $a0, '\n'
li $v0, 11            # Imposta stampa carattere
syscall               # Stampa

add  $a0, $v1, $zero  # Carica il risultato per la stampa
addi $v0, $zero, 1    # Imposta stampa intero
syscall               # Stampa


addi $v0, $zero, 10   # Imposta uscita
syscall

#### Funzioni
########################

# Input:
#   $a0: indirizzo base della stringa di input
#   $a2: indirizzo base della stringa di output
# Output:
#   $v0: 0 se tutta la stringa di input è stata tradotta; altrimenti, 1
#   $v1: numero di caratteri nella stringa ottale prodotta
codificaOttale:
  addi $sp, $sp, -4
  sw   $a2, 0($sp)
  
  li   $t7, 0                     # Inizializza la somma temporanea

  cycle:
    addi $v0, $0, 0               # Se la stringa finisce qui, tutti i caratteri sono stati trasposti
    lb   $t2, ($a0)               # Carica primo carattere
    beq  $t2, '\n', returnToMain  # È il carattere '\n'? Esci
    sub  $t2, $t2, 0x30           # Trasformalo in intero (da ASCII)
    sll  $t2, $t2, 2              # Moltiplicalo per 4              
    add  $t7, $t7, $t2            # Aggiungi alla somma la prima cifra ottale
    addi $a0, $a0, 1              # Incrementa puntatore memoria
    addi $v1, $v1, 1              # Incrementa il contatore delle cifre ottali
    
    addi $v0, $0, 1               # Se la stringa finisce qui o al prossimo carattere, NON tutti sono stati trasposti
    lb   $t1, ($a0)               # Carica secondo carattere
    beq  $t1, '\n', skip          # È il carattere '\n'? Esci
    sub  $t1, $t1, 0x30           # Trasformalo in intero (da ASCII)
    sll  $t1, $t1, 1              # Moltiplicalo per 2              
    add  $t7, $t7, $t1            # Aggiungi alla somma la seconda cifra ottale
    addi $a0, $a0, 1              # Incrementa puntatore memoria
    
    
    lb   $t0, ($a0)               # Carica terzo carattere
    beq  $t0, '\n', skip          # È il carattere '\n'? Esci
    sub  $t0, $t0, 0x30           # Trasformalo in intero (da ASCII)
    add  $t7, $t7, $t0            # Aggiungi alla somma la terza cifra ottale
    addi $a0, $a0, 1              # Incrementa puntatore memoria
    
    
    add  $t7, $t7, 0x30           # Trasforma $t7 in ASCII (da intero)
    sb   $t7, 0($a2)              # Scrivi in memoria il risultato
    addi $a2, $a2, 1              # Incrementa il puntatore di scrittura
    add  $t7, $0, $0              # Azzera il risultato corrente
    
    j cycle
    
    skip:
    add  $t7, $t7, 0x30           # Trasformalo $t7 in ASCII (da intero)
    sb   $t7, 0($a2)              # Scrivi in memoria il risultato

    

  returnToMain:         
    lw   $a2, 0($sp)
    addi $sp, $sp, 4       
    jr   $ra                      # Ritorna a main
