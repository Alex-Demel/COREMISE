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

;Definir booleana para botón S1
s1Pressed	.word 	0

;Definir booleana para botón S2
s2Pressed	.word 	0

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
team		.word	0,0,0,0,0,20,5,1,13,0,27,28,0,0,0,0,0,0,0,-1

;Definir los índices del string 'Elvin Cruz'
elvin		.word	0,0,0,0,0,5,12,22,9,14,0,3,18,21,26,0,0,0,0,0,0,-1

;Definir los índices del string 'Victor Cruz'
victor		.word	0,0,0,0,0,22,9,3,20,15,18,0,3,18,21,26,0,0,0,0,0,0,-1

;Definir los índices del string 'Alex Demel'
alex		.word	0,0,0,0,0,1,12,5,24,0,4,5,13,5,12,0,0,0,0,0,0,-1

;Definir los índices del string 'Braian Diaz'
braian		.word	0,0,0,0,0,2,18,1,9,1,14,0,4,9,1,26,0,0,0,0,0,0,-1

;Definir las direcciones de los arreglos con los miembros
members		.word	team,elvin,victor,alex,braian,-1

RESET       mov.w   #__STACK_END,SP         ; Inicializar stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Parar watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

			; Equipo 03
			; Elvin Cruz
			; % de contribución
			; Victor Cruz
			; % de contribución
			; Alex Demel
			; % de contribución
			; Braian Diaz
			; % de contribución

			;Inicializar la aplicación
			CALL	#Setup

			;Establecer el estado 0
			MOV		#0,R14

;Manejar los diferentes estados de la aplicación
stateMachine:

			CMP		#0,R14							;Verificar si estamos en el comienzo
			JEQ		zeroState						;Ir al estado 0

			CMP		#1,R14							;Verificar si estamos en el estado 1
			JEQ		firstState						;Ir al primer estado

			JMP 	stateMachine					;Verificar estados nuevamente

zeroState:
			MOV		#members,R4						;Guardar la ubicación de los miembros
			CALL	#StartSub						;Llamar la subrutina que maneja el estado inicial
			JMP		stateMachine					;Verificar estados nuevamente

firstState:
			;CALL	#SubName						;Llamar la subrutina que maneja el estado
			JMP		stateMachine					;Verificar estados nuevamente

	        JMP		$
			nop

;-------------------------------------------------------------------------------
;StartSub
;Objetivo: Mostrar el número del equipo seguido por los miembros
;al oprimir S1. Cambiarán los miembros mostrados con cada uso del botón
;Precondiciones: La dirección del arreglo conteniendo los addresses de
;los miembros debe estar dado en el registro R8
;Postcondiciones: La pantalla mostrará el número del equipo seguido por los miembros
;Autor: Alex Demel
;Fecha: 11/6/2023
;-------------------------------------------------------------------------------
StartSub:
			PUSH	R5								;Guardar el contenido de R5
			PUSH	R8								;Guardar el contenido de R8

restart:	MOV.W	R4,R5							;Usar R5 como índice

next:		MOV.W	@R5+,R8							;Mover la dirección del primer integrante a R8
			CALL	#ScrollStr
			CMP		#1,R14
			JEQ		end
			CMP		#-1,0(R5)						;Verificar si seguimos en el arreglo
			JEQ		restart
			JMP		next

end:		POP		R5								;Recuperar el contenido de R5
			POP		R8								;Recuperar el contenido de R8

			RET

;-------------------------------------------------------------------------------
;ScrollStr
;Objetivo: Dibujar un string 'scrolling' en la pantalla
;Precondiciones: La dirección del arreglo conteniendo el string debe estar dada en R4
;Postcondiciones: La pantalla mostrará el string dado por R4 'scrolling'
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
ScrollStr:
			PUSH	R4								;Guardar el contenido de R4
			PUSH	R5								;Guardar el contenido de R5
			PUSH	R6								;Guardar el contenido de R6
			PUSH	R7								;Guardar el contenido de R7
			PUSH	R9								;Guardar el contenido de R9

