.model small
.stack 100H
.data
    ;Textos que serao impressos na Tela
    ;-----------------------------------  
        ; MENU
        TETRIS  db 15, ' T E T R I S ', 15,'$'
        JOGAR db '(J)ogar$'
        SAIR  db '(S)air$'
        DESENV db 'Desenvolvido por Marcelo e Franco, 2019$'
    
        ; Layout Jogo
        QUADRADO_CHAR equ 00DBh ; ASCII Character
        LATERAL_JOGO  db QUADRADO_CHAR, '          ', QUADRADO_CHAR,'$'
        BASE_JOGO db 12 dup(QUADRADO_CHAR), '$'
        BASE_CAIXA_PECA db 8 dup(QUADRADO_CHAR), '$'
        LATERAL_CAIXA_PECA db QUADRADO_CHAR, '      ', QUADRADO_CHAR,'$'
        SCORE_MSG db 'SCORE$'

        PECA_S db ' ',QUADRADO_CHAR,QUADRADO_CHAR,' $',QUADRADO_CHAR,QUADRADO_CHAR,'  $','    $','    $'
        PECA_T db ' ',QUADRADO_CHAR,'  $',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,' $','    $','    $'
        PECA_J db QUADRADO_CHAR,'   $',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,' ','$','    $','    $'
        PECA_O db ' ',QUADRADO_CHAR,QUADRADO_CHAR,' $',' ',QUADRADO_CHAR,QUADRADO_CHAR,' $','    $','    $'
        PECA_I db '    $',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,'$','    $','    $'
        PECA_Z db QUADRADO_CHAR,QUADRADO_CHAR,'  $',' ',QUADRADO_CHAR,QUADRADO_CHAR,' $','    $','    $'
        PECA_L db '  ',QUADRADO_CHAR,' $',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,' $','    $','    $'
        

        ; Tela de Sa?da do Jogo
        OBRIGADO    db 'O B R I G A D O$P O R   J O G A R$'
       
        ;Tela Game over
        GAME    db 'G A M E$'
        OVER    db 'O V E R$'

    
    ;  ~Variaveis ~ Jogo
    ;------------------------------------
    SCORE_JOGO db 5 dup('0'),'$'  ; Texto do Score
    SCORE_JOGO_HEX dw ?       ; Pontuacao (hex)
    PROX_PECA_NUM db ?
    CURR_PECA_NUM db ?
    CURR_W db ?
    CURR_H db ?
    PECA_TEMP db 20 dup(' ')

    HORA_ULTIMA_LEITURA            dd 11111111h  ; Hora do ultimo scroll
    DIFERENCA_TEMPO              dd 11111111h  ; DIFERENCA_TEMPOado do calculo do tempo

    ; Teclas
    ;------------------------------------
    KeyDown             equ 5000h
    KeyLeft             equ 4B00h
    KeyRight            equ 4D00h
    KeySpaceBar         equ 0020h
   
.code

PushAXBX macro 
    push AX 
    push BX 
endm

PushAXBXCX macro 
    PushAXBX 
    push CX 
endm

PushAXBXCXDX macro 
    PushAXBXCX
    push DX 
endm
    
PopAXBX macro 
    pop  BX
    pop  AX 
endm

PopAXBXCX macro 
    pop  CX 
    PopAXBX 
endm

PopAXBXCXDX macro 
    pop  DX 
    PopAXBXCX 
endm

GENERATE_RANDOM proc ; Return AL
    push BX
    push CX
    push DX
    
    mov AX, 0605h
    mov BX, 0000h
    mov CX, 021Ch
    mov DX, 0621h
    int 10h
    
    mov  AX, 0h
    int  1Ah
    
    mov  AX, DX
    mov  CX, 7h
    mov  DX, 0h
    div  CX
    mov  AX, DX
    xor  AH, AH

    pop DX
    pop CX
    pop BX
    ret
endp

