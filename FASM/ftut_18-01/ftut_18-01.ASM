format PE GUI
include 'win32ax.inc'
 pb1		 equ 1
 sb1		 equ 2
 tm1		 equ 3
 btn1		 equ 4
 PBS_SMOOTH	 equ 1
 PBS_VERTICAL	 equ 4
   start:	xchg ebx,eax
		mov edi,wTitle
		mov esi,400000h
		; +------------------------------+
		; | registering the window class |
		; +------------------------------+
		invoke RegisterClass,esp,ebx,window_procedure,ebx,\
		       ebx,esi,ebx,10011h,COLOR_BTNFACE+1,ebx,edi
		       push ebx
		       push esi
		       shl esi,9
		invoke CreateWindowEx,ebx,edi,edi,\
		       WS_OVERLAPPEDWINDOW+WS_VISIBLE- WS_MAXIMIZEBOX - WS_SIZEBOX,\
		       esi,esi,394,240,ebx,ebx
		       pop esi
		       mov  edi,eax
		invoke CreateWindowEx,WS_EX_DLGMODALFRAME,progressclass,ebx,WS_CHILD + WS_VISIBLE,\
		       10,10,367,22,eax,pb1,esi,ebx
		       mov  [pb1H],eax
		invoke SendMessage,eax,PBM_SETSTEP,2,ebx

		invoke CreateWindowEx,WS_EX_CLIENTEDGE+WS_EX_STATICEDGE,progressclass,ebx,WS_CHILD + WS_VISIBLE + PBS_SMOOTH,\
		       10,40,367,22,edi,pb1,esi,ebx
		       mov  [pb2H],eax
		invoke SendMessage,eax,PBM_SETSTEP,2,ebx

		invoke CreateWindowEx,ebx,progressclass,ebx,WS_CHILD + WS_VISIBLE + PBS_VERTICAL,\
		       305,80,25,100,edi,pb1,esi,ebx
		       mov  [pb3H],eax
		invoke SendMessage,eax,PBM_SETSTEP,2,ebx

		invoke CreateWindowEx,ebx,progressclass,ebx,WS_CHILD + WS_VISIBLE + PBS_SMOOTH + PBS_VERTICAL,\
		       350,80,25,100,edi,pb1,esi,ebx
		       mov  [pb4H],eax
		invoke SendMessage,eax,PBM_SETSTEP,2,ebx

		invoke CreateStatusWindow,WS_CHILD + WS_VISIBLE,ebx,edi,sb1
		       mov  [sb1H],eax
		invoke CreateWindowEx,ebx,"BUTTON","Click To Start",\
		       WS_CHILD + WS_VISIBLE + BS_PUSHBUTTON,\
		       10,90,100,30,edi,btn1,esi,ebx
		       mov  [btn1H],eax
		invoke CreateSolidBrush,0FF0000h
		       mov [blueBrush],eax
		       mov ebp,esp
		;+---------------------------+
		;| entering the message loop |
		;+---------------------------+
window_message_loop_start: invoke  GetMessage,ebp,ebx,ebx,ebx
		       invoke  DispatchMessage,ebp
		       jmp window_message_loop_start
   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
window_procedure:
hWnd	      equ ebp+8
uMsg	      equ ebp+0xC
wParam	      equ ebp+10h
lParam	      equ ebp+14h
buffer	      equ ebp-14h
oldBrush      equ buffer - 4
		enter sizeof.PAINTSTRUCT + 18h,0
		xor ebx,ebx
		mov eax,[uMsg]
		mov edi,[hWnd]
		dec eax;cmp [uMsg],WM_DESTROY=2
		dec eax
		je  wmDESTROY
		sub eax,WM_PAINT-WM_DESTROY;cmp [uMsg],WM_PAINT=0Fh
		je  wmPAINT
		sub eax,WM_COMMAND-WM_PAINT;cmp [uMsg],WM_COMMAND=111h
		je  wmCOMMAND
		dec eax;cmp [uMsg],WM_TIMER=113h
		dec eax
		je  wmTIMER
wmDefault:	leave
		jmp [DefWindowProc]
