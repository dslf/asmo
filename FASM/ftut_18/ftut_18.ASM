format PE GUI
include 'win32ax.inc'
 pb1		 equ 1
 sb1		 equ 2
 tm1		 equ 3
 btn1		 equ 4
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
		invoke CreateWindowEx,ebx,"msctls_progress32",ebx,WS_CHILD + WS_VISIBLE,\
		       10,10,367,22,eax,pb1,esi,ebx
		       mov  [pb1H],eax
		invoke SendMessage,eax,PBM_SETRANGE,ebx,6553600
		invoke SendMessage,[pb1H],PBM_SETSTEP,2,ebx

		invoke CreateStatusWindow,WS_CHILD + WS_VISIBLE,ebx,edi,sb1
		       mov  [sb1H],eax
		invoke CreateWindowEx,ebx,"BUTTON","Click To Start",\
		       WS_CHILD + WS_VISIBLE + BS_PUSHBUTTON,\
		       10,40,100,30,edi,btn1,esi,ebx
		       mov  [btn1H],eax
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
hWnd	      equ esp+4
uMsg	      equ esp+8
wParam	      equ esp+0Ch
lParam	      equ esp+10h
		mov eax,[uMsg]
		mov edi,[hWnd]
		dec eax;cmp [uMsg],WM_DESTROY=2
		dec eax
		je  wmDESTROY
		sub eax,WM_COMMAND-WM_DESTROY;cmp [uMsg],WM_COMMAND=111h
		je  wmCOMMAND
		dec eax;cmp [uMsg],WM_TIMER=113h
		dec eax
		je  wmTIMER
		jmp [DefWindowProc]
wmDESTROY:	invoke ExitProcess,ebx
wmCOMMAND:	cmp dword[wParam],BN_CLICKED shl 16 or 4
		jne wmBYE
wmCOMMAND_btn1: invoke SetTimer,edi,tm1,100,ebx
		invoke EnableWindow,[btn1H],ebx
		jmp wmBYE
wmTIMER:	lea esi,[SendMessage]
		push ebx
		push ebx
		push PBM_STEPIT
		push [pb1H]
		call dword[esi];invoke SendMessage,[pb1H],PBM_STEPIT,ebx,ebx
		push ebx
		push ebx
		push PBM_GETPOS
		push [pb1H]
		call dword[esi];invoke SendMessage,[pb1H],PBM_GETPOS,ebx,ebx
		sub esp,12h;создаем временный буфер
		mov ebp,esp
		cinvoke wsprintf,ebp," Process : %i %%",eax
		push ebp
		push ebx
		push SB_SETTEXT
		push [sb1H]
		call dword[esi];invoke SendMessage,[sb1H],SB_SETTEXT,ebx,ebp
		add esp,12h;удаляем временный буфер
		sub [pb1StepCurrent],2
		jne wmBYE
		invoke	KillTimer,edi,tm1
		call @f
		db ' 100% Completed',0
@@:		push ebx
		push SB_SETTEXT
		push [sb1H]
		call dword[esi];invoke SendMessage,[sb1H],SB_SETTEXT,ebx," 100% Completed"
		push MB_OK + MB_ICONWARNING
		call @f
db 'Virus Detected - Norton Antivirus',0
@@:		call @f
db 'Norton Antivirus detected "ftut_18.exe" contained virus.',13,10
db 'Please remove this application!',0
@@:		invoke MessageBox,edi
wmBYE:		retn 10h
	wTitle		db 'Iczelion Tutorial #18: Common Controls',0
	pb1H		dd ?
	pb1StepCurrent	dd 100			  ;current step value
	sb1H		dd ?
	btn1H		dd ?
data import
    library	KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL',\
		COMCTL32, 'COMCTL32.DLL'
    import	KERNEL32,\
		ExitProcess,		'ExitProcess'
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
		PostQuitMessage,	'PostQuitMessage'
    import	COMCTL32,\
		CreateStatusWindow,	'CreateStatusWindow'
end data