;******************************************************************************
;   MSP-FET430P430 Demo - USART0, 19200 UART Echo ISR, DCO SMCLK
;
;   Description: Echo a received character, RX ISR used. Normal mode is LPM0.
;   USART0 RX interrupt triggers TX Echo.
;   Baud rate divider with 1048576hz = 1048576Hz/19200 = ~54.61 (0036h|6Bh)
;   ACLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO = 32 x ACLK = 1048576Hz
;   ;* An external watch crystal between XIN & XOUT is required for ACLK *//	
;
;                MSP430FG439
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |       P2.4/UTXD0|----------->
;            |                 | 19200 - 8N1
;            |       P2.5/URXD0|<-----------
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
SetupP3     bis.b   #030h,&P2SEL            ; P2.4,5 = USART0 TXD/RXD
SetupUART0  bis.b   #UTXE0+URXE0,&ME1       ; Enable USART0 TXD/RXD
            bis.b   #CHAR,&UCTL0            ; 8-bit characters
            mov.b   #SSEL1,&UTCTL0          ; UCLK = SMCLK
            mov.b   #036h,&UBR00            ; 1MHz 19200
            mov.b   #000h,&UBR10            ; 1MHz 19200
            mov.b   #06Bh,&UMCTL0           ; Modulation
            bic.b   #SWRST,&UCTL0           ; **Initialize USART state machine**
            bis.b   #URXIE0,&IE1            ; Enable USART0 RX interrupt
                                            ;
Mainloop    bis.b   #CPUOFF+GIE,SR          ; Enter LPM0, interrupts enabled
            nop                             ; Needed only for debugger
                                            ;
;------------------------------------------------------------------------------
USART0RX_ISR;  Echo back RXed character, confirm TX buffer is ready first
;------------------------------------------------------------------------------
TX0         bit.b   #UTXIFG0,&IFG1          ; USART0 TX buffer ready?
            jz      TX0                     ; Jump if TX buffer not ready
            mov.b   &RXBUF0,&TXBUF0         ; TX -> RXed character
            reti                            ;
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; RESET Vector
            .short  RESET                   ;
            .sect   ".int09"                ; USART0 Receive Vector
            .short  USART0RX_ISR            ;
            .end