wmDESTROY:	invoke ExitProcess,ebx
wmPAINT:	invoke BeginPaint,edi,esp
		invoke SelectObject,dword[esp+4],[blueBrush]
		mov [oldBrush],eax
		finit
		fld dword[angle]
		fsincos
		push 80.0
		push 80.0
		fmul dword[esp]
		fistp dword[esp]
		fmul dword[esp+4]
		fchs
		fist dword[esp+4]
		add dword[esp+4],130
		add dword[esp],190
		invoke Pie,dword[esp+32],110,80,270,180,190,80
		invoke SelectObject,dword[esp+4],dword[oldBrush]
		invoke EndPaint,edi,esp
		jmp wmBYE
wmCOMMAND:	cmp dword[wParam],BN_CLICKED shl 16 or 4
		jne wmBYE
wmCOMMAND_btn1: invoke SetTimer,edi,tm1,100,ebx
		invoke EnableWindow,[btn1H],ebx
		jmp wmBYE
wmTIMER:	lea esi,[SendMessage]
		mov edi,3
@@:		push ebx
		push ebx
		push PBM_STEPIT
		push [pb1H+edi*4]
		call dword[esi];invoke SendMessage,[pb1H],PBM_STEPIT,ebx,ebx
		push ebx
		push ebx
		push PBM_GETPOS
		push [pb1H+edi*4]
		call dword[esi];invoke SendMessage,[pb1H],PBM_GETPOS,ebx,ebx
		dec edi
		jns @b
		lea edi,[buffer]
		cinvoke wsprintf,edi," Process : %i %%",eax
		push edi
		push ebx
		push SB_SETTEXT
		push [sb1H]
		call dword[esi];invoke SendMessage,[sb1H],SB_SETTEXT,ebx,ebp
		invoke InvalidateRect,dword[hWnd],ebx,ebx
		finit
		fld dword[delta]
		fadd dword[angle]
		fst dword[angle]
		sub [pb1StepCurrent],2
		jne wmBYE
		invoke	KillTimer,dword[hWnd],tm1
		call @f
		db ' 100% Completed',0
@@:		push edi
		push SB_SETTEXT
		push [sb1H]
		call dword[esi];invoke SendMessage,[sb1H],SB_SETTEXT,ebx," 100% Completed"
		push MB_OK + MB_ICONWARNING
		call @f
db 'Virus Detected - Norton Antivirus',0
@@:		call @f
db 'Norton Antivirus detected "ftut_18.exe" contained virus.',13,10
db 'Please remove this application!',0
@@:		invoke MessageBox,dword[hWnd]
wmBYE:		leave
		retn 10h
	wTitle		db 'Iczelion Tutorial #18: Common Controls',0
	pb1H		dd ?
	pb2H		dd ?
	pb3H		dd ?
	pb4H		dd ?
	pb1StepCurrent	dd 100			  ;current step value
	sb1H		dd ?
	btn1H		dd ?
	angle		dd 1.5795229730548682671159401454822;90.5*pi/180
	delta		dd 0.12548917321839229658081336625433;7.19*pi/180
	progressclass	db 'msctls_progress32',0
	blueBrush	dd ?
data import
    library	KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL',\
		gdi32,	  'gdi32.dll',\
		COMCTL32, 'COMCTL32.DLL'
    import	KERNEL32,\
		ExitProcess,		'ExitProcess'
    import	gdi32,\
		Pie,			'Pie',\
		SelectObject,		'SelectObject',\
		CreateSolidBrush,	'CreateSolidBrush'
    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		SetTimer,		'SetTimer',\
		KillTimer,		'KillTimer',\
		wsprintf,		'wsprintfA',\
		MessageBox,		'MessageBoxA',\
		EnableWindow,		'EnableWindow',\
		DestroyWindow,		'DestroyWindow',\
		DispatchMessage,	'DispatchMessageA',\
		BeginPaint,		'BeginPaint',\
		EndPaint,		'EndPaint',\
		InvalidateRect, 	'InvalidateRect',\
		PostQuitMessage,	'PostQuitMessage'
    import	COMCTL32,\
		CreateStatusWindow,	'CreateStatusWindow'
end data