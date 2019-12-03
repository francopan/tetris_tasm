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
        
        ; Pecas (Nomes retirados de https://en.wikipedia.org/wiki/Tetromino)
        PECA_S db '    $','    $',' ',QUADRADO_CHAR,QUADRADO_CHAR,' $',QUADRADO_CHAR,QUADRADO_CHAR,'  $'
        PECA_T db '    $','    $','  ',QUADRADO_CHAR,' $',' ',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,'$'
        PECA_J db '    $','    $',QUADRADO_CHAR,'   $',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,' ','$'
        PECA_O db '    $','    $',' ',QUADRADO_CHAR,QUADRADO_CHAR,' $',' ',QUADRADO_CHAR,QUADRADO_CHAR,' $'
        PECA_I db '    $','    $','    $',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,'$'
        PECA_L db '    $','    $','   ',QUADRADO_CHAR,'$',' ',QUADRADO_CHAR,QUADRADO_CHAR,QUADRADO_CHAR,'$'
        PECA_Z db '    $','    $',QUADRADO_CHAR,QUADRADO_CHAR,'  $',' ',QUADRADO_CHAR,QUADRADO_CHAR,' $'
        
            
    
    ;  ~Variaveis ~ Jogo
    ;------------------------------------
    SCORE_JOGO db 5 dup('0'),'$'  ; Texto do Score
    SCORE_JOGO_HEX dw ?       ; Pontuacao (hex)
    
    
    
.code



; ~Variaveis~ globais 
;----------------------
len db 0h

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


IMP_PECA proc ; AX  = offset peca ; DH = linha da peca; DL = coluna da peca; BL = cor da peca
  PushAXBXCXDX
   mov CX,4
   imprime_peca:
    call IMP_STRING
    inc DH
    ADD AL,5
    loop imprime_peca
  PopAXBXCXDX 
  ret
ret
endp


IMP_STRING proc ; Proc recebe a palavra, posicao e cor para imprimir na tela [AX palavra, DH posx, DL posy, BL cor]
    PushAXBXCXDX
    mov SI, AX
    xor AX, AX
    mov  AL, [SI]       ;Aponta para o endereco na memoria da string.
    loop_imp_string:
        call GOTO_XY            ;Chama o macro que seta o cursor [x,y]
        call CHAR_DISPLAY    ;Chama o macro que imprime na tela o caractere colorido
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
    mov DX, 1928h
    int 10h
    PopAXBXCXDX
    ret
endp


TELA_JOGO proc
    PushAXBXCXDX
    
    call LIMPAR_TELA
    
  ; Exibe Score (Pontuacao)
    mov AX, offset SCORE_JOGO
    mov DH, 02h
    mov DL, 04h
    mov BL, 06h  
    call IMP_STRING    
    
    ; Exibe Score (String)
    mov AX, offset SCORE_MSG
    mov DH, 01h
    mov DL, 04h
    mov BL, 07h  
    call IMP_STRING  
    
    ; Linha Superior e inferior do Jogo
    mov  AX, offset BASE_JOGO
    mov  DX, 010Ch
    call IMP_STRING
    mov DL, 0Ch
    mov DH, 18h
    call IMP_STRING
    
    ; Linhas Laterais Jogo
    mov CX,16h
    LOOP_TELA_JOGO:
        mov  AX, offset LATERAL_JOGO  
        inc   CL
        mov DL, 0Ch
        mov  DH, CL
        dec  CL
        mov  DL, 0Ch
        call IMP_STRING
        loop LOOP_TELA_JOGO
    
    ; Linha Superior e inferior Caixa Proxima Pe?a    
    mov  AX, offset BASE_CAIXA_PECA
    mov  DH, 1h
    mov  DL, 1Bh
    call IMP_STRING
    mov DH, 08h
    call IMP_STRING
    
    mov CX,06h
    LOOP_TELA_CAIXA:
    mov  AX, offset LATERAL_CAIXA_PECA  
        inc  CL
        mov  DH, CL
        dec  CL
        call IMP_STRING
        loop LOOP_TELA_CAIXA
    
    
    PopAXBXCXDX
    ret
endp

  
TELA_INICIAL proc
   PushAXBXCXDX
   call LIMPAR_TELA
   
   ; Exibe tela inicial para o usuario
   mov AX, offset TETRIS ; Titulo
   mov BL, 02h
   mov DH, 05h 
   mov DL, 0Bh ;12d
   call IMP_STRING
  
   ; Exibe Tetraminos
   mov AX, OFFSET PECA_T
   mov BL, 04h
   mov DH, 07h
   mov DL, 06h
   call IMP_PECA
   
   mov AX, OFFSET PECA_S
   mov BL, 06h
   ;mov DH, 06h
   mov DL, 0Bh
   call IMP_PECA   
   
   mov AX, OFFSET PECA_Z
   mov BL, 0Eh
   ;mov DH, 06h
   mov DL, 0Fh
   call IMP_PECA
   
   mov AX, OFFSET PECA_I
   mov BL, 02h
   ;mov DH, 06h
   mov DL, 13h
   call IMP_PECA
   
   mov AX, OFFSET PECA_O
   mov BL, 03h
   ;mov DH, 06h
   mov DL, 17h
   call IMP_PECA
   
   mov AX, OFFSET PECA_L
   mov BL, 01h
   ;mov DH, 06h
   mov DL, 1Eh
   call IMP_PECA
   
   mov AX, OFFSET PECA_J
   mov BL, 09h
   ;mov DH, 06h
   mov DL, 1Bh
   call IMP_PECA
   
   mov AX, offset JOGAR ; Opcao de Jogar
   mov BL, 0Fh
   mov DH, 0Fh 
   mov DL, 0Fh ; 15d
   call IMP_STRING
  
   mov AX, offset SAIR ; Opcao de Sair
   mov DH, 11h ;17d
   mov DL, 0Fh ; 15d
   call IMP_STRING

   mov AX, offset DESENV ; Mensagem Desenvolvedores
   mov BL, 04h
   mov DH, 016h ;22d
   mov DL, 01h 
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
    ;call TELA_JOGO
    
    ;mov AH, 4ch                     ;Procedimentos de finalizacao do programa
    ;mov AL, 00
    ;int 21h

end MAIN




