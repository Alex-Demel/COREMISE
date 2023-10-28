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

pos1	.equ	9      ; Alfanumerico A1 comienza en S18
pos2	.equ	5      ; Alfanumerico A2 comienza en S10
pos3 	.equ	3      ; Alfanumerico A3 comienza en S6
pos4 	.equ	18     ; Alfanumerico A4 comienza en S36
pos5	.equ	14     ; Alfanumerico A5 comienza en S28
pos6 	.equ	7      ; Alfanumerico A6 comienza en S14

;Definir high y low bytes para generar caracteres
;char          0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   26   29   30   31   32   33   34   35
;              A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P    Q    R    S    T    U    V    W    X    Y    Z    0    1    2    3    4    5    6    7    8    9
charH	.byte 0xEF,0xF1,0x9C,0xF0,0x9F,0x8E,0xBD,0x6F,0x90,0x78,0x0E,0x1C,0x6C,0x6C,0xFC,0xCF,0xFC,0xCF,0xB7,0x80,0x7C,0x0C,0x7C,0x00,0x00,0x90,0xFC,0x00,0xDB,0xF3,0x67,0xB7,0xBF,0xE0,0xFF,0xE7
charL	.byte 0x00,0x50,0x00,0x50,0x00,0x00,0x00,0x00,0x50,0x00,0x22,0x00,0xA0,0x82,0x00,0x00,0x02,0x02,0x00,0x50,0x00,0x28,0x10,0xAA,0xB0,0x28,0x28,0x50,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

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

			;Escribir TEAM03 en la pantalla
			MOV.B   #pos1,R14
			MOV.W	#19,R5
  			MOV.B   charH(R5),0x0a20(R14)
	        MOV.B   charL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.W	#4,R5
			MOV.B   charH(R5),0x0a20(R14)
	        MOV.B   charL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.W	#0,R5
			MOV.B   charH(R5),0x0a20(R14)
	        MOV.B   charL(R5),0x0a20+1(R14)

	        MOV.B   #pos4,R14
			MOV.W	#12,R5
			MOV.B   charH(R5),0x0a20(R14)
	        MOV.B   charL(R5),0x0a20+1(R14)

	        MOV.B   #pos5,R14
			MOV.W	#26,R5
			MOV.B   charH(R5),0x0a20(R14)
	        MOV.B   charL(R5),0x0a20+1(R14)

	        MOV.B   #pos6,R14
			MOV.W	#29,R5
			MOV.B   charH(R5),0x0a20(R14)
	        MOV.B   charL(R5),0x0a20+1(R14)

	        JMP		$
			nop

;NombreDeSubrutina (Ejemplo)
;Objetivo:
;Precondiciones:
;Postcondiciones:
;Autor:
;Fecha: dia/mes/2023

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
