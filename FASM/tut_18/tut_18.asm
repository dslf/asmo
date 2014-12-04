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
		push ebx
		push ebx
		shl esi,9
		invoke CreateWindowEx,ebx,edi,edi,\
		WS_OVERLAPPEDWINDOW+WS_VISIBLE- WS_MAXIMIZEBOX - WS_SIZEBOX,\
		esi,esi,394,240
		pop esi
		mov  edi,eax
		invoke	CreateWindowEx,NULL,ctlClsNamePb,ebx,WS_CHILD + WS_VISIBLE,\
			10,10,367,22,eax,pb1,esi,NULL
			mov  [pb1H],eax
			mov  [pb1StepCurrent],100;eax
			mov  [pb1Range],6553600;eax
			mov  [pb1StepInc],2
		call	pb1_config
		invoke	CreateStatusWindow,WS_CHILD + WS_VISIBLE,NULL,edi,sb1
			mov  [sb1H],eax
		invoke	CreateWindowEx,NULL,ctlClsNameBtn,btn1Txt,WS_CHILD + WS_VISIBLE + BS_PUSHBUTTON,\
			10,40,100,30,edi,btn1,esi,ebx
			mov  [btn1H],eax
		mov ebp,esp
		;+---------------------------+
		;| entering the message loop |
		;+---------------------------+
window_message_loop_start: invoke  GetMessage,ebp,ebx,ebx,ebx
		xchg	eax,ecx
		jecxz	 window_message_loop_end
		invoke	DispatchMessage,ebp
		jmp	window_message_loop_start

window_message_loop_end:


   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
   proc window_procedure,hWnd,uMsg,wParam,lParam
		cmp  [uMsg],WM_TIMER
		je   wmTIMER
		cmp  [uMsg],WM_COMMAND
		je   wmCOMMAND
		cmp  [uMsg],WM_DESTROY
		je   wmDESTROY

	wmDEFAULT: leave
		jmp  [DefWindowProc]

wmDESTROY:	invoke	ExitProcess,ebx
wmTIMER:	invoke	SendMessage,[pb1H],PBM_STEPIT,ebx,ebx
		invoke	SendMessage,[pb1H],PBM_GETPOS,ebx,ebx
		cinvoke wsprintf,sbBuffer1,sbf1,eax
		invoke	SendMessage,[sb1H],SB_SETTEXT,ebx,sbBuffer
			sub  [pb1StepCurrent],2
			cmp  [pb1StepCurrent],ebx
			jne  @f
				invoke	KillTimer,[hWnd],[tm1H]
					mov  [tm1H],ebx
				invoke	SendMessage,[sb1H],SB_SETTEXT,0,sbf2
				invoke	MessageBox,[hWnd],msg1Txt,msg1Title,MB_OK + MB_ICONWARNING
			@@:
			jmp  wmBYE

wmCOMMAND:		cmp  [wParam],BN_CLICKED shl 16 or 4
			jne   wmBYE
		
wmCOMMAND_btn1: 	invoke	SetTimer,[hWnd],tm1,100,ebx
				mov  [tm1H],eax
			invoke	EnableWindow,[btn1H],ebx
	wmBYE:	leave
		retn 10h
   endp

   proc pb1_config
	invoke	SendMessage,[pb1H],PBM_SETRANGE,ebx,[pb1Range]
	invoke	SendMessage,[pb1H],PBM_SETSTEP,[pb1StepInc],ebx
	retn
   endp
	wTitle		db 'Iczelion Tutorial 18: Common Controls',0
	ctlClsNamePb	db 'msctls_progress32',0
	ctlClsNameBtn	db 'BUTTON',0
	pb1H		dd ?
	pb1StepCurrent	dd ?			;current step value
	pb1Range	dd ?			;range
	pb1StepInc	dd ?			;increase step value
	sb1H		dd ?
	sbBuffer	db ' Process : '
	sbBuffer1	rb 0xF
	sbf1		db '%i %%',0
	sbf2		db ' 100% Completed',0
	msg1Title	db 'Virus Detected - Norton Antivirus',0
	msg1Txt 	db 'Norton Antivirus detected "tut_18.exe" contained virus.',13,10,'Please remove this application!',0
	tm1H		dd ?
	btn1H		dd ?
	btn1Txt 	db 'Click To Start',0
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