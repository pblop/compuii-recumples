.area PROG (ABS)

; CONSTANTES
fin      .equ 0xFF01
pantalla .equ 0xFF00
teclado  .equ 0xFF02

; DIRECTIVAS
.org 0x100
.globl programa

enero:  .ascii "enero"
        .byte 0

febrero:  .ascii "febrero"
        .byte 0

marzo:  .ascii "marzo"
        .byte 0

abril:  .ascii "abril"
        .byte 0

mayo:  .ascii "mayo"
        .byte 0

junio:  .ascii "junio"
        .byte 0

julio:  .ascii "julio"
        .byte 0

agosto:  .ascii "agosto"
        .byte 0

septiembre:  .ascii "septiembre"
        .byte 0

octubre:  .ascii "octubre"
        .byte 0

noviembre:  .ascii "noviembre"
        .byte 0

diciembre:  .ascii "diciembre"
        .byte 0

programa:
  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa