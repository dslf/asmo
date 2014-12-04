format PE GUI
include 'win32ax.inc'
start:	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke LoadImage,esi,edi,ebx,ebx,ebx,LR_LOADFROMFILE,ebx,edi
	  invoke CreatePatternBrush,eax
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,eax
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,\
	  WS_OVERLAPPEDWINDOW+WS_VISIBLE-WS_MAXIMIZEBOX-WS_THICKFRAME,\
	  esi,esi,286,305,ebx,ebx
	  mov ebp,esp
   ;+---------------------------+
   ;| entering the message loop |
   ;+---------------------------+
   window_message_loop_start:
	  invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke DispatchMessage,ebp
	  jmp window_message_loop_start
   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
window_procedure:  cmp dword[esp+8],WM_DESTROY
	  je wmDESTROY
	  jmp dword [DefWindowProc]
wmDESTROY: invoke ExitProcess,ebx

	wTitle	      db 'Images\tweety78.bmp',0

data import
library     KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL',\
		GDI32,	  'GDI32.DLL'
    
    import	KERNEL32,\
		ExitProcess,		'ExitProcess'

    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		GetMessage,		'GetMessageA',\
		DispatchMessage,	'DispatchMessageA',\
		LoadImage,		'LoadImageA'

    import	GDI32,\
		CreatePatternBrush,	'CreatePatternBrush'
end data