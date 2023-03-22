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
RAM     EQU     $000000
ROM     EQU     $010000
DUART   EQU     $020000

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
MRRst   EQU     $10     ;Reset MRA/MRB Pointer
RxRst   EQU     $20     ;Reset Rx
TxRst   EQU     $30     ;Reset Tx
BAUD_RATE   EQU     $CC    ;Baud Rate = 19.2K Baud = 2400 bytes/second

    ORG    $0000
    
    ORG    $1000
MONITOR:                  ; first instruction of program

* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

* ASCII Symbols
NULL    EQU     $00     ;Null
BS      EQU     $08     ;Backspace
CR      EQU     $0D     ;Carriage Return
LF      EQU     $0A     ;Line Feed
SPACE   EQU     $20     ;Space
WAIT    EQU     'W'     ;Wait Character
ESC     EQU     $1B     ;Escape Key
EOT     EQU     $04     ;End of Transmission
BANNER:
    DC.B    CR,LF,'             ___   ________   ________   ___  __     ________   ________      '
    DC.B    CR,LF,'            |\  \ |\   __  \ |\   ____\ |\  \|\  \  |\   __  \ |\   ____\     '
    DC.B    CR,LF,'            \ \  \\ \  \|\  \\ \  \___| \ \  \/  /|_\ \  \|\  \\ \  \___|_    '
    DC.B    CR,LF,'          __ \ \  \\ \   __  \\ \  \     \ \   ___  \\ \  \\\  \\ \_____  \   '
    DC.B    CR,LF,'         |\  \\_\  \\ \  \ \  \\ \  \____ \ \  \\ \  \\ \  \\\  \\|____|\  \  '
    DC.B    CR,LF,'         \ \________\\ \__\ \__\\ \_______\\ \__\\ \__\\ \_______\ ____\_\  \ '
    DC.B    CR,LF,'          \|________| \|__|\|__| \|_______| \|__| \|__| \|_______||\_________\'
    DC.B    CR,LF,'                                                                  \|_________|'
    DC.B    CR,LF,'                                                  Welcome to jackOS alpha v0.0'                                                                                                                                      
MENU:
    DC.B    CR,LF,'     COMMANDS [1-6]:'
    DC.B    CR,LF,'         *[1] - Display Registers'
    DC.B    CR,LF,'         *[2] - Write Registers'
    DC.B    CR,LF,'         *[3] - Display Memory'
    DC.B    CR,LF,'         *[4] - Write Memory'
    DC.B    CR,LF,'         *[5] - Load S-Record over Serial'
    DC.B    CR,LF,'         *[6] - Run S-Record'

    INCLUDE "JSERIAL.X68"

MAINLOOP:
    bsr GETCHAR
    
    cmpi D1, #$31
    
    
    END    MONITOR        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
