
.MODEL small
.STACK 100H

.DATA
;data declarations

    
;-----------------------------------------------------------------
    
;for MergeSort:
    array db 5, 1, 26, 182, 5, 253, 98, 182 ;(Decimal)
    
    ;After MergeSort is done:
    ;array : 1, 5, 5, 26, 98, 182, 182, 253 (Decimal)
    ;array : 1, 5, 5, 1A, 62, B6, B6, FD    (Hexadecimal)
     
    len EQU ($-array) ; len becomes the length of `array` in bytes
    
    R db len dup(?)
    L db len dup(?)
    
    left_index dw 0
    right_index dw 0
    m dw 0
    n1 dw 0
    n2 dw 0
    arr_address dw 0
    i dw 0
    j dw 0
    k dw 0
    
;-----------------------------------------------------------------

.CODE

main:   
    mov ax, @data  ;initialize ds register
    mov ds, ax

;----------------------------------------------------------------- 
               ;Goal: 
               ; Merge Sort with proc 


    ;------------------------------------------------------------   
    ;    calc idea in cpp:
    ;    
    ;    https://www.geeksforgeeks.org/merge-sort/
    ;-----------------------------------------------------------    
    

    ;clear all data to 0
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    
    lea bx, array ;get the address of array
    mov cx, len   ;arr length
    
    mov left_index,0 
    mov right_index,len-1
    
    push left_index
    push right_index
    call mergeSort ;mergeSort(*array, left_index, right_index)
                   ;
                   ;   array is global 
                   ;   so there's no actual need to send the address 
    
    JMP TheEnd
    
    
    
    mergeSort PROC    
        mov bp,sp
        
        mov ax, [bp+2] ;right_index  
        mov dx, [bp+4] ;left_index                   
        cmp dx, ax     
        jae cont        ;if (left_index < right_index)                     
        
        
        mov left_index,dx
        mov right_index,ax
        mov m,0
        
        ;m = l+(r-l)/2;
        ;Same as (l+r)/2, but avoids overflow for large l and h
        mov ax,left_index
        mov m,ax 
        mov ax,right_index
        sub ax, left_index 

        shr ax,1 ;ax = ax/2
        add m, ax 
        
        ;Sort first halve
                            ;saving current data
        push left_index
        push right_index
        push m
        
                            ;parameters for function
        push left_index
        push m              ;new right_index
        call mergeSort
                            
                            ;get old data back after function
        pop m
        pop right_index
        pop left_index
        
        
        ;Sort second halve
                            ;saving current data
        push left_index
        push right_index
        push m
          
        inc m               ;parameters for function
        push m              ;new left_index
        push right_index
        call mergeSort
        
                            ;get old data back after function
        pop m
        pop right_index
        pop left_index
         
        ;re-arange the arr
        mov bx, offset array
        push left_index     ;parameters for function
        push right_index
        push m
        call merge
        
        cont: ret 4
   mergeSort ENDP
   
    
   merge PROC
        mov bp,sp
        mov ax, [bp+2]
        mov m,ax
        
        mov ax, [bp+4]
        mov right_index,ax
        
        mov ax, [bp+6]
        mov left_index,ax
                           
        mov i,0
        mov j,0
        mov k,ax ;left_index
        
        mov arr_address, bx                             
        
        ;Copy data to temp arrays L[] and R[]
        mov cx,m
        sub cx,left_index
        add cx,1
        mov n1,cx
        
        Loop1:
            mov si,i
            add si,left_index
            mov al,array[si]     
            sub si,left_index
            mov L[si],al         
                                 
            inc i
        loop Loop1
        mov i,0
        
        mov cx,right_index
        sub cx,m
        mov n2,cx 
        
        Loop2:
            mov si,j
            add si,m
            add si,1
            mov al,array[si]
            sub si,m
            sub si,1
            mov R[si],al
            inc j
        loop Loop2
        mov j,0
        
        ;Merge the temp arrays back into arr[l..r]
        whileLoop1:
            mov ax,n1
            cmp i,ax
            jae whileLoop1_end
            mov ax,n2
            cmp j,ax
            jae whileLoop1_end
            
            mov si,i
            mov al,L[si]
            mov si,j
            mov ah,R[si]
            cmp al,ah ;if (L[i] <= R[j]) 
            ja else
            
            mov si,k     ;then
            mov array[si],al
            inc i
            jmp keepGoing 
          
          else:
            mov si,k
            mov array[si],ah
            inc j
          
          keepGoing:
            inc k
        jmp whileLoop1
            
   whileLoop1_end:
            ;Copy the remaining elements of L[], if there are any
        whileLoop2:
            mov ax,n1
            cmp i,ax
            jae whileLoop2_end
            
            mov si,i
            mov al,L[si]
            mov si, k
            mov array[si],al
            inc i
            inc k
        jmp whileLoop2
            
   whileLoop2_end:
            ;Copy the remaining elements of R[], if there are any
        whileLoop3:
            mov ax,n2
            cmp j,ax
            jae whileLoop3_end
            
            mov si,j
            mov al,R[si]
            mov si, k
            mov array[si],al
            inc j
            inc k
        jmp whileLoop3
            
   whileLoop3_end:
                 
        ret 6
   merge ENDP
    
;-----------------------------------------------------------------
    
    TheEnd: ;return control to the operating system
    mov ax, 4C00h  
    int 21h
      
END main      
