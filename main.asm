;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------

pos1	.equ	9      ; Aplhanumeric A1 begins at S18
pos2	.equ	5      ; Aplhanumeric A2 begins at S10
pos3 	.equ	3      ; Aplhanumeric A3 begins at S6
pos4 	.equ	18     ; Aplhanumeric A4 begins at S36
pos5	.equ	14     ; Aplhanumeric A5 begins at S28
pos6 	.equ	7      ; Aplhanumeric A6 begins at S14

;Define high and low byte values to generate chars J, N, F
;JNF           J    N    F
jnfH	.byte 0x78,0x6C,0x8F
jnfL	.byte 0x00,0x82,0x00

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
			;Initialize LCD segments 0 - 21; 26 - 43
			MOV.W   #0xFFFF,&LCDCPCTL0
			MOV.W   #0xfc3f,&LCDCPCTL1
  		    MOV.W   #0x0fff,&LCDCPCTL2

UnlockGPIO  bic.w   #LOCKLPM5,&PM5CTL0      ; Disable the GPIO power-on default
                                            ; high-impedance mode to activate
                                            ; previously configured port settings

			;Initialize LCD_C
  		    ;ACLK, Divider = 1, Pre-divider = 16; 4-pin MUX
			MOV.W   #0x041e,&LCDCCTL0

  		    ;VLCD generated internally,
  		    ;V2-V4 generated internally, v5 to ground
  		    ;Set VLCD voltage to 2.60v
  		    ;Enable charge pump and select internal reference for it
  		    MOV.W   #0x0208,&LCDCVCTL

			MOV.W   #0x8000,&LCDCCPCTL   ;Clock synchronization enabled

			MOV.W   #2,&LCDCMEMCTL       ;Clear LCD memory

			;Turn LCD on
			BIS.W   #1,&LCDCCTL0

			;Write JNF on display's A1-A3 Alphanumeric chars
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
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
