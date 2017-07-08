;******************************************************************************
;   MSP-FET430P430 Demo - 3-Amp Differential Amplifier with OA2, OA0, and OA1
;
;   Description: Configure OA2, OA0, and OA1 as a 3-Amp Differential Amp.
;   In this configuration, the R2/R1 ratio sets the gain. The R ladders for
;   OA1 and OA2 form the R2/R1 dividers. The OAFBRx settings for both OA1
;   and OA2 must be equal.
;   ACLK = n/a, MCLK = SMCLK = default DCO
;
;                |\
;                | \ OA2
;   V2-----------|+ \           R1             R2
;                |   |----+---/\/\/\/---+----/\/\/\/----|
;            ----|- /     |             |               |
;            |   | /      |             |  |\          GND
;            |   |/       |             |  | \ OA1
;            |____________|             ---|+ \
;                                          |   |--------+--------->
;                                       ---|- /         |
;                |\                     |  | /          | Vout = (V2-V1)xR2/R1
;                | \ OA0                |  |/           |        (Gain is 3)
;   V1-----------|+ \           R1      |      R2       |
;                |   |----+---/\/\/\/---+----/\/\/\/----|
;            ----|- /     |
;            |   | /      |
;            |   |/       |
;            |____________|
;
;
;                 MSP430FG439
;              -------------------
;          /|\|                XIN|-
;           | |                   |
;           --|RST            XOUT|-
;             |                   |
;       V2 -->|P6.6/OA2I0         |
;       V1 -->|P6.0/OA0I0         |
;             |                   |
;             |          P6.3/OA1O|--> Diff Amp Output
;
;   M. Mitchell / M. Mitchell
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
                                            ;
SetupOA     mov.b   #OAPM_1,&OA0CTL0        ; Select inputs, power mode
            mov.b   #OAFC_7,&OA0CTL1        ; Differential amp mode
                                            ;
            mov.b   #OAN_3+OAP_3+OAPM_1+OAADC1,&OA1CTL0
                                            ; Select inputs, output
            mov.b   #OAFC_6+OAFBR_4+OARRIP,&OA1CTL1
                                            ; Inverting PGA mode,
                                            ; OAFBRx sets gain
                                            ;
            mov.b   #OAPM_1,&OA2CTL0        ; Select inputs, power mode
            mov.b   #OAFC_1+OAFBR_4,&OA2CTL1; Unity gain mode,
                                            ; OAFBRx sets gain
                                            ;
Mainloop    bis.w   #LPM3,SR                ; Enter LPM3
            nop                             ; Required only for debug
                                            ;
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; RESET Vector
            .short  RESET                   ;
            .end