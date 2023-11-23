/*
 * File:   %<%NAME%>%.%<%EXTENSION%>%
 * Author: %<%USER%>%
 *
 * Created on %<%DATE%>%, %<%TIME%>%
 */

    .include "p33FJ32MC202.inc"


;..............................................................................
;Program Specific Constants (literals used in code)
;..............................................................................

    .equ SAMPLES, 64         ;Number of samples



;..............................................................................
;Global Declarations:
;..............................................................................

    .global _wreg_init       ;Provide global scope to _wreg_init routine
                                 ;In order to call this routine from a C file,
                                 ;place "wreg_init" in an "extern" declaration
                                 ;in the C file.

    .global __reset          ;The label for the first line of code.
    .GLOBAL __INT0Interrupt
    .GLOBAL __INT1Interrupt
    .global __INT2Interrupt
;..............................................................................
;Constants stored in Program space
;..............................................................................

    .section .myconstbuffer, code
    .palign 2                ;Align next word stored in Program space to an
                                 ;address that is a multiple of 2
ps_coeff:
    .hword   0x0002, 0x0003, 0x0005, 0x000A




;..............................................................................
;Uninitialized variables in X-space in data memory
;..............................................................................

    .section .xbss, bss, xmemory
x_input: .space 2*SAMPLES        ;Allocating space (in bytes) to variable.



;..............................................................................
;Uninitialized variables in Y-space in data memory
;..............................................................................

    .section .ybss, bss, ymemory
y_input:  .space 2*SAMPLES




;..............................................................................
;Uninitialized variables in Near data memory (Lower 8Kb of RAM)
;..............................................................................

    .section .nbss, bss, near
var1:     .space 2               ;Example of allocating 1 word of space for
SERGIO: .SPACE 3
RODRIGO: .SPACE 4;variable "var1".




;..............................................................................
;Code Section in Program Memory
;..............................................................................

.text                             ;Start of Code section
__reset:
    MOV #__SP_init, W15       ;Initalize the Stack Pointer
    MOV #__SPLIM_init, W0     ;Initialize the Stack Pointer Limit Register
    MOV W0, SPLIM
    NOP                       ;Add NOP to follow SPLIM initialization

    CALL _wreg_init           ;Call _wreg_init subroutine
                                  ;Optionally use RCALL instead of CALL

				  


        ;<<insert more user code here>>

CALL	CONF_PORTB
CALL	CONF_INT0
CALL	CONF_INT1
	

MOV	#250,   W9	    ;PARAMETER FOR DELAY_ms(w9)
CLR	var1	
done:    
    COM.B    PORTB
    CALL    DELAY_1ms
    NOP
    NOP 
    NOP
    NOP
    
    BRA     done              ;Place holder for last line of executed code



;..............................................................................
;Subroutine: Initialization of W registers to 0x0000
;..............................................................................

_wreg_init:
    CLR W0
    MOV W0, W14
    REPEAT #12
    MOV W0, [++W14]
    CLR W14
    RETURN
    
CONF_PORTB:
    SETM    AD1PCFGL	;PORTB AS DIGITAL
    CLR	    TRISB	;PORTB AS OUTPUT  
    BSET    TRISB,	#RB7 ;HERE THE EXTERNAL INT0
    RETURN

CONF_INT0:
    BSET    INTCON1,	#NSTDIS
    
    BSET    IPC0,	#INT0IP2
    BCLR    IPC0,	#INT0IP1
    BCLR    IPC0,	#INT0IP0
    
    BCLR    INTCON2,	#INT0EP	    ;External Interrupt 0 Edge Detect Polarity Select bit
    BCLR    IFS0,	#INT0IF
    BSET    IEC0,	#INT0IE    
    
    RETURN	
    
CONF_INT1:
    PUSH    W0    
    
    BSET    IPC5,	#INT1IP2
    BCLR    IPC5,	#INT1IP1
    BCLR    IPC5,	#INT1IP0
    
    BCLR    INTCON2,	#INT1EP	    ;External Interrupt 1 Edge Detect Polarity Select bit
    BCLR    IFS1,	#INT1IF
    BSET    IEC1,	#INT1IE 
    
    BSET    TRISB,	#15	    ;Ext Interrupt 1 is attachet to RB15
    MOV	    #0X0F00,	W0
    MOV	    W0,		RPINR0
    
    POP	    W0
    RETURN	
    
    
    DELAY_1ms:
    PUSH    W0
    PUSH    W9	    ;ARGUMENT: HOW MANY MILISECONDS
    DEC	    W9,	    W9
    DO	    W9,	    B2
	MOV	    #3682,	W0	;1ms / 271ns = 3686 pulses - some of them
	REPEAT  W0			;for the call and return.
	NOP
    B2: NOP
    
    POP	    W9
    POP	    W0
    RETURN    
    

__INT0Interrupt:
    PUSH    PORTB		    ;keep safe PORTB
    PUSH    W0
    PUSH    W9
    
    MOV	    #1500,   W9
    INC	    var1
    MOV	    var1,   W0
    MOV	    W0,	    PORTB
    CALL    DELAY_1ms
    
    POP	    W9
    POP	    W0
    POP	    PORTB
    BCLR    IFS0,	#INT0IF	    ;the user must clear the interrupt flag
    RETFIE
    
__INT1Interrupt:
    PUSH    PORTB		    ;keep safe PORTB
    PUSH    W0
    PUSH    W9
    
    MOV	    #1500,   W9
    INC2    var1
    MOV	    var1,   W0
    MOV	    W0,	    PORTB
    CALL    DELAY_1ms
    
    POP	    W9
    POP	    W0
    POP	    PORTB
    BCLR    IFS1,	#INT1IF	    ;the user must clear the interrupt flag
    RETFIE


;--------End of All Code Sections ---------------------------------------------

.end                               ;End of program code in this file
