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
	  mov ebp,msg
	  ; +---------------------------+
	  ; | entering the message loop |
	  ; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke DispatchMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
window_procedure:
hWnd	equ ebp+8
uMsg	equ ebp+0xC
wParam	equ ebp+10h
lParam	equ ebp+14h
hMenu	equ ebp-4
;rect    equ hMenu-sizeof.RECT
	 enter sizeof.RECT+4,0
	 mov eax,[uMsg]
	 dec eax; cmp uMsg,WM_DESTROY
	 dec eax
	 je wmDESTROY
	 sub eax,WM_COMMAND-WM_DESTROY; cmp uMsg,WM_PAINT
	 je wmCOMMAND
	 sub eax,WM_RBUTTONDOWN-WM_COMMAND;cmp uMsg,WM_RBUTTONDOWN
	 je wmRBUTTONDOWN
	 leave
	 jmp dword [DefWindowProc]

wmRBUTTONDOWN: invoke CreatePopupMenu
	mov edi,eax;hPopupMenu,eax
	invoke CreateMenu
	mov [hMenu],eax
	lea esi,[AppendMenu]
	push menu_test1
	push ZZZ_TEST
	push MF_STRING
	push edi;hPopupMenu
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
	push menu_file
	push edi;hPopupMenu
	push MF_POPUP
	push dword [hMenu]
	call dword [esi];_imp__AppendMenuA@16
	push menu_exit1
	push ZZZ_EXIT
	push MF_STRING
	push dword [hMenu]
	call dword [esi];_imp__AppendMenuA@16
	invoke TrackPopupMenu,edi,TPM_LEFTALIGN+TPM_LEFTBUTTON,[msg.pt.x],[msg.pt.y],\
	ebx,dword [hWnd],ebx
	invoke GetWindowRect,dword [hWnd],esp;push offset rect
	jmp end_wm_check

wmCOMMAND: mov ebx,[wParam]
	 cmp ebx,ZZZ_EXIT
	 je wmDESTROY;menu_exit
show_msg: invoke MessageBox,dword [hWnd],[menu_handlers+ebx*4],menu_name,eax
end_wm_check: leave
	 retn 0x10
wmDESTROY:  invoke ExitProcess,ebx
     ;exp = experiment
wTitle	  db   'Iczelion Tutorial 8-6: Создание плавающего меню',0 ;name of our window
menu_file	db 'File',0
menu_test1	db 'Test',0
menu_open1	db 'Open',0
menu_save1	db 'Save',0
menu_exit1	db 'Exit',0

menu_name	db	'ZZZ_Menu',0
test_msg	db	'You select menu item TEST',0
open_msg	db	'You select menu item OPEN',0
save_msg	db	'You select menu item SAVE',0
menu_handlers dd test_msg, open_msg, save_msg
msg		MSG	<>

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
		CreateMenu,	    'CreateMenu',\
		AppendMenu,	    'AppendMenuA',\
		TrackPopupMenu,     'TrackPopupMenu',\
		GetWindowRect,	    'GetWindowRect',\
		CreatePopupMenu,    'CreatePopupMenu',\
		MessageBox,	    'MessageBoxA'

end data
section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       30,LANG_ENGLISH,Menu

     menu Menu
	  menuitem  '&File',10,MFR_POPUP
	  menuitem  '&Test',ZZZ_TEST,MFT_STRING
	  menuitem  '&Open',ZZZ_OPEN,MFT_STRING
	  menuitem  '&Save',ZZZ_SAVE,MFT_STRING
			 menuseparator
	  menuitem  '&Exit',ZZZ_EXIT,MFR_END
	  menuitem  '&Exit',ZZZ_EXIT,MFR_END