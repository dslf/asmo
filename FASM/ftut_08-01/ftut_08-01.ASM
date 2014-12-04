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
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,menu_name,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  push ebx
	  push ebx
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi
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
	 leave
	 jmp dword [DefWindowProc]

wmCOMMAND: mov ebx,[wParam]
	 cmp ebx,ZZZ_EXIT
	 je wmDESTROY;menu_exit
show_msg: push eax;MB_OK
	 push menu_name
	 push [menu_handlers+ebx*4];eax
	 push [hWnd]
	 call [MessageBox]
	 leave
	 retn 0x10
wmDESTROY:  invoke ExitProcess,ebx
endp
     ;exp = experiment
wTitle	  db   'Iczelion Tutorial #8-1:Создание меню через файл ресурсов в FASM',0 ;name of our window
menu_name	db	'ZZZ_Menu',0
test_msg	db	'You select menu item TEST',0
open_msg	db	'You select menu item OPEN',0
save_msg	db	'You select menu item SAVE',0
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
		MessageBox,	    'MessageBoxA'

end data
section '.rsrc' resource from 'ftut_08-01.res' data readable




