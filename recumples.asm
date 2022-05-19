.area PROG (ABS)

; CONSTANTES
fin             .equ 0xFF01
pantalla        .equ 0xFF00
teclado         .equ 0xFF02

; VARIABLES AUX
i               .equ 0x80
a_ano           .equ 0x81
a_ano_primera   .equ 0x81
a_ano_segunda   .equ 0x82
a_dia           .equ 0x83
a_mes           .equ 0x84
iBCD            .equ 0x85

; DIRECTIVAS
.area _CODE (ABS)
.org 0x100
.globl programa

; VARIABLES
aNo:         .word 0x{ANO}
mes:         .word 0x{MES}
dia:         .word 0x{DIA}
nCumples:    .byte 30

; LISTA CON LAS CADENAS DE TEXTO DE LOS MESES
;
; Guardamos un byte 0 al comienzo de la misma porque los meses están indizados en 1,
; es decir, enero es el mes 1, no el mes 0. 
; De esta manera, cuando buscamos ceros mas adelante en imprimir_mes, si queremos
; imprimir enero encontrara 1, para febrero encontrara 2, etc.
; por el byte que hemos añadido.
lista_nombres: 
  .byte 0
  enero:        .asciz "enero"
  febrero:      .asciz "febrero"
  marzo:        .asciz "marzo"
  abril:        .asciz "abril"
  mayo:         .asciz "mayo"
  junio:        .asciz "junio"
  julio:        .asciz "julio"
  agosto:       .asciz "agosto"
  septiembre:   .asciz "septiembre"
  octubre:      .asciz "octubre"
  noviembre:    .asciz "noviembre"
  diciembre:    .asciz "diciembre"

; TABLA CON LOS DIAS DE CADA MES
tabladiasmes:
  .byte 0x31    ; 0x1 (enero)
  .byte 0x28    ; Los días de febrero los actualizaremos más adelante, 
  .byte 0x31    ; en función de si es o no bisiesto.
  .byte 0x30
  .byte 0x31
  .byte 0x30
  .byte 0x31
  .byte 0x31
  .byte 0x30   ; 0x9
  .byte 0x31   ; 0xA -> 0x10
  .byte 0x30   ; 0xB -> 0x11
  .byte 0x31   ; 0xC -> 0x12 

; FUNCIONES QUE HACEN CALCULOS

; FUNCION
;       Ajuste de la resta para que nos de un numero en BCD.
; 
;   Explicacion:
;       Hemos comprobado que solamente hay que corregir la resta cuando
;       el último dígito del sustraendo es más grande que el
;       último dígito del minuendo.
;       - Ejemplo: 0x31 - 0x28 = 0x08, en BCD seria 0x02. (8 > 1)
;                  0x37 - 0x30 = 0x07, no hay que hacer ajuste (0 < 7)
; 
;   Entrada: 
;       Minuendo: a
;       Sustraendo: b
;
;   Salida:
;       Diferencia (ajustada): a
ajuste_resta:
  pshs d       ; Guardamos los dos miembros de la resta
  anda #0x0f   ; a contiene la última cifra (uc1) del minuendo
  andb #0x0f   ; b contiene la uc2 del sustraendo

  pshs a       ; Comparo b con a
  cmpb ,s+     ; 

  puls d
  ; Ajustar resta si uc2 > uc1.       
  bls ar_noajustarresta 
  suba #6

  ar_noajustarresta:
    rts



; Funcion.
; Corregir el dia si nos pasamos de los que puede tener un mes
; Entrada: a_dia, a_mes 
; Salida:  a_dia
; Registros afectados: a, b
corregir_dia:
  leax (tabladiasmes-1), pcr
  cd_while:
    ; Función en linea
    ; Actualiza el valor de la tabla de los días de los meses
    ; en función de si el año actual es bisiesto.
    ; Entrada: nada
    ; Salida: los días de febrero en la tabladiasmes
    ; Afecta: D, tabladiasmes
      ldb *a_ano_segunda ; solo necesitamos la ultima parte de ano
      ; Si el último bit de la última cifra es 1, no es bisiesto.
      asrb
      bcs ab_no_bisiesto

      andb #0b00001001
      beq ab_si_bisiesto
      cmpb #0b00001001 
      beq ab_si_bisiesto

      ab_no_bisiesto:
        ldb #0x28
        bra ab_ret
      ab_si_bisiesto:
        ldb #0x29
      ab_ret:
        stb 2,x
    ; Fin de funcion en linea
    ldd *a_dia ; Guardamos el día en a, y el mes en b
    cmpb #10
    blo cd_menor10

    subb #(0x10-0xA) ; Igual que en imprimeMes
    
    cd_menor10:
      cmpa b, x ; numero de dias del mes en el que estamos
      bls cd_ret
      
      ldb b, x  ; b = dias[mes-1]
      pshs b
      bsr ajuste_resta
      suba ,s+  ; dia -= dias[mes-1]

      sta *a_dia

    lda *a_mes
    bsr inc8  ; mes++
    bsr corregir_mes

    bra cd_while

  cd_ret:
    rts

; Función.
;   Vuelve a enero cuando estamos en el mes 13 e incrementa el año.
; Entrada: a (mes) 
; Salida: a (mes modificado)
; Afecta: a
corregir_mes:
  cmpa #0x12
  bhi cm_cuerpowhile

  sta *a_mes
  rts 

  cm_cuerpowhile:
    ldb #0x12
    bsr ajuste_resta
    ;; cuerpo del while
    suba #0x12

    bsr incano

    bra corregir_mes


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
incano:
  pshs a

  lda *a_ano_segunda
  bsr inc8
  sta *a_ano_segunda
  beq incano_2000
  bra incano_ret
  
  incano_2000:
    lda #0x20
    sta *a_ano_primera

  incano_ret:
    puls a
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
  daa         ; Puede ser que daa a secas funcione pq la suma nunca > 0x61 (falla cuando pasa de 0x90)
  rts


