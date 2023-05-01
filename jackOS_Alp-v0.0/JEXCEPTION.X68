*-----------------------------------------------------------
* Title      :JEXCEPTION 
* Written by :Ian Crochet
* Date       :4/23/2023
* Description:takes care of error handling
*-----------------------------------------------------------
    ORG $88E0
UNI_EX:
            MOVE.L  A1, -(SP)
            LEA     BOMB, A1
            BSR     PUTSTR
            LEA     EX_UNI, A1
            BSR     PUTSTR
            MOVE.L  (SP)+, A1
            BRA     MAINLOOP
ADD_ERR:
            MOVE.L  A1, -(SP)
            LEA     BOMB, A1
            BSR     PUTSTR
            LEA     ERR_ADD, A1
            BSR     PUTSTR
            MOVE.L  (SP)+, A1
            BRA     MAINLOOP
IL_ERR:
            MOVE.L  A1, -(SP)
            LEA     BOMB, A1
            BSR     PUTSTR
            LEA     ERR_IL, A1
            BSR     PUTSTR
            MOVE.L  (SP)+, A1
            BRA     MAINLOOP
DIV_ZER:
            MOVE.L  A1, -(SP)
            LEA     BOMB, A1
            BSR     PUTSTR
            LEA     ERR_DIV, A1
            BSR     PUTSTR
            MOVE.L  (SP)+, A1
            BRA     MAINLOOP

BOMB:
    DC.B    CR,LF,'                             ____'
    DC.B    CR,LF,'                     __,-~~/~    `---.'
    DC.B    CR,LF,'                   _/_,---(      ,    )'
    DC.B    CR,LF,'               __ /        <    /   )  \___'
    DC.B    CR,LF,'- ------===;;;',$27,'====------------------===;;;===----- -  -'
    DC.B    CR,LF,'                  \/  ~"~"~"~"~"~\~"~)~"/'
    DC.B    CR,LF,'                  (_ (   \  (     >    \)'
    DC.B    CR,LF,'                   \_( _ <         >_>',$27
    DC.B    CR,LF,'                      ~ `-i',$27,' ::>|--"'
    DC.B    CR,LF,'                          I;|.|.|'
    DC.B    CR,LF,'                         <|i::|i|`.'
    DC.B    CR,LF,'                        (` ^',$27,'"`-',$27,' ")'
    DC.B    CR,LF,'Oopsie woopsie, looks like one of our PIPE BOMBS went off while you were acting DEVIOUS just now.'
    DC.B    CR,LF,'PIPE BOMB REPORT: ',EOT
EX_UNI: DC.B    'Stack Pointer Uninitialized',CR,LF,EOT
ERR_ADD: DC.B    'Address Error',CR,LF,EOT
ERR_IL: DC.B    'Illegal Instruction Error',CR,LF,EOT
ERR_DIV: DC.B    'Division by Zero Error',CR,LF,EOT

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
