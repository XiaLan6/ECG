;******************************************************************************
;   MSP-FET430P430 Demo - Timer_A, Toggle P5.1, Overflow ISR, DCO SMCLK
;
;   Description: This program toggles P5.1 using software and the Timer_A
;   overflow ISR. In this example an ISR triggers when TA overflows.
;   Inside the ISR P5.1 is toggled. Toggle rate is 16Hz when using default
;   FLL+ register settings and an external 32kHz watch crystal.	
;   ACLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO = 32 x ACLK = 1048576Hz
;   ;* An external watch crystal between XIN & XOUT is required for ACLK *//	
;
;                MSP430FG439
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |             P5.1|-->LED
;
;   M. Buccini / M. Mitchell
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430xG43x.h"
;------------------------------------------------------------------------------
            .text                  ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupFLL    bis.b   #XCAP14PF,&FLL_CTL0     ; Configure load caps
SetupP5     bis.b   #002h,&P5DIR            ; P5.1 output
SetupTA     mov.w   #TASSEL_2+MC_2+TAIE,&TACTL  ; SMCLK, cont. mode, interrupt
                                            ;						
Mainloop    bis.w   #CPUOFF+GIE,SR          ; CPU off, interrupts enabled
            nop                             ; Required for debugger
                                            ;
;------------------------------------------------------------------------------
TAX_ISR;    Common ISR for CCR1-4 and overflow
;------------------------------------------------------------------------------
            add.w   &TAIV,PC                ; Add Timer_A offset vector
            reti                            ; Vector 0 - no interrupt
            reti                            ; Vector 1 - CCR1
            reti                            ; Vector 2 - CCR2
            reti                            ; Vector 3 - CCR3
            reti                            ; Vector 4 - CCR4
TA_over     xor.b   #002h,&P5OUT            ; Vector 5 - overflow (Toggle P5.1)
            reti                            ; Return from overflow ISR		
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int05"                ; Timer_AX Vector
            .short  TAX_ISR                 ;
            .end
