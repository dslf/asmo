format PE GUI
include 'win32ax.inc'
; import data in the same section

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,CS_HREDRAW or CS_VREDRAW,window_procedure,ebx,\
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
window_procedure:
	hWnd	 equ ebp+8
	uMsg	 equ ebp+0xC
	expRect  equ ebp - sizeof.RECT
		 enter sizeof.PAINTSTRUCT + sizeof.RECT ,0
		 mov eax,[uMsg]
		 mov edi,[hWnd]
		 dec eax; cmp uMsg,WM_DESTROY
		 dec eax
		 je wmDESTROY
		 sub eax,WM_PAINT-WM_DESTROY; cmp uMsg,WM_PAINT
		 je   wmPAINT
		 leave
		 jmp dword [DefWindowProc]
wmPAINT:	 invoke BeginPaint,edi,esp
		 lea esi,[expRect]
		 invoke GetClientRect,edi,esi,eax
		 invoke DrawText,dword[esp+16],expTxt,-1,esi,DT_SINGLELINE or DT_CENTER or DT_VCENTER
		 invoke EndPaint,edi,esp
		 leave
		 retn 0x10
wmDESTROY:	 invoke ExitProcess,eax

      wTitle	db   'Iczelion Tutorial #4:Painting with Text',0 ;name of our window
      expTxt	db   'Win32 assembly with FASM is great and easy',0
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
		BeginPaint,	    'BeginPaint',\
		GetClientRect,	    'GetClientRect',\
		DrawText,	    'DrawTextA',\
		EndPaint,	    'EndPaint',\
		DispatchMessage,    'DispatchMessageA'
end data