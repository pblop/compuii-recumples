.area PROG (ABS)

; CONSTANTES
fin      .equ 0xFF01
pantalla .equ 0xFF00
teclado  .equ 0xFF02

; DIRECTIVAS
.org 0x100
.globl programa

; VARIABLES

mes: .byte 0x11

enero:       .asciz "enero"
febrero:     .asciz "febrero"
marzo:       .asciz "marzo"
abril:       .asciz "abril"
mayo:        .asciz "mayo"
junio:       .asciz "junio"
julio:       .asciz "julio"
agosto:      .asciz "agosto"
septiembre:  .asciz "septiembre"
octubre:     .asciz "octubre"
noviembre:   .asciz "noviembre"
diciembre:   .asciz "diciembre"

tablames:
  .word enero
  .word febrero
  .word marzo
  .word abril
  .word mayo
  .word junio
  .word julio
  .word agosto
  .word septiembre ; 0x9
  .word octubre    ; 0x10
  .word noviembre  ; 0x11
  .word diciembre  ; 0x12


programa:
  ldx #tablames
  ; 123 ciclos
  ldb mes
  cmpb #0x10
  blt menor10
  subb #(0x10 - 0xA) ; Si el número es >=0x10, le restamos 0x6 (la distancia desde
                     ; 0xA (10) y 0x10 (el número que queremos) para que
                     ; el número 0x10 de al elemento 10 (0xA), no al 16(0x10).
                     ; Osea, convertimos el BCD a hexa.

  menor10:
    decb
    aslb
    ldx b,x

  ; 123 ciclos
  ;lda mes
  ;deca
  ;asla
  ;ldx #tablames
  ;leax a,x
  ;ldx ,x

  bucle:
    lda ,x+
    beq acabar
    sta pantalla
    bra bucle


  ; Final del programa
  acabar:
    clra
    sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa
