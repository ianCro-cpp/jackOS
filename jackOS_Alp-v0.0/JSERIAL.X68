*-----------------------------------------------------------
*   JSERIAL.X68 - INPUT/OUTPUT UTILITY ROUTINES
* Keep in mind both input and output bytes will load into the D0
*-----------------------------------------------------------
    ORG $80A2
* DUART Offsets
*   Channel A
MR1A    EQU      $01    ;Mode Register A (Read and Write Mode)
MR2A    EQU      $01    ;Mode Register A (Read and Write Mode)
SRA     EQU      $03    ;Status Register A (Read Mode)
CSRA    EQU      $03    ;Clock Select Register A (Write Mode)
CRA     EQU      $05    ;Command Register A (Write Mode)
HRA     EQU      $07    ;Holding Register A (Tx and Rx)
*   Channel B
MR1B    EQU      $11    ;Mode Register B (Read and Write Mode)
MR2B    EQU      $11    ;Mode Register B (Read and Write Mode)
SRB     EQU      $13    ;Status Register B (Read Mode)
CSRB    EQU      $13    ;Clock Select Register B (Write Mode)
CRB     EQU      $15    ;Command Register B (Write Mode)
HRB     EQU      $17    ;Holding Register B (Tx and Rx)
*   General DUART Control
ACR     EQU     $09     ;Auxilary Control Register
CTU     EQU     $0D     ;Counter/Timer Upper Byte Register 
CTL     EQU     $0F     ;Counter/Timer Lower Byte Register
* DUART Command Register Values
RxEn    EQU     $01     ;Enable Rx
RxDs    EQU     $02     ;Disable Rx
TxEn    EQU     $04     ;Enable Tx
TxDs    EQU     $08     ;Disable Tx
MRRst   EQU     $10     /Reset MRA/MRB Pointer
RxRst   EQU     $20     ;Reset Rx
TxRst   EQU     $30     ;Reset Tx
Rx_Rdy  EQU     $00     ;Check SRA/SRB output bit for RXRDY
Tx_Rdy  EQU     $02     ;Check SRA/SRB output bit for TXRDY

DATA        EQU     $100000 ;Uses the RAM start
BAUD_RATE   EQU     $CC    ;Baud Rate = 19.2K Baud = 2400 bytes/second

*---------------------------
*     DUART INITIALIZATION
*---------------------------
INIT_DUART:  LEA     DUART,A0    ;point the A0 to the base DUART address

;First, reset both channels A and B during a software reset
    ;Channel A
            MOVE.B  #$30,CRA(A0)    ;reset the TxA
            MOVE.B  #$20,CRA(A0)    ;reset the RxA
            MOVE.B  #$10,CRA(A0)    ;reset the MRA pointer
    ;Channel B
            ;MOVE.B  #$30,CRB(A0)    
            ;MOVE.B  #$20,CRB(A0)
            ;MOVE.B  #$10,CRB(A0)
;Then, intiialize both channels
    ;Channel A
            MOVE.B  #$80,ACR(A0)    ;selects the baud rate set 2
            MOVE.B  #BAUD_RATE,CSRA(A0) ;sets to 19.2k baud for Tx/Rx
            MOVE.B  #$13,MR1A(A0)   ;8bits, no parity, 1 stop bit
    ;Channel B
            ;MOVE.B  #BAUD_RATE,CSRB(A0)
            ;MOVE.B  #$13,MR1B(A0)
            
            MOVE.B  #$07,MR2A(A0) ;auto Echo with Stop Bit Length of 1
            ;MOVE.B  #$47,MR2B(A0)
            
            MOVE.B  #$05,CRA(A0) ;sets both Tx and Rx ready
            ;MOVE.B  #$05,CRB(A0)
            RTS
            
CLEAR:      MOVE.L  D0, -(SP)
            MOVE.B  #NEWPAGE, D0
            BSR PUTCHAR
            MOVE.L  (SP)+, D0
            RTS
            
OUTSPACE:   MOVE.L  D0, -(SP)
            MOVE.B  #SPACE, D0
            BSR PUTCHAR
            MOVE.L  (SP)+, D0
            RTS
            
OUTNL:      MOVE.L  D0, -(SP)
            MOVE.B  #CR, D0
            BSR PUTCHAR
            MOVE.B  #LF, D0
            BSR PUTCHAR
            MOVE.L  (SP)+, D0
            RTS  
            
CLEAR_ALL:  CLR.L   D0
            CLR.L   D1
            CLR.L   D2
            CLR.L   D3
            CLR.L   D4
            CLR.L   D5
            CLR.L   D6
            CLR.L   D7
            MOVE.L  D0,A0
            MOVE.L  D0,A1
            MOVE.L  D0,A2
            MOVE.L  D0,A3
            MOVE.L  D0,A4
            MOVE.L  D0,A5
            MOVE.L  D0,A6
            MOVEM.L A0-A7/D0-D7, -(SP)
            MOVE.W  #14,D6
            LEA     DATA+REG_F, A0
.loop       MOVE.L  (SP)+, (A0)+
            DBRA    D6,.loop
            MOVE.L  USP, A2
            MOVE.L  A2, (A0)+
            MOVE.L  (SP)+, D0
            SUB.L   #10, D0
            MOVE.L  D0, (A0)+
            MOVE.W  #$2000, (A0)+
            MOVE.L  #$101000, (A0)+
            RTS

