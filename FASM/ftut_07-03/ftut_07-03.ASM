format PE GUI
include 'win32ax.inc'
ICON_SIZE = 744  ;taille de Icon.ico (header=22 Image=744) total=766
; import data in the same section

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  invoke LoadCursorFromFile,CursorFile,COLOR_WINDOW+1,ebx,edi
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
	  invoke CreateIconFromResource,ptIcon,ICON_SIZE,-1,030000h
	  mov [hIcon],eax
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
hWnd	equ ebp+8
uMsg	equ ebp+0xC
	    enter sizeof.PAINTSTRUCT,0
	    mov eax,[uMsg]
	    mov edi,[hWnd]
	    dec eax
	    dec eax;cmp d[esp+0x08],WM_DESTROY
	    jz wmDESTROY
	    sub eax,WM_PAINT-WM_DESTROY
	    jz wmPAINT
	    leave
	    jmp dword [DefWindowProc]

wmPAINT:    invoke BeginPaint,edi,esp
	    invoke DrawIcon,eax,134,68,[hIcon]
	    invoke EndPaint,edi,esp
exit:	    leave
	    retn 10h

wmDESTROY: invoke ExitProcess,eax
wTitle	   db	'Iczelion Tutorial #7-3:Icone datas binaire in  FASM',0 ;name of our window
hIcon	   rd 1
ptIcon	   FILE 'Images\Cursor.cur':22	 ;sauter le header du fichier d'icone
CursorFile db 'Images\cursor.cur',0
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
		LoadCursorFromFile, 'LoadCursorFromFileA',\
		BeginPaint,	    'BeginPaint',\
		EndPaint,	    'EndPaint',\
		DrawIcon,	    'DrawIcon',\
		CreateIconFromResource, 'CreateIconFromResource'
end data