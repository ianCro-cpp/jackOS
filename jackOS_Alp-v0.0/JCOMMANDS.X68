*-----------------------------------------------------------
* Title      : JCOMMANDS.X68
* Written by : Ian Crochet
* Date       :  4/24/2023
* Description: One subroutine per monitor program command
*-----------------------------------------------------------
    ORG $8240
REGDISP:    LEA COM1,A1
            BSR PUTSTR
            MOVE.L  D0,-(SP)
            CLR.L   D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L (SP),D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A0,D0
            BSR OUT8X
            BSR OUTNL
            MOVE.B   #$01,D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L D1,D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A1,D0
            BSR OUT8X
            BSR OUTNL
            MOVE.B   #$02,D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L D2,D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A2,D0
            BSR OUT8X
            BSR OUTNL
            MOVE.B   #$03,D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L D3,D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A3,D0
            BSR OUT8X
            BSR OUTNL
            MOVE.B   #$04,D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L D4,D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A4,D0
            BSR OUT8X
            BSR OUTNL
            MOVE.B   #$05,D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L D2,D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A5,D0
            BSR OUT8X
            BSR OUTNL
            MOVE.B   #$06,D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L D6,D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A6,D0
            BSR OUT8X
            BSR OUTNL
            MOVE.B   #$07,D0
            BSR OUT1X
            BSR OUTSPACE
            MOVE.L D7,D0
            BSR OUT8X
            BSR OUTSPACE
            MOVE.L A7,D0
            BSR OUT8X
            BSR OUTNL
.input      bsr GETCHAR
            CMPI.B    #ESC, D0
            BNE .input
            MOVE.L (SP)+, D0
            BRA MAINMENU

REGMOD:     MOVEM.L A0-A7/D0-D7, -(SP)
            CLR.L D0
            CLR.L D1
            MOVEA.L SP, A2
            MOVEA.L SP, A3
            LEA COM2,A1
            BSR PUTSTR
.inp1       bsr HEX
            SUBI.B    #$0D, D0
            BEQ .inp2
            SUBI.B    #$FD, D0
            BNE .inp1
            ADDA.W  #$20,A2
.inp2       bsr HEX
            CMPI.B  #06,D0
            BGT .inp2
            SUBI.B  #1,D0
.mul        ADDA.W  #4,A2
            DBEQ    D0, .mul
            LEA C2PMT,A1
            BSR PUTSTR
            BSR LONGWD            
            MOVEA.L A2,SP
            MOVE.L  D0,(SP)
            MOVEA.L A3,SP
            MOVEM.L (SP)+, A0-A7/D0-D7 
            BRA MAINMENU

MEMDISP:    MOVEM.L A0-A7/D0-D7, -(SP)
            LEA COM3,A1 ;A2 = START ADDRESS A3 = END ADDRESS
            CLR.W   D0
            MOVE.W D0,A2
            MOVE.W D0,A3
            BSR PUTSTR
            BSR LONGWD
            CMPI.B    #1, D7
            BEQ .ER3
            CMPI.L  #$10FFF0, D0
            BGT .ER3
            MOVE.L  D0,A2
            LEA COM3F,A1
            BSR PUTSTR
            BSR LONGWD
            CMPI.B    #1, D7
            BEQ .ER3
            CMPI.L  #$10FFFF, D0
            BGT .ER3
            MOVE.L  D0,A3
            LEA COM3_X,A1
            BSR PUTSTR
.OUTER      MOVE.L A2,D0
            BSR OUT8X
            LEA C3_DIV, A1
            BSR PUTSTR
            MOVE.W  #15,D6
.INNER      MOVE.B (A2)+,D0
            BSR OUT2X
            BSR OUTSPACE
            ;SUBI.B #1,D6
            DBRA    D6,.INNER
            BSR OUTNL
            CMP.L   A3,A2
            BLT .OUTER
            BRA .input
.ER3        LEA C3ERR,A1
            BSR PUTSTR
            BRA MEMDISP
.input      bsr GETCHAR
            CMPI.B    #ESC, D0
            BNE .input
.EXIT       MOVEM.L (SP)+, A0-A7/D0-D7
            BRA MAINMENU

MEMMOD:     MOVEM.L A0-A7/D0-D7, -(SP)
.prompt     LEA COM4,A1
            BSR PUTSTR
            BSR LONGWD
            CMPI.B    #1, D7
            BEQ .ER3
            CMPI.L  #$00100000, D0
            BLT .ER3
            CMPI.L  #$0010FFFF, D0
            BGT .ER3
            MOVE.L  D0, A2
            MOVE.L  D0, A3
            LEA C4SB,A1
            BSR PUTSTR
            BSR HEX
            SUBI.B  #1, D0
            BEQ .byte
            SUBI.B  #1, D0
            BEQ .word
            SUBI.B  #1, D0
            BEQ .long
            LEA IERR,A1
            BSR PUTSTR
            BRA MEMMOD
