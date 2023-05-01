*-----------------------------------------------------------
* Title      : jackOS Alpha v0.0
* Written by : Ian C. Crochet, Zachary Stewart
* Date       : March 7, 2023
* Description: jackOS Av0.0 is a simple interactive 'toy-box' system that
*              utilizes the EASy68K Fast Floating Point library for three simple games:
*              - Hammurabi (based upon Doug Dyment's text-based BASIC game in 1968)
*              - Interactive Unit Circle
*              - 68Karnage: a basic first-person ray tracing demo
*-----------------------------------------------------------
* Component Allocation
ROM:        EQU     $000000
RAM:        EQU     $100000
DUART:      EQU     $200000

STACK:      EQU     $10FFF0   ; starts from the bottom of RAM up

DATA:       EQU     RAM         ; Data origin
MAXCHR:     EQU     64          ; Length (bytes) of input line buffer
LNBUFF:     DS.B    MAXCHR      ; Input line buffer
BUFFEND:    EQU     LNBUFF+MAXCHR-1 ; end of line buffer
BUFFPT:     DS.L    1           ; Pointer to line buffer
PARAMTR:    DS.L    1           ; Last parameter from line buffer
ECHO:       DS.B    1           ; Enable input echo when clear
U_CASE:     DS.B    1           ; Flag for upper-case conversion
REG_F:      DS.W    37          ; Frame for D0-D7, A0-A6, USP, SSP, SR, PC
PROG:       DS.L    1           ; Start address of last program loaded

SIM:        EQU     $00     ;00 = hardware, 01 = simulation
            ORG     $000
            DCB.L   254,UNI_EX
            ORG     $0000    ; first instruction of program 
            DC.L    STACK
            DC.L    START
            ORG     $00C
            DC.L    ADD_ERR
            DC.L    IL_ERR
            DC.L    DIV_ZER
            ORG     $080
            DC.L    MAINMENU
            ORG     $0BC
            DC.L    TRAP_15
            
            
* Put program code here
START:      ORG  $8000  
            IFNE SIM
            MOVE.B #$00,D1
            MOVE.B #12,D0
            TRAP #15
            MOVE.L  #758*$10000+700,D1
            MOVE.B  #33,D0
            TRAP    #15
            MOVE.L  #STACK, A7
            CLR.L   D0
            CLR.L   D1
            ENDC
            
            BSR CLEAR_ALL
            BSR INIT_DUART
            
            * Setup global vars
            lea     DATA,A6         ; A6 points to data area
            clr.b   U_CASE(A6)      ; Set automatic upper-case conversion
            clr.b   ECHO(A6)        ; Set automatic input echo
    
            *setup global
MAINMENU:   BSR CLEAR
            BSR PRINTBAN
            CLR.W   D7
MENULOOP:   LEA MENU, A1
            BSR PUTSTR 
MAINLOOP:   LEA DATA,A6    
.input      BSR GETCHAR
            BSR PUTCHAR
            BSR CLEAR
            BSR PRINTBAN
            
.execute    CMPI.B    #$31, D0
            BEQ REGDISP
            CMPI.B    #$32, D0
            BEQ REGMOD
            CMPI.B    #$33, D0
            BEQ MEMDISP
            CMPI.B    #$34, D0
            BEQ MEMMOD
            CMPI.B    #$35, D0
            BEQ LOADSREC
            CMPI.B    #$36, D0
            BEQ RUNSREC
            BRA MENULOOP
            
PRINTBAN:   MOVE.L  A1, -(SP)
            LEA BANNER, A1
            BSR PUTSTR
            MOVE.L  (SP)+, A1
            RTS
    
* Put variables and constants here
    INCLUDE 'JSERIAL.X68'
    INCLUDE 'JCOMMANDS.X68'
    INCLUDE 'JEXCEPTION.X68'
    
* TRAP 15 brancher
TRAP_15:
.t0     cmp.b   #0,D0           ; D0=0, Print the byte in D1.B
        bne     .t1
        bsr     OUT2X
        rte
.t1     cmp.b   #1,D0           ; D0=1, Print the word in D1.W
        bne     .t2
        bsr     OUT4X
        rte
.t2     cmp.b   #2,D0           ; D0=2, Print Lowest 6 bytes in D1
        bne     .t3
        bsr     OUT6X
        rte
.t3     cmp.b   #3,D0           ; D0=3, Print the longword in D1.L
        bne     .t4
        bsr     OUT8X
        rte
.t4     cmp.b   #4,D0           ; D0=4, Print newline
        bne     .t5
        bsr     OUTNL
        rte
.t5     cmp.b   #5,D0           ; D0=5, Read single ascii character into D1.B
        bne     .t6
        bsr     GETCHAR
        rte
.t6     cmp.b   #6,D0           ; D0=6, Display single ascii character in D1.B
        bne     .t7
        bsr     PUTCHAR
        rte
.t7     cmp.b   #7,D0           ; D0=7, Read a hex character into D1
        bne     .t8             ; All input routines set D7 bit 0 (LSB) on conversion error
        bsr     HEX
        rte
.t8     cmp.b   #8,D0           ; D0=8, Read a hex byte into D1.B
        bne     .t9
        bsr     BYTE
        rte
.t9     cmp.b   #9,D0           ; D0=9, Read a hex word into D1.W
        bne     .t10
        bsr     WORD
        rte
.t10    cmp.b   #10,D0          ; D0=10, Read a longword into D1.L
        bne     .t13
        bsr     LONGWD
        rte
.t13    cmp.b   #13,D0          ; D0=13, Display Null terminated string at A1
        bne     .t14            ; With CR,LF
        bsr     PUTSTR
        bsr     OUTNL
        rte
.t14    cmp.b   #14,D0          ; D0=14, Display Null terminated string at A1
        bne     .t15
        bsr     PUTSTR
        rte
.t15    rte

* ASCII Symbols
NULL    EQU     $00     ;Null
BS      EQU     $08     ;Backspace
LF      EQU     $0A     ;Line Feed
CR      EQU     $0D     ;Carriage Return
NEWPAGE EQU     $0C     ;New Page
SPACE   EQU     $20     ;Space
WAIT    EQU     'W'     ;Wait Character
ESC     EQU     $1B     ;Escape Key
EOT     EQU     $04     ;End of Transmission
STARTUP
BANNER:
    DC.B    CR,LF,'           _                   ___  _          __       ____  _______                  _           '
    DC.B    CR,LF,'        _/( ) ____  ________  / _/ (_)__ _____/ /______/ __ \/ __/  / ________  ____  ( )_/|       '
    DC.B    CR,LF,'       > _<V /___/ /___/___/ / /  / / _ `/ __/  ',$27,'_/___/ /_/ /\ \ / / /___/___/ /___/   V> _<       '
    DC.B    CR,LF,'       |/      ___/___/     / /__/ /\_,_/\__/_/\_\    \____/___// /     /___/___        |/         '
    DC.B    CR,LF,'              /___/        /__/___/                           /__/         /___/                   '
    DC.B    CR,LF,'@#*~---------------------------------[jackOS alpha v0.0, 2023]---------------------------------~*#@',CR,LF,EOT                                                                                                                                      
MENU:
    DC.B    CR,LF,'     COMMANDS [1-6]:'
    DC.B    CR,LF,'         *[1] - Display Registers'
    DC.B    CR,LF,'         *[2] - Write Registers'
    DC.B    CR,LF,'         *[3] - Display Memory'
    DC.B    CR,LF,'         *[4] - Write Memory'
    DC.B    CR,LF,'         *[5] - Load SMILE at RAM START via AutoKey'
    DC.B    CR,LF,'         *[6] - Run SMILE',CR,LF,EOT

    END     START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
