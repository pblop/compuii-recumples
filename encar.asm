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
dia:      .byte 0x27
mes:      .byte 0x7
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
  ldb 1,u
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

  bsr imprimeASCII
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
  cmpb #2
  beq iBCD_bucle
    ; Día
    lda ,u
    lsra lsra lsra lsra
    adda #'0
    sta pantalla

    lda ,u
    anda #0x0f
    adda #'0
    sta pantalla
    bra iBCD_fin
  iBCD_ano:
    ldd 2,u ;; Dos primeras cifras
    lsra lsra lsra lsra
    adda #'0
    sta pantalla
    ldd 2,u
    anda #0x0f
    adda #'0
    sta pantalla
    
    ldd 2,u ;; Dos últimas cifras
    lsrb lsrb lsrb lsrb
    addb #'0
    stb pantalla
    ldd 2,u
    andb #0x0f
    addb #'0
    stb pantalla
    bra iBCD_fin

  iBCD_bucle:
    ; i
    lda 4,u
    lsra lsra lsra lsra
    adda #'0
    sta pantalla

    lda 4,u
    anda #0x0f
    adda #'0
    sta pantalla

  iBCD_fin:
    rts

; Función
; Imprime " de " por pantalla.
; Entrada: nada
; Salida: pantalla
; Afecta: X
imprimeDe:
  ldx #de
  bsr imprimeASCII

  rts

; Funcion
; Corrige i para poder imprimirlo (tenemos en cuenta que no va a ser mayor de 30)
; Entrada: b (desde el stack)
; Salida: b (ya sale en forma de caracter, con los espacios y los :)
; Afecta: d

;; convierto i a BCD y luego llamo la funcion imprimirBCD
Imprime_bucle:
  lda 4,u
  ;; lo guardo momentaneamente en s
  sta 4,u
  ldb #2
  bsr imprimeBCD
  ldb #':
  stb pantalla
  ldb #' 
  stb pantalla

; Función.
; Imprime una fecha en el fomato correcto por pantalla. 
; Entrada:
;          X (año (BCD))
;          A (mes (BCD))
;          B (día (BCD))
; Salida: pantalla
; Afecta: X, D
imprime_fecha:
  clrb
  lbsr imprimeBCD
  bsr imprimeDe
  lbsr imprimeMes
  bsr imprimeDe
  ldb #1
  lbsr imprimeBCD
  ldb #'\n
  stb pantalla

  rts

; Función: inc8.
;   Incrementa un número de 8 bits
; Entrada: a (número a incrementar)
; Salida: a
; Registros afectados: b
inc8:
  inca
  tfr a,b
  andb #0x0f
  cmpb #0x0a
  bne inc8_segunda
  adda #6
inc8_segunda:
  cmpa #0xa0
  blo inc8_ret
  clra
inc8_ret:
  rts

; Función.
;   Incrementa un año (16 bits).
; Entrada: año (stack)
; Salida: año (stack)
; Registros afectados: a
incano:
  lda 3,u
  bsr inc8
  sta 3,u
  cmpa #0
  beq incano_2000
  ; No debería de hacer falta esta línea.
  ; lda #0x19
  rts
incano_2000:
  lda #0x20
  sta 2,u
  rts


; Función.
;   Vuelve a enero cuando estamos en el mes 13 e incrementa el año.
; Entrada: b (mes) 
; Salida: b (mes modificado)
; Afecta: 
corregir_mes:
  cmpb #0x12
  bhi cm_cuerpowhile

  rts 

  cm_cuerpowhile:
    ;; cuerpo del while
    subb #0x12
    bsr incano
  
    bra corregir_mes

; Función.
; Actualiza el valor de la tabla de los días de los meses
; en función de si el año actual es bisiesto.
; Entrada: nada
; Salida: los días de febrero en la tabladiasmes
; Afecta: D, tabladiasmes
actualiza_bisiesto:
  ldd 2,u ;; TODO: Posiblemente optimizable (a lo mejor haciendo un ldb con sólo el último byte 
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

; Funcion.
; Corregir el dia si nos pasamos de los que puede tener un mes
; Entrada: a (dia)
;          b (mes)
; Salida:  a (dia)
; Registros afectados: a, b
corregir_dia:
  ldd ,u
  ldx #(tabladiasmes-1)
  cd_while:
    pshs d
    bsr actualiza_bisiesto
    puls d
    cmpa b, x ; numero de dias del mes en el que estamos
    ble cd_ret

    suba b, x ; dia -= dias[mes-1]

    exg a,b   ; 
    bsr inc8  ; mes++
    exg b,a   ;
    
    bsr corregir_mes

    bra cd_while

  cd_ret:
    sta ,u
    rts

; Función.
; Suma dos números en BCD.
; Entrada:
;          a: primer número
;          nCumples: segundo numero
; Registros afectados: a
; Salida:
;          a: suma
suma88:
  adda nCumples
  ;bsr daa ; TODO: Puede ser que daa a secas funcione pq la suma nunca > 61
  daa
  rts

; Función.
; Suma dos números (8 y 16 bits) en BCD.
; Entrada:
;          stack u (año): primer número
;          nCumples: segundo numero
; Registros afectados: 
; Salida:
;          stack u (año): suma
sumaano:
  lda 3,u
  bsr suma88
  sta 3,u
  blo sumaano_carry ; Salta si C=1 (si el daa de suma88 activa el carry).
  ; lda #0x19 ; Lo mismo que para inc8, creo que no hace falta
  rts
sumaano_carry:
  lda #0x20
  sta 2,u
sumaano_ret:
  rts



programa:
  ; Inicializar stacks.
  lds #0xF000
  ldu #0xE000
  ; STACK U    (5, u)
  ; 1: i       (4, u)
  ; 2: ano     (2, u) => 19: 2,u. 69: 3,u.
  ; 1: mes     (1, u)
  ; 1: dia     (0, u)

  ; Bucle para i.
  lda #0
  pshu a     ; i = 0
  mbuclei:
    ; Cargar dia, mes y año en el stack.
    ldx ano
    ldd dia     ; Cargo mes y día en d (de tal forma que quedan como en el
                ; esquema de arriba.
    pshu x, d
    ldd ,u

    bsr incano  ; año += 1
    lda 1,u
    lbsr inc8    ; mes += 1
    sta 1,u
    
    bsr corregir_mes
    bsr corregir_dia
    lda ,u
    lbsr inc8
    sta ,u

    bsr corregir_dia

    lbsr Imprime_bucle

    ; Hacer pulu de x y d, o hacer u+=4
    ; u = 4 + u
    leau 4,u

    debug8:
    inc ,u
    lda ,u
    cmpa nCumples
    ble mbuclei

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa

;; TE QUIERO <3
