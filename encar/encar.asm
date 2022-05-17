.area PROG (ABS)

; CONSTANTES
fin      .equ 0xFF01
pantalla .equ 0xFF00
teclado  .equ 0xFF02

; VARIABLES AUX
i        .equ 0x80
a_ano    .equ 0x81
a_mes    .equ 0x83
a_dia    .equ 0x84
iBCD     .equ 0x85

; DIRECTIVAS
.area _CODE (ABS)
.org 0x100
.globl programa

; VARIABLES
ano:      .word 0x{ANO}
mes:      .word 0x{MES}
dia:      .word 0x{DIA}
nCumples: .byte 30

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

de: .asciz " de "

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

tabladiasmes:
  .byte 0x31
  .byte 0x28
  .byte 0x31
  .byte 0x30
  .byte 0x31
  .byte 0x30
  .byte 0x31
  .byte 0x31
  .byte 0x30       ; 0x9
  .byte 0x31       ; 0x10
  .byte 0x30       ; 0x11
  .byte 0x31       ; 0x12

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
  lda *a_ano+1
  bsr inc8
  sta *a_ano+1
  cmpa #0
  beq incano_2000
  ; No debería de hacer falta esta línea.
  ; lda #0x19
  rts
incano_2000:
  lda #0x20
  sta *a_ano
  rts

; Función
;   Hace una primitiva corrección de la resta para BCD.
; Entrada: a
; Salida:  a
; Afecta:  a
daaresta:
  pshs b
  tfr a, b
  andb #0x0f
  cmpb #0x0a
  bls daar_fin
  suba #6

  daar_fin:
    puls b
    rts


; Función.
;   Vuelve a enero cuando estamos en el mes 13 e incrementa el año.
; Entrada: a (mes) 
; Salida: a (mes modificado)
; Afecta: 
corregir_mes:
  cmpa #0x12
  bhi cm_cuerpowhile

  rts 

  cm_cuerpowhile:
    ;; cuerpo del while
    suba #0x12
    bsr daaresta
    
    pshs a
    bsr incano
    puls a

    bra corregir_mes

