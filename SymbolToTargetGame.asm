
.MODEL small
.STACK 100H

.DATA
;data declarations

    
;-----------------------------------------------------------------
    
;for Part1:
    screenPosition dw 0h
    
    screenCenter EQU 7CEh
    upArrow EQU 48h
    downArrow EQU 50h
    leftArrow EQU 04Bh
    rightArrow EQU 04Dh
    
    ;rows diff = 0A0h | cols diff = 02h
    rowSize EQU 0A0h
    colSize EQU 02h 
    
    ;screen has total space of 25x80 spots
    currentRow dw 13d  ;initial mid pos
    currentCol dw 40d  ;initial mid pos
    
;   screen limits:
;   39 + center + 40 (cols)
;   12 + center +12  (rows)

;For Part2:
    i dw 0
    j dw 0
    
    win dw 0 ;this will be 1 if we got into the yellow box 

;for Part3:
    msgFast db 'You are fast!$' ; 0 - 5 [sec]
    msgOK db 'Okay.$'           ; 5 - 10 [sec]
    msgSlow db 'That is slow.$' ; > 10 [sec]
    error_msg db 'Error$'
    
    RTC_seconds EQU 00h
    RTC_minutes EQU 02h
    
    startMint db 0
    startSec db 0
    
    endMint db 0
    endSec db 0
    
;-----------------------------------------------------------------

.CODE

main:   
    mov ax, @data  ;initialize ds register
    mov ds, ax
    
;-----------------------------------------------------------------
    ;Goal:
    
          ;Part 1 - 
            ;move the "@" from the center of the screen
            ;using the user's keyboard
            ;make sure not to step out of screen
            
          ;Part2 -
            ;repeat part 1 until user enters yellow part of the screen
            ;which means user has won the game
            ;yellow part = rows 0-5 , cols 0-15    
            
          ;Part3 -
            ;show winning msg according to time 
            ;consider the start hour & end hour are the same
            ;only minutes & seconds may change during the game
      
            
    ;clear all data to 0
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    
    
    call drawGameInitialState
    
    call checkTime
    ;now CL = minute, DH = second
    mov startMint, cl
    mov startSec, dh
    
    mov ax, screenCenter
    mov screenPosition, ax
   
    waitingForInput:
        call moveSymbolByArrows
    
        cmp win,0
    je waitingForInput
    
    call checkTime
    mov endMint, cl
    mov endSec, dh
    
    
    call winnersTimeMsg
    
    JMP TheEnd
    
    
       
    drawGameInitialState PROC    
        mov bp,sp                    
        
        xor ax,ax
        mov al, '@'
        mov ah,15d
        
        push ax
        push screenCenter
        call printCharInPos
        
        
        mov screenPosition,0
        
        mov i,0 ;outerloop index
        
        mov cx, 5 ;rows 0-5
        outerLoop:
            mov screenPosition,0
            mov j,0 ;inner loop index
            
            mov ax,i
            mov dx, rowSize
            mul dx
            
            mov screenPosition, ax
            
            innerLoop:
                            
              mov ax,j
              mov dx,colSize
              mul dx
              
              mov bx, screenPosition
              add screenPosition, ax   
              
              push bx   ;save old pos
              
              
              xor ax,ax
              mov al, ' '
              mov ah, 11101110b ; bg yellow & txt color yellow
                                ;  1110b = 14
              push ax
              push screenPosition
              call printCharInPos
              
              pop bx    ;get old pos back
              mov screenPosition,bx
              
              inc j
              cmp j,15 ;cols 0-15
            jb innerLoop
            
            inc i
        loop outerLoop
        
        mov screenPosition,0    
        ret 0
   drawGameInitialState ENDP
   
   
   printCharInPos PROC    
        mov bp,sp                    
        mov bx, [bp+2] ;get position to print
        mov dx, [bp+4] ;get char to print (in dl)
                       ;get color to print (in dh)
                                     
        ;setting extra segment to screen memory
        mov ax, 0b800h
        mov es, ax
    
        mov al, dl
        mov ah, dh
        mov es:[bx], ax
        
        ret 4
   printCharInPos ENDP
   
       
   moveSymbolByArrows PROC    
        mov bp,sp                    
                                     
        ;setting extra segment to screen memory
        mov ax, 0b800h
        mov es, ax

;--------------------------------------------------------  
;   INT 16h / AH = 00h - get keystroke from keyboard (no echo).
;   return:
;   AH = BIOS scan code.
;   AL = ASCII character.
;   (if a keystroke is present, it is removed from the keyboard buffer).
;--------------------------------------------------------        
        
     ;using Service 0 of 16h Interrupt        
        
        mov ah,0
        int 16h
        ;now AH = BIOS scan code
        
        ;and we can send the key pressed 
        ;into the function to see which key it was
;--------------------------------------------------------        
        
     ;using 64h/60h ports
        
        ;masking
