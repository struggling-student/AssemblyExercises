##########################################
# INSERIRE I PROPRI DATI QUI
# Nome:
# Cognome:
# Matricola:
##########################################

# NON MODIFICARE QUESTA PARTE
.data
    buffer: .space 20

.text

main:
    li $v0, 8       # Codice per input stringa
    la $a0, buffer  # Carica indirizzo base in $a0
    li $a1, 20      # Alloca al massimo 20 caratteri
    syscall         # $a0 contiene l'indirizzo base della stringa


##########################################
## INSERIRE IL CODICE QUI

#### Inizializzazione
########################
add $v0, $zero, $zero

#### Run
########################
jal contaOccorrenze

add  $a0, $v0, $zero  # Carica il risultato per la stampa
addi $v0, $zero, 1    # Imposta stampa intero
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
#   $a0: indirizzo base della stringa
# Output:
#   $v0: somma cifre prese a due a due
#   $v1: numero di caratteri
contaOccorrenze:
  li   $v0, 0                   # Inizializza $v0
  li   $v1, 0                   # Inizializza $v1
  li   $t7, '\n'                # Carattere '\n'
  li   $t3, 10                  # temp per 10


  cycle:
    lb   $t0, ($a0)               # Carica primo carattere
    beq  $t0, $t7, returnToMain   # È il carattere '\n'? Esci
    sub  $t0, $t0, 0x30           # Trasformalo in intero (da ASCII)
    addi $a0, $a0, 1              # Incrementa contatore memoria
    
    lb   $t1, ($a0)               # Carica secondo carattere
    beq  $t1, $t7, halfExit       # Se manca siamo nel caso dispari
    addi $v1, $v1, 2              # Incrementa contatore caratteri di due
    sub  $t1, $t1, 0x30           # Trasformalo in intero (da ASCII)
    mul  $t0, $t0, $t3            # Moltiplica per 10 il carattere delle decine
    add  $v0, $v0, $t0            # Aggiungilo alla somma
    add  $v0, $v0, $t1            # Aggiungi il carattere delle unità alla somma
    addi $a0, $a0, 1              # Incrementa contatore memoria
    j cycle
    
    halfExit:                     # Caso in cui usciamo a metà: in quel caso la prima cifra è delle unità e non delle decine
    add  $v0, $v0, $t0            # somma come unità
    addi $v1, $v1, 1              # incrementa contatore caratteri di uno
    j returnToMain
    
  returnToMain:                 
    jr   $ra                    # Ritorna a main