restart2:	MOV.B   #0,R6							;Usar R6 como índice de comienzo
			MOV.B   #0,R9							;Usar R9 como contador

			MOV.B   #0,R14							;Establecer estado cero

			CMP		#team,R8						;Verificar si estamos mostrando el número de equipo
			JNZ		first							;Si no lo estamos mostrando, ve al comienzo
			MOV.B   #1,R14							;Si lo estamos mostrando, establece el estado 1

first:		MOV.B   R6,R7							;Guardar R6 (ídice de comienzo) en R7 (índice general)

			MOV.W	#31250,R4						;Establecer los ciclos a esperar
			CALL	#Delay							;Antes de volver a dibujar en la pantalla

next2:		MOV.B   pos(R9),R4						;Guardar la pocisión del caracter en R4
			MOV.W	R8,R5							;Guardar la dirección del arreglo en R5
			ADD.W	R7,R5							;Sumar el índice a R5
			MOV.W	@R5,R5							;Colocar el caracter apuntado por R5 en R5
			CALL	#DrawChar

			INCD.B	R9								;Incrementar contador
			INCD.B	R7								;Incrementar el índice general

	        CMP		#-1,R5							;Verificar si llegamos al último caracter
			JZ		restart2						;Regresar al inicio
			CMP		#14,R9							;Verificar si llegamos a la última posición
			JNZ		next2							;Si no hemos llegado, continúa
	        MOV.B   #0,R9							;Si llegamos al final, regresa a cero
	        INCD.W	R6								;Incrementar R6 (ídice de comienzo)

	        CMP		#1,s1Pressed					;Verificar si se oprimió s1
	        JEQ		s1Stop							;Parar la subrutina

	        CMP		#1,s2Pressed					;Verificar si se oprimió s2
	        JEQ		s2Stop							;Parar la subrutina

			MOV.W	#31250,R4						;Establecer los ciclos a esperar
			CALL	#Delay							;Luego de dibujar en la pantalla

			JMP		first							;Si el botón no se ha presionado, regresa al inicio

s1Stop:		MOV.B	#0,s1Pressed					;Booleana es falsa
			MOV.B   #0,R14							;Establecer estado cero
			JMP		stop

s2Stop:		MOV.B	#0,s2Pressed					;Booleana es falsa
			JMP		stop							;Si no es el caso, vuelve al comienzo

stop:		MOV.W   #2,&LCDCMEMCTL       			;Borrar memoria LCD

			POP		R9								;Recuperar el contenido de R9
	        POP		R7								;Recuperar el contenido de R7
	        POP		R6								;Recuperar el contenido de R6
	        POP		R5								;Recuperar el contenido de R5
	        POP		R4								;Recuperar el contenido de R4

			RET

;-------------------------------------------------------------------------------
;DrawChar
;Objetivo: Dibujar un caracter en la pantalla en la posición dada por R4
;Precondiciones: La posición del caracter debe estar dada en R4 y el índice
;del caracter debe estar dado en R5.
;Postcondiciones: La pantalla mostrará el caracter dado por R5 en la posición
;dada por R4.
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
;DrawNum
;Objetivo: Dibujar un número en la pantalla en la posición dada por R4
;Precondiciones: La posición del número debe estar dada en R4 y el índice
;del número debe estar dado en R5.
;Postcondiciones: La pantalla mostrará el número dado por R5 en la posición
;dada por R4.
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
DrawNum:
  			MOV.B   numH(R5),0x0a20(R4)			;Accesar los segmentos (high/low)
  												;guardados en el índice de R5 y
  			MOV.B   numL(R5),0x0a20+1(R4)		;dibujar en la posición dada por
  												;R4+0x0a20 y R4+0x0a20+1
  			RET

;-------------------------------------------------------------------------------
;Delay
;Objetivo: Esperar x cantidad de ciclos antes de continuar el programa
;Precondiciones: La cantidad de ciclos a esperar debe estar dada en R4
;Postcondiciones: El programa esperará la cantidad de ciclos dados en R4 y continuará
;Autor: Alex Demel
;Fecha: 11/4/2023
;-------------------------------------------------------------------------------
Delay:
			BIS    	#BIT4,TA0CTL			;Empezar el timer
			MOV     R4,TA0CCR0       	 	;Establecer los ciclos de espera
			BIS		#CPUOFF, SR				;Entrar a low power
			RET

