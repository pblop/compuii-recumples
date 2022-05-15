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

de: .asciz " de "

tabladiasmes:
  .byte 0x31
  .byte 0x28
  .byte 0x31
  .byte 0x30
  .byte 0x31
  .byte 0x30
  .byte 0x31
  .byte 0x31
  .byte 0x30
  .byte 0x31
  .byte 0x30
  .byte 0x31

; Función.
; Actualiza el valor de la tabla de los días de los meses
; en función de si el año actual es bisiesto.
; Entrada: nada
; Salida: los días de febrero en la tabladiasmes
; Afecta: D, tabladiasmes
actualiza_bisiesto:
  ldd ano ;; TODO: Posiblemente optimizable (a lo mejor haciendo un ldb con sólo el último byte 
          ;; de ano).

  ; Si el último bit de la última cifra es 1, no es bisiesto.
  bitb #0b00000001
  bne ab_no_bisiesto

  andb #0b00010010
  beq ab_si_bisiesto
  cmpb #0b00010010
  beq ab_si_bisiesto

  ab_no_bisiesto:
    ldb #0x28
  ab_si_bisiesto:
    ldb #0x29
  ab_ret:
    stb tabladiasmes+2-1
    rts

; Función.
; Imprime la cadena ASCII marcada por X por pantalla.
; Entrada: X (dirección de la cadena a imprimir)
; Salida: pantalla
; Afecta: X, A
imprimeASCII:
  iA_bucle:
    lda ,x+
    beq iA_acabar
    sta pantalla
    bra iA_bucle

  iA_acabar:
    rts

; Función.
; Imprime el mes en B por pantalla.
; Entrada: B (el mes)
; Salida: pantalla
; Afecta: X, A
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


; Función.
; Imprime el día o el año (en BCD), en función del
; valor de B (si 0, día; si 1, año).
; Entrada: B: 0 si dia, 1 si año
; Salida: pantalla
; Afecta: D
imprimeBCD:
  ;; TODO: Optimizar esto.
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

; Función
; Imprime " de " por pantalla.
; Entrada: nada
; Salida: pantalla
; Afecta: X
imprimeDe:
  ldx #de
  jsr imprimeASCII

  rts

; Función.
; Imprime una fecha en el fomato correcto por pantalla. 
; Entrada:
;          X (año (BCD))
;          A (mes (BCD))
;          B (día (BCD))
; Salida: pantalla
; Afecta: X, D
imprimeFecha:
  ldb #0
  jsr imprimeBCD
  jsr imprimeDe
  jsr imprimeMes
  jsr imprimeDe
  ldb #1
  jsr imprimeBCD

  rts

; Función.
; Corrige los meses para que sean válidos (no sean >12), ajustando los años
; a la vez.
; Entrada: stack u.
; Salida:  stack u.
; Afecta: 
corregirMes:
  rts

; Función.
;
corregirDia:
  rts

programa:
  ; Inicializar stacks.
  lds #0xF000
  ldu #0xE000
  ; STACK U    (5, u)
  ; 1: i       (4, u)
  ; 2: ano     (2, u)
  ; 1: mes     (1, u)
  ; 1: dia     (0, u)

  ; Bucle para i.
  lda #1
  pshu a     ; i = 0
  mbuclei:
    ; Cargar dia, mes y año en el stack.
    ldx ano
    ldd mes     ; Cargo mes y día en d (de tal forma que quedan como en el
                ; esquema de arriba.
    pshu x, d

    inc16 2,u  ; año += 1
    inc8 1,u ; mes += 1
    
    bsr corregirMes
    bsr corregirDia

    inc8 ,u

    bsr corregirDia

    bsr imprimeFecha

    ; Hacer pulu de x y d, o hacer x+=3
    leau 3,x

    inc 4,u
    lda 4,u
    cmpa nCumples
    ble mbuclei

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa


;; TE QUIERO <3
