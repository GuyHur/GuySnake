TITLE Assembly project Guy Hrushovski
Name Snake

IDEAL
MODEL small
STACK 100h
;-----------------------------
;MACRO_SECTION
;-----------------------------
macro print_tail color
	mov ax,[si]
	mov [x1],ax
	mov ax,[si+2]
	mov [y1],ax
	mov ax,[si+4]
	mov [x2],ax
	mov ax,[si+6]
	mov[y2],ax
	print_snake_node [x1],[y1],[x2],[y2],color
endm print_tail


macro paint_characters color,v1,v2,v3,v4
	xor al,al
	mov bh, color
	mov ch,v1
	mov cl,v2
	mov dh,v3
	mov dl,v4
	mov ah,6h
	int 10h


endm paint_characters

macro flush_buffer
	mov ah,0Ch
	xor al,al
	int 21h
endm flush_buffer

macro push_registers  r1,r2,r3,r4
     irp register,<r1,r2,r3,r4>
         ifnb <register>
                 push register
         endif
     endm
endm push_registers


macro pop_registers  r1,r2,r3,r4
      irp register,<r1,r2,r3,r4>
          ifnb <register>
                  pop register
          endif
      endm
endm pop_registers

macro set_node_edges
	mov ax,[randX]
	add ax,5
	mov [endRandX],ax
	mov bx,[randY]
	add bx,5
	mov [endRandY],bx
endm set_node_edges


macro get_pixel_color_by_pos cx_value,dx_value
	mov cx,cx_value
	mov dx,dx_value
	mov ah,0Dh
	int 10h
endm get_pixel_color_by_pos

macro print_snake_node sX,sY,eX,eY,color
	local line
	xor bh,bh
	mov ah,0Ch
	mov cx, sX
	mov dx, sY
	mov al, color
	line:
		int 10h
		inc cx
		cmp cx,eX
		jne line
	inc dx
	mov cx,sX
	cmp dx,eY
	jne line

endm print_snake_node

macro random_get max_value
	mov ax,40h
	mov es,ax               ;For Timer
	mov ax,[Clock]
    mov ah,[byte cs:bx]
	xor al,ah
	xor ah,ah               
	and al,max_value        ;Leave The Random Number Between 0-max_value 
endm random_get



macro timer_wait
	local wait_loop
	local change
	wait_loop:
		mov ah,2ch
		int 21h
		mov [prevMil],dl
		change:
			mov ah,2ch
			int 21h
			cmp dl,[prevMil]
			je change
endm timer_wait



macro get_tail_position
	local look
	local outlook
	mov bx, offset arr.x
	look:
		cmp [byte ptr bx],0
		je outlook
		add bx,11
		jmp look
	outlook:
		mov si,bx
		sub si,11
endm get_tail_position

macro set_cursor_position row,column
	push_registers ax,bx,dx
	xor bh,bh
	mov ah,02h
	mov dh,row
	mov dl,column
	int 10h
pop_registers dx,bx,ax
endm set_cursor_position

macro print_str string
	push_registers ax,dx
	mov dx,offset string
	mov ah,9h
	int 21h
	pop_registers dx,ax
endm print_str

macro touchapple_add v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11
	get_tail_position
	mov ax,v1
	mov v2,ax
	mov ax,v3
	mov v4,ax
	mov ax,v5
	add ax,5
	mov v6,ax
	mov ax,v7
	add ax,5
	mov v8,ax
	mov al,v9
	mov v10,al
	mov v11,al

endm touchapple_add

macro touchapple_sub v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11
	get_tail_position
	mov ax,v1
	mov v2,ax
	mov ax,v3
	mov v4,ax
	mov ax,v5
	sub ax,5
	mov v6,ax
	mov ax,v7
	sub ax,5
	mov v8,ax
	mov al,v9
	mov v10,al
	mov v11,al
	
endm touchapple_sub

