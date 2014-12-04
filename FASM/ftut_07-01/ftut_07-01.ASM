format PE GUI
include 'win32ax.inc'
; import data in the same section
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  invoke LoadCursorFromFile,"Images\cursor.cur",COLOR_WINDOW+1,ebx,edi
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,\
	  ebx,ebx,esi,eax,eax
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
window_procedure: cmp dword[esp+0x08],WM_DESTROY
	       je wmDESTROY
	       jmp dword [DefWindowProc]
wmDESTROY: invoke ExitProcess,ebx
;---------------------------------------------------------------------------------
wTitle db   'Iczelion Tutorial #7-1:Создание курсора и иконки из файла в FASM',0 ;name of our window
;--------------------------------------------------------------------------------
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
		LoadCursorFromFile, 'LoadCursorFromFileA'
end data