; Función.
; Actualiza el valor de la tabla de los días de los meses
; en función de si el año actual es bisiesto.
; Entrada: nada
; Salida: los días de febrero en la tabladiasmes
; Afecta: D, tabladiasmes
actualiza_bisiesto:
  ldd *a_ano ;; TODO: Posiblemente optimizable (a lo mejor haciendo un ldb con sólo el último byte 
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
    bra ab_ret
  ab_si_bisiesto:
    ldb #0x29
  ab_ret:
    stb tabladiasmes+2-1, pcr
    rts

; Funcion.
; Corregir el dia si nos pasamos de los que puede tener un mes
; Entrada: b (dia)
;          a (mes)
; Salida:  b (dia)
; Registros afectados: a, b
corregir_dia:
  leax (tabladiasmes-1), pcr
  cd_while:
    ;TODO: creo que esto no cuenta
    pshs d
    bsr actualiza_bisiesto
    puls d
  
    ;TODO: ldd
    ldb *a_dia
    lda *a_mes
    cmpa #10
    blo cd_menor10

    suba #(0x10-0xA) ; Igual que en imprimeMes
    
    cd_menor10:
      cmpb a, x ; numero de dias del mes en el que estamos
      bls cd_ret
       
      ; Ajuste de la resta.
      ; sale mal si el último dígito del sustraendo 2 es más grande que el
      ; último dígito del sustraendo uno.
      ; Ejemplo: 31-28=08 pero tenía que ser 2.
      ; En este caso: sustraendo 2: a,x. Sustraendo 1: b
      pshs d
      lda a, x
      anda #0x0f   ; A contiene la última cifra (uc) del sus2.
      andb #0x0f   ; B contiene la uc del sus1.
      pshs b
      cmpa ,s+
      puls d
      bls cd_noajustarresta ; Ajustar resta si uc2 > uc1.

      subb #6

      cd_noajustarresta:
        subb a, x ; dia -= dias[mes-1]

      stb *a_dia

    
    lda *a_mes
    lbsr inc8  ; mes++
    bsr corregir_mes
    sta *a_mes

    bra cd_while

  cd_ret:
    rts

; Función.
; Suma dos números en BCD.
; Entrada:
;          a: primer número
;          i: segundo numero
; Registros afectados: a
; Salida:
;          a: suma
suma88:
  adda *iBCD
  ;bsr daa ; TODO: Puede ser que daa a secas funcione pq la suma nunca > 0x61 (falla cuando pasa de 0x90)
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
  lda #0x0      ; i = 0 para el bucle
  
  sa_bucle:
    cmpa *iBCD
    bhs sa_ret

    pshs a
    lbsr incano
    puls a

    lbsr inc8
    bra sa_bucle  ; while i < nCumples
  
  sa_ret:
    rts

programa:
  ; Inicializar stacks.
  lds #0xF000
  ldu #0xE000

  ; Bucle para i.
  lda #0
  sta *i     ; i = 0
  sta *iBCD  ; iBCD = 0
  mbuclei:
    ; Cargar dia, mes y año en nuestras variables auxiliares (con las que trabajamos).
    ldd ano
    std *a_ano
    ldb mes+1
    stb *a_mes
    ldb dia+1
    stb *a_dia

    bsr sumaano       ; año += i

    lda *a_mes          ; mes += i
    bsr suma88          ;
    ds: 
    lbsr corregir_mes ; corregir_mes()
    sta *a_mes
    
    dcm:
    bsr corregir_dia  ; corregir_dia()
    dcd:
    lda *a_dia          ; dia += i
    bsr suma88         ;
    sta *a_dia          ;

    cs2:
    lbsr corregir_dia  ; corregir_dia()
    dcd2:
    bsr ImprimeFecha; printf

    ; Incrementamos la variable BCD
    lda *iBCD
    lbsr inc8
    sta *iBCD
    ; Incrementamos la variable hexa
    lda *i
    inca
    sta *i
    ; Condicion de salida del bucle
    cmpa nCumples
    bls mbuclei

  ; Final del programa
  clra
  sta fin

; FUNCIONES PARA IMPRIMIR
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
  leax tablames, pcr
  ldb *a_mes
  cmpb #0x10
  blo iM_menor10
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

; Funcion
; Imprime la cifra de las decenas de un numero en BCD (byte)
; Entrada: a
; Salida: pantalla
; Afecta:

ImprimeCifra1:
  lsra lsra lsra lsra
  adda #'0 ; convertir a caracter
  sta pantalla;
  rts

; Funcion
; Imprime la cifra de las unidades de un numero en BCD (byte)
; Entrada: a
; Salida: pantalla
; Afecta:

ImprimeCifra2:
  anda #0x0f
  adda #'0 ; convertir a caracter
  sta pantalla;
  rts

; Funcion
; Imprime la fecha en el formato correcto por la pantalla
; Entrada: a
; Salida: pantalla
; Afecta: 
ImprimeFecha:
;; imprimimos i
  lda *iBCD
  bsr ImprimeCifra1
  lda*iBCD
  bsr ImprimeCifra2
  lda #':
  sta pantalla
  lda #' 
  sta pantalla

;; imprimimos el dia
  lda *a_dia
  cmpa #0x10
  blo dia_menor10 ; si es menor que diez no se imprime el 0

  bsr ImprimeCifra1

  dia_menor10:
    lda *a_dia
    bsr ImprimeCifra2

;; imprimirmos el mes
  bsr imprimeDe
  bsr imprimeMes
  bsr imprimeDe

;; imprimimos el ano
  ; imprimimos las dos primeras cifras
  lda *a_ano
  bsr ImprimeCifra1
  lda *a_ano
  bsr ImprimeCifra2
  ; imrprimimos las dos ultimas cifras
  lda *a_ano+1
  bsr ImprimeCifra1
  lda *a_ano+1
  bsr ImprimeCifra2

  lda #'\n
  sta pantalla

  rts


; Función
; Imprime " de " por pantalla.
; Entrada: nada
; Salida: pantalla
; Afecta: X
imprimeDe:
  leax de, pcr
  bsr imprimeASCII

  rts

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa

;; TE QUIERO <3
