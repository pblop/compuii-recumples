.area PROG (ABS)

;; CONSTANTES
pantalla .equ 0xFF00
fin      .equ 0xFF01
teclado  .equ 0xFF02

;; DIRECTIVAS
.org 0x100
.globl programa

;; VARIABLES

ano: .byte 0x1

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
;          b: segundo número
; Registros afectados: 
; Salida:
;          a: suma
suma88:
  pshs b
  adda ,s
  bsr daa
  puls b
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
; Funciona casi bien del todo, falta corregir la tercera. 
;; Función: inc16.
;;   Incrementa un año (16 bits), optimizada.
;; Entrada: d (número a incrementar)
;; Salida: d
;; Registros afectados:
;inc16:
;  inc 3,u
;  ldd 2,u
;  ; pshs d          ; pila [D]
;  andb #0x0f
;  cmpb #0x0a
;  bne inc16_segunda
;  ldb #6
;  addb 3, u
;  stb 3, u
;inc16_segunda:
;  cmpb #0xa0
;  blo inc16_ret
;  ldb #0x60
;  addb 3, u
;  stb 3, u
;inc16_tercera:
;  ;lda 2, u
;  anda #0x0f
;  cmpa #0x0a
;  bne inc16_ret
;  ;ldb 3, u
;  addb #6
;  stb 3, u
;inc16_ret:
;  rts

; Función: inc16.
;   Incrementa un año (16 bits), optimizada.
; Entrada: año (stack)
; Salida: año (stack)
; Registros afectados: a
inc16:
  lda 3,u
  bsr inc8
  sta 3,u
  cmpa #0
  beq inc16_2000
  ; No debería de hacer falta esta línea.
  ; lda #0x19
  rts
inc16_2000:
  lda #0x20
  sta 2,u
  rts

programa:
  ldu #0xE000

  lda #1
  lda ano
  lda *ano
  lda 1,x
  lda 1,y
  lda 2,u
  lda 3,s
  pshu a
  ; Cargar dia, mes y año en el stack.
  ldx #0x1999
  ldd #0x0721
  pshu x, d

  lda ,u
  bsr inc8
  sta ,u
  lda 1,u
  bsr inc8
  sta 1,u
  
  nop
  bsr inc16

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'

.org 0xFFFE
.word programa
