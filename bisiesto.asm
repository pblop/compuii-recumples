; Pablo Pérez Rodríguez <pab@usal.es>

.area PROG (ABS)

; CONSTANTES
pantalla .equ 0xFF00
fin      .equ 0xFF01
teclado  .equ 0xFF02

; DIRECTIVAS
.org 0x100
.globl programa

; VARIABLES
ano: .word 0x2004

programa:
  ldd ano

  ; Si el último bit de la última cifra es 1, no es bisiesto.
  bitb #0b00000001
  bne no_bisiesto

  andb #0b00010010
  beq si_bisiesto
  cmpb #0b00010010
  beq si_bisiesto
  
  no_bisiesto:
    lda #'N
    sta pantalla
    lda #'o
    sta pantalla
    lda #'\n
    sta pantalla
    bra final

  si_bisiesto:
    lda #'S
    sta pantalla
    lda #'i
    sta pantalla
    lda #'\n
    sta pantalla
  
  final:
    ; Final del programa
    clra
    sta fin

; Iniciar el programa en 'programa'

.org 0xFFFE
.word programa