.byte       BSR OUTNL
            ADDA    #2, a3
            CMPI.L  #$10FFFF, D0
            BGT .ER3
            BSR BYTE
            MOVE.B D0, (A2)
            BRA .EXIT
.word       BSR OUTNL
            ADDA    #4, a3
            CMPI.L  #$10FFFF, D0
            BGT .ER3
            BSR WORD
            BRA .EXIT
            MOVE.W D0, (A2)
.long       BSR OUTNL
            ADDA    #8, a3
            CMPI.L  #$10FFFF, D0
            BGT .ER3
            BSR LONGWD
            MOVE.L D0, (A2)
            BRA .EXIT
.ER3        LEA C3ERR,A1
            BSR PUTSTR
            BRA .prompt
.EXIT       MOVEM.L (SP)+, A0-A7/D0-D7
            BRA MAINMENU

LOADSREC:   MOVEM.L A0-A7/D0-D7, -(SP)
            LEA RAM,A2
            LEA COM5,A1
            BSR PUTSTR
            ;outer loop
.outer      BSR GETCHAR
            CMPI.B  #ESC,D0
            BEQ .rts
            BSR PUTCHAR
            CMPI.B  #'S',D0
            BNE .outer
            BSR HEX              
            CMPI.B  #$09,D0
            BEQ .term
            CMPI.B  #$08,D0
            BEQ .term
.data       CMPI.B  #$02,D0
            BEQ .s2
            CMPI.B  #$01,D0
            BNE .outer
            ;inner loops
            ;2-BYTE
.s1         CLR.B   D3
            BSR .readb
            SUB.B   #3,D0
            MOVE.B  D0,D2
            CLR.L   D0
            BSR .readb
            ASL.L   #8,D1
            BSR .readb
            ;MOVE.L  D0,A2
            BRA .store
            ;3-BYTE
.s2         CLR.B   D3
            BSR .readb
            SUB.B   #4,D0
            MOVE.B  D0,D2
            CLR.L   D0
            BSR .readb
            ASL.L   #8,D0
            BSR .readb
            ASL.L   #8,D0
            BSR .readb
            ;MOVE.L  D0,A2
.store      bsr .readb
            move.b  D0,(A2)+
            sub.b   #1, D2
            bne .store
            bsr .readb
            add.b   #1,D3
            beq .outer
            or.b    #%0000100,d7
            bra .exit
            ;termination code
.term       BSR .readb
            MOVE.B  D0,D6
.tloop      BSR .READB
            SUB.B   #1,D6
            BNE .tloop
.exit       btst    #0,D7
            BEQ .chk
            LEA IERR, A1
            BSR PUTSTR
.chk        btst    #2,D7
            BEQ .rts
            LEA C5ERR, A1
            BSR PUTSTR
.rts        MOVEM.L (SP)+, A0-A7/D0-D7
            BRA MAINMENU
.readb      BSR BYTE
            ADD.B D0, D3
            RTS

RUNSREC:    LEA COM6,A1
            BSR PUTSTR
            JSR (RAM)
            BRA MAINMENU
COM1:   DC.B    CR,LF,'    DATA    ADDRESS',CR,LF,EOT
COM2:   DC.B    CR,LF,'Enter in the desired register [D0-D7 or A0 - A6]: ',EOT
C2PMT:  DC.B    CR,LF,'Enter in the the new value for the respected register: ',EOT
COM3:   DC.B    CR,LF,'Enter in the starting address you want to view: ',EOT
COM3F:  DC.B    CR,LF,'Enter in the ending address you want to view: ',EOT
COM3_X: DC.B    CR,LF,'ADDRESS    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F',CR,LF,'--------------------------------------------------------',CR,LF,EOT
C3_DIV: DC.B    ' | ',EOT
C3ERR:  DC.B    CR,LF,'ERROR: Invalid Address Input. Address must be within the following boundaries [00100000 - 0010FFFF]',CR,LF,EOT
COM4:   DC.B    CR,LF,'Enter the desired start address [00100000 - 0010FFFF]: ',EOT
C4SB:   DC.B    CR,LF,'Select the desired size to modify [1 - BYTE, 2 - WORD, 3 - LONGWORD]: ',EOT
IERR:   DC.B    CR.LF,'ERROR: Invalid Input',CR,LF,EOT
COM5:   DC.B    CR,LF,'[S]-Record',CR,LF,'[M]emory',CR,LF,'F[ILE]',CR,LF,'Please paste the SMILE file here: ',CR,LF,EOT
C5ERR:  DC.B    CR,LF,'ERROR: Issue with loading SMILE',CR,LF,EOT
COM6:   DC.B    CR,LF,'Entering RAM...',CR,LF,EOT


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
