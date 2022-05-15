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
; Afecta: d
actualiza_bisiesto:
  ldd ano ;; TODO: Posiblemente optimizable.

  ; Si el último bit de la última cifra es 1, no es bisiesto.
  bitb #0b00000001
  bne actualiza_bisiesto_no_bisiesto

  andb #0b00010010
  beq actualiza_bisiesto_si_bisiesto
  cmpb #0b00010010
  beq actualiza_bisiesto_si_bisiesto

  actualiza_bisiesto_no_bisiesto:
    ldb #0x28
  actualiza_bisiesto_si_bisiesto:
    ldb #0x29
  actualiza_bisiesto_ret:
    stb tabladiasmes+2-1
    rts

;; void corregirMes()
;; {
;;   while (mes > 12)
;;   {
;;     mes -= 12;
;;     ano++;
;;   }
;; }

; Función: vuelve a enero cuando estamos en diciembre e incrementa el ano
; Entrada: a (mes)
; Salida: a (mes modificado)
; Afecta: 

corregir_mes:
  cmpa #12
  bhi corregir_mes_bucle
  bra corregir_mes_return

corregir_mes_bucle:
  suba #12

  ;; OPCIONES
  ;; 1. Poner el ano en el registro d y el mes en una pila, y con la instruccion cmpu o cmpx o lo que sea comparar
  ;; 2. Poner el mes en el registro a, y cuando llegue aqui guardar el valor, cargar el ano y volver a cargar el mes

  cmpa #12
  bhi corregir_mes_bucle

corregir_mes_return:
  rts

; void corregirDia()
; {
;   while (1)
;   {
;     actualizarBisiesto();
;     if (!(dia > dias[mes - 1]))
;       break;
; 
;     dia = dia - dias[mes - 1];
;     mes++;
;     corregirMes();
;   }
; }

; Funcion: corregir el dia si nos pasamos de los que puede tener un mes
; Entrada: a (dia)
;          b (mes)

; Salida: a (dia)
; Registros afectados

corregir_dia:
  bra actualiza_bisiesto
  addb (tabladiasmes-1) ; numero de dias del mes en el que estamos
  cmpa

  bra corregir_dia

corregir_dia_return:
  rts


programa:
  lds #0xF000
  ; Final del programa
  clra
  sta fin

; Iniciar el programa en 'programa'
.org 0xFFFE
.word programa


;; TE QUIERO <3
