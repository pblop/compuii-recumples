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


; Función: suma88                Suma dos números en BCD.
; Entrada:
;          a: primer número
;          x: segundo número
; Registros afectados: 
; Salida:
;          a: suma
suma88:
  adda ,x
  ;; si el segundo dígito es a..f, sumar 6
  tfr a,b
  andb #0x0f
  cmpb #0x0a
  beq sumar88_suma6
  ;; si H=1, sumar 6
  tfr cc,b
  bitb #%00100000
  ; Ahora mismo Z=0 si H=1, Z=1 si H=0
  beq suma88_ret ; beq salta si Z=1
  
  suma88_suma6:
    adda #6
  suma88_ret:
    rts

incrementa:
  inca
  tfr a,b
  andb #0x0f
  cmpb #0x0a
  bne incrementaSegunda
  adda #6
incrementaSegunda:
  cmpa #0xa0
  blo incrementa
  clra
incrementaRetorno:
  rts

programa:
  lda #12
  adda #9
  tfr cc,a

  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'

.org 0xFFFE
.word programa
