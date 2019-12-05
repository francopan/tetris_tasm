PushAXBXCXDX

    mov BX, 4H ; Variavel de controle do loop externo (contem posicao inicial da linha a ser transposta)
    transpor_peca: 
        ; Calcula posicao incial na matriz transposta:  16 - (4* (( INDEX / 4)+1))
        mov AX, BX
        push BX
            mov BL, 4h
            div BL
            mov AL, AH
            xor AH,AH
        pop BX

        inc AL
        sal AL, 2 ; sal = shift arithmetic left
        mov DX, 16d
        sub DX, AX

        ; Adiciona as proximas quatro linhas
        mov CX, 4h
        mov BP, DX
        transpoe_linha:
            mov AX, [SI]
            mov [DI + BP], AX
            sub BP, 5
            inc SI
        loop transpoe_linha
        inc SI
        inc BX
        cmp BX, 8
    jne transpor_peca

    mov BP, 5
    mov AX, '$'
    adiciona_cifrao:
        mov [DI + BP], AX
        add BP, 5
        cmp BP,25
        jne adiciona_cifrao

    PopAXBXCXDX