CHAR_DISPLAY proc  ; Proc que imprime na tela UM caractere em determinada cor (BL)
    PushAXBXCX
    xor  AH, AH
    xor  CX, CX
    mov  AH, 09h            ;Servico da interrupcao 10h para imprimir caractere na tela  
    mov  CX, 01h            ;Numero de vezes que o caractere sera mostrado na tela
    int  10h                ;Interrupcao de video 10h   
    PopAXBXCX
    ret
endp

GOTO_XY proc   ;Macro que seta o cursor em uma posicao X [BL],Y [BH]  AH=02h    BH = Page Number, DH = Row, DL = Column 
    PushAXBXCXDX  
    xor AX, AX
    mov AH, 2       ;Servico da interrupcao 10h para alterar posicao do cursor 
    int 10h         ;Interrupcao de video 10h
    popAXBXCXDX
    ret
endp

IMP_PECA_GENERICO proc ; SI  = offset peca ; DH = linha da peca; DL = coluna da peca; BL = cor da peca
  PushAXBXCXDX
  mov CX,4
  imprime_peca:
    call IMP_STRING
    inc DH
    inc SI
    loop imprime_peca
  PopAXBXCXDX 
  ret
endp

IMP_PECA proc ; al = peca ; ah [0 = escreve; 1 = apaga]
    PushAXBXCXDX
    cmp  AL, 00d ; Peca T
    jne  tenta_peca_s
        mov BL, 04h            
        mov SI, OFFSET PECA_T
        jmp imprime_peca_agora
    tenta_peca_s:
    cmp  AL, 01d ; Peca S
    jne  tenta_peca_z
        mov BL, 06h            
        mov SI, OFFSET PECA_S
        jmp imprime_peca_agora
    tenta_peca_z:    
    cmp  AL, 02d ; Peca Z
    jne  tenta_peca_i
        mov BL, 0Eh            
        mov SI, OFFSET PECA_Z
        jmp imprime_peca_agora
    tenta_peca_i:    
    cmp  AL, 03d ; Peca I
    jne  tenta_peca_o
        mov BL, 02h            
        mov SI, OFFSET PECA_I
        jmp imprime_peca_agora
    tenta_peca_o:    
    cmp  AL, 04d ; Peca O
    jne  tenta_peca_J
        mov BL, 03h            
        mov SI, OFFSET PECA_O
        jmp imprime_peca_agora
    tenta_peca_J:    
    cmp  AL, 05d ; Peca j
    jne  tenta_peca_L
        mov BL, 09h            
        mov SI, OFFSET PECA_J
        jmp imprime_peca_agora
    tenta_peca_L:
        mov BL, 01h            
        mov SI, OFFSET PECA_L
        jmp imprime_peca_agora

    imprime_peca_agora:
    cmp ah, 1
    jne pula_e_imprime
    mov bl,0
    pula_e_imprime:
    mov AX,0
    call IMP_PECA_GENERICO

    PopAXBXCXDX
ret
endp

IMP_STRING proc ; Proc recebe a palavra, posicao e cor para imprimir na tela [SI palavra, DH posx, DL posy, BL cor]
    PushAXBXCXDX
    ;mov SI, AX
    ;xor AX, AX
    mov  AL, [SI]       ;Aponta para o endereco na memoria da string.
    loop_imp_string:
        call GOTO_XY            ;Chama o macro que seta o cursor [x,y]
        cmp AL, ' '
        je pula_char_display
        call CHAR_DISPLAY    ;Chama o macro que imprime na tela o caractere colorido
        pula_char_display:
        inc SI             ;Incremente a posicao na memoria para o proximo caractere
        inc DL              ;Incrementa a posicao x na tela para impressao do proximo caractere 
        mov AL, [SI]       ;Aponta para o endereco na memoria da string.
        cmp AL, '$'       ;Checa se chegou ao fim da string
        jne loop_imp_string
    PopAXBXCXDX
    ret
endp

LIMPAR_TELA proc  ; Essa proc limpa a tela do usuario
    PushAXBXCXDX   
    mov AX, 0620h
    mov BX, 0h
    mov CX, 0h
    mov DX, 1998h
    int 10h
    PopAXBXCXDX
    ret
endp

