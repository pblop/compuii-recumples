.area PROG (ABS)

; CONSTANTES
fin             .equ 0xFF01
pantalla        .equ 0xFF00
teclado         .equ 0xFF02

; VARIABLES AUX
i               .equ 0x80           ; Usamos dos i distintas, una normal para 
iBCD            .equ 0x81
a_ano           .equ 0x82           ; poder comparar con nCumpeles al final del 
a_ano_primera   .equ 0x82           ; bucle y otra en BCD, para poder imprimirla 
a_ano_segunda   .equ 0x83           ; y hacer cuentas mas fácilmente
a_dia           .equ 0x84
a_mes           .equ 0x85

; DIRECTIVAS
.area _CODE (ABS)
.org 0x100
.globl programa

; VARIABLES
aNo:         .word 0x{ANO}
mes:         .word 0x{MES}
dia:         .word 0x{DIA}
nCumples:    .byte 30


; LISTA CON LOS DÍAS DE CADA MES
listadiasmes:
  .byte 0x31    ; 0x1 (enero)
  .byte 0x28    ; Los días de febrero los actualizaremos más adelante, 
  .byte 0x31    ; en función de si es o no bisiesto.
  .byte 0x30
  .byte 0x31
  .byte 0x30
  .byte 0x31
  .byte 0x31
  .byte 0x30   ; 0x9
  .byte 0x31   ; 0xA (no 0x10)
  .byte 0x30   ; 0xB (no 0x11)
  .byte 0x31   ; 0xC (no 0x12)

; FUNCIÓNES QUE HACEN CALCULOS

; FUNCIÓN
;       Ajuste de la resta para que nos de un número en BCD.
; 
;   Explicacion:
;       Hemos comprobado que solamente hay que corregir la resta cuando
;       el último dígito del sustraendo es más grande que el
;       último dígito del minuendo.
;       - Ejemplo: 0x31 - 0x28 = 0x08, en BCD seria 0x02. (8 > 1)
;                  0x37 - 0x30 = 0x07, no hay que hacer ajuste (0 < 7)
; 
;   Entrada: 
;       Minuendo: A
;       Sustraendo: B
;
;   Salida:
;       Diferencia (ajustada): A
;
;   Registros afectados: A, B
resta_ajustada:
  pshs d        ; Guardamos los dos miembros de la resta
  anda #0x0f    ; A contiene la última cifra (uc1) del minuendo
  andb #0x0f    ; B contiene la uc2 del sustraendo

  pshs a        ; Comparo A con B
  cmpb ,s+      ; 

  puls a        ; Sacamos a, porque lo hemos modificado anteriormente,
                ; para poder hacer la resta.
  ; Ajustar resta si uc2 > uc1.       
  bls ra_noajustar 
  suba #6

  ra_noajustar: 
    suba ,s+    ; Restamos los dos números.
    rts

; FUNCIÓN
;       Corregir el día si nos pasamos de los que puede tener un mes
; 
;   Entrada: 
;       a_dia 
;       a_mes 
;
;   Salida:
;       a_dia ajustado
;
;   Registros afectados: A, B
corregir_dia:
  leax (listadiasmes-1), pcr  ; Cargamos la dirección anterior  
                              ; al inicio de la tabla porque 
                              ; los meses empizan en 1 y no en 0
  cd_while:
    ; Función en linea
    ;     Actualiza el valor de la tabla de los días de los meses
    ;     en función de si el año actual es bisiesto
    ;
    ;   Entrada:
    ;     x: listadiasmes-1
    ;     a_ano_segunda
    ;
    ;   Salida: 
    ;     los días de febrero en la listadiasmes
    ;
    ;   Registros afectados: D, listadiasmes
    actualiza_bisiesto:
      ldb *a_ano_segunda      ; Solo necesitamos la última parte de año
      lda #0x28               ; Cargo 0x28, este es el número que vamos a guardar
                              ; en la entrada de febrero en listadiasmes. Si es bisiesto
                              ; incrementamos el número (0x29) antes de guardarlo.

      asrb                    ; Si el último bit de la última cifra es 1, 
      bcs ab_no_bisiesto      ; no es bisiesto.

      andb #0b00001001        ; Para que un número sea bisiesto, en binario
      beq ab_si_bisiesto      ; su bit 0 tiene que ser igual al bit 3
      cmpb #0b00001001 
      bne ab_no_bisiesto

      ab_si_bisiesto:
        inca
      ab_no_bisiesto:
      ab_ret:
        sta 2,x
    ; Fin de función en linea
    ldd *a_dia                ; Guardamos el día en A y el mes en B
    cmpb #10                  
    blo cd_menor10

    subb #(0x10-0xA)          ; Ajuste para el índice (por el BCD)
    
    cd_menor10:
      cmpa b, x               ; Número de días del mes en el que estamos
      bls inc8_rts            ; Saltamos a un return. Podía ser el de nuestra función, pero ocupa menos
                              ; saltar al de otra.
      
      ldb b, x                ; B = dias[mes-1]
      bsr resta_ajustada      ; dias = dias - dias[mes-1]
      sta *a_dia

    lda *a_mes
    bsr inc8                  ; mes++
    bsr corregir_mes          ; Corregimos el mes y guardamos el valor corregido en *a_mes

    bra cd_while