DATASEG
	; --------------------------
	; Variables
	; --------------------------
	;GENERAL_VARS
	x dw 0
	y dw 0
	prevMil db ?
	colorsnake db 3
	Clock equ es:6Ch
	ColorsOptions db 14,6,10,2,11,3,9,1,13,5
	flagsc db ?
	
	;APPLE_GENERATION
	pointapple db 10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150,155     ;array of 30 possible position to put random apples
	randX dw ?
	randY dw ?
	flagrand db 0
	random_flag db 0
	;SNAKE_VARS
	num_of_apples db 0
	endRandX dw ?                                   ;cordinatot of random apples
	endRandY dw ?                                   ;cordinatot of random apples
	flagout db 0
	;Struct, The snake node
	struc snake_node
		x dw ?
		y dw ?
		endx dw ?
		endy dw ?
		direcB db ?
		direcN db ? ; 1- up, 2- down, 3-left, 4-right
		next db ?
	
	
	
	ends snake_node
	
	arr snake_node 5000 dup (?)
	x1 dw ?
	x2 dw ?
	y1 dw ?
	y2 dw ?
	
	;MENU_VARS
	Press_Enter db 'Press Enter To Start Playing$'
	Example db 'Example$'
	instruc_design db 'Pick A Color $'
	filename db 'menu.bmp',0
	filehandle dw ?
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10 ,'$'
	Score_Text db 'Score:$'
	Score_Number dw 0
	Present_Score db 'Your Score is: $'
	ascii db"   _____                 _    _____                      _ ",13,10
  db"  / ____|               | |  / ____|                    | |",13,10
  db" | |  __  ___   ___   __| | | |  __  __ _ _ __ ___   ___| |",13,10
  db" | | |_ |/ _ \ / _ \ / _` | | | |_ |/ _` | '_ ` _ \ / _ \ |",13,10
  db" | |__| | (_) | (_) | (_| | | |__| | (_| | | | | | |  __/_|",13,10
  db"  \_____|\___/ \___/ \__,_|  \_____|\__,_|_| |_| |_|\___(_)$",13,10    
CODESEG
;----------------
;STARTING_CODE
;----------------
start:
	mov ax, @data
	mov ds, ax
	mov es, ax
	call main

exit:
		mov ax, 4C00h
		int 21h



proc main
;clearing screen
	push_registers ax,bx,cx,dx
;change to graphic mode
	mov ax, 13h
	int 10h
	;TEXT->GRAPHIC
	call main_menu
	;GRAPHIC->TEXT
	mov ax,13h
	int 10h
	set_cursor_position 23,16
	print_str Score_Text
	mov [word ptr Score_Number],0
	call Print_Score
		
	call draw_borders
		
	call Random
		
	set_node_edges
	print_snake_node [randX],[randY],[endRandX],[endRandY],4
	mov bx,offset arr.x
		
	mov [byte ptr arr.x],100
	mov [byte ptr arr.endx],105
	mov [byte ptr arr.y],160
	mov [byte ptr arr.endy],165
    mov [byte ptr arr.direcN],4
	mov [byte ptr arr.direcB],4
		;--------------
	mov bx,offset arr.x
	mov [byte ptr bx+11],95
	mov bx,offset arr.endx			
	mov [byte ptr bx+11],100
	mov bx,offset arr.y
	mov [byte ptr bx+11],160
	mov bx,offset arr.endy
	mov [byte ptr bx+11],165
	mov bx,offset arr.direcN
	mov [byte ptr bx+11],4
	mov bx,offset arr.direcB
	mov [byte ptr bx+11],4
		
	call Play 
	call clear_screen
	call display_GameOver
	jmp end_main
		
		end_main:
			pop_registers dx,cx,bx,ax
			jmp exit
		
endp main

