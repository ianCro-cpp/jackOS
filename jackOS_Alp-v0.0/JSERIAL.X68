*-----------------------------------------------------------
*   JSERIAL.X68 - INPUT/OUTPUT UTILITY ROUTINES
* Keep in mind both input and output bytes will load into the D0
*-----------------------------------------------------------
* Device Addresses
* DUART Offsets
*   Channel A
MRA     EQU      $01    ;Mode Register A (Read and Write Mode)
SRA     EQU      $03    ;Status Register A (Read Mode)
CSRA    EQU      $03    ;Clock Select Register A (Write Mode)
CRA     EQU      $05    ;Command Register A (Write Mode)
HRA     EQU      $07    ;Holding Register A (Tx and Rx)
*   Channel B
MRB     EQU      $11    ;Mode Register B (Read and Write Mode)
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
Rx_Rdy  EQU
Tx_Rdy  EQU
BAUD_RATE   EQU     $CC    ;Baud Rate = 19.2K Baud = 2400 bytes/second


SIM     EQU     $01     ;00 = hardware, 01 = simulation

*---------------------------
*     DUART INITIALIZATION
*---------------------------

*--------------------------------
*     GENERAL UTILITY SUBROUTINES
*--------------------------------
PUTCHAR:    MOVE.L  (D0/A0),-(SP)
            IFNE SIM
                MOVE    #06,A0
                TRAP    #15
                BRA     .EXIT
            ENDC
            LEA     DUART,A0
.WAIT       BTST    Tx_Rdy, SRA()
.EXIT       MOVE.L  (D0/A0), -(SP)
            RTS

* PUTSTR: print string in memory. string terminated by $04 (ASCII End of Transmission)
* arguments: address of first character in D0
* return: no values
PUTSTR:     MOVE.L (D0), -(SP) ; SAVE ON STACK. string pointer (argument)
            MOVE.L D1, -(SP) ; SAVE ON STACK. temp string pointer
            
            MOVE.L D0, D1 ; move pointer to d1 (since d0 needed to call PUTCHAR)
            
.1CHAR      MOVE.L (D1), D0 ; load character from string to d0
            CMPI #$04, D0 ; char is $04?
            BEQ .PSTREXIT ; if yes, we're done
            BSR PUTCHAR ; print the character
            ADDI #$1, D1 ; move up pointer by 1
            BRA .1CHAR ; and repeat print
            
.PSTREXIT   MOVE.L (SP)+, D1 ; RESTORE FROM STACK. temp string pointer
            MOVE.L (SP)+, (D0) ; RESTORE FROM STACK. string pointer (argument)
            RTS

            
            
            
            
                    
GETCHAR:

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
        
OUT4X   ROR.W   #8,D0
        BSR     OUT2X
        ROL.W   #8,D0
        BRA     OUT2X
        
OUT8X   SWAP    D0
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
        SUB.B   #$30,D0
        BMI.S   NOT_HEX
        CMP.B   #$09,D0
        BLE.S   HEX_OK
        SUB.B   #$07,D0
        CMP.B   #$0F,D0
        BLE.S   HEX_OK
NOT_HEX OR.B    #1,D7
HEX_OK  RTS

BYTE:   MOVE.L  D1,-(SP)
        BSR     HEX
        ASL.B   #4,D0
        MOVE.B  D0,D1
        BSR     HEX
        ADD.B   D1,D0
        MOVE.L  (SP)+,D1
        RTS

WORD    BSR     BYTE
        ASL.W   #8,D0
        BRA     BYTE
        
LONGWD  BSR     WORD
        SWAP    D0
        BRA     WORD
       

