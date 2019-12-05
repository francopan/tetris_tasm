
ROTACIONAR proc ; SI = Peca Fonte ; DI = Peca Destino
    PushAXBXCXDX
    ;mov CX, 20d
    ;mov BX, 0
    ;loop_rotaciona:
    ;    mov AX, [SI + BX]
    ;    mov [DI + BX], AX
    ;    inc BX
    ;loop loop_rotaciona

  
    
    ; Coloca Cifroes
    mov BX,4
    mov CX,4
    loop_t5:
        mov AX, [SI + BX]
        mov [DI + BX], AX
        add BX,5
        ;inc SI
    loop loop_t5
    
    mov BX,3
    mov CX,4
    loop_t1:
        mov AX, [SI + BX]
        mov [DI + BX], AX
        add BX,5
        ;inc SI
    loop loop_t1
    ;inc SI

    mov BX,2
    mov CX,4
    loop_t2:
        mov AX, [SI + BX]
        mov [DI + BX], AX
        add BX,5
        ;inc SI
    loop loop_t2
    ;inc SI
 

    mov BX,1
    mov CX,4
    loop_t3:
        mov AX, [SI  + BX]
        mov [DI + BX], AX
        add BX,5
        ;inc SI
    loop loop_t3
    ;inc SI

    mov BX,0
    mov CX,4
    loop_t4:
        mov AX, [SI  + BX]
        mov [DI + BX], AX
        add BX,5
        ;inc SI
    loop loop_t4

    PopAXBXCXDX
ret
endp