proc Play
;This is the main game function, function of the snake.
	push_registers ax,bx,cx,dx
	Main_Loop:
		set_cursor_position 23,22
		oo:
			cmp[arr.endy],170
			jae beforeOutlop
			cmp [arr.endx],312
			jae beforeOutlop
			cmp [arr.x],7
			jle beforeOutlop
			cmp [arr.y],7
			jle beforeOutlop
			mov ax,[arr.x]
			cmp [arr.endx],ax
			je beforeOutlop
			mov bx,offset arr.direcN

		waitForKey:
			in al,64h
			cmp al,10b
			je waitForKey
			in al,60h
			jmp checkKey
		beforeOutlop:
			jmp outlop
			
		checkKey:
			cmp al,1Eh
			je left_Key
			cmp al,1Fh
			je down_Key
			cmp al,20h
			je right_Key
			cmp al,11h
			je up_Key
			cmp [arr.direcB],1
			je up_Key
			cmp [arr.direcB],2
			je down_Key
			cmp [arr.direcB],3
			je left_Key
			cmp [arr.direcB],4
			je right_Key			
			
		left_Key:
			cmp [arr.direcB],4
			je Move_Snake
			mov [byte ptr bx],3
			jmp Move_Snake
		
		
		right_Key:
			cmp [arr.direcB],3
			je Move_Snake
			mov [byte ptr bx],4
			jmp Move_Snake
		
		down_Key:
			cmp [arr.direcB],1
			je Move_Snake
			mov [byte ptr bx],2
			jmp Move_Snake
		up_Key:
			cmp [arr.direcB],2
			je Move_Snake
			mov [byte ptr bx],1
		Move_Snake:
			flush_buffer
			call Settings_Move
			cmp[flagout],1
			je outlop
			jmp Main_Loop
		outlop:
			pop_registers dx,cx,bx,ax
			ret

endp Play

proc Settings_Move
	;Settings for the movement of the snake
	mov si, offset arr.x
	Settings_1:
		add si,11
		cmp [byte ptr si],0
		jne Settings_1
		sub si,11
		print_tail 0

		call Touching_Apple_Check
		call Snake
		mov [flagout],0
		call Touching_Himself
		cmp [flagout],1
		je exitset
		
		mov si, offset arr.x
		print_snake_node_loop:
			print_tail [colorsnake]
			add si,11
			cmp [byte ptr si],0
			jne print_snake_node_loop
		
		timer_wait

		mov bx, offset arr.direcB
		copy:
			mov al,[bx+1]
			mov [bx],al
			add bx,11
			cmp [byte ptr bx],0
			jne copy
		exitset:
			ret

endp Settings_Move

proc Touching_Himself
	cmp [arr.direcN],1
	je CheckUp
	cmp [arr.direcN],2
	je CheckDown
	cmp [arr.direcN],3
	je CheckLeft
	
	
	
		mov ax,[arr.y]
		mov [y1],ax
		add [y1],3
		mov ax,[arr.endx]
		inc ax
		mov [x1],ax
		get_pixel_color_by_pos [x1],[y1]
		cmp al,[colorsnake]
		je touchhimself
		jmp outhimself
	
	checkUp:
		mov ax,[arr.x]
		mov [y1],ax
		add [y1],3
		mov ax,[arr.y]
		inc ax
		mov [x1],ax
		get_pixel_color_by_pos [y1],[x1]
		cmp al,[colorsnake]
		je touchhimself
		jmp outhimself
	
	checkDown:
		mov ax,[arr.x]
		mov [y1],ax
		add [y1],3
		mov ax,[arr.endy]
		inc ax
		mov [x1],ax
		get_pixel_color_by_pos [y1],[x1]
		cmp al,[colorsnake]
		je touchhimself
		jmp outhimself
	CheckLeft:
		mov ax,[arr.y]
		mov [y1],ax
		add [y1],3
		mov ax,[arr.x]
		inc ax
		mov [x1],ax
		get_pixel_color_by_pos [x1],[y1]
		cmp al,[colorsnake]
		je touchhimself
		jmp outhimself
	touchhimself:
		mov [flagout],1
	outhimself:
	ret
		

endp Touching_Himself

proc clear_screen

    mov ah,0
    mov al,13h
    int 10h

    mov ah,0Bh
    mov bh,00h
    mov bl,00h
    int 10h

    ret

endp clear_screen
	
proc OpenFile
	; Open file function
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc outopenfile
	mov [filehandle], ax
	ret
outopenfile:
	ret
