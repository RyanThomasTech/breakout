	.model tiny
	.code
start:
	cli
	mov ax,1234h		; debugger will stop when ax=1234
	mov ax,cs
	mov ds,ax			; allows us to get at variables
	
	mov ax,0b800h
	mov es,ax

	mov al, 00h
	mov si, 1
blankscreen:
	mov [es:si], al
	add si, 02h
	cmp si, 4000
	jle blankscreen

;==============ball init here
	mov si,ballx
	add si,bally		;move forward to color
		;purple = 5, purple background = 50
	mov al, 11h
	mov [es:si],al		;draw the ball

				
;================paddle starts here
	mov si, paddx
	add si, 3200
	mov al, 22h
	mov [es:si],al
	
	mov cl, 1		;counter to 1
	mov dl, 10		;data to 10 (width of paddle)

paddle:
	cmp dl, cl
	jz paddleEND

	add si, 02h
	mov [es:si],al
	add cl, 1
	jmp paddle
paddleEND:

;=======blocks start here
				;blocks start at 11,3
				;3 * 80 * 2 + 11*2 + 1 = 503 = 01f7h
	mov al, 55h
	mov si, 01f7h
	mov[es:si],al

	mov cl,1
	mov dl,20

blocks:
	cmp dl, cl
	jz blocksEND

	add si, 04h		;skip over a space each time
	mov [es:si],al
	add cl, 1
	jmp blocks
blocksEND:

;==========bounce logic===========

bounce:
	cmp ballx, 01h
	jz flipx
	cmp bally, 00h
	jz flipy
	cmp ballx, 159
	jz flipx
	cmp bally, 3840
	jnz notGameOver
	jmp gameOver
notGameOver:
	jmp moveBall
flipx:
	mov ax, 00h
	sub ax, balldx
	mov balldx, ax
	jmp moveBall		;note: corners will exhibit odd behavior

flipy:
	mov ax, 00h
	sub ax, balldy
	mov balldy, ax
	jmp moveBall

;===========movement logic=============

moveBall:
	mov si, ballx
	add si, bally
	mov al, 00h
	mov [es:si],al		;blank current ball spot

	mov dx, ballx
	add dx, balldx
	mov ballx, dx
	mov dx, bally
	add dx, balldy
	mov bally, dx		;calculate new ball spot

	mov si, ballx
	add si, bally
	mov al, 11h
	mov [es:si],al		;draw new ball spot

	mov cx, 3000h
delay:	

	in al,64h	; read from the keyboard command port
        and al,1	; get rid of all but the last bit
        jz nokey	; if it's zero, no key is pressed
        in al,60h	; get the keycode
        cmp al,4bh	; 4b is left arrow (4d is right arrow)
        jz moveleft	; handle left arrow
	cmp al, 4dh
	jz moveRight	; handle right arrow
        jmp clrbuf	; clear the keyboard buffer
moveleft:		; move paddle left
	sub paddx, 02h
	mov si, paddx
	add si, 3200
	mov al, 22h;
	mov [es:si],al
	add si, 20
	mov al, 00h
	mov [es:si],al
	jmp clrbuf
moveRight:
	mov si, paddx
	add si, 3200
	mov al, 00h;
	mov [es:si],al
	add paddx, 02h
	add si, 20
	mov al, 22h
	mov [es:si],al

clrbuf:			; go here after you move the paddle
        in al,60h	; read from the keyboard and throw away
        in al,64h	; check if the buffer is empty
        and al,1
        jnz clrbuf	; if it isn't, read again
nokey:

	sub cx, 1
	jnz delay
	
	cmp balldy, 0
	jg dontAbort0
	jmp bounce
dontAbort0:
	cmp bally, 3040
	jge dontAbort1
	jmp bounce
dontAbort1:
	mov ax, paddx
	cmp ballx, ax
	jge dontAbort2
	jmp bounce
dontAbort2:
	mov ax, paddx
	add ax, 20
	cmp ballx, ax
	jle paddleBounce
	jmp bounce
paddleBounce:
	mov ax, 0
	sub ax, balldy
	mov balldy, ax
	jmp bounce
	




gameOver:
	
	mov ah,0			; ah=0 means exit to dos
	jmp start
bally 	dw 1600
ballx	dw 97				;current location of the ball
balldy	dw 0ff60h			;-160 in 2s complement aka 1 row
balldx	dw 2				;+2, aka 1 space to the right
paddx	dw 67				;paddle starts at 33 from the left, or 67
	end