;-------------------------------------------------------------------------------
;Setup
;Objetivo: Iniciar el display y habilitar interrupciones del timer
;Precondiciones: No hay precondiciones
;Postcondiciones: El LCD y Timer estarán inicializados
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
Setup:

UnlockGPIO:
			bic.w   #LOCKLPM5,&PM5CTL0      ; Desactivar el modo de alta impedancia
											; predeterminado de GPIO al encender para
											; activar configuraciones de puerto
											; previamente configuradas

			;----------------------------------------------------------------------
			;								Botones

  		    ;Inicializar los botones
	        BIC.B   #0xFF,&P1SEL0
	        BIC.B   #0xFF,&P1SEL1			;Establecer PxSel0 y PxSel1 como digital I/O

	        MOV.B   #11111001B,&P1DIR       ;Establecer P1.1 y P1.2 como input y los demás como output

	        MOV.B   #00000110B,&P1REN       ;Activar los resistores pullup/pulldown de P1.1 y P1.2

	        BIS.B   #00000110B,&P1OUT       ;Establecer resistores como pullup

	        BIS.B   #2, &P1IE             	;Habilitar la interrupción de P1.1
	        BIS.B   #4, &P1IE             	;Habilitar la interrupción de P1.2

	        BIC.B   #0000110b, &P1IFG		;Borrar flags previos

			;----------------------------------------------------------------------
			;								Display

			;Inicializar segmentos 0 - 21; 26 - 43 del LCD
			MOV.W   #0xFFFF,&LCDCPCTL0
			MOV.W   #0xfc3f,&LCDCPCTL1
  		    MOV.W   #0x0fff,&LCDCPCTL2

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

			;----------------------------------------------------------------------
			;								Timer

			NOP
			BIS     #GIE, SR	;Habilitar interrupciones
			NOP

    		;Cambiar fuente de reloj a SMLCK = 1 MHz  (#TASSEL_2)
			;Cambiar modo a 'Stop'  (MC_0)
			;Establecer divisor de input 4 (ID_2)

			MOV		#CCIE, &TA0CCTL0        ;Habilitar interrupción TACCR0

	        MOV     #TASSEL_2+MC_0+ID_2, &TA0CTL

		    NOP

			RET

;-------------------------------------------------------------------------------
TA0_ISR:
	        BIC    	#BIT5+BIT4,TA0CTL  		;Parar el timer
	        MOV		#CCIE, &TA0CCTL0        ;Rehabilitar interrupción TACCR0
	        BIC		#0x10, 0(SP)			;Salir de low power
	        RETI

;-------------------------------------------------------------------------------
PORT1_ISR:
            BIT.B   #00000010b, &P1IFG      ;Verificar P1.1
            JNZ		s1Press

            BIT.B   #00000100b, &P1IFG      ;Verificar P1.2
            JNZ		s2Press

s1Press:
			MOV.B	#1,s1Pressed			;Booleana es cierta
			JMP 	end2
s2Press:
			CMP		#0,R14					;Verificar si estamos en el estado 0
			JEQ		end2					;Si estamos en el estado 0, terminar
			MOV.B	#1,s2Pressed			;De lo contario, poner booleana cierta
			JMP 	end2
end2:
			BIC 	#00000010b, &P1IFG		;Borrar flag de P1.1
			BIC	    #00000100b, &P1IFG		;Borrar flag de P1.2

            RETI

;-------------------------------------------------------------------------------
; Definición de stackpointer
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Vectores de interrupción
;-------------------------------------------------------------------------------
            .sect   ".reset"                ;Vector RESET del MSP430
            .short  RESET
            .sect   ".int37"    			;Port1 Interrupt
            .short  PORT1_ISR
            .sect   ".int44"				;TA0 Interrupt
            .short  TA0_ISR
