format PE GUI
include 'win32ax.inc'
; import data in the same section
ZZZ_TEST equ 0
ZZZ_OPEN equ 1
ZZZ_SAVE equ 2
ZZZ_EXIT equ 3
MFR_END    equ 80h
MFR_POPUP  equ 01h

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi
	  invoke    LoadMenuIndirect,appMenuTemplate
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi,ebx,eax
	  mov ebp,esp
	  ; +---------------------------+
	  ; | entering the message loop |
	  ; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke DispatchMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
proc window_procedure,hWnd,uMsg,wParam,lParam
		  mov eax,[uMsg]
		  dec eax; cmp uMsg,WM_DESTROY
		  dec eax
		  je wmDESTROY
		  sub eax,WM_COMMAND-WM_DESTROY; cmp uMsg,WM_PAINT
		  je wmCOMMAND
wmDEFAULT:	  leave
		  jmp dword [DefWindowProc]

wmCOMMAND:	  mov ebx,[wParam]
		  cmp ebx,ZZZ_EXIT;03
		  je wmDESTROY;menu_exit
show_msg:	  invoke MessageBox,[hWnd],[menu_handlers+ebx*4],menu_name,eax
wmBYE:		  leave
		  retn 0x10

wmDESTROY:	 invoke ExitProcess,ebx
endp
     ;exp = experiment
wTitle	  db   'Iczelion Tutorial #8-3: Создание меню через через Template-структуру в FASM',0 ;name of our window
menu_name	db	'ZZZ_Menu',0
test_msg	db	'You select menu item TEST',0
open_msg	db	'You select menu item OPEN',0
save_msg	db	'You select menu item SAVE',0
menu_handlers dd test_msg, open_msg, save_msg
appMenuTemplate dw 1	; menu template version
		dw 4	; offset from end of this word to menu item list
		dd 0	; menu bar help ID
		dd MFT_STRING,MFS_ENABLED,0
		dw MFR_POPUP			; first column
		dw '&','F','i','l','e',0,0	; pad to align 4
		dd 0			       ; popup help ID
		dd MFT_STRING,MFS_ENABLED,ZZZ_TEST
		dw 0,'&','T','e','s','t',0,0
		dd MFT_STRING,MFS_ENABLED,ZZZ_OPEN
		dw 0,'&','O','p','e','n',0,0
		dd MFT_STRING,MFS_ENABLED,ZZZ_SAVE
		dw 0,'&','S','a','v','e',0,0
		dd MFT_SEPARATOR,0,0
		dw 0,0	  ; pad to align 4
		dd MFT_STRING,MFS_ENABLED,ZZZ_EXIT
		dw MFR_END			; bottom of column
		dw '&','E','x','i','t',0,0	; pad to align 4
		dd MFT_STRING,MFS_ENABLED,ZZZ_EXIT
		dw MFR_END	   ; second column, last one
		dw '&','E','x','i','t',0,0	; pad to align 4
		dd 0				; popup help ID

data import
 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		DispatchMessage,    'DispatchMessageA',\
		DestroyWindow,	    'DestroyWindow',\
		MessageBox,	    'MessageBoxA',\
		LoadMenuIndirect,   'LoadMenuIndirectA'
end data