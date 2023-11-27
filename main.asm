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

;Definir la longitud de medio segundo
secLen		.word 	62500

;Definir word para la velocidad del conteo
speed		.word 	0

;Definir high y low bytes para generar caracteres
;char          0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28
;             ' '   A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P    Q    R    S    T    U    V    W    X    Y    Z    0    3
charH	.byte 0x00,0xEF,0xF1,0x9C,0xF0,0x9F,0x8E,0xBD,0x6F,0x90,0x78,0x0E,0x1C,0x6C,0x6C,0xFC,0xCF,0xFC,0xCF,0xB7,0x80,0x7C,0x0C,0x7C,0x00,0x00,0x90,0xFC,0xF3
charL	.byte 0x00,0x00,0x50,0x00,0x50,0x00,0x00,0x00,0x00,0x50,0x00,0x22,0x00,0xA0,0x82,0x00,0x00,0x02,0x02,0x00,0x50,0x00,0x28,0x10,0xAA,0xB0,0x28,0x28,0x00

;Definir high y low bytes para generar números
;num           0    1    2    3    4    5    6    7    8    9	' '
numH	.byte 0xFC,0x00,0xDB,0xF3,0x67,0xB7,0xBF,0xE0,0xFF,0xE7,0x00
numL	.byte 0x28,0x50,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

;Definir los índices del string 'Team 03'
team		.word	0,0,0,0,0,0,20,5,1,13,0,27,28,0,0,0,0,0,0,0,-1

;Definir los índices del string 'Elvin Cruz'
elvin		.word	0,0,0,0,0,0,5,12,22,9,14,0,3,18,21,26,0,0,0,0,0,0,-1

;Definir los índices del string 'Victor Cruz'
victor		.word	0,0,0,0,0,0,22,9,3,20,15,18,0,3,18,21,26,0,0,0,0,0,0,-1

;Definir los índices del string 'Alex Demel'
alex		.word	0,0,0,0,0,0,1,12,5,24,0,4,5,13,5,12,0,0,0,0,0,0,-1

;Definir los índices del string 'Braian Diaz'
braian		.word	0,0,0,0,0,0,2,18,1,9,1,14,0,4,9,1,26,0,0,0,0,0,0,-1

;Definir las direcciones de los arreglos con los miembros
members		.word	team,elvin,victor,alex,braian,-1

;Definir variable para estado del timer
timerState	.word 	0

;Definir variable para ciclos
timeCycles	.word 	0

;Definir booleana para debouncing
debounce	.byte 	0

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

			MOV		#0,R15							;Establecer el estado 0
			MOV.W   #2,&LCDCMEMCTL       			;Borrar memoria LCD
			MOV		#62500,secLen					;Recuperar la duración de 0.5s
			MOV		#0,speed						;Darle clear a la velocidad de conteo

;Manejar los diferentes estados de la aplicación
stateMachine:

			CMP		#0,R15							;Verificar si estamos en el comienzo
			JEQ		zeroState						;Ir al estado cero

			CMP		#1,R15							;Verificar si estamos en el estado 1
			JEQ		firstState						;Ir al primer estado

			CMP		#2,R15							;Verificar si estamos en el estado 2
			JEQ		secondState						;Ir al segundo estado

			CMP		#3,R15							;Verificar si estamos en el estado 3
			JEQ		thirdState						;Ir al tercer estado

			CMP		#4,R15							;Verificar si estamos en el estado 4
			JEQ		fourthState						;Ir al cuarto estado

			CMP		#5,R15							;Verificar si estamos en el estado 5
			JEQ		fifthState						;Ir al quinto estado

			JMP 	stateMachine					;Verificar estados nuevamente

zeroState:
			MOV		#members,R8						;Guardar la ubicación de los miembros
			CALL	#StartSub						;Llamar la subrutina que maneja el estado inicial
			JMP		stateMachine					;Verificar estados nuevamente

firstState:
			CALL	#NumSelect						;Comenzar la selección de números
			JMP		stateMachine					;Verificar estados nuevamente

secondState:
			CALL	#ReadyCheck						;Verificar si comenzammos el conteo
			JMP		stateMachine					;Verificar estados nuevamente

thirdState:
			CALL	#CounterSub						;Comenzar el conteo
			JMP		stateMachine					;Verificar estados nuevamente