;        in al,21h
;        or al,02h
;        out 21h,al    
        
;      IsKeyPressed:
;        in al,64h
;        test al,01h
;        jz IsKeyPressed ;if no key was pressed - repeat
                        
                        ;if key is pressed:
;        xor ax,ax       ;clean ax from old value
;        in ah,60h       ;get key pressed into ah
        
        ;now AH = BIOS scan code + 80h for release (msb)
       
        ;and we can send the key pressed 
        ;into the function to see which key it was

;--------------------------------------------------------

        
        mov dx,screenPosition ;save old position
        mov bx,screenPosition ;initialize bx with old pos
         
        mov al, upArrow 
        cmp ah,al
        jnz notUp
        
        ;up pressed
        mov cx, currentRow 
        sub cx,1
        cmp cx, 0
        je  continue
        
        sub currentRow,1
        mov bx,screenPosition
        sub bx,rowSize 
        mov screenPosition, bx
        jmp moveDraw
        
       notUp:
        mov al, downArrow 
        cmp ah,al
        jnz notDown
        
        ;down pressed
        mov cx, currentRow 
        add cx,1
        cmp cx, 26
        je  continue
        
        add currentRow,1
        mov bx,screenPosition
        add bx,rowSize
        mov screenPosition,bx
        jmp moveDraw
        
       notDown:
        mov al, leftArrow 
        cmp ah,al
        jnz notLeft
        
        ;left pressed
        mov cx, currentCol 
        sub cx,1
        cmp cx, 0
        je  continue
        
        sub currentCol,1
        mov bx,screenPosition
        sub bx,colSize
        mov screenPosition,bx
        jmp moveDraw
        
       notLeft:
        mov al, rightArrow 
        cmp ah,al
        jnz moveDraw    ;anything else means no need to draw again
        
        ;right pressed
        mov cx, currentCol 
        add cx,1
        cmp cx, 81
        je  continue
        
        add currentCol,1
        mov bx,screenPosition
        add bx,colSize
        mov screenPosition, bx
        

       moveDraw: 
        cmp screenPosition, dx     ;check if pose changed
        je continue    ;if they are the same no need to draw anything
        
        ;delete old pos
        xor ax,ax
        mov al, ' '
        mov ah, 15d
        
        push ax
        push dx ;old pos
        call printCharInPos
        

        ;write to new pos
        xor ax,ax
        cmp currentCol,15
        ja normalPrint
        cmp currentRow,5
        ja normalPrint
        
        ;next draw is between rows 0-5 & cols 0-15
        mov ah,11100000b ; bg yellow & txt color black
                         ;  1110b = 14  
        mov win,1
        jmp callPrintFunc
        
       normalPrint:
        mov ah,15d
                                        
       callPrintFunc:
        mov al, '@' 
        push ax
        push screenPosition ;new pos
        call printCharInPos
        
       continue:
        ret 0
   moveSymbolByArrows ENDP
   
   
   checkTime PROC
        mov bp,sp                    
;--------------------------------------------------------        
        
     ;using 70h/71h ports
                            
        ;mov al, RTC_minutes
        ;out 70h, al
        ;in al,71h
        ;mov cl,al
        
        ;mov al, RTC_seconds
        ;out 70h, al
        ;in al,
        ;mov dl,al

;--------------------------------------------------------        
        
     ;using Service 2Ch of 21h Interrupt
             
        mov ah,2Ch
        int 21h
        ;now CH = hour. CL = minute. DH = second. DL = 1/100 seconds.
;--------------------------------------------------------
                
        ret 0
   checkTime ENDP
   
   winnersTimeMsg PROC
        mov bp,sp
        
        mov bl,startMint
        mov bh,endMint
        cmp bh,bl
        je mintsDidntChange
        
        sub bh,bl
        xor ax,ax
        mov al,bh
        mov bx, 60d
        mul bx ;minutes diff * 60 sec per min -> ax
       
        add endSec, al 
            
      mintsDidntChange:
        mov bx, offset error_msg
        
        mov al,startSec
        mov ah,endSec
        sub ah,al
        cmp ah,10d
        ja slow
        
        cmp ah,5d
        ja ok
        
        mov bx, offset msgFast
        jmp printMsg
        
      ok:
        mov bx, offset msgOK
        jmp printMsg
        
        slow:
        mov bx, offset msgSlow
        
      printMsg:
      
        ;setting cursor to mid screen
        
        mov dh,13d ;set cursor row = mid row
        mov dl,40d ;set cursor col = mid col
        mov ah,02h ;use service 02h
        int 10h    ;use interrupt 10h
        
        ;print the string msg using 09 service of 21h interrupt
        mov dx,bx
        mov ah,09h
        int 21h
        
        ret 0
   winnersTimeMsg ENDP

;-----------------------------------------------------------------
    
    TheEnd: ;return control to the operating system
    mov ax, 4C00h  
    int 21h
      
END main      