GERAR_PROXIMA_PECA proc
    PushAXBXCXDX
    mov SI, offset PROX_PECA_NUM
    mov AL, [SI]
    mov AH, 1h
    mov  DH, 04h
    mov  DL, 1Dh
    call IMP_PECA
    
    call GENERATE_RANDOM
    mov  AH, 0h
    call IMP_PECA
    mov SI, offset PROX_PECA_NUM
    mov [SI], AL
    PopAXBXCXDX
ret
endp

DELAY proc
    PushAXBXCXDX
    MOV     AL, 0
    MOV     CX, 0FH
    MOV     DX, 4240H
    MOV     AH, 86H
    INT     15H
    PopAXBXCXDX
ret
endp

PEGAR_POSICAO_PECA proc
    mov SI, offset CURR_W
    mov DH, [SI]
    mov SI, offset CURR_H
    mov DL, [SI]
    mov SI, offset CURR_PECA_NUM
    mov AL, [SI]
ret
endp

SETAR_POSICAO_ATUAL proc
    mov SI, offset CURR_W
    mov [SI], DH
    mov SI, offset CURR_H
    mov [SI], DL
ret
endp

ADD_PROX_PECA proc
    ; Adiciona Proxima Peca na tela
    PushAXBXCXDX
    mov SI, offset PROX_PECA_NUM
    mov AL, [SI]
    mov SI, offset CURR_PECA_NUM
    mov [SI], AL
    mov DL, 10h
    mov DH, 2h
    call SETAR_POSICAO_ATUAL
    call IMP_PECA
    PopAXBXCXDX
    call GERAR_PROXIMA_PECA
ret
endp

ATUALIZA_TEMPO proc ;Salva a hora atual na variavel lastTime
    PushAXBXCXDX
    mov  AX, 0h                     ; Ajusta para obter Contador de Tempo System-Timer
    int  1Ah                        ; Realiza a interrupcao

    mov  word ptr HORA_ULTIMA_LEITURA, DX      ; DX = Low-order part of clock count
    mov  word ptr HORA_ULTIMA_LEITURA + 2, CX  ; CX = High-order part of clock count
    PopAXBXCXDX
    ret
endp

VERIFICA_ULTIMO_TEMPO proc ; Salva em DIFERENCA_TEMPO decorrido entre a hora atual e a hora salva em HORA_ULTIMA_LEITURA
                               ; Retorna em AX o valor dos primeiros 16 bits
    PushAXBXCXDX
    mov  AX, 0h
    int  1Ah
    mov  AX, word ptr HORA_ULTIMA_LEITURA
    sub  DX, AX
    mov  word ptr DIFERENCA_TEMPO, DX
    mov  AX, word ptr HORA_ULTIMA_LEITURA + 2
    sbb  CX, AX
    mov  word ptr DIFERENCA_TEMPO + 2, CX
    PopAXBXCXDX
    mov  AX, word ptr DIFERENCA_TEMPO
    ret
endp


VERIFICA_INPUT proc
    PushAXBXCX
    verifica_novamente:
        push AX                 ; Armazena valor de AX para poder ler do teclado
        mov AH, 01h             ; Le o buffer
        mov AL, 00h
        int 16h                 ; Interrupcao de leitura
        jz sair_verifica_input  ; Se nao tem nada para ler, pula para fim do laco
        mov ah, 0   ; get       ; Obtem valor do teclado
        int 16h 
        
        ; Apaga Peca Atual
        push AX                 ; Empilha valor lido
        mov SI, offset CURR_PECA_NUM ; Pega numero da peca atual
        mov AX, [SI]
        mov AH, 1               ; Ajusta para escrever a peca em preto
        call IMP_PECA           ; Imprime a peca (como esta preta, vai apagar da tela)
        pop AX                  ; Desempilha valor lido
    
        ; Desloca Peca conforme valor lido no teclado
        call ATUALIZA_TEMPO 
        cmp AX, KeyRight        ; Verifica se foi seta direita
        je moveRight            
        cmp AX, KeyLeft         ; Verifica se foi seta esquerda
        jne sair_verifica_input ; Nao leu valor valido, portanto, pula outras verificacoes de leitura

        dec DL                  ; Decrementa Coluna
        jmp sair_verifica_input
        moveRight:
        inc DL


        sair_verifica_input:    
        pop AX          ; Retorna valor original do AX antes da leitura do teclado
        mov AH,0        ; Ajusta parametro para imprimir peca colorida
        call IMP_PECA   ;Imprime Peca
        call SETAR_POSICAO_ATUAL
        

        push AX
        call VERIFICA_ULTIMO_TEMPO
        mov CX, AX
        pop AX
        cmp  CX, 0Fh
        jna  verifica_novamente

    PopAXBXCX
