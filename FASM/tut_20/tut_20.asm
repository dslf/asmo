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
		push ebx
		push ebx
		shl esi,9
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
		esi,esi,400,240
		pop esi
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,ctlClsNameEdit,NULL,\
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
   
proc edit1_procedure,hWnd,uMsg,wParam,lParam
		cmp  [uMsg],WM_CHAR
		je   edit1_wmCHAR
		cmp  [uMsg],WM_KEYDOWN
		je   edit1_wmKEYDOWN
		jmp  @f
	
edit1_wmCHAR:		mov  eax,[wParam]
			cmp  al,VK_BACK 	;compare with virtual key BACKSPACE
			je   @f
			cmp  al,0x30		;compare with ascii 0
			jb   edit1_wmBYE
			cmp  al,0x39		;compare with ascii 9
			jbe  @f
			cmp  al,0x41		;compare with ascii A
			jb   edit1_wmBYE
			cmp  al,0x46		;compare with ascii F
			jbe  @f
			cmp  al,0x61		;compare with ascii a
			jb   edit1_wmBYE
			cmp  al,0x66		;compare with ascii f
			ja  edit1_wmBYE        ;something else

wmCHAR_add:		sub  [wParam],0x20	;so our AL become big letter
		@@:	invoke	CallWindowProc,[wndProcAddr],[hWnd],[uMsg],[wParam],[lParam]
			jmp  edit1_wmBYE
	
	edit1_wmKEYDOWN:mov  eax,[wParam]
			cmp  al,VK_RETURN	;compare with virtual key RETURN
			jne  @b
		invoke	MessageBox,[hWnd],edit1Txt1,wTitle,ebx;MB_OK
		invoke	SetFocus,[hWnd]
	
	edit1_wmBYE:	leave
			retn 10h
endp
	wTitle	      db 'Iczelion Tutorial 20: Window Subclassing',0
	wndProcAddr	dd ?
	ctlClsNameEdit	db 'EDIT',0
	edit1Txt1	db 'A simple HEX edit control!',0
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

