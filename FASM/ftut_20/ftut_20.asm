format PE GUI
include 'win32ax.inc'
start:	xchg ebx,eax
	mov edi,wTitle
	mov esi,400000h
		; +------------------------------+
		; | registering the window class |
		; +------------------------------+
		invoke RegisterClass,esp,ebx,window_procedure,ebx,\
		ebx,esi,ebx,10011h,COLOR_BTNFACE+1,ebx,edi,esi
		; +--------------------------+
		; | creating the main window |
		; +--------------------------+
		push ebx
		push esi
		shl esi,9
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
		esi,esi,400,240,ebx,ebx
		pop esi
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,"EDIT",NULL,\
			WS_CHILD + WS_VISIBLE + WS_BORDER,20,20,300,24,\
			eax,ebx,esi,ebx
			mov  edi,eax
		invoke	SetFocus,eax
		invoke	SetWindowLong,edi,GWL_WNDPROC,edit1_procedure
			mov  [wndProcAddr],eax
		mov ebp,esp
   ;+---------------------------+
   ;| entering the message loop |
   ;+---------------------------+
window_message_loop_start:
	invoke	GetMessage,ebp,ebx,ebx,ebx
	invoke	TranslateMessage,ebp
	invoke	DispatchMessage,ebp
	jmp window_message_loop_start
   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
window_procedure: cmp  dword[esp+8],WM_DESTROY
		je   wmDESTROY
		jmp [DefWindowProc]
wmDESTROY:	invoke	ExitProcess,ebx
   
edit1_procedure:
hWnd		equ esp+4
uMsg		equ esp+8
wParam		equ esp+0Ch
lParam		equ esp+10h
		mov edi,[hWnd]
		mov edx,[wParam]
		mov eax,[uMsg]
		sub eax,WM_KEYDOWN;WM_KEYDOWN = 100h
		je   edit1_wmKEYDOWN
		dec eax;WM_CHAR =  102h
		dec eax
		jne  @f
	
edit1_wmCHAR:		cmp  dl,VK_BACK 	;compare with virtual key BACKSPACE
			je   @f
			cmp  dl,0x30		;compare with ascii 0
			jb   edit1_wmBYE
			cmp  dl,0x39		;compare with ascii 9
			jbe  @f
			and  dl,0xDF		;so our DL become big letter
			cmp  dl,0x41		;compare with ascii A
			jb   edit1_wmBYE
			cmp  dl,0x46		;compare with ascii F
			ja  edit1_wmBYE 	;something else
		@@:	invoke	CallWindowProc,[wndProcAddr],edi,dword[uMsg+8],edx,dword[lParam]
			jmp  edit1_wmBYE
	
	edit1_wmKEYDOWN:cmp  dl,VK_RETURN	;compare with virtual key RETURN
			jne  @b
		invoke	MessageBox,edi,"A simple HEX edit control!",wTitle,ebx;MB_OK
		invoke	SetFocus,edi
	
	edit1_wmBYE:	retn 10h
;--------------------------------------------------------------------------------
	wTitle	      db 'Iczelion Tutorial #20:Window Subclassing in FASM',0
	wndProcAddr	dd ?
	ctlClsNameEdit	db '',0
data import
    library	KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL'
    
    import	KERNEL32,\
		ExitProcess,		'ExitProcess'
    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		MessageBox,		'MessageBoxA',\
		SetFocus,		'SetFocus',\
		SetWindowLong,		'SetWindowLongA',\
		CallWindowProc, 	'CallWindowProcA',\
		DestroyWindow,		'DestroyWindow',\
		TranslateMessage,	'TranslateMessage',\
		DispatchMessage,	'DispatchMessageA'
end data