ret
endp

DESCE_LINHA proc
    ; Apaga Peca
    mov AH,1
    call IMP_PECA

    ; Desce Linha
    inc DH

    ; Imprime Peca
    mov AH,0
    call IMP_PECA
    call ATUALIZA_TEMPO  
ret
endp

GAMEPLAY proc
    loop_jogo:
    ;call DELAY
    call ADD_PROX_PECA
    call PEGAR_POSICAO_PECA
    

    mov CX,20d
    loop_cai_peca:
        call DELAY
        call ATUALIZA_TEMPO
        call VERIFICA_INPUT 
        call DESCE_LINHA   

    loop loop_cai_peca
    jmp loop_jogo
ret
endp

TELA_JOGO proc
    PushAXBXCXDX   
    call LIMPAR_TELA
    
    ; Exibe Score (Pontuacao)
    mov SI, offset SCORE_JOGO
    mov DH, 02h
    mov DL, 04h
    mov BL, 06h  
    call IMP_STRING    
    
    ; Exibe Score (String)
    mov SI, offset SCORE_MSG
    mov DH, 01h
    mov DL, 04h
    mov BL, 07h  
    call IMP_STRING  
    
    ; Linha Superior e inferior do Jogo
    mov  SI, offset BASE_JOGO
    mov  DX, 010Ch
    call IMP_STRING
    mov DL, 0Ch
    mov DH, 18h
    mov  SI, offset BASE_JOGO
    call IMP_STRING
    
    ; Linhas Laterais Jogo
    mov CX,16h
    LOOP_TELA_JOGO:
    mov  SI, offset LATERAL_JOGO  
        inc   CL
        mov DL, 0Ch
        mov  DH, CL
        dec  CL
        mov  DL, 0Ch
        call IMP_STRING
        loop LOOP_TELA_JOGO
    
    ; Linha Superior e inferior Caixa Proxima Peca    
    mov  SI, offset BASE_CAIXA_PECA
    mov  DH, 1h
    mov  DL, 1Bh
    call IMP_STRING
    mov  SI, offset BASE_CAIXA_PECA
    mov DH, 08h
    call IMP_STRING
   
    mov CX,06h
    LOOP_TELA_CAIXA:
    mov  SI, offset LATERAL_CAIXA_PECA  
        inc  CL
        mov  DH, CL
        dec  CL
        call IMP_STRING
        loop LOOP_TELA_CAIXA

    ; Imprime Primeira Peca
    call GAMEPLAY
    PopAXBXCXDX
    ret
endp

