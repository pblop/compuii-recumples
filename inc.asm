.area PROG (ABS)

;; CONSTANTES
fin      .equ 0xFF01
pantalla .equ 0xFF00
teclado  .equ 0xFF02

;; DIRECTIVAS
.org 0x100
.globl programa

;; VARIABLES
ano:      .word 0x1969
mes:      .byte 0x7
dia:      .byte 0x27
nCumples: .byte 10

;; FUNCIONES

increm8:
        inca
        tfr a,b
        andb #0x0F
        cmpb #0x0A
        bne incrementaSegunda
        adda #6
incrementaSegunda:
        cmpa #0xA0
        blo incrementaRetorno
        clra
incrementaRetorno:
        rts

programa:

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa


;; TE QUIERO <3
