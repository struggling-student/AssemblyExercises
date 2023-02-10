# Soluzione 1
add $s0, $zero, $zero       # $s0 assume valore 0
add $s1, $zero, $zero       # $s1 assume valore 0
nor $s1, $s1, $s1           # $s1 assume valore 0xFFFFFFFF
beq $s1, $s0, Exit          # In caso di guasto, il risultato di $s1-$s0 (cioè 0xFF…F) verrà scritto in $s0
Exit:

# Soluzione 2
add $s0, $zero, $zero       # $s0 assume valore 0
sw  $s0, 0xFFFFFFFF($zero)  # In caso di guasto, la somma di 0 + 0xFFFFFFFF verrà scritta in $s0
