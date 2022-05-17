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

de: .asciz " de "

; Variables para imprimir el mes
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


;; FUNCIONES


; Función: imprimeASCII
; Entrada:
;          X: dirección de la cadena
; Registros afectados: X, A
; Salida:
;          pantalla: cadena
imprimeASCII:
  iA_bucle:
    lda ,x+
    beq iA_acabar
    sta pantalla
    bra iA_bucle

  iA_acabar:
    rts


; Función: imprimeMes
; Entrada:
;          B: mes (BCD)
; Registros afectados: X, B
; Salida:
;          pantalla: mes (palabra)
imprimeMes:
  ldx #tablames
  ldb mes
  cmpb #0x10
  blt iM_menor10
  subb #(0x10-0xA) ; Si el número es >=0x10, le restamos 0x6 (la distancia desde
                   ; 0xA (10) y 0x10 (el número que queremos) para que
                   ; el número 0x10 de al elemento 10 (0xA), no al 16(0x10).
                   ; Osea, convertimos el BCD a hexa.
  iM_menor10:
    decb
    aslb
    ldx b,x

  jsr imprimeASCII
  rts

; Función: imprimeBCD
; Entrada:
;          B: 0 si dia, 1 si año
; Registros afectados: A, B, D 
; Salida:
;          pantalla: número BCD en pantalla
imprimeBCD:
  cmpb #1
  beq iBCD_ano
    ; Día
    lda dia
    lsra lsra lsra lsra
    adda #'0
    sta pantalla

    lda dia
    anda #0x0f
    adda #'0
    sta pantalla
    bra iBCD_fin
  iBCD_ano:
    ldd ano ;; Dos primeras cifras
    lsra lsra lsra lsra
    adda #'0
    sta pantalla
    ldd ano
    anda #0x0f
    adda #'0
    sta pantalla
    
    ldd ano ;; Dos últimas cifras
    lsrb lsrb lsrb lsrb
    addb #'0
    stb pantalla
    ldd ano
    andb #0x0f
    addb #'0
    stb pantalla

  iBCD_fin:
    rts


imprimeDe:
  ldx #de
  jsr imprimeASCII

  rts


; Función: imprimeFecha
; Entrada:
;          X: año (BCD)
;          A: mes (BCD)
;          B: día (BCD)
; Salida:
;          pantalla: fecha
;
;
imprimeFecha:
  ldb #0
  jsr imprimeBCD
  jsr imprimeDe
  jsr imprimeMes
  jsr imprimeDe
  ldb #1
  jsr imprimeBCD

  rts


programa:
  jsr imprimeFecha 

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa


;; TE QUIERO <3