endp OpenFile

proc ReadHeader
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader 

proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette
	
proc CopyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB .
	mov al,[si+2] ; Get red value .
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it .
	mov al,[si+1] ; Get green value .
	shr al,2
	out dx,al ; Send it .
	mov al,[si] ; Get blue value .
	shr al,2
	out dx,al ; Send it .
	add si,4 ; Point to next color .
	loop PalLoop
	ret
endp CopyPal

proc CopyBitmap
	mov ax, 0A000h
	mov es, ax
	mov cx,200
	PrintBMPLoop :
	push cx
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
	cld
	mov cx,320
	mov si,offset ScrLine
	rep movsb
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitmap

proc main_menu
	push_registers ax,bx,cx,dx
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	mov ah,00h
	int 16h
	call clear_screen

	pop_registers dx,cx,bx,ax
	ret

endp main_menu

proc Random
	;Creates random apples on the screen
	generate_apple:
		random_get 29d ;get a random number between 0-30d
		mov bx, offset pointapple
		add bx,ax
		mov al,[bx]
		mov [randX],ax
		random_get 29d
		mov bx, offset pointapple
		add bx,ax
		mov al,[bx]
		add [randX],ax
		random_get 29d
		mov bx, offset pointapple
		add bx,ax
		mov al,[bx]
		mov [randY],ax
		mov [flagrand],0
		call Check_Random
		cmp [flagrand],1
		je generate_apple
	   ret
	
endp Random

proc Check_Random
	;Checks if the Random generated apple is on the snake position(bad)
	get_tail_position
	mov bx, offset arr.x
	sub bx,11
	checkapple:
		add bx,11
		mov ax,[randX]
		cmp ax,[bx]
		je bad
		mov ax,[randY]
		cmp ax,[bx+1]
		je bad
		cmp si,bx
		jae bad
		jmp checkapple
	bad:
		cmp si,bx
		jae outcheckapple
		mov [flagrand],1
	outcheckapple:
	ret
endp Check_Random


proc Touching_Apple_Check
	;Checks if the Snake is touching the apple
	add [randX],3
	add [randY],3
	get_pixel_color_by_pos [randX],[randY]
	sub [randX],3
	sub	[randY],3
	cmp al,[colorsnake]
	je Apple_Touch
	jmp Exit_AppleTouch
	Apple_Touch:
		inc [Score_Number]
		call Print_Score

		cmp[byte ptr si+9],2
		je is_down
		cmp [byte ptr si+9],3
		je is_left
		cmp [byte ptr si+9],1
		je bis_up
		cmp[byte ptr si+9],4
		je is_right
		
	is_left:
		touchapple_add [si+2],[bx+2],[si+6],[bx+6],[si],[bx],[si+4],[bx+4],[si+8],[bx+8],[bx+9]
		jmp con
	is_down:
		touchapple_sub[si],[bx],[si+4],[bx+4],[si+2],[bx+2],[si+6],[bx+6],[si+8],[bx+8],[bx+9]
		jmp con
	bis_up:
		jmp is_up
	is_right:
		touchapple_sub[si+2],[bx+2],[si+6],[bx+6],[si],[bx],[si+4],[bx+4],[si+8],[bx+8],[bx+9]
		jmp con
	is_up:
		touchapple_add[si],[bx],[si+4],[bx+4],[si+2],[bx+2],[si+6],[bx+6],[si+8],[bx+8],[bx+9]
	con:
		sub [randX],3
		sub [randY],3
		add [endRandX],3
		add [endRandY],3
		print_snake_node [randX],[randY],[endRandX],[endRandY],0 
		call Random
		set_node_edges
		print_snake_node [randX],[randY],[endRandX],[endRandY],4
	Exit_AppleTouch:
		ret
endp Touching_Apple_Check


