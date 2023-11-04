;-------------------------------------------------------------------------------
; Plantilla de código ensamblador MSP430 para usar con TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Incluir archivo header del MSP430

;-------------------------------------------------------------------------------
            .def    RESET                   ; Exportar el punto de entrada del
            								; programa para darlo a conocer al
            								; ensamblador
;-------------------------------------------------------------------------------
            .text                           ; Ensamblar en la memoria del programa.
            .retain                         ; Anulación de la vinculación condicional ELF
                                            ; y conservar la sección actual.
            .retainrefs                     ; Conservar las secciones que tengan
                                            ; referencias a la sección actual.

;-------------------------------------------------------------------------------
;Definir pocisiones del LCD
;pos          0 2 4 8  10 12
pos		.word 9,5,3,18,14,7

;Definir high y low bytes para generar caracteres
;char          0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28
;             ' '   A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P    Q    R    S    T    U    V    W    X    Y    Z    0    3
charH	.byte 0x00,0xEF,0xF1,0x9C,0xF0,0x9F,0x8E,0xBD,0x6F,0x90,0x78,0x0E,0x1C,0x6C,0x6C,0xFC,0xCF,0xFC,0xCF,0xB7,0x80,0x7C,0x0C,0x7C,0x00,0x00,0x90,0xFC,0xF3
charL	.byte 0x00,0x00,0x50,0x00,0x50,0x00,0x00,0x00,0x00,0x50,0x00,0x22,0x00,0xA0,0x82,0x00,0x00,0x02,0x02,0x00,0x50,0x00,0x28,0x10,0xAA,0xB0,0x28,0x28,0x00

;Definir high y low bytes para generar números
;num           0    1    2    3    4    5    6    7    8    9
numH	.byte 0xFC,0x00,0xDB,0xF3,0x67,0xB7,0xBF,0xE0,0xFF,0xE7
numL	.byte 0x28,0x50,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

;Definir los índices del string 'Team 03'
team		.word	0,0,0,0,0,20,5,1,13,0,27,28,0,0,0,0,0,-1

;Definir los índices del string 'Alex Demel'
alex		.word	0,0,0,0,0,1,12,5,24,0,4,5,13,5,12,0,0,0,0,0,-1

RESET       mov.w   #__STACK_END,SP         ; Inicializar stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Parar watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			; Equipo 03
			; Alex Demel
			; % de contribución
			; Braian Diaz
			; % de contribución
			; Elvin Cruz
			; % de contribución
			; Victor Cruz
			; % de contribución

			;Inicializar el LCD
			CALL	#SetupLCD

			;Dibujar Team03 en el LCD
			MOV		#team,R8
			CALL	#ScrollStr

	        JMP		$
			nop

;-------------------------------------------------------------------------------
;DrawChar
;Objetivo: Dibujar un caracter en la pantalla en la posición dada
;Precondiciones: La posición del caracter debe estar dada
;en R4 y el índice del caracter debe estar dado en R5.
;Postcondiciones: La pantalla mostrará el caracter
;dado por R5 en la posición dada por R4.
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
DrawChar:
  			MOV.B   charH(R5),0x0a20(R4)		;Accesar los segmentos (high/low)
  												;guardados en el índice de R5 y
  			MOV.B   charL(R5),0x0a20+1(R4)		;dibujar en la posición dada por
  												;R4+0x0a20 y R4+0x0a20+1
  			RET

;-------------------------------------------------------------------------------
;ScrollStr
;Objetivo: Dibujar un string 'scrolling' en la pantalla
;Precondiciones: La dirección del arreglo conteniendo el string debe estar dada en R8
;Postcondiciones: La pantalla mostrará el string dado por R8 'scrolling'
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
ScrollStr:
			PUSH	R4							;Guardar el contenido de R4
			PUSH	R5							;Guardar el contenido de R5
			PUSH	R6							;Guardar el contenido de R6
			PUSH	R7							;Guardar el contenido de R7
			PUSH	R9							;Guardar el contenido de R9