TELA_INICIAL proc
   PushAXBXCXDX
   call LIMPAR_TELA
   
   ; Exibe tela inicial para o usuario
   mov SI, offset TETRIS ; Titulo
   mov BL, 02h
   mov DH, 05h 
   mov DL, 0Bh ;12d
   call IMP_STRING
  
   ; Exibe Tetraminos
   mov DH, 09h ; Linha inicial
   mov DL, 05h ; Coluna inicial
   mov AX, 00h ; Tetramino inicial
   mov CX, 7
   loop_tetramino_menu:
    call IMP_PECA
    add DL, 04d
    inc AL
   loop loop_tetramino_menu

    ; COOMENTADO - ROTACAO
   ;mov SI, offset PECA_I
   ;mov DI, offset PECA_TEMP
   ;call ROTACIONAR
   ;mov SI, offset PECA_TEMP

   ;mov DH, 09h ; Linha inicial
   ;mov DL, 05h ; Coluna inicial
   ;mov BL, 02h
   ;call IMP_PECA_GENERICO



   ; Opcao de Jogar
   mov SI, offset JOGAR 
   mov BL, 0Fh
   mov DH, 0Fh 
   mov DL, 0Fh ; 15d
   call IMP_STRING
   
   ; Opcao de Sair
   mov SI, offset SAIR 
   mov DH, 11h ;17d
   mov DL, 0Fh ; 15d
   call IMP_STRING
   
   ; Mensagem Desenvolvedores
   mov SI, offset DESENV 
   mov BL, 04h
   mov DH, 016h ;22d
   mov DL, 0h
   call IMP_STRING
   
   ; Realiza a leitura do usuario para entrar ou sair do jogo
   LEITURA_MENU:
       mov AX, 0h
       int 16h 
       cmp    AL, 'J'
       je     COMECA_JOGO
       cmp    AL, 'j'
       je     COMECA_JOGO
       cmp    AL, 'S'  
       je     FINALIZOU
       cmp    AL, 's'
       je     FINALIZOU  
   loopne LEITURA_MENU

   COMECA_JOGO:
       call TELA_JOGO
   FINALIZOU:
       call TELA_SAIDA  
   PopAXBXCXDX
   ret
endp

GAME_OVER proc
    PushAXBXCXDX
    call LIMPAR_TELA
    
    mov SI, offset GAME  
    mov BL, 0Ch
    mov DH, 05h 
    mov DL, 0Fh
    call IMP_STRING
    
    mov SI, offset OVER  
    mov BL, 0Ch
    mov DH, 0Ah 
    mov DL, 0Fh
    call IMP_STRING
    
    mov SI, offset JOGAR ; Opcao de Jogar
    mov BL, 0Fh
    mov DH, 0Fh 
    mov DL, 0Fh 
    call IMP_STRING
  
    mov SI, offset SAIR ; Opcao de Sair
    mov DH, 11h 
    mov DL, 0Fh 
    call IMP_STRING
   
    LEITURA_MENU2:
        mov AX, 0h
        int 16h 
        cmp    AL, 'J'
        je     COMECA_JOGO2
        cmp    AL, 'j'
        je     COMECA_JOGO2
        cmp    AL, 'S'  
        je     FINALIZOU2
        cmp    AL, 's'
        je     FINALIZOU2  
        loopne LEITURA_MENU2

        COMECA_JOGO2:
            call TELA_JOGO
            loopne LEITURA_MENU2
        FINALIZOU2:
            call TELA_SAIDA

    PopAXBXCXDX
ret
endp


TELA_SAIDA proc
    PushAXBXCXDX
    call LIMPAR_TELA
   
    ;Mensagem de despedida
    mov SI, offset OBRIGADO  
    mov BL, 04h
    mov DH, 05h 
    mov DL, 0Bh 
    call IMP_STRING
    
    inc SI
    mov BL, 02h
    mov DH, 0Ah 
    call IMP_STRING
   
    mov SI, offset TETRIS 
    mov BL, 0Eh
    mov DH, 0Fh 
    call IMP_STRING
   
    mov AL, 01h
    mov BL, 02h
    mov DH, 12h 
    mov DL, 5h
    mostra_carinhas: 
        call GOTO_XY
        call CHAR_DISPLAY
        add DL, 2h
        inc BL
        cmp DL, 21h
        jne mostra_carinhas
    PopAXBXCXDX
ret
endp 


MAIN:                               ;Bloco inicial do programa
    mov AX, @DATA
    mov DS, AX
        
    mov AH, 00h                     ;Servico de interrupcao que permite escrita na memoria de video 
    mov AL, 01h
    int 10h
    
    mov AX, 0b800h                  ;Inicio da regiao da memoria de video
    mov ES, AX
  
    call TELA_INICIAL
    ;call TELA_SAIDA
    
    mov AH, 4ch                     ;Procedimentos de finalizacao do programa
    mov AL, 00
    int 21h

end MAIN