proc Snake
	;Snake procedure
	mov bx, offset arr.direcB
	setDirectionBefore:
		mov al,[bx]
		mov [bx+12],al
		cmp [word ptr bx+23],0
		je outDirectionBefore
		add bx,11
		jmp setDirectionBefore
	outDirectionBefore:
		mov bx, offset arr.direcN
		mov di,2
		xor cx,cx
		xor ax,ax
		mov dx,2
	MovDirectionNow:
		mov si,offset arr.x
		cmp[byte ptr bx], 1
		je callup
		cmp [byte ptr bx],2
		je calldown
		cmp [byte ptr bx],3
		je callleft
		
		push bx
		mov bx,cx
		add [word ptr si+bx],5
		add [word ptr si+bx+4],5
		pop bx
		jmp checkmov
	callup:
		push bx
		mov bx,di
		sub [word ptr si+bx],5
		sub [word ptr si+bx+4],5
		pop bx
		jmp checkmov
	calldown:
		push bx
		mov bx,dx
		add [word ptr si+bx],5
		add [word ptr si+bx+4],5
		pop bx
		jmp checkmov
	callleft:
		push bx
		mov bx,ax
		sub [word ptr si+bx],5
		sub [word ptr si+bx+4],5
		pop bx
	checkmov:
		add bx,11
		add di,11
		add ax,11
		add cx,11
		add dx,11
		cmp [byte ptr bx],0
		jne MovDirectionNow
	ret

endp Snake





proc draw_borders
	;Draw the borders of the game.
	push_registers ax,bx,cx,dx

	xor bl,bl
	xor bh,bh
	mov al,15
	mov ah,0Ch
	;-----------
	xor cx,cx
	xor dx,dx
	jmp draw
	Bottom_Settings:
		mov dx,170
	draw:
		int 10h
		inc cx
		cmp cx,320
		jne draw
		inc dx
		xor cx,cx
		cmp bl, 1
		je Bottom
		cmp dx,5
		jne draw
		mov bl,1
		jmp Bottom_Settings
	Bottom:
			cmp dx,175
			jne draw
				xor bl,bl
				xor cx,cx
				xor dx,dx
				jmp draw2
	Right_Settings:
		mov cx,315
	draw2:
		int 10h
		inc dx
		cmp dx,175
		jne draw2
			inc cx
			xor dx,dx
			cmp bl,1
			je Right
			cmp cx,5
			jne draw2
			mov bl,1
			jmp Right_Settings
	Right:
		cmp cx,320
		jne draw2

	
	pop_registers dx,cx,bx,ax
	ret
		
endp draw_borders


proc Print_Score
	
	push bp
	
	mov bp, sp
	sub sp, 3*8
	mov ax,[Score_Number]
    mov [WORD PTR bp - 2*8], ax
    mov [BYTE PTR bp - 3*8], 0
    getDigits:
		mov ax, [WORD PTR bp - 2*8]
		mov dx, 0
		mov bx, 10
		div bx
		push dx
		mov [WORD PTR bp - 2*8], ax
		inc [byte PTR bp - 3*8]
		cmp [WORD PTR bp - 2*8], 0
		je getDigitsEnd
		jmp getDigits
	getDigitsEnd:

	printDigits:
		cmp [BYTE PTR bp - 3*8], 0; compare digits count and 0
		je printDigitsEnd
		pop ax
		add al, 30h     ; get character from digit into al
		mov ah, 0eh
		int 10h
		dec [BYTE PTR bp - 3*8]  ; digitsCount--
		jmp printDigits
	printDigitsEnd:
		mov sp, bp
        pop bp
        ret


endp Print_Score

proc display_GameOver
	mov ah, 00h
	mov al, 2h
	int 10h
	
	paint_characters 2,1,0,4,70
    paint_characters 2,5,0,8,70
    set_cursor_position 1,0
    print_str ascii
    paint_characters 00000100b,8,29,9,70
    set_cursor_position 8,29
    print_str Present_Score
    call Print_Score
	ret

endp display_GameOver

proc noise
	in al,61h
	or al, 00000011b
	out 61h, al
	mov al, 0b6h
	out 43h, al
	mov ax,1000h
	out 42h, al
	mov al,ah
	out 42h,al
	ret
endp noise


proc stopnoise
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
endp stopnoise

END start