restart:	MOV.B   #0,R6						;Usar R6 como índice de comienzo
			MOV.B   #0,R9						;Usar R9 como contador

first:		CALL	#delay						;Esperar antes de reescribir la pantalla
			MOV.B   R6,R7						;Guardar R6 (ídice de comienzo) en R7 (índice general)

next:		MOV.B   pos(R9),R4					;Guardar la pocisión del caracter en R4
			MOV.W	R8,R5						;Guardar la dirección del arreglo en R5
			ADD.W	R7,R5						;Sumar el índice a R5
			MOV.W	@R5,R5						;Colocar el caracter apuntado por R5 en R5
			CALL	#DrawChar

			INCD.B	R9							;Incrementar contador
			INCD.B	R7							;Incrementar el índice general

	        CMP		#-1,R5						;Verificar si llegamos al último caracter
			JZ		restart						;Regresar al inicio
			CMP		#14,R9						;Verificar si llegamos a la última posición
			JNZ		next						;Si no hemos llegado, continúa
	        MOV.B   #0,R9						;Si llegamos al final, regresa a cero
	        INCD.W	R6							;Incrementar R6 (ídice de comienzo)
			JMP		first

			POP		R9							;Recuperar el contenido de R9
	        POP		R7							;Recuperar el contenido de R7
	        POP		R6							;Recuperar el contenido de R6
	        POP		R5							;Recuperar el contenido de R5
	        POP		R4							;Recuperar el contenido de R4

			RET

;-------------------------------------------------------------------------------
;SetupLCD
;Objetivo: Hacer la inicialización del display
;Precondiciones: No hay precondiciones
;Postcondiciones: El LCD estará inicializado
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
SetupLCD:

			;Inicializar segmentos 0 - 21; 26 - 43 del LCD
			MOV.W   #0xFFFF,&LCDCPCTL0
			MOV.W   #0xfc3f,&LCDCPCTL1
  		    MOV.W   #0x0fff,&LCDCPCTL2

UnlockGPIO  bic.w   #LOCKLPM5,&PM5CTL0      ; Desactivar el modo de alta impedancia
											; predeterminado de GPIO al encender para
											; activar configuraciones de puerto
											; previamente configuradas

			;Inicializar LCD_C
  		    ;ACLK, Divider = 1, Pre-divider = 16; 4-pin MUX
			MOV.W   #0x041e,&LCDCCTL0

  		    ;VLCD generado internamente,
  		    ;V2-V4 generado internamente, v5 a ground
  		    ;Establecer voltaje VLCD a 2.60v
  		    ;Habilitar la bomba de carga y seleccionar la referencia interna para ella
  		    MOV.W   #0x0208,&LCDCVCTL

			MOV.W   #0x8000,&LCDCCPCTL   ;Sincronización de reloj activada

			MOV.W   #2,&LCDCMEMCTL       ;Borrar memoria LCD

			;Encender LCD
			BIS.W   #1,&LCDCCTL0

			RET

;-------------------------------------------------------------------------------
;delay
;Objetivo: Que el programa espere un poco antes de continuar
;Precondiciones: No hay precondiciones
;Postcondiciones: El programa esperará un poco y continuará
;Autor: Alex Demel
;Fecha: 10/28/2023
;-------------------------------------------------------------------------------
delay:
			PUSH	R4							;Guardar el contenido de R4

			MOV.W	#0,R4						;Usar R4 como contador
cuenta:		INC		R4							;Incrementar R4
			CMP		#0xFFFF,R4					;Verificar si R4 llegó a su máximo
			JLO		cuenta						;Si no ha llegado, continúa

			POP		R4							;Recuperar el contenido de R4

			RET

;-------------------------------------------------------------------------------
; Definición de stackpointer
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Vectores de interrupción
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; Vector RESET del MSP430
            .short  RESET
