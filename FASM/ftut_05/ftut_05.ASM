format PE GUI
include 'win32ax.inc'
; import data in the same section

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,\
	  ebx,ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi
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
		 enter sizeof.PAINTSTRUCT,0
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
		 invoke    GetCurrentObject,eax,ebx;OBJ_FONT
		 invoke    CreateFont,26,12,ebx,ebx,400,ebx,ebx,ebx,\
				   -1,\;OEM_CHARSET,\
				   ebx,\;OUT_DEFAULT_PRECIS,\
				   ebx,\;CLIP_DEFAULT_PRECIS,\
				   ebx,\;DEFAULT_QUALITY,\
				   DEFAULT_PITCH or FF_SCRIPT,\
				   "script",eax ;default font object
		    invoke    SelectObject,dword[esp+8],eax
		    invoke    SetTextColor,dword[esp+8],0x32C8C8;RGB=50,200,200
		    invoke    SetBkColor,dword[esp+8],0xFF0000;RGB=0,0,255
		    invoke    TextOut,dword[esp+20],ebx,ebx,expTxt,Num-expTxt
		    invoke    SelectObject,dword[esp];esi
		    invoke    EndPaint,edi,esp
		    leave
		    retn 0x10

wmDESTROY:	 invoke ExitProcess,ebx

     ;exp = experiment
      wTitle	db   'Iczelion Tutorial #5:More about Text',0 ;name of our window
      expTxt	db   'Win32 assembly with FASM is great and easy'
      Num	db   0
data import

 library KERNEL32, 'KERNEL32.DLL',\
	 GDI32,    'GDI32.DLL',\
	 user32,   'USER32.DLL'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		BeginPaint,	    'BeginPaint',\
		EndPaint,	    'EndPaint',\
		DispatchMessage,    'DispatchMessageA'
  import    GDI32,\
	       CreateFont,	   'CreateFontA',\
	       SetTextColor,	   'SetTextColor',\
	       SetBkColor,	   'SetBkColor',\
	       TextOut, 	   'TextOutA',\
	       GetCurrentObject,   'GetCurrentObject',\
	       SelectObject,	   'SelectObject'

end data