fourthState:
			PUSH	TA0CTL							;Grabar el estado del timer

			MOV     #TASSEL_2+MC_0+ID_3,&TA0CTL		;Establecer frecuencia base
			CALL	#NumBlink						;Parpadear la pantalla

			POP		TA0CTL							;Recuperar el estado del timer
			MOV		TA0CTL,timerState				;Grabar estado

			JMP		stateMachine					;Verificar estados nuevamente

fifthState:
			MOV     #TASSEL_2+MC_0+ID_3,&TA0CTL		;Establecer frecuencia base
			CALL	#NumBlink						;Parpadear la pantalla

			MOV.W   #2,&LCDCMEMCTL       			;Borrar memoria LCD
			MOV		#0,speed						;Darle clear a la velocidad de conteo
			MOV		#62500,secLen					;Recuperar la duración de 0.5s
			MOV     #TASSEL_2+MC_0+ID_3,&TA0CTL		;Establecer frecuencia base
			MOV		TA0CTL,timerState				;Grabar estado base

			MOV.W	#6250,R4						;Establecer los ciclos a esperar
			CALL	#Delay

			JMP		stateMachine					;Verificar estados nuevamente

	        JMP		$
			nop

;-------------------------------------------------------------------------------
;CounterSub
;Objetivo: Contar regresivamente usando los registros R11-R14. Los valores de
;los registros son mostrados en las últimas 4 posiciones de la pantalla.
;Precondiciones: Debemos estar en el estado 3 (R15 debe contener #3)
;Postcondiciones: La subrutina contará hasta que todos los registros sean cero
;o hasta que ocurra una interrupción / cambio de estado.
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
CounterSub:

			BIS.B   #0x04,&0x0A33					;Dibujar ':' antes de todos los números
			CALL	#OneSecond						;Esperar 1s y continuar

			CALL	#CheckEnd						;Verificar si continuamos en el estado 3
			CMP.B	#3,R15
			JNZ		timeEnd

endPause:	CMP.B	#0,R14							;Verificar si secondLow es cero
			JNZ		secLo							;De no ser el caso, manejar secLo
			MOV.B	#10,R14							;De ser el caso, colocar 10 en secLo
			CALL	#DecSecondLow					;E inmediatamente decrementar a 9
			JMP		secHiChk						;Chequear si podemos decrementar secHi

secLo:		CALL	#DecSecondLow					;Decrementar secondLow
			JMP		CounterSub						;Volver al comienzo

secHiChk:	CMP.B	#0,R13							;Verificar si secondHigh es cero
			JNZ		secHi							;De no ser el caso, manejar secHi
			MOV.B	#6,R13							;De ser el caso, colocar 6 en secHi
			CALL	#DecSecondHigh					;E inmediatamente decrementar a 5
			JMP		minLoChk						;Chequear si podemos decrementar minLo

secHi:		CALL	#DecSecondHigh
			JMP		CounterSub						;Volver al comienzo

minLoChk:	CMP.B	#0,R12							;Verificar si minuteLow es cero
			JNZ		minLo							;De no ser el caso, manejar minLo
			MOV.B	#10,R12							;De ser el caso, colocar 10 en minLo
			CALL	#DecMinuteLow					;E inmediatamente decrementar a 9
			JMP		minHiChk						;Chequear si podemos decrementar minHi

minLo:		CALL	#DecMinuteLow
			JMP		CounterSub						;Volver al comienzo

minHiChk:	CMP.B	#0,R11							;Verificar si minuteHigh es cero
			JNZ		minHi							;De no ser el caso, manejar minHi
			JMP		CounterSub						;De ser el caso, volver al comienzo

minHi:		CALL	#DecMinuteHigh
			JMP		CounterSub						;Volver al comienzo

timeEnd:
			RET

;-------------------------------------------------------------------------------
;CountSpeed
;Objetivo: Incrementar la velocidad de conteo basado en la variable speed
;Precondiciones: El word que contiene la velocidad debe estar definido
;Postcondiciones: Se incrementará la velocidad de conteo si se cumplen las condiciones
;Autor: Alex Demel
;Fecha: 11/8/2023
;-------------------------------------------------------------------------------
CountSpeed:

			CMP		#0,speed						;Verificar velocidad 0
			JZ		endSpeed						;De ser el caso, terminar

speed1:
			CMP		#1,speed						;Verificar velocidad 1
			JNZ		speed2							;De no ser el caso, verificar prox.
			MOV     #TASSEL_2+MC_0+ID_2,&TA0CTL		;De ser el caso, ajustar Input Divider
			JMP		endSpeed						;Terminar

speed2:
			CMP		#2,speed						;Verificar velocidad 2
			JNZ		speed3							;De no ser el caso, verificar prox.
			MOV     #TASSEL_2+MC_0+ID_1,&TA0CTL		;De ser el caso, ajustar Input Divider
			JMP		endSpeed						;Terminar

speed3:
			CMP		#3,speed						;Verificar velocidad 3
			JNZ		speed4							;De no ser el caso, verificar prox.
			MOV     #TASSEL_2+MC_0+ID_0,&TA0CTL		;De ser el caso, ajustar Input Dividerider
			JMP		endSpeed						;Terminar
speed4:
			CMP		#1,secLen						;Verificar si podemos decrementar la duración
			JEQ		endSpeed						;Si la duración es 1, no decrementamos

			RRA		secLen							;Dividir la duración de 0.5s a la mitad
			BIC		#0x8000,secLen					;Darle clear al MSB de la duración
			JMP		endSpeed						;Terminar

endSpeed:
			RET

;-------------------------------------------------------------------------------
;ReadyCheck
;Objetivo: Entrar a low power hasta que se oprima S2
;Precondiciones: Debemos estar en el estado 2 (R15 debe contener #2)
;Postcondiciones: Entraremos en low power
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
ReadyCheck:

			NOP
			BIS		#GIE+LPM0,SR					;De lo contrario, entrar a low power
			NOP
			RET

;-------------------------------------------------------------------------------
;NumBlink
;Objetivo: Hacer 'Blinking' en los números que estan mostrados en la pantalla
;Precondiciones: Los registros R11-14 deben estar definidos y contener MM:SS respectivamente
;Postcondiciones: los números que estan mostrados en la pantalla harán 'Blinking'
;Autor: Alex Demel
;Fecha: 11/8/2023
;-------------------------------------------------------------------------------
NumBlink:

			MOV.B   #3,R10							;Guardar la pocisión de minuteHigh
			MOV.W	#10,R5							;Darle clear a minuteHigh (Blinking)
			CALL	#DrawNum						;Dibujar en la posición de minuteHigh

			MOV.B   #18,R10							;Guardar la pocisión de minuteLow
			MOV.W	#10,R5							;Darle clear a minuteLow (Blinking)
			CALL	#DrawNum						;Dibujar en la posición de minuteLow

			MOV.B   #14,R10							;Guardar la pocisión de secondHigh
			MOV.W	#10,R5							;Darle clear a secondHigh (Blinking)
			CALL	#DrawNum						;Dibujar en la posición de secondHigh

			MOV.B   #7,R10							;Guardar la pocisión de secondLow
			MOV.W	#10,R5							;Darle clear a secondLow (Blinking)
			CALL	#DrawNum						;Dibujar en la posición de secondLow

			MOV.W	#12500,R4						;Establecer los ciclos a esperar
			CALL	#Delay

draw:		MOV.B   #3,R10							;Guardar la pocisión de minuteHigh
			MOV.W	R11,R5							;Guardar el valor de minuteHigh en R5
			CALL	#DrawNum						;Dibujar en la posición de minuteHigh

			MOV.B   #18,R10							;Guardar la pocisión de minuteLow
			MOV.W	R12,R5							;Guardar el valor de minuteLow en R5
			CALL	#DrawNum						;Dibujar en la posición de minuteLow

			MOV.B   #14,R10							;Guardar la pocisión de secondHigh
			MOV.W	R13,R5							;Guardar el valor de secondHigh en R5
			CALL	#DrawNum						;Dibujar en la posición de secondHigh

			MOV.B   #7,R10							;Guardar la pocisión de secondLow
			MOV.W	R14,R5							;Guardar el valor de secondLow en R5
			CALL	#DrawNum						;Dibujar en la posición de secondLow

			MOV.W	#12500,R4						;Establecer los ciclos a esperar
			CALL	#Delay

			CMP.B	#4,R15							;Verificar si estamos en pausa
			JZ		NumBlink						;De ser el caso, continuar blinking

			CMP.B	#5,R15							;Verificar si terminamos el conteo
			JZ		NumBlink						;De ser el caso, continuar blinking

			JMP		blinkEnd						;Si no es el caso, terminar

blinkEnd:
			RET

;-------------------------------------------------------------------------------
;CheckEnd
;Objetivo: Verificar si llegamos al final del conteo
;Precondiciones: Los registros R11-14 deben estar definidos y contener MM:SS respectivamente
;Postcondiciones: Se mostrará 00:00 en la pantalla hasta que se presione S1.
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
CheckEnd:
			CMP		#0,R11							;Verificar si todos los registros son cero
			JNZ		ignore							;De lo contrario ignorar
			CMP		#0,R12
			JNZ		ignore
			CMP		#0,R13
			JNZ		ignore
			CMP		#0,R14
			JNZ		ignore

			CALL	#NumBase						;Dibujar 00:00 en la pantalla
			MOV		#5,R15							;Establecer el estado 5

ignore:
			RET

;-------------------------------------------------------------------------------
;DecMinuteHigh
;Objetivo: Decrementar minuteHigh por 1
;Precondiciones: El registro R11 debe contener el número correspondiente a minuteHigh
;Postcondiciones: R11 será decrementado por 1 y la pantalla reflejará el cambio
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
DecMinuteHigh:

			MOV.B   #3,R10							;Guardar la pocisión de minuteHigh
			DEC.B	R11								;Decrementar R13 (minuteHigh)
			MOV.W	R11,R5							;Guardar el valor decrementado en R5
			CALL	#DrawNum						;Dibujar en la posición de minuteHigh
			RET

;-------------------------------------------------------------------------------
;DecMinuteLow
;Objetivo: Decrementar minuteLow por 1
;Precondiciones: El registro R12 debe contener el número correspondiente a minuteLow
;Postcondiciones: R12 será decrementado por 1 y la pantalla reflejará el cambio
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
DecMinuteLow:

			MOV.B   #18,R10							;Guardar la pocisión de minuteLow
			DEC.B	R12								;Decrementar R13 (minuteLow)
			MOV.W	R12,R5							;Guardar el valor decrementado en R5
			CALL	#DrawNum						;Dibujar en la posición de minuteLow
			RET

;-------------------------------------------------------------------------------
;DecSecondHigh
;Objetivo: Decrementar secondHigh por 1
;Precondiciones: El registro R13 debe contener el número correspondiente a secondHigh
;Postcondiciones: R13 será decrementado por 1 y la pantalla reflejará el cambio
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
DecSecondHigh:

			MOV.B   #14,R10							;Guardar la pocisión de secondHigh
			DEC.B	R13								;Decrementar R13 (secondHigh)
			MOV.W	R13,R5							;Guardar el valor decrementado en R5
			CALL	#DrawNum						;Dibujar en la posición de secondHigh
			RET

;-------------------------------------------------------------------------------
;DecSecondLow
;Objetivo: Decrementar secondLow por 1
;Precondiciones: El registro R14 debe contener el número correspondiente a secondLow
;Postcondiciones: R14 será decrementado por 1 y la pantalla reflejará el cambio
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
DecSecondLow:

			MOV.B   #7,R10							;Guardar la pocisión de secondLow
			DEC.B	R14								;Decrementar R14 (secondLow)
			MOV.W	R14,R5							;Guardar el valor decrementado en R5
			CALL	#DrawNum						;Dibujar en la posición de secondLow
			BIS.B   #0x04,&0x0A33					;Dibujar ':'
			RET

;-------------------------------------------------------------------------------
;NumSelect
;Objetivo: Permitir al usuario seleccionar / incrementar los números en la pantalla
;desde izquierda a derecha usando S1 y S2 respectivamente.
;Precondiciones: Debemos estar en el estado 1 (R15 debe contener #1)
;Postcondiciones: El usuario podrá editar los números
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
NumSelect:

			PUSH	R4								;Guardar el contenido de R4
			PUSH	R5								;Guardar el contenido de R5
			PUSH	R6								;Guardar el contenido de R6
			PUSH	R7								;Guardar el contenido de R7
			PUSH	R10

			CALL	#NumBase						;Dibujar 00:00 en la pantalla

			MOV.B	#4,R6							;Usar R6 como índice
			MOV.B	#0,R7							;Usar R7 como counter
			MOV.W	#0,R5							;Mover cero a R5 (comenzar en cero)

nextNum:
			MOV.W	#6250,R4						;Establecer los ciclos a esperar
			CALL	#Delay

			MOV.B   pos(R6),R10						;Guardar la pocisión del número en R10
			MOV.W	#10,R5							;Darle clear al número (Blinking)
			CALL	#DrawNum						;Dibujar en la posición dada por R10

			BIS.B   #0x04,&0x0A33					;Dibujar ':'

			MOV.W	#12500,R4						;Establecer los ciclos a esperar
			CALL	#Delay

			MOV.B   pos(R6),R10						;Guardar la pocisión del número en R10
			CALL	#CheckNum						;Verificar si el número es válido

			MOV.W	R7,R5							;Mover el número a R5
			CALL	#DrawNum						;Dibujar en la posición dada por R10
			CALL	#StoreNum						;Grabar el número que dibujamos

			BIS.B   #0x04,&0x0A33					;Dibujar ':'

			MOV.W	#6250,R4						;Establecer los ciclos a esperar
			CALL	#Delay

			CMP		#1,R15							;Verificar si seguimos en el estado 1
			JZ		nextNum							;Si es el caso, continuar

			POP		R10								;Recuperar el contenido de R10
			POP		R7								;Recuperar el contenido de R7
			POP		R6								;Recuperar el contenido de R6
			POP		R5								;Recuperar el contenido de R5
			POP		R4								;Recuperar el contenido de R4

			RET

;-------------------------------------------------------------------------------
;StoreNum
;Objetivo: Guardar el número seleccionado por NumSelect en el registro correspondiente
;Precondiciones: La posición del número debe estar dada por R4 y el número debe estar dado en R7
;Postcondiciones: El número de R7 será grabado en el registro correspondiente
;R11:minuteHigh,  R12:minuteLow,  R13:secondHigh,  R14:secondLow
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
StoreNum:
			CMP		#3,R10							;Verificar si estamos en la posición minuteHigh
			JNZ		chk2							;Si no es el caso, chequear próxima posición
			MOV		R7,R11							;Guardar el número en minuteHigh y terminar
			JMP		endStore

chk2:		CMP		#18,R10							;Verificar si estamos en la posición minuteLow
			JNZ		chk3							;Si no es el caso, chequear próxima posición
			MOV		R7,R12							;Guardar el número en minuteLow y terminar
			JMP		endStore

chk3:		CMP		#14,R10							;Verificar si estamos en la posición secondHigh
			JNZ		chk4							;Si no es el caso, chequear próxima posición
			MOV		R7,R13							;Guardar el número en secondHigh y terminar
			JMP		endStore

chk4:		CMP		#7,R10							;Verificar si estamos en la posición secondLow
			JNZ		endStore						;Si no es el caso, terminar
			MOV		R7,R14							;Guardar el número en secondLow y terminar

endStore:
			RET

;-------------------------------------------------------------------------------
;CheckNum
;Objetivo: Verificar si el número dado por R7 es mayor que 5 y decrementar a 0 si R4 es 12 o 3.
;Adicionalmente, si el número es mayor que 9, también decrementar a 0.
;Precondiciones: R7 debe contener un número del 0-9 y R4 debe contener una posición
;Postcondiciones: R7 será igualado a 0 si se cumplen las condiciones. De lo contrario permanece igual
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
CheckNum:
			CMP		#10,R7							;Verificar si R7 > 9
			JLO		cmpr							;Si es menor o igual chequear posición

			MOV		#0,R7							;Si R7 > 9, cambiar a 0
			JMP		skip							;Brincar luego del cambio a 0

cmpr:		CMP		#14,R10							;Verificar la posición 12
			JZ		cmpr2							;Si es el caso, verificar si R7 > 5

			CMP		#3,R10							;Verificar la posición 3
			JNZ		skip							;Si no es el caso, brincar

cmpr2:		CMP		#6,R7							;Verificar si R7 > 5
			JLO		skip							;Si no es el caso, brincar
			MOV		#0,R7							;Si R7 > 5, cambiar a 0

skip:
			RET

;-------------------------------------------------------------------------------
;NumBase
;Objetivo: Mostrar 00:00 en la pantalla
;Precondiciones: Los arreglos numH y numL deben estar definidos
;Postcondiciones: La pantalla mostrará 00:00
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
NumBase:
			PUSH	R4								;Guardar el contenido de R4
			PUSH	R5								;Guardar el contenido de R5
			PUSH	R6								;Guardar el contenido de R6

			MOV.B	#4,R6							;Usar R6 como índice

nextNum2:	MOV.B   pos(R6),R10						;Guardar la pocisión del caracter en R10
			MOV.W	#0,R5							;El número a dibujar es cero
			CALL	#DrawNum						;Dibujar el cero en la posición dada por R10
			INCD.B	R6								;Incrementar el índice

			CMP		#14,R6							;Verificar si llegamos a la última posición
			JNZ		nextNum2						;Si no es el caso, continuar

			BIS.B   #0x04,&0x0A33					;Dibujar ':'

			POP		R4								;Guardar el contenido de R4
			POP		R5								;Guardar el contenido de R5
			POP		R6								;Guardar el contenido de R6

			RET

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
			PUSH	R4								;Guardar el contenido de R4
			PUSH	R5								;Guardar el contenido de R5
			PUSH	R6								;Guardar el contenido de R6
			PUSH	R7								;Guardar el contenido de R7
			PUSH	R9								;Guardar el contenido de R9
			PUSH	R10								;Guardar el contenido de R10

restart:	MOV.B   #0,R6							;Usar R6 como índice de comienzo
			MOV.B   #0,R9							;Usar R9 como contador

first:		MOV.B   R6,R7							;Guardar R6 (ídice de comienzo) en R7 (índice general)

			MOV.W	#31250,R4						;Establecer los ciclos a esperar
			CALL	#Delay							;Antes de volver a dibujar en la pantalla

next:		MOV.B   pos(R9),R10						;Guardar la pocisión del caracter en R10
			MOV.W	@R8,R5							;Guardar la dirección del arreglo en R5
			ADD.W	R7,R5							;Sumar el índice a R5
			MOV.W	@R5,R5							;Colocar el caracter apuntado por R5 en R5
			CALL	#DrawChar

			INCD.B	R9								;Incrementar contador
			INCD.B	R7								;Incrementar el índice general

	        CMP		#-1,R5							;Verificar si llegamos al último caracter
			JZ		restart							;Regresar al inicio
			CMP		#14,R9							;Verificar si llegamos a la última posición
			JNZ		next							;Si no hemos llegado, continúa
	        MOV.B   #0,R9							;Si llegamos al final, regresa a cero
	        INCD.W	R6								;Incrementar R6 (ídice de comienzo)

	        CMP		#1, R15							;Verificar si cambiamos de estado
	        JEQ		endSub
			JMP		first							;Si no es el caso, regresa al comienzo

endSub:		MOV.W   #2,&LCDCMEMCTL       			;Borrar memoria LCD

			POP		R10								;Recuperar el contenido de R10
			POP		R9								;Recuperar el contenido de R9
	        POP		R7								;Recuperar el contenido de R7
	        POP		R6								;Recuperar el contenido de R6
	        POP		R5								;Recuperar el contenido de R5
	        POP		R4								;Recuperar el contenido de R4

			RET

;-------------------------------------------------------------------------------
;DrawChar
;Objetivo: Dibujar un caracter en la pantalla en la posición dada por R10
;Precondiciones: La posición del caracter debe estar dada en R10 y el índice
;del caracter debe estar dado en R5.
;Postcondiciones: La pantalla mostrará el caracter dado por R5 en la posición
;dada por R10.
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
DrawChar:
  			MOV.B   charH(R5),0x0a20(R10)		;Accesar los segmentos (high/low)
  												;guardados en el índice de R5 y
  			MOV.B   charL(R5),0x0a20+1(R10)		;dibujar en la posición dada por
  												;R4+0x0a20 y R4+0x0a20+1
  			RET

;-------------------------------------------------------------------------------
;DrawNum
;Objetivo: Dibujar un número en la pantalla en la posición dada por R10
;Precondiciones: La posición del número debe estar dada en R10 y el índice
;del número debe estar dado en R5.
;Postcondiciones: La pantalla mostrará el número dado por R5 en la posición
;dada por R10.
;Autor: Alex Demel
;Fecha: 11/2/2023
;-------------------------------------------------------------------------------
DrawNum:
  			MOV.B   numH(R5),0x0a20(R10)		;Accesar los segmentos (high/low)
  												;guardados en el índice de R5 y
  			MOV.B   numL(R5),0x0a20+1(R10)		;dibujar en la posición dada por
  												;R4+0x0a20 y R4+0x0a20+1
  			RET

;-------------------------------------------------------------------------------
;OneSecond
;Objetivo: Esperar 1 segundo y continuar la ejecución del programa
;Precondiciones: El timer debe estar inicializado
;Postcondiciones: El programa esperará 1 segundo y continuará
;Autor: Alex Demel
;Fecha: 11/7/2023
;-------------------------------------------------------------------------------
OneSecond:
			CMP		#14,speed				;Verificar si la velocidad > 15
			JHS		instant					;Si es el caso, terminar

			MOV		secLen,R4				;Establecer los ciclos de espera
			CALL	#Delay					;Esperar 0.5s antes de continuar
			CALL	#Delay					;Esperar 0.5s antes de continuar

instant:
			RET

;-------------------------------------------------------------------------------
;Delay
;Objetivo: Esperar la cantidad de ciclos dada en R4 antes de continuar el programa
;Precondiciones: La cantidad de ciclos a esperar debe estar dada en R4
;Postcondiciones: El programa esperará la cantidad de ciclos dados en R4 y continuará
;Autor: Alex Demel
;Fecha: 11/4/2023
;-------------------------------------------------------------------------------
Delay:
			BIS    	#BIT4,&TA0CTL			;Empezar el timer
			MOV     R4,&TA0CCR0       	 	;Establecer los ciclos de espera

			NOP
			BIS		#GIE+LPM0,SR			;Entrar a low power
			NOP
			RET

;-------------------------------------------------------------------------------
;DebounceSub
;Objetivo: Esperar 0.15s y actualizar la variable debounce
;Precondiciones: El timer debe estar inicializado
;Postcondiciones: El programa esperará 0.15s y actualizará la variable debounce
;Autor: Alex Demel
;Fecha: 11/4/2023
;-------------------------------------------------------------------------------
DebounceSub:
			MOV		#1,debounce						;Actualizar variable
			MOV		TA0CTL,timerState				;Guardar estado del timer
			MOV		TA0CCR0,timeCycles				;Guardar ciclos anteriores

			MOV     #TASSEL_2+MC_1+ID_3, &TA0CTL	;Establecer frecuencia base
			MOV     #18750, &TA0CCR0				;Esperar 0.15s
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
			;Cambiar modo a 'stop'  (MC_0)
			;Establecer divisor de input 8 (ID_3)

			MOV		#CCIE, &TA0CCTL0        ;Habilitar interrupción TACCR0

	        MOV     #TASSEL_2+MC_0+ID_3, &TA0CTL

		    NOP

			RET

;-------------------------------------------------------------------------------
TA0_ISR:
			CMP		#1,debounce
			JNZ		delayHandler

			MOV		#0,debounce				;Actualizar variable
			MOV		timerState,TA0CTL		;Recuperar estado del timer
			MOV		timeCycles,TA0CCR0		;Recuperar ciclos anteriores

			BIC		#0x10, 0(SP)			;Salir de low power
			JMP		endTimerSub

delayHandler:
	        BIC    	#BIT5+BIT4,TA0CTL  		;Parar el timer
	        BIC		#0x10, 0(SP)			;Salir de low power

endTimerSub:
			MOV		#CCIE, &TA0CCTL0        ;Rehabilitar interrupción TACCR0
	        RETI

;-------------------------------------------------------------------------------
PORT1_ISR:
			CMP		#1,debounce
			JZ		endPortSub

	    	BIT.B   #00000010b, &P1IFG      ;Verificar P1.1
            JNZ		s1Press

            BIT.B   #00000100b, &P1IFG      ;Verificar P1.2
            JNZ		s2Press

s1Press:
			CMP		#0,R15					;Verificar si estamos en el estado 0
			JNZ		check1S1				;Si no es el caso, verificar el proximo estado
			INCD	R8						;Si es el caso, incrementar el índice
			MOV.B   #0,R6					;Reiniciar índice de comienzo
			MOV.B   #0,R7					;Reiniciar índice general
			MOV.B   #0,R9					;Reiniciar contador

			CMP		#-1,0(R8)				;Verificar si seguimos en el arreglo
			JNZ		endPortSub				;Si seguimos en el arreglo terminar
			MOV		#members,R8				;Si no es el caso, reiniciar el index del arreglo

			CALL	#DebounceSub
			JMP		endPortSub				;Terminar

check1S1:
			CMP		#1,R15					;Verificar si estamos en el estado 1
			JNZ		check2S1				;Si no es el caso, verificar el proximo estado
			INC		R7						;Si es el caso, incrementar el counter

			CALL	#DebounceSub
			JMP		endPortSub				;Terminar

check2S1:
			CMP		#2,R15					;Verificar si estamos en el estado 2
			JNZ		check3S1				;Si no es el caso, verificar el proximo estado

			JMP 	endPortSub				;Terminar

check3S1:
			CMP		#3,R15					;Verificar si estamos en el estado 3
			JNZ		check4S1				;Si no es el caso, verificar el proximo estado

			ADD		#1,speed				;Incrementar velocidad de conteo
			CALL	#CountSpeed

			CALL	#DebounceSub
			JMP 	endPortSub				;Terminar

check4S1:
			CMP		#4,R15					;Verificar si estamos en el estado 4
			JNZ		check5S1				;Si no es el caso, verificar el proximo estado

			JMP 	endPortSub				;Terminar

check5S1:
			CMP		#5,R15					;Verificar si estamos en el estado 5
			JNZ		endPortSub				;Si no es el caso, terminar

			MOV.W	#0,R15					;Regresar al estado 0

			CALL	#DebounceSub
			JMP		endPortSub				;Terminar

s2Press:
			CMP		#0,R15					;Verificar si estamos en el estado 0
			JNZ		check1S2				;Si no es el caso, verificar el proximo estado

			CMP		#team,0(R8)				;Verificar si estamos mostrando el número de equipo
			JNZ		endPortSub				;Si no lo estamos mostrando, terminar
			INC   	R15						;Si lo estamos mostrando, establece el estado 1

			CALL	#DebounceSub
			JMP 	endPortSub				;Terminar

check1S2:
			CMP		#1,R15					;Verificar si estamos en el estado 1
			JNZ		check2S2				;Si no es el caso, verificar el proximo estado

			MOV.W	R7,R5					;Mover el número a R5
			CALL	#DrawNum				;Dibujar en la posición dada por R10

			INCD	R6
			MOV.W	#0,R7					;Mover cero a R7 (comenzar en cero)
			MOV.W	#0,R5					;Mover cero a R5 (comenzar en cero)

			CMP		#12,R6					;Verificar si llegamos a la última posición
			JNZ		endPortSub				;Si no es el caso, terminar
			MOV		#2,R15					;Si es el caso, establecer el estado 2
			BIC		#0x10,0(SP)				;Salir de low power

			CALL	#DebounceSub
			JMP		endPortSub				;Terminar

check2S2:
			CMP		#2,R15					;Verificar si estamos en el estado 2
			JNZ		check3S2				;Si no es el caso, verificar el proximo estado

			MOV.W	#3,R15					;Incrementar al estado 3
			BIC		#0x10,0(SP)				;Salir de low power

			CALL	#DebounceSub
			JMP		endPortSub				;Terminar

check3S2:
			CMP		#3,R15					;Verificar si estamos en el estado 3
			JNZ		check4S2				;Si no es el caso, verificar el proximo estado

			MOV.W	#4,R15					;Incrementar al estado 4

			CALL	#DebounceSub
			JMP		endPortSub				;Terminar

check4S2:
			CMP		#4,R15					;Verificar si estamos en el estado 4
			JNZ		endPortSub				;Si no es el caso, terminar

			MOV.W	#3,R15					;Regresar al estado 3
			BIC		#0x10,0(SP)				;Salir de low power

			CALL	#DebounceSub
			JMP		endPortSub				;Terminar

endPortSub:
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
