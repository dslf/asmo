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
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,512,352,ebx,ebx
	  mov ebp,esp
	  ; +---------------------------+
	  ; | entering the message loop |
	  ; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke TranslateMessage,ebp
	  invoke DispatchMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
window_procedure:
	hWnd	 equ ebp+8
	uMsg	 equ ebp+0xC
	wParam	 equ ebp+0x10
		  enter sizeof.PAINTSTRUCT,0
		  mov eax,[uMsg]
		  mov edi,[hWnd]
		  mov esi,expChar
		  dec eax; cmp uMsg,WM_DESTROY
		  dec eax
		  je wmDESTROY
		  sub eax,WM_PAINT-WM_DESTROY; cmp uMsg,WM_PAINT
		  je   wmPAINT
		  sub eax,WM_CHAR-WM_PAINT
		  je   wmCHAR
		  leave
		  jmp dword [DefWindowProc]

wmCHAR: 	  push dword [wParam]
		  pop dword  [esi]
		  invoke InvalidateRect,edi,eax,TRUE
		  jmp  wmBYE

wmPAINT:	  invoke BeginPaint,edi,esp
		  invoke TextOut,eax,142,90,Message,expChar-Message-1
		  invoke TextOut,dword[esp+16],242,150,esi,1
		  invoke EndPaint,edi,esp
wmBYE:		  leave
		  retn 0x10

wmDESTROY:	 invoke ExitProcess,eax
     ;exp = experiment
      wTitle	db   'Iczelion Tutorial #6:Keyboard Input in FASM',0 ;name of our window
      Message	db 'Нажмите любую клавишу',0
      expChar	dd '?'
data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 GDI32,    'GDI32.DLL'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		BeginPaint,	    'BeginPaint',\
		EndPaint,	    'EndPaint',\
		DispatchMessage,    'DispatchMessageA',\
		TranslateMessage,   'TranslateMessage',\
		InvalidateRect,     'InvalidateRect'
  import    GDI32,\
	       TextOut, 	   'TextOutA'

end data