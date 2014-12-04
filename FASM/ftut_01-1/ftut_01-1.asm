; fasm dos exe #
format MZ

start:	  mov ax,cs
	  mov ds,ax

	  mov dx,Hello
	  mov ah,9
	  int 0x21
	  mov ah,0
	  int 0x16
	  mov ax,0x4c00
	  int 0x21

Hello:	db 'Hello, world from FASM-DOS-EXE!$'