*--------------------------------
*     GENERAL UTILITY SUBROUTINES
*--------------------------------
PUTCHAR:    MOVE.L      D1,-(SP)
            MOVE.L      D0,-(SP)
            MOVE.B      D0,D1
            IFNE SIM
            MOVE    #06,D0
            TRAP    #15
            BRA     .EXIT
            ENDC
            LEA     DUART,A0
.WAITA      BTST    #Tx_Rdy, SRA(A0)
            BEQ     .WAITA     
;.WAITB      BTST    #Tx_Rdy, SRB(A0)
;            BEQ     .WAITA
;.MOVEB      MOVE.B  D1,HRB(A0)
;            JSR     .EXIT
.MOVEA      MOVE.B  D1,HRA(A0)
.EXIT       MOVE.L  (SP)+,D0
            MOVE.L  (SP)+,D1
            RTS
            
GETCHAR:
    MOVE.L      D1,-(SP)
    MOVE.B      D0,D1
    IFNE SIM
    MOVE.B      #5,D0
    TRAP        #15
    BRA         .EXIT
    ENDC
.WAITA    BTST        #Rx_Rdy,SRA(A0)
          BEQ         .WAITA
;.WAITB    BTST        #Rx_Rdy,SRB(A0)
;          BEQ         .WAITA
;.GRABB    MOVE.B      HRB(A0),D1
;          JSR         .EXIT
.GRABA    MOVE.B      HRA(A0),D1
.EXIT     MOVE.B      D1,D0
          MOVE.L      (SP)+,D1
          RTS

* PUTSTR: print string in memory. string terminated by $04 (ASCII End of Transmission)
* arguments: address of first character in D0
* return: no values
PUTSTR:     MOVE.L D0,-(SP) ; SAVE ON STACK. string pointer (argument)
            MOVE.L D1, -(SP) ; SAVE ON STACK. temp string pointer
            
            ;MOVE.L A1, D0 ; move address of the string to d0
            ;MOVE.L D0, D1 ; move pointer to d1 (since d0 needed to call PUTCHAR)
            ANDI    #$00000000, D0
            
.1CHAR      MOVE.B (A1)+, D0 ; load character from string to d0
            CMPI #$04, D0 ; char is $00?
            BEQ .PSTREXIT ; if yes, we're done
            BSR PUTCHAR ; print the character
            ;ADDI #$1, D1 ; move up pointer by 1
            BRA .1CHAR ; and repeat print
            
.PSTREXIT   MOVE.L (SP)+, D1 ; RESTORE FROM STACK. temp string pointer
            MOVE.L (SP)+, D0 ; RESTORE FROM STACK. string pointer (argument)
            RTS

    
*---------------------------
*     OUTPUT SUBROUTINES
*
*     OUT1X = PRINT ONE HEXADECIMAL CHARACTER
*     OUT2X = PRINT TWO HEXADECIMAL CHARACTER
*     OUT4X = PRINT FOUR HEXADECIMAL CHARACTER
*     OUT8X = PRINT EIGHT HEXADECIMAL CHARACTER
*---------------------------
OUT1X:  MOVE.B  D0,-(SP)    ;
        AND.B   #$0F,D0     ;
        ADD.B   #$30,D0
        CMP.B   #$39,D0
        BLS.S   OUT1X1
        ADD.B   #$07,D0
        
OUT1X1: BSR     PUTCHAR
        MOVE.B  (SP)+,D0
        RTS
        
OUT2X:  ROR.B   #4,D0
        BSR     OUT1X
        ROL.B   #4,D0
        BRA     OUT1X
        
OUT4X:   ROR.W   #8,D0
        BSR     OUT2X
        ROL.W   #8,D0
        BRA     OUT2X

OUT6X:  ROR.W   #8,D0
        BSR     OUT2X
        ROL.W   #8,D0
        BRA     OUT4X
        
OUT8X:   SWAP    D0
        BSR     OUT4X
        SWAP    D0
        BRA     OUT4X
 
*---------------------------
*     INPUT SUBROUTINES
*
*   HEX = GET ONE HEX CHARACTER INTO D0
*   BYTE = GET TWO HEX CHARACTERS INTO D0
*   WORD = GET FOUR WORD HEX CHARACTERS INTO D0
*   LONGWD = GET A LONGWORD FROM THE LINE BUFFER INTO D0
*   Keep in mind Bit 0 of D7 is set to indicate a hexadecimal input error
*---------------------------
HEX:    BSR     GETCHAR
        BSR     PUTCHAR
        SUB.B   #$30,D0
        BMI.S   .NOT_HEX
        CMP.B   #$09,D0
        BLE.S   .HEX_OK
        SUB.B   #$07,D0
        CMP.B   #$0F,D0
        BLE.S   .HEX_OK
        
.NOT_HEX OR.B    #1,D7
         MOVE.B  #BS,D0
         BSR    PUTCHAR

.HEX_OK RTS

BYTE:   MOVE.L  D1,-(SP)
        BSR     HEX
        ASL.B   #4,D0
        MOVE.B  D0,D1
        BSR     HEX
        ADD.B   D1,D0
        MOVE.L  (SP)+,D1
        RTS

WORD:    BSR     BYTE
        ASL.W   #8,D0
        BRA     BYTE
        
LONGWD:  BSR     WORD
        SWAP    D0
        BRA     WORD


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
