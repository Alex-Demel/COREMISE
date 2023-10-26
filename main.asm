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

;Definir high y low bytes para generar caracteres J, N, F
;JNF           J    N    F
jnfH	.byte 0x78,0x6C,0x8F
jnfL	.byte 0x00,0x82,0x00

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

			;Escribir JNF en los caracteres alfanuméricos A1-A3 de la pantalla
			MOV.B   #pos1,R14
			MOV.B	#0,R5
  			MOV.B   jnfH(R5),0x0a20(R14)
	        MOV.B   jnfL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   jnfH(R5),0x0a20(R14)
	        MOV.B   jnfL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.B	#2,R5
			MOV.B   jnfH(R5),0x0a20(R14)
	        MOV.B   jnfL(R5),0x0a20+1(R14)

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
