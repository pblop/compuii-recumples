; definimos un par de constantes
fin     .equ 0xFF01
pantalla .equ 0xFF00

	.globl programa

temp:   .byte 0 ; una variable temporal
prefijo:.asciz "0x"

programa:
	lda #28 ; pongamos este nUmero como prueba
        jsr imprimir_byte_hexa
        ; imprimamos un salto de lInea al final
        lda #'\n
        sta pantalla

        ; el programa acaba
        clra
	sta fin


imprimir_byte_hexa:
        ldx #prefijo
        jsr imprime_cadena

        ; primero imprimamos la primera cifra hexadecimal
        sta temp ; guardamos A en temp
        lsra
        lsra
        lsra
        lsra ; en temp estA la primera cifra, de 0 a 15
        beq segunda
        cmpa #10
        blo menor10
        adda #7
menor10:adda #'0
        sta pantalla

segunda:
        lda temp ; recuperamos el valor original
        anda #0b1111
        cmpa #10
        blo menor10bis
        adda #7
menor10bis:
        adda #'0
        sta pantalla

        lda temp
        rts

imprime_cadena:
        pshs a
sgte:   lda ,x+
        beq ret_imprime_cadena
        sta pantalla
        jmp sgte
ret_imprime_cadena:
        puls a
        rts