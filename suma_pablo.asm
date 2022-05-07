.area PROG (ABS)

;; CONSTANTES
pantalla .equ 0xFF00
fin      .equ 0xFF01
teclado  .equ 0xFF02

;; DIRECTIVAS
.org 0x100
.globl programa

;; VARIABLES

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
;          x: segundo número
; Registros afectados: 
; Salida:
;          a: suma
suma88:
  adda ,x
  bsr daa
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

; Función: inc16.
;   Incrementa un año (16 bits), optimizada.
; Entrada: d (número a incrementar)
; Salida: d
; Registros afectados:
inc16:
  incb
  tfr d,x
  tfr b,a
  andb #0x0f
  cmpb #0x0a
  bne inc16_segunda
  adda #6
inc16_segunda:
  cmpa #0xa0
  blo inc16_ret
  ldb #0xFF
  abx
  clra
inc16_ret:
  
  rts


programa:
  lda #0x69
  adda #0x7
  daa

  jsr suma88

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'

.org 0xFFFE
.word programa
