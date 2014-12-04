format PE GUI
include 'win32ax.inc'
; import data in the same section
ZZZ_TEST equ 0
ZZZ_OPEN equ 1
ZZZ_SAVE equ 2
ZZZ_EXIT equ 3

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi,ebx,ebx
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
	  dec eax; cmp uMsg,WM_CREATE
	  je wmCREATE
	  dec eax; cmp uMsg,WM_DESTROY
	  je wmDESTROY
	  sub eax,WM_COMMAND-WM_DESTROY; cmp uMsg,WM_PAINT
	  je wmCOMMAND
	  leave
	  jmp dword [DefWindowProc]
wmCREATE: invoke CreatePopupMenu
	  mov edi,eax;    mov hPopupMenu,eax
	  lea esi,[AppendMenu]
	  push menu_test1
	  push ZZZ_TEST
	  push MF_STRING
	  push eax;hPopupMenu
	  call dword [esi];_imp__AppendMenuA@16
	  push menu_open1
	  push ZZZ_OPEN
	  push MF_STRING
	  push edi;hPopupMenu
	  call dword [esi];_imp__AppendMenuA@16
	  push menu_save1
	  push ZZZ_SAVE
	  push MF_STRING
	  push edi;hPopupMenu
	  call dword [esi];_imp__AppendMenuA@16
	  push ebx;0
	  push ebx;0
	  push MF_SEPARATOR
	  push edi;hPopupMenu
	  call dword [esi];_imp__AppendMenuA@16
	  push menu_exit1
	  push ZZZ_EXIT
	  push MF_STRING
	  push edi;hPopupMenu
	  call dword [esi];_imp__AppendMenuA@16
	  invoke CreateMenu,MF_POPUP,edi,menu_file
	  mov edi,eax;mov edi,hMenu
	  push edi;hMenu
	  call dword [esi];_imp__AppendMenuA@16
	  push menu_exit1
	  push ZZZ_EXIT
	  push MF_STRING
	  push edi;hMenu
	  call dword [esi];_imp__AppendMenuA@16
	  invoke SetMenu,[hWnd],edi
	  jmp wmBYE
wmCOMMAND: mov ebx,[wParam]
	  cmp ebx,ZZZ_EXIT;03
	  je wmDESTROY;menu_exit
show_msg: invoke MessageBox,[hWnd],[menu_handlers+ebx*4],menu_name,eax
wmBYE:	  leave
	  retn 0x10

wmDESTROY: invoke ExitProcess,ebx
endp
     ;exp = experiment
wTitle	  db   'Iczelion Tutorial #8-4:Программное создание меню в FASM',0 ;name of our window
menu_file	db 'File',0
menu_test1	db 'Test',0
menu_open1	db 'Open',0
menu_save1	db 'Save',0
menu_exit1	db 'Exit',0
menu_name	db 'ZZZ_Menu',0
test_msg	db 'You select menu item TEST',0
open_msg	db 'You select menu item OPEN',0
save_msg	db 'You select menu item SAVE',0
menu_handlers dd test_msg, open_msg, save_msg

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
		AppendMenu,	    'AppendMenuA',\
		CreatePopupMenu,    'CreatePopupMenu',\
		CreateMenu,	    'CreateMenu',\
		SetMenu,	    'SetMenu'
end data