; FUNCIÓN
;       Resta 12 al mes que tenemos hasta quedarnos
;       con uno válido e incrementa el año con cada vuelta
; 
;   Entrada: 
;       A (mes)
;
;   Salida:
;       A (a_mes ajustado) = a_mes
;       a_mes
;
;   Registros afectados: A, B
corregir_mes:
  cmpa #0x12
  bhi cm_cuerpowhile

  sta *a_mes                ; No corregimos el mes
  rts 

  cm_cuerpowhile:
    ldb #0x12
    bsr resta_ajustada      ; mes = mes -12
    bsr incano              ; ano++

    bra corregir_mes

; FUNCIÓN
;       Incrementa un número de 8 bits en BCD
; 
;   Entrada: 
;       A (número a incrementar) 
;
;   Salida:
;       A (número incrementado)
;
;   Registros afectados: A, B
inc8:
  inca
  tfr a,b
  andb #0x0f            ; Comprobamos si la última cifra es 
  cmpb #0x0a            ; A-F
  bne inc8_segunda
  adda #6               ; Convertirmos en BCD
inc8_segunda:
  cmpa #0xa0            ; Comprobamos si la primera cifra es 
  blo inc8_rts          ; A-F
  clra                  ; Convertimos en BCD
inc8_rts:
  rts
  
; FUNCIÓN
;       Incrementa un número de 16 bits en BCD (año)
; 
;   Entrada: 
;       a_ano_segunda 
;
;   Salida:
;       a_ano_segunda y a_ano_primera
;
;   Registros afectados: A, S
incano:
  pshs a                      ; Guardamos el valor de A para no borrarlo

  lda *a_ano_segunda
  bsr inc8                    ; Incrementamos las dos últimas cifras
  sta *a_ano_segunda
  bne incano_ret              ; A vacío (00) para hacer el cambio
                              ; de milenio 
  incano_2000:
    lda #0x20
    sta *a_ano_primera

  incano_ret:
    ; Al hacer puls pc, hago lo mismo que rts, pero con una instrucción menos.
    puls a, pc                    ; Restauramos el valor después de incrementar

; FUNCIÓN
;       Suma i (BCD, 8 bits) a otro número en BCD de 8 bits
; 
;   Entrada: 
;       A (número a sumar) 
;
;   Salida:
;       A (suma)
;
;   Registros afectados: A
suma_i:
  adda *iBCD 
  daa             ; Podemos usar daa a secas porque la suma 
  rts             ; nunca > 0x61 (falla cuando pasa de 0x90)

programa:
  ; Inicializar stack
  lds #0xF000

  ; Bucle principal -> for(int i = 0; i <= nCumples; i++)
  clra clrb            
  std *i                      ; Inicilizamos i a 0
  mbuclei:
    ldd aNo, pcr              ; Cargamos dia, mes año originales en las 
    std *a_ano                ; variables auxiliares, con las que
    ldb mes+1, pcr            ; vamos a trabajar
    stb *a_mes
    ldb dia+1, pcr
    stb *a_dia

    ; Función en línea: sumaano
    ;
    ; Entrada:
    ;          a_año: primer número
    ;          nCumples: segundo número
    ; Registros afectados: 
    ; Salida:
    ;          a_año: suma
    ; Función en linea
    ;      Suma dos números (8 y 16 bits) en BCD (i y aNo)
    ;
    ;   Explicacion:
    ;      Para ahorrarnos espacio, lo hemos hecho en forma de bucle.
    ;      Lo que hacemos es incrementar año j veces, mientras j
    ;      sea menor que i, de esta manera es como si sumasemos
    ;      i y año. (año += i)
    ;
    ;   Entrada:
    ;       a_ano
    ;       iBCD
    ;
    ;   Salida: 
    ;       a_ano
    ;
    ;   Registros afectados: D, listadiasmes
    sumaano:
      clra                      ; j = 0 para el bucle
      sa_bucle:                 
        cmpa *iBCD              ; while j < i
        bhs sa_ret

        bsr incano              ; ano++               

        bsr inc8                ; j++
        bra sa_bucle            
      sa_ret:
    ; Fin de función en línea
    lda *a_mes                  ; mes += i
    bsr suma_i                  ;

    bsr corregir_mes 
    
    lbsr corregir_dia  

    lda *a_dia                  ; dia += i
    bsr suma_i                  ;
    sta *a_dia                  ;

    lbsr corregir_dia 

    bsr imprime_fecha

    lda *iBCD                   ; Incrementamos la variable BCD
    bsr inc8
    sta *iBCD
    
    lda *i                      ; Incrementamos la variable hexa
    inca
    sta *i

    cmpa nCumples, pcr
    bls mbuclei

  ; Final del programa
  clra
  sta fin

