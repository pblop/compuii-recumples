.area PROG (ABS)

;; CONSTANTES
pantalla .equ 0xFF00
fin      .equ 0xFF01
teclado  .equ 0xFF02

;; DIRECTIVAS
.org 0x100
.globl programa

;; VARIABLES
nCumples: .byte 0x42

;; FUNCIONES

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; daa                                                              ;
;     simula la instrucciOn daa del ensamblador                    ;
;     se debe usar detAs de la instrucciOn adda para sumas BCD     ;
;                                                                  ;
;   Entrada: A-resultado de la suma    CC-flags de la suma         ;
;   Salida:  A-resultado ajustado BCD  CC-flags ajustados BCD      ;
;   Registros afectados: ninguno                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

daa:
  pshs a,cc
  lda ,s             ; A=CC
  clr ,-s            ; S-> 00 CC A
  anda #0x20         ; bit H de CC
  bne daa_ajusteBajo ; si H=1, hay que ajustar la cifra baja
  lda 2,s            ; si H=0 y la cifra baja>9, ajustarla
  anda #0xF
  cmpa #0xA
  blo daa_sinAjusteBajo
daa_ajusteBajo:
  lda #6
  sta ,s
daa_sinAjusteBajo:
  lda #1
  anda 1,s
  bne daa_ajusteAlto    ; si flag C=1, hay que ajustar la alta
  lda 2,s               ; o si C=0 y resultado>0x9A
  cmpa #0x9A
  blo daa_sinAjusteAlto
daa_ajusteAlto:
  lda ,s
  ora #0x60
  sta ,s
daa_sinAjusteAlto:
  lda  ,s+   ; aNadimos el ajuste a A
  adda 1,s
  sta  1,s
  tfr cc,a   ; el flag C es el or del C original y el de la suma
  ora ,s
  sta ,s
  puls cc,a
  tsta       ; ajustamos los flags Z y N del resultado
  rts

; Función: suma88                Suma dos números en BCD.
; Entrada:
;          a: primer número
;          nCumples: segundo numero
; Registros afectados: 
; Salida:
;          a: suma
suma88:
  adda nCumples
  bsr daa
  rts

; Función: suma816               Suma dos números (8 y 16 bits) en BCD.
; Entrada:
;          d: primer número
;          nCumples: segundo numero
; Registros afectados: 
; Salida:
;          d: suma
suma816:
  tfr b,a 
  bsr suma88
  tfr a,b
  blo suma816_carry
  lda #0x19

  bra suma816_ret
suma816_carry:
  lda #0x20
suma816_ret:
  rts

;; intento fallido
;;    pshs d ; guardamos en numero en la pila
;;    ; comprobamos el carry de la suma de las unidades
;;    ; para ello me voy a quedar solo con la cifra de las unidades, voy a sumarlas
;;    ; y voy a ver si esta suma es mayor o igual a 10
;;    andb #0x0f
;;    lda ,y
;;    anda #0x0f
;;    tfr a,x ; no puedo hacer esto viva
;;    abx ; sumamos el registro x y b, el resultado se queda en x
;;    ldb ,x
;;    cmpb #10
;;    bhs unidades_carry
;;    ldx #0;; 
;;  unidades_carry:
;;    ldx #1;; 
;;    ; comprobamos las decenas
;;    puls d
;;    pshs d
;;    andb #0xf0
;;    lda ,y
;;    anda #0xf0
;;    adda ,x
;;    tfr a,x
;;    abx
;;    ldb ,x
;;    cmpb #10
;;    bhs decenas_carry
;;    puls d;; 
;;  decenas_carry:
;;    puls d
;;    ldb #20 ; el rango de anos va desde 1900 y pico hasta 2000 y pico, no hay mas posibilidades;; 
;;    ; ahrora sumamos
;;    pshs a
;;    tfr b,a
;;    bsr suma88
;;    tfr a,b
;;    puls a

; Función: inc8.
;   Incrementa un número de 8 bits
; Entrada: b (número a incrementar)
; Salida: b
; Registros afectados: 
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

; Función: inc16.
;   Incrementa un año (16 bits), optimizada.
; Entrada: d (número a incrementar)
; Salida: d
; Registros afectados:
inc16:
  tfr b,a
  bsr inc8
  cmpa #0
  tfr a,b
  beq inc16_2000
  lda #0x19
  bra inc16_ret
inc16_2000:
  lda #0x20 
inc16_ret:
  rts

programa:
  ldd #0x1999
  jsr inc16

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'

.org 0xFFFE
.word programa
