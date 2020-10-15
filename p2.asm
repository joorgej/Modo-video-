org 100h

%macro print 3 		;x0,y0,cadena
	push dx
	push ax
	xor ax,ax
    xor dx,dx

	mov ah,02h
	mov dh,%1
	mov dl,%2
	int 10h

	mov dx,%3
	mov ah,9h
	int 21h
	pop dx
	pop ax
%endmacro

%macro escanear_pulsacion 0     ;retorna el caracter en AL
    xor ax,ax
    mov ah, 08h    
    int 21h
%endmacro

%macro pushear 0
	push ax
	push bx
	push cx
	push dx
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
%endmacro

%macro popear 0
	pop ax
	pop bx
	pop cx
	pop dx
%endmacro

%macro pixel 3				;x0,y0,color
	pushear
	;funcion 0ch = pintar un pixel, donde:
	;al = color del pixel
	;bh = 0h
	;dx = coordenada en y0
	;cx = coordenada en x0
	mov ah,0ch		;funcion pinta un pixel
	mov al,%3
	mov bh,0h
	mov dx,%2		;coord y0
	mov cx,%1		;coord x0
	int 10h
	popear
%endmacro

%macro dibujar_bloque 5		;x0,y0,tamX,tamY,color
	push di
	push si
	push dx
	xor di,di
	xor si,si
	mov di,%1		;x
	mov si,%2		;y
	%%ejex:
		pixel di,si,%5
		inc di
		xor dx,dx
		mov dx,%1
		add dx,%3
		cmp di,dx
		jne %%ejex
	%%ejey:
		inc si
		xor di,di
		mov di,%1
		xor dx,dx
		mov dx,%2
		add dx,%4
		cmp si,dx
		jne %%ejex
	%%fin:
		pop di
		pop si
		pop dx
%endmacro

%macro dibujar_linea 5 		;x0,y0,color,largo,direccion(1=horizontal,0=vertical)
	push di
	push si
	push bx
	push cx
	xor di,di
	xor si,si
	mov di,%1 	;x
	mov si,%2	;y
	mov cx,%5  	;direccion	

	%%direccion:
		cmp cx,1
		je %%ejex
		cmp cx,0
		je %%ejey
		jmp %%fin

	%%ejex:
		pixel di,si,%3
		inc di
		xor bx,bx
		mov bx,%1
		add bx,%4
		cmp di,bx
		je %%fin
		jmp %%ejex

	%%ejey:
		pixel di,si,%3
		inc si
		xor bx,bx
		mov bx,%2
		add bx,%4
		cmp si,bx
		je %%fin
		jmp %%ejey

	%%fin:
		pop di
		pop si
		pop bx
		pop cx
		
%endmacro

%macro dibujar_cuadro 5		;x0,y0,tamX,tamY,color
	dibujar_linea %1,%2,%5,%3,1
	dibujar_linea %1,%2,%5,%4,0
	push dx
	xor dx,dx
	mov dx,%2
	add dx,%4
	sub dx,1
	dibujar_linea %1,dx,%5,%3,1
	xor dx,dx
	mov dx,%1
	add dx,%3
	sub dx,1
	dibujar_linea dx,%2,%5,%4,0
	pop dx
%endmacro


section .data

;colores
negro equ 00h
blanco equ 0fh
rojo equ 0ch
celeste equ 4dh
amarillo equ 44h
verde equ 60h

;barra
barraX dw 118
barraY dw 181
barraTamX dw 84
barraTamY dw 4

;menu
menu1 db 'INGRESAR','$'
encab1 db 'USER1','$'

section .text
global _start
_start:
	mov ax,13h
	int 10h
	jmp menu

menu:
	print 3,6,menu1
	jmp _prech

	
interfaz:
	dibujar_cuadro 5,20,310,176,blanco
	dibujar_cuadro 6,21,308,174,blanco
	print 1,1,encab1
	dibujar_bloque 10,26,56,9,rojo
	dibujar_bloque 71,26,56,9,rojo
	dibujar_bloque 132,26,56,9,rojo
	dibujar_bloque 193,26,56,9,rojo
	dibujar_bloque 254,26,56,9,rojo
	dibujar_bloque 10,39,56,9,celeste
	dibujar_bloque 71,39,56,9,celeste
	dibujar_bloque 132,39,56,9,celeste
	dibujar_bloque 193,39,56,9,celeste
	dibujar_bloque 254,39,56,9,celeste
	dibujar_bloque barraX[0],barraY[0],barraTamX[0],barraTamY[0],amarillo
	
control:
	escanear_pulsacion
	cmp al,'a'
	je movIzq
	cmp al,'d'
	je movDer 
	jmp _exit

movIzq:
	xor ax,ax
	mov ax,barraX[0]
	cmp ax,10
	jb control
	dibujar_bloque barraX[0],barraY[0],barraTamX[0],barraTamY[0],negro
	xor ax,ax
	mov ax,5
	sub barraX[0],ax
	dibujar_bloque barraX[0],barraY[0],barraTamX[0],barraTamY[0],amarillo
	jmp control
movDer:
	xor ax,ax
	mov ax,barraX[0]
	cmp ax,225
	ja control
	dibujar_bloque barraX[0],barraY[0],barraTamX[0],barraTamY[0],negro
	xor ax,ax
	mov ax,5
	add barraX[0],ax
	dibujar_bloque barraX[0],barraY[0],barraTamX[0],barraTamY[0],amarillo
	jmp control
	
_prech:
	;leer si se presiona una tecla para salir del modo video
	mov ah,10h
	int 16h
_exit:	
	; voy a regresar a mi modo texto
	mov ax,3h
	int 10h
	
	;salimos del programa
	ret