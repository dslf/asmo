; fasm dos com #
org 100h
start:	mov ah,9
	mov dx,Hello
	int 21h
	mov ah,0
	int 16h
	retn
Hello	db 'Hello, world from FASM-DOS-COM!$'