programa:
  ; Inicializar stacks.
  lds #0xF000

  ; Bucle para i.
  ; No inicializo las variables i e iBCD a 0 porque por defecto esas direcciones
  ; de memoria son 0.
  mbuclei:
    ; Cargar dia, mes y año en nuestras variables auxiliares (con las que trabajamos).
    ldd aNo, pcr
    std *a_ano
    ldb mes+1, pcr
    stb *a_mes
    ldb dia+1, pcr
    stb *a_dia

    ; Hacemos ano += i con esta función
    ; Función en línea: sumaano
    ; Suma dos números (8 y 16 bits) en BCD.
    ; Entrada:
    ;          a_año: primer número
    ;          nCumples: segundo numero
    ; Registros afectados: 
    ; Salida:
    ;          a_año: suma
    sumaano:
      lda #0x0      ; j = 0 para el bucle
      sa_bucle:
        cmpa *iBCD
        bhs sa_ret

        bsr incano

        bsr inc8
        bra sa_bucle  ; while j < i
      sa_ret:

    lda *a_mes          ; mes += i
    bsr suma88        ;
    ds: 
    bsr corregir_mes ; corregir_mes()
    
    dcm:
    lbsr corregir_dia  ; corregir_dia()
    dcd:
    lda *a_dia          ; dia += i
    bsr suma88       ;
    sta *a_dia          ;

    cs2:
    lbsr corregir_dia  ; corregir_dia()
    dcd2:
    bsr imprime_fecha; printf

    ; Incrementamos la variable BCD
    lda *iBCD
    bsr inc8
    sta *iBCD
    ; Incrementamos la variable hexa
    lda *i
    inca
    sta *i
    cmpa nCumples, pcr
    bls mbuclei

  ; Final del programa
  clra
  sta fin

; FUNCIONES PARA IMPRIMIR

; Función.
; Imprime el mes en B por pantalla.
; Entrada: B (el mes)
; Salida: pantalla
; Afecta: X, A
imprimeMes:
  leax lista_nombres, pcr ; Cargamos la dirección anterior al comienzo de la tabla porque los meses empiezan 
                         ; en 1, en vez de 0.

  ldb *a_mes
  cmpb #0x10
  blo iM_menor10
    subb #(0x10-0xA) ; Si el número es >=0x10, le restamos 0x6 (la distancia desde
                     ; 0xA (10) y 0x10 (el número que queremos) para que
                     ; el número 0x10 de al elemento 10 (0xA), no al 16(0x10).
                     ; Osea, convertimos el BCD a hexa.
  iM_menor10:
  iM_bucle:
    lda ,x+
    bne iM_bucle

  iM_cero:           ; Cuando encontramos un caracter 0, le restamos 1 a b.
    decb             ; Cuando llegamos a 0, imprimimos.
    bne iM_bucle     ; (BNE salta cuando no hemos llegado a 0) 

  ; Aquí pondríamos un bsr imprimeASCII y un rts, pero como es el final de la función,
  ; podríamos optimizarlo con un bra imprimeASCII en su lugar.
  ; Pero además, como imprimeASCII está justo debajo de esta función, no tenemos
  ; ni que saltar a ella.

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

; Funcion
; Imprime la fecha en el formato correcto por la pantalla
; Entrada: a
; Salida: pantalla
; Afecta: a
dospuntos: .asciz ": "
imprime_fecha:
  lda *iBCD           ; Imprime i con el formato %02d
  bsr imprime_cifra1
  lda *iBCD
  bsr imprime_cifra2

  leax dospuntos, pcr
  bsr imprimeASCII

  lda *a_dia          ; Imprimimos a_dia con el formato %d
  cmpa #0x10          ;
  blo if_menor10      ;   Si a_dia < 10, no imprimimos la primera cifra.

  bsr imprime_cifra1
  if_menor10:
    lda *a_dia        ;   Segunda cifra de a_dia
    bsr imprime_cifra2

  bsr imprimeDe       ; Imprimimos el primer 
  bsr imprimeMes
  bsr imprimeDe

  lda *a_ano_primera  ; Imprimimos a_ano con el formato %d
  bsr imprime_cifra1  ; Aquí la primera cifra
  lda *a_ano_primera
  bsr imprime_cifra2  ; Aquí la segunda cifra
  lda *a_ano_segunda
  bsr imprime_cifra1  ; Aquí la tercera cifra
  lda *a_ano_segunda
  bsr imprime_cifra2  ; Aquí la cuerta cifra

  lda #'\n
  sta pantalla

  rts

; Función
; Imprime " de " por pantalla.
; Entrada: nada
; Salida: pantalla
; Afecta: X
de: .asciz " de "
imprimeDe:
  leax de, pcr
  bra imprimeASCII


; Función.
;   Imprime la cifra de las decenas de un numero en BCD (byte)
; Entrada: a
; Salida: pantalla
; Afecta: a
imprime_cifra1:
  lsra lsra lsra lsra
  adda #'0 
  sta pantalla
  rts

; Función.
;   Imprime la cifra de las unidades de un numero en BCD (byte)
; Entrada: a
; Salida: pantalla
; Afecta: a
imprime_cifra2:
  anda #0x0f
  adda #'0
  sta pantalla
  rts

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa

;; TE QUIERO <3
