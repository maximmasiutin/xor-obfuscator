;9A-attr
;149

CSEG    segment
        assume  cs:CSEG
        org     100h
START:
        jmp     PREPARE
ToAfterPrepare:
        int     21h
        mov     ax,4200h
        xor     cx,cx
        cwd
        int     21h
        mov     di,offset ENDPRG+3
        mov     cx,bp
        mov     si,offset ENDPRG
        push    si
        mov     dx,si
        lodsw
        mov     word ptr ds:B_1&2,ax
        lodsb
        mov     byte ptr ds:B_3,al
        mov     si,di
CODE_LOOP:
        lodsb
        not     al
        stosb
        loop    CODE_LOOP
        pop     di
        mov     byte ptr [di],0E9h
        mov     ax,bp
        mov     cx,ax
        sub     ax,3
        inc     di
        stosw
        inc     ax
        shr     ax,1
        mov     word ptr ds:LEN,ax
        mov     word ptr ds:LEN2,ax
        add     ax,9
	push	cx
        mov     cl,3
        shr     ax,cl
	pop	cx
        mov     word ptr ds:Alc,ax
        mov     ah,40h
        int     21h
        lea     dx,DECODE
        mov     cx,(offset DECODE_END-offset DECODE)
        mov     ah,40h
        int     21h
        mov     ah,3Eh
        int     21h
        pop     ax
        pop     cx
        mov     ch,0
        pop     dx
        int     21h
        int     20h

REP_SYMB proc near
;
; AL - character
; CX - repeater
;
        mov     dl,al
        mov     ah,2
 REP_SYMB_LOOP:
        int     21h
        loop    REP_SYMB_LOOP
        ret

REP_SYMB endp

MY_LINE proc near
        mov     al,'Ä'
        mov     cx,69
        call    REP_SYMB
        lea     dx,CRLF
        mov     ah,9
        int     21h
        ret
CRLF    db      13,10,'$'
MY_LINE endp

DECODE:
        pushf
        cli
        cld
        push    ds
        push    es
	mov	bx,1000h
	mov	ah,4Ah
	int	21h
        mov     ah,48h
        mov     bx,0DEADh
   Alc  equ     $-2
        int     21h
        mov     es,ax
        mov     si,103h
        mov     cx,0FADEh
  LEN2  equ     $-2
        push    cx
        mov     di,3
        push    di
        rep     movsw
        push    es
        pop     ds
        mov     cx,0FADEh
   LEN  equ     $-2
        pop     si
        mov     di,si
DECODE_LOOP:
        lodsw
        not     ax
        stosw
        loop    DECODE_LOOP
        push    cs
        pop     es
        xor     si,si
        mov     word ptr ds:[si],0FACEh
 B_1&2  equ     $-2
        mov     byte ptr ds:[si+2],0ADh
   B_3  equ     $-1
        mov     di,100h
        pop     cx
        inc     cx
        inc     cx
        rep     movsw
        push    ds
        pop     es
        mov     ah,49h
        int     21h
	mov	bx,0FFFFh
	mov	ah,48h
	int	21h
	push	cs
	pop	es
	mov	ah,4Ah
	int	21h
        pop     es
        pop     ds
        mov     ax,100h
        push    cs
        push    ax
        iret
DECODE_END:
ENDPRG  :                       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PREPARE proc    near
        mov     ah,30h
        int     21h
        cmp     al,2
        ja      RIGHT_VERSION
        int     20h
RIGHT_VERSION:
        cld
        push    cs
        pop     ds
        push    cs
        pop     es
        mov     al,'Ä'
        mov     cx,47
        call    REP_SYMB
        lea     dx,RSsoftware
        mov     ah,9
        int     21h
        mov     al,'Ä'
        mov     cx,10
        call    REP_SYMB
        lea     dx,ABOUT
        mov     ah,9
        int     21h
        call    MY_LINE
        mov     si,80h
        lodsb
        or      al,al
        jnz     NEXT_0
        lea     dx,Usage
        mov     ah,9
        int     21h
        call    MY_LINE
        int     20h
NEXT_0:
        lodsb
        cmp     al,20h
        jz      NEXT_0
        dec     si
        mov     dx,si
        mov     di,si
        mov     cx,0Fh
        mov     al,0Dh
        repnz   scasb
        dec     di
        mov     byte ptr ds:[di],0
        mov     ah,4Eh
        xor     cx,cx
        dec     cx
        int     21h
        jnc     NEXT_1
        lea     dx,BadFN
        mov     ah,9
        int     21h
        int     20h
NEXT_1:
        mov     dx,9Eh
        push    dx
        push    word ptr ds:[149]
        xor     cx,cx
        mov     ax,4301h
        push    ax
        int     21h
        cmp     word ptr ds:[9Ch],0
        jz      NEXT_2
TOO_BIG: lea    dx,TooBig
        mov     ah,9
        int     21h
        int     20h
NEXT_2:
        ja      TOO_BIG
        mov     ax,word ptr ds:[9Ah]
        cmp     ax,63000
        ja      TOO_BIG
        mov     bp,ax
        mov     dx,9Eh
        mov     ax,3D02h
        int     21h
        mov     dx,offset ENDPRG
        mov     bx,ax
        mov     ah,3Fh
        mov     cx,bp
        jmp     ToAfterPrepare
PREPARE endp

RSsoftware db   ' RSsoftware $'
ABOUT   db      13,10,'XOR program coder. Version 2.0. Copyright (C) 1992-93 by MasyutinMax~',13,10,'$'
Usage   db      13,10,'Usage:    XOR.COM <filename.ext>',13,10,'$'
BadFN   db      13,10,'File not found',13,10,'$'
TooBig  db      13,10,'This file is to big to be coded',13,10,'$'

CSEG    ends
        end     START

