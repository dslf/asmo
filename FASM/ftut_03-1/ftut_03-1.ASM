format PE GUI
include 'win32ax.inc'
; import data in the same section

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi
	  push ebx
	  push esi
	  push ebx
	  push ebx
	  push 352;WinH
	  push 512;WinW
	  invoke GetSystemMetrics,SM_CYSCREEN
	  sub eax,352
	  shr eax,1
	  push eax
	  invoke GetSystemMetrics,SM_CXSCREEN
	  sub eax,512
	  shr eax,1
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,eax
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
      wTitle db   'Iczelion Tutorial #3:A Simple Window in centre in FASM',0 ;name of our window
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
		GetSystemMetrics,   'GetSystemMetrics'
end data