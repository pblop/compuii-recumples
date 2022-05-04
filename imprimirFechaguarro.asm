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

de: .ascii " de "
    .byte 0

; Variables para imprimir el mes
enero:       .ascii "enero"
             .byte 0
febrero:     .ascii "febrero"
             .byte 0
marzo:       .ascii "marzo"
             .byte 0
abril:       .ascii "abril"
             .byte 0
mayo:        .ascii "mayo"
             .byte 0
junio:       .ascii "junio"
             .byte 0
julio:       .ascii "julio"
             .byte 0
agosto:      .ascii "agosto"
             .byte 0
septiembre:  .ascii "septiembre"
             .byte 0
octubre:     .ascii "octubre"
             .byte 0
noviembre:   .ascii "noviembre"
             .byte 0
diciembre:   .ascii "diciembre"
             .byte 0
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

  iM_bucle:
    lda ,x+
    beq iM_acabar
    sta pantalla
    bra iM_bucle

  iM_acabar:
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
  bra iM_bucle
  
  ;iD_bucle:
  ;  lda ,x+
  ;  beq iD_acabar
  ;  sta pantalla
  ;  bra iD_bucle

  ;iD_acabar:
  ;  rts


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
