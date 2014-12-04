format PE GUI 4.0
include 'win32ax.inc'
start:	xchg ebx,eax
	mov esi,400000h
	invoke	DialogBoxParam,esi,101,ebx,dialog_procedure,ebx
	retn

dialog_procedure:
hdlg	equ ebp+8
umsg	equ ebp+0Ch
ti	equ ebp-sizeof.TOOLINFO
		enter sizeof.RECT+sizeof.TOOLINFO,0
		mov eax,[umsg]
		mov edi,[hdlg]
		sub eax,WM_CLOSE;cmp  [umsg],WM_CLOSE
		je wmCLOSE
		sub eax,WM_INITDIALOG-WM_CLOSE;cmp  [umsg],WM_INITDIALOG
		je wmINITDIALOG
		xor eax,eax;mov  eax,FALSE
		jmp a1
wmCLOSE:	invoke	EndDialog,edi,eax
		jmp wmBYE
wmINITDIALOG:	invoke	InitCommonControls
		xor ebx,ebx
		push ebx
		push esi
		shl esi,9;esi=CW_USEDEFAULT
		invoke	CreateWindowEx,ebx,ctlClsNameTips,ebx,TTS_ALWAYSTIP,\
		esi,esi,esi,esi,ebx,ebx
		mov  [tipsH],eax
		lea esi,[ti]
		mov [esi+TOOLINFO.cbSize],sizeof.TOOLINFO
		mov [esi+TOOLINFO.uFlags],TTF_SUBCLASS
		mov [esi+TOOLINFO.hwnd],edi
		invoke GetWindowRect,edi,esp
		or ebx,3
@@:		stdcall SetDlgToolArea,dword[hdlg],esi,[handel+ebx*4],ebx,esp
		dec ebx
		jns @b
		invoke EnumChildWindows,edi,EnumChild,esi
	wmBYE:	mov eax,TRUE
   a1:		leave
		retn 10h

EnumChild:
hwndChild	equ ebp+8
lParam		equ ebp+0Ch
buffer		equ ebp-100h
		enter 100h,0
		push edi
		mov edi,[lParam]
		push dword[hwndChild]
		pop [edi + TOOLINFO.uId]
		or [edi + TOOLINFO.uFlags],TTF_IDISHWND
		lea eax,[buffer]
		mov [edi + TOOLINFO.lpszText],eax
	invoke	GetWindowText,dword[hwndChild],eax,0xFF
	invoke	SendMessage,[tipsH],TTM_ADDTOOL,ebx,edi
		pop edi
		leave
		retn 8

SetDlgToolArea:
hDlg		equ ebp+8h
lpti		equ ebp+0Ch
lpText		equ ebp+10h
id		equ ebp+14h
lprect		equ ebp+18h
		push ebp
		mov ebp,esp
		pusha
		mov  edi,[lpti]
		mov  esi,[lprect]
		xor ebx,ebx
		mov eax,[id]
		mov  [edi + TOOLINFO.Rect.left],ebx
		mov  [edi + TOOLINFO.Rect.top],ebx
		mov  [edi + TOOLINFO.Rect.right],350
		mov  [edi + TOOLINFO.Rect.bottom],188
		jmp [handels+eax*4];229,96
	id_0:	mov  [edi + TOOLINFO.Rect.right],165
		mov  [edi + TOOLINFO.Rect.bottom],74
		jmp  id_exit
	id_1:	mov  [edi + TOOLINFO.Rect.bottom],74
		mov  [edi + TOOLINFO.Rect.left],166
		jmp  id_exit
	id_2:	mov  [edi + TOOLINFO.Rect.right],165
		mov  [edi + TOOLINFO.Rect.top],75
		jmp  id_exit
	id_3:	mov  [edi + TOOLINFO.Rect.left],166
		mov  [edi + TOOLINFO.Rect.top],75
id_exit:	push dword[lpText]
		pop  [edi + TOOLINFO.lpszText]
		invoke	SendMessage,[tipsH],TTM_ADDTOOL,ebx,edi;dword[lpti]
		popa
		pop ebp
		retn 14h

handels dd id_0, id_1, id_2, id_3
handel	dd tipsTxt1, tipsTxt2, tipsTxt3, tipsTxt4
	tipsH		dd ?
	ctlClsNameTips	db 'Tooltips_class32',0
	tipsTxt1	db 'Ёто верхн€€ лева€ область',0
	tipsTxt2	db 'Ёто верхн€€ права€ область',0
	tipsTxt3	db 'Ёто нижн€€ лева€ область',0
	tipsTxt4	db 'Ёто нижн€€ права€ область',0
data import
    library	USER32,   'USER32.DLL',\
		COMCTL32, 'COMCTL32.DLL'

    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DialogBoxParam, 	'DialogBoxParamA',\
		EndDialog,		'EndDialog',\
		GetWindowRect,		'GetWindowRect',\
		EnumChildWindows,	'EnumChildWindows',\
		GetWindowText,		'GetWindowTextA',\
		SendMessage,		'SendMessageA'

    import	COMCTL32,\
		InitCommonControls,	'InitCommonControls'

section '.rsrc' resource data readable
	directory	RT_DIALOG,appDialog
	
	resource	appDialog,\
			101,LANG_NEUTRAL,dlgMain

	dialog dlgMain,'Iczelion Tutorial 27: Tooltip Example',0,0,229,96,\
		WS_CAPTION + WS_POPUP + WS_SYSMENU + DS_MODALFRAME
		dialogitem 'BUTTON','',-1,0,-4,115,51,WS_VISIBLE+BS_GROUPBOX
		dialogitem 'BUTTON','',-1,114,43,115,53,WS_VISIBLE+BS_GROUPBOX
		dialogitem 'BUTTON','&Ok',1000,55,68,50,14,BS_PUSHBUTTON + WS_VISIBLE + WS_TABSTOP
		dialogitem 'BUTTON','&Exit',1001,123,68,50,14,BS_PUSHBUTTON + WS_VISIBLE + WS_TABSTOP
	enddialog

end data