
.MODEL small
.STACK 100H

.DATA
;data declarations

    
;-----------------------------------------------------------------

;Example values for matrix multiplication:
    N EQU 3
    MAT1 db 2h,3h,1h,0Ah,8h,1h,0Fh,5h,4h
    MAT2 db  db 7h,3h,9h,0h,0Dh,1h,6h,0Bh,2h
    RESULT dw N*N dup (0)
    
    i dw 0
    j dw 0
    k dw 0
    mat_row_i dw 0
    mat_row_k dw 0     
    
;-----------------------------------------------------------------

.CODE

main:   
    mov ax, @data  ;initialize ds register
    mov ds, ax
    
;-----------------------------------------------------------------
   ;Goal: 
            ;mat1*mat2 -> res mat 
    
    
    ;------------------------------------------------------------   
    ;    calc idea in cpp
    ;    
    ;    mat1[N][N];   //cells initialized with values
    ;    mat2[N][N];   //cells initialized with values
    ;    result[N][N]; //all cells set to 0
    ;    
    ;    for(int i=0;i<N; i++)
    ;        for(int j=0; j<N; j++)
    ;             for(int k=0; k<N; k++)
    ;                   result[i][j] += mat1[i][k] * mat2[k][j];
    ;-----------------------------------------------------------    
            
    ;clear all data to 0
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    
    ;start outer loop - cx is loop index 
    mov cx,N 
    
    
  OuterLoop:
    mov i,N
    sub i,cx ;reverse loop index (from 0 up) 
    
    ;push ax
    push i
    call multiplyIndexByN
    mov i,ax
    ;pop ax
    
    mov j,0h ;inner loop index
              
              ; SI = i , DI = j
    InnerLoop1:
        mov k,0
        InnerLoop2: 

            ;push ax
            push k
            call multiplyIndexByN
            mov mat_row_k,ax
            ;pop ax
            
            mov di,mat_row_k ;jump "rows" in mat
            add di,j  
            mov dl,MAT2[di] ;matrix2[k][di]
            
            xor ax,ax
            
            mov si,i
            add si, k
            mov al,MAT1[si] ;matrix1[si][k] = matrix [si+k]
            sub si, k
                      
            imul dl     ;matrix[si][k] * matrix2[k][di] => AX
            add si,j   ;[i][j]
            add RESULT[si],ax ;last clac + now calc into Result matrix
            
            inc k
            cmp k,N
            JB InnerLoop2
            
        inc j
        cmp j,N
        JB InnerLoop1 
    dec j
    loop OuterLoop        
    
    JMP TheEnd
  
    
    multiplyIndexByN PROC    
        mov bp,sp                    
                                     
        mov ax,[bp+2]                
        mov dx,N
        mul dx ;result in ax
        
        ret 2
   multiplyIndexByN ENDP
    
;-----------------------------------------------------------------
    
    TheEnd: ;return control to the operating system
    mov ax, 4C00h  
    int 21h
      
END main      
