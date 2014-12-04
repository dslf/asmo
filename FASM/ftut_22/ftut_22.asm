format PE GUI

include 'win32a.inc'

start:	xchg ebx,eax
	mov edi,wTitle
	mov esi,400000h
	invoke RegisterClass,esp,ebx,window_procedure,ebx,\
		ebx,esi,ebx,10011h,COLOR_BTNFACE+1,ebx,edi,esi
	push ebx
	push esi
	shl esi,9
	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW + WS_VISIBLE,\
		esi,esi,400,240,ebx,ebx
		mov  [wndH],eax
		pop esi
		mov  edi,editCls
		invoke	GetClassInfoEx,ebx,ctlClsNameEdit,edi
			push [editCls.lpfnWndProc]
			pop  [wndProcAddr]
			mov  [editCls.lpfnWndProc],edit_hex_procedure
			mov  [editCls.lpszClassName],ctlClsNameEditHex
		invoke	RegisterClassEx,edi
			mov ebp,3;xor  ebp,ebp
			mov  edi,20
@@:		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,ctlClsNameEditHex,ebx,\
			WS_CHILD + WS_VISIBLE + WS_BORDER,20,edi,300,24,\
			[wndH],ebx,esi,ebx
			mov  [editH + 4 * ebp],eax
		invoke	SendMessage,eax,EM_LIMITTEXT,15,ebx		  ;limit to 15 chars
			add  edi,30
			dec ebp
			jns @b;jmp  @b
		invoke	SetFocus,[editH]
		mov ebp,esp
   ;+---------------------------+
   ;| entering the message loop |
   ;+---------------------------+
   window_message_loop_start:
	invoke	GetMessage,ebp,ebx,ebx,ebx
	invoke	TranslateMessage,ebp
	invoke	DispatchMessage,ebp
		jmp	window_message_loop_start
   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
window_procedure: cmp  dword[esp+8],WM_DESTROY
		je   wmDESTROY
		jmp  [DefWindowProc]
wmDESTROY:	invoke	ExitProcess,ebx
   
proc edit_hex_procedure hWnd,umsg,wParam,lParam
		mov edi,[hWnd]
		mov  eax,[wParam]
		mov edx,[umsg]
		cmp  edx,WM_KEYDOWN
		je   edit_hex_wmKEYDOWN
		cmp  edx,WM_CHAR
		jne  @f

edit_hex_wmCHAR:	cmp  al,VK_BACK 	;compare with virtual key BACKSPACE
			je   @f
			cmp  al,0x30		;compare with ascii 0
			jb   edit_hex_wmBYE
			cmp  al,0x39		;compare with ascii 9
			jbe  @f
			and eax,-33 ;so our AL become big letter
			cmp  al,0x41		;compare with ascii A
			jb   edit_hex_wmBYE
			cmp  al,0x46		;compare with ascii F
			ja  edit_hex_wmBYE     ;something else
		
		@@:	invoke	CallWindowProc,[wndProcAddr],edi,edx,eax,[lParam]
			jmp  edit_hex_wmBYE

edit_hex_wmKEYDOWN:	cmp  al,VK_RETURN	;compare with virtual key RETURN
			je   wmKEYDOWN_VK_RETURN
			cmp  al,VK_TAB
			jne  @b

wmKEYDOWN_VK_TAB:	invoke	GetKeyState,VK_SHIFT
				test eax,eax;test eax,0x80000000
				js VK_TAB_PREV;jne   VK_TAB_PREV
VK_TAB_NEXT:		invoke	GetWindow,edi,GW_HWNDNEXT;=2
				test  eax,eax
				jne  VK_TAB_BYE
				invoke	GetWindow,edi,ebx;GW_HWNDFIRST=0
				jmp  VK_TAB_BYE
VK_TAB_PREV:		invoke	GetWindow,edi,GW_HWNDPREV;=3
				test  eax,eax
				jne  VK_TAB_BYE
			invoke	GetWindow,edi,GW_HWNDLAST;=1
VK_TAB_BYE:		invoke	SetFocus,eax
			xor  eax,eax
			jmp  edit_hex_wmBYE

wmKEYDOWN_VK_RETURN:	invoke	SendMessage,edi,EM_GETLINE,ebx,editHBuffer
			invoke	MessageBox,edi,editHBuffer,wTitle,MB_OK
			invoke	SetFocus,edi
edit_hex_wmBYE: 	leave
			retn 10h
   endp
	wndH		dd ?
	wTitle		db 'Iczelion Tutorial #22:Superclassing in FASM',0
	wndProcAddr	dd ?
	editCls WNDCLASSEX	sizeof.WNDCLASSEX,0,edit_hex_procedure,0,0,400000h,0,0,0,0,0,0
	ctlClsNameEdit		db 'EDIT',0
	ctlClsNameEditHex	db 'EDIT_HEX',0
	
	editH:		times 6 dd ?
	editHBuffer	dw 16	;2 bytes here
			rb 14	;14 + 2 = 16 bytes required, 15 for text, 1 for null terminated byte
data import
    library	KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL'
    
    import	KERNEL32,\
		ExitProcess,		'ExitProcess'
    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		RegisterClassEx,	'RegisterClassExA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		MessageBox,		'MessageBoxA',\
		GetClassInfoEx, 	'GetClassInfoExA',\
		GetKeyState,		'GetKeyState',\
		GetWindow,		'GetWindow',\
		SetFocus,		'SetFocus',\
		CallWindowProc, 	'CallWindowProcA',\
		DestroyWindow,		'DestroyWindow',\
		TranslateMessage,	'TranslateMessage',\
		DispatchMessage,	'DispatchMessageA'
end data
