format PE GUI 4.0
include 'win32ax.inc'

; import data in the same section
	  xchg ebx,eax; ebx:=0
	  mov edi,wTitle
	  invoke InitCommonControlsEx
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_BTNFACE+1,ebx,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  invoke CreateWindowEx,ebx,edi,edi,\
	  WS_OVERLAPPEDWINDOW+WS_VISIBLE-WS_MAXIMIZEBOX,300,300,350,244,ebx,ebx,esi,ebx
	  ; параметры для SendDlgItemMessage
	  call @f; push AviFile
AviFile     db 'skeleton.avi',0
@@:	  push esi
	  push ACM_OPEN
	  push ebx
	  push eax;hwnd for SendDlgItemMessage
	  ; параметры для CreateWindowEx
	  push ebx
	  mov ebp,esp; в ebp указатель на пустую строку
	  invoke CreateWindowEx,WS_EX_STATICEDGE+WS_EX_CLIENTEDGE,"SysAnimate32",ebp,\
	  WS_CHILD+WS_VISIBLE+WS_TABSTOP+ACS_AUTOPLAY,86,38,ebx,ebx,eax,ebx,esi
	  invoke SendDlgItemMessage
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
	  jz wmCLOSE
	  jmp dword [DefWindowProc]
wmCLOSE: invoke ExitProcess,ebx
;===========================================================================================
      wTitle db   'Iczelion Tutorial #37:Animate in FASM',0 ;name of our window
data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 comctl32, 'COMCTL32.DLL'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		SendDlgItemMessage, 'SendDlgItemMessageA',\
		DispatchMessage,    'DispatchMessageA'
 import comctl32,\
		InitCommonControlsEx, 'InitCommonControlsEx'
end data