; FUNCIÓNES PARA IMPRIMIR

; FUNCIÓN
;       Imprime el mes por pantalla
; 
;   Entrada: 
;       B (mes) 
;
;   Salida:
;       Pantalla
;
;   Registros afectados: A, B, X
imprimeMes:
  leax lista_nombres, pcr     ; Cargamos la dirección anterior al comienzo de la 
                              ; tabla porque los meses empiezan en 1, en vez de 0

  ldb *a_mes                  ; Si el número es >=0x10, le restamos 0x6 (la distancia
  cmpb #0x10                  ; desde 0xA (10) y 0x10 (el número que queremos) para que
  blo iM_menor10              ; el número 0x10 de al elemento 10 (0xA), no al 16(0x10).
    subb #(0x10-0xA)          ; Osea, convertimos el BCD a hexa.
                              
  iM_menor10:
    iM_bucle:
      lda ,x+
      bne iM_bucle

    iM_cero:                
      decb                    ; Cuando encontramos un caracter 0, le restamos 1 a b.
      bne iM_bucle            ; Cuando llegamos a 0, imprimimos. 
                              ; BNE salta cuando no hemos llegado a 0

  ; Aquí pondríamos un bsr imprimeASCII y un rts, pero como es el final de la función,
  ; podríamos optimizarlo con un bra imprimeASCII en su lugar.
  ; Pero además, como imprimeASCII está justo debajo de esta función, no tenemos
  ; ni que saltar a ella.

; FUNCIÓN
;       Imprime la cadena ASCII marcada por X por pantalla
; 
;   Entrada: 
;       X (dirección de la cadena a imprimir) 
;
;   Salida:
;       Pantalla
;
;   Registros afectados: A, X
imprimeASCII:
  iA_bucle:
    lda ,x+
    beq in_rts 
    sta pantalla
    bra iA_bucle

; FUNCIÓN
;       Imprime la fecha en el formato correcto por la pantalla
; 
;   Entrada: 
;       A  
;
;   Salida:
;       Pantalla
;
;   Registros afectados: A
dospuntos: .asciz ": "
imprime_fecha:
  lda *iBCD                   ; Imprime i con el formato %02d
  bsr imprime_cifras

  leax dospuntos, pcr
  bsr imprimeASCII

  lda *a_dia                  ; Imprimimos a_dia con el formato %d
  cmpa #0x10                  ;
  blo if_menor10              ; Si a_dia < 10, no imprimimos la primera cifra
  
  bsr imprime_cifras
  bra if_finmenor10
  if_menor10:
    bsr imprime_cifra2
  if_finmenor10:

  bsr imprimeDe               ; Imprimimos el primer de
  bsr imprimeMes
  bsr imprimeDe

  lda *a_ano_primera          ; Imprimimos a_ano con el formato %d
  bsr imprime_cifras          ; Aquí la primera y segunda cifras
  lda *a_ano_segunda
  bsr imprime_cifras          ; Aquí la tercera y cuarta cifras

  lda #'\n-#'0                ; Cargar esto es una mickey-herramienta sorpresa
  bra imprime_num             ; para poder usar imprime_num (que añade #'0 a a) 

; FUNCIÓN
;       Imprime " de " por pantalla
; 
;   Entrada: 
;       X 
;
;   Salida:
;       Pantalla
;
;   Registros afectados: A, B
de: .asciz " de "
imprimeDe:
  leax de, pcr
  bra imprimeASCII

; FUNCIÓN
;       Imprime ambas cifras de un número en BCD (byte)
; 
;   Entrada: 
;       A 
;
;   Salida:
;       Pantalla
;
;   Registros afectados: 
imprime_cifras:
  pshs a
  lsra lsra lsra lsra
  bsr imprime_num
  puls a

; FUNCIÓN
;       Imprime la segunda cifra de un número en BCD (byte)
; 
;   Entrada: 
;       A 
;
;   Salida:
;       Pantalla
;
;   Registros afectados: A
imprime_cifra2:
  anda #0x0f

; Para ahorrar espacio, saltamos a esta mini-función cada vez que queramos hacer:
;       adda #'0
;       sta pantalla
;       rts
; ¡Así ahorramos 2 bytes (o 3)!
imprime_num:
  adda #'0
  sta pantalla
in_rts:
  rts

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

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa

