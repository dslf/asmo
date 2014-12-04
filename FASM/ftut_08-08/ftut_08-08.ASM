format PE GUI
include 'win32ax.inc'
; import data in the same section
ZZZ_TEST      equ 0
ZZZ_OPEN      equ 1
ZZZ_SAVE      equ 2
ZZZ_EXIT      equ 3
IDM_MENU      equ 37
IDM_FILE      equ 100	       ;menu 1
IDM_EXIT      equ 200	       ;menu 2
IDR_MAINACCEL equ 105

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi
	  invoke    LoadMenu,esi,IDM_MENU
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push esi
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi,ebx,eax
	  mov [hwnd],eax
	  pop esi
	  invoke LoadAccelerators,esi,IDR_MAINACCEL
	  mov [ACC],eax
	  mov ebp,esp
	  ; +---------------------------+
	  ; | entering the message loop |
	  ; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke DispatchMessage,ebp
	  invoke TranslateAccelerator,[hwnd],[ACC],ebp
	  test eax,eax
	  jne message_loop
	  invoke TranslateMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
window_procedure:
hWnd	equ esp+4
uMsg	equ esp+8
wParam	equ esp+0xC
lParam	equ esp+10h
	 mov eax,[uMsg]
	 dec eax
	 dec eax; cmp uMsg,WM_DESTROY
	 je wmDESTROY
	 sub eax,WM_COMMAND-WM_DESTROY; cmp uMsg,WM_COMMAND
	 je wmCOMMAND
	 jmp dword [DefWindowProc]
wmCOMMAND: mov ax,[wParam]
	 cmp eax,ZZZ_EXIT
	 je wmDESTROY;menu_exit
show_msg: invoke MessageBox,dword[hWnd+12],[menu_handlers+eax*4],menu_name,ebx;MB_OK
	 retn 0x10
wmDESTROY:  invoke ExitProcess,eax
     ;exp = experiment
wTitle	  db   'Iczelion Tutorial #8-8: Работа с таблицей акселераторов в FASM',0 ;name of our window
menu_name	db	'ZZZ_Menu',0
test_msg	db	'You select menu item TEST',0
open_msg	db	'You select menu item OPEN',0
save_msg	db	'You select menu item SAVE',0
menu_handlers dd test_msg, open_msg, save_msg
ACC	rd 1
hwnd	rd 1

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
		TranslateAccelerator,'TranslateAcceleratorA',\
		LoadAccelerators,   'LoadAcceleratorsA',\
		LoadMenu,	    'LoadMenuA',\
		TranslateMessage,   'TranslateMessage'
end data
section '.rsrc' resource data readable

  directory RT_MENU,menus,\
	    RT_ACCELERATOR,accelerators

  resource menus,\
	   IDM_MENU,LANG_ENGLISH+SUBLANG_DEFAULT,main_menu

  resource accelerators,\
	   IDR_MAINACCEL,LANG_ENGLISH+SUBLANG_DEFAULT,main_keys

 _ equ ,09h,		       ;tab

  menu main_menu
       menuitem '&File',IDM_FILE,MFR_POPUP
		menuitem '&Test' _ 'Ctrl+T',ZZZ_TEST
		menuitem '&Open' _ 'Ctrl+O',ZZZ_OPEN
		menuitem '&Save' _ 'Ctrl+S',ZZZ_SAVE
		menuseparator
		menuitem '&Exit' _ 'Ctrl+X',ZZZ_EXIT,MFR_END

       menuitem '&Exit',IDM_EXIT,MFR_POPUP + MFR_END
		menuitem '&Exit',ZZZ_EXIT,MFR_END

  accelerator main_keys,\
	      FVIRTKEY+FNOINVERT+FCONTROL,'T',ZZZ_TEST,\
	      FVIRTKEY+FNOINVERT+FCONTROL,'O',ZZZ_OPEN,\
	      FVIRTKEY+FNOINVERT+FCONTROL,'S',ZZZ_SAVE,\
	      FVIRTKEY+FNOINVERT+FCONTROL,'X',ZZZ_EXIT



