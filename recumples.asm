.area PROG (ABS)

; CONSTANTES
fin      .equ 0xFF01
pantalla .equ 0xFF00
teclado  .equ 0xFF02

; DIRECTIVAS
.org 0x100
.globl programa

; VARIABLES
ano:      .word 0x1969
mes:      .byte 0x7
dia:      .byte 0x27
nCumples: .byte 10


programa:
  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa


;; TE QUIERO <3
