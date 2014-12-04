format PE GUI
include 'win32ax.inc'
WMU_MOUSEHOOK	equ WM_USER + 6
DLG_MAIN	equ 101
EDIT_CLSNAME	equ 1001
EDIT_HANDLE	equ 1002
EDIT_WNDPROC	equ 1003
BTN_HOOK	equ 1004
BTN_EXIT	equ 1005

start:	xchg eax,ebx
	invoke	DialogBoxParam,400000h,DLG_MAIN,ebx,dialog_procedure,ebx
	retn

dialog_procedure:
hDlg  equ ebp+8
uMsg  equ ebp+0Ch
wParam equ ebp+10h
lParam equ ebp+14h
		enter sizeof.RECT,0
		lea edi,[SetDlgItemText]
		mov eax,[uMsg]
		mov esi,[hDlg]
		sub eax,WM_CLOSE;cmp  dword[uMsg],WM_CLOSE;10h
		je   wmCLOSE
		sub eax,WM_INITDIALOG-WM_CLOSE;cmp  dword[uMsg],WM_INITDIALOG;110h
		je   wmINITDIALOG
		dec eax;cmp  dword[uMsg],WM_COMMAND;111h
		je   wmCOMMAND
		sub eax,WMU_MOUSEHOOK-WM_COMMAND;cmp  dword[uMsg],WMU_MOUSEHOOK;406h
		jne  wmBYE

wmuMOUSEHOOK:	invoke	GetDlgItemText,esi,EDIT_HANDLE,buf2,128
		invoke	wsprintf,buf1,f1,dword[wParam]
		mov esi,EDIT_HANDLE
		call proc1
		invoke	GetDlgItemText,esi,EDIT_CLSNAME,buf2,128
		invoke	GetClassName,dword[wParam],buf1,128
		mov esi,EDIT_CLSNAME
		call proc1
		invoke	GetDlgItemText,esi,EDIT_WNDPROC,buf2,128
		invoke	GetClassLong,dword[wParam],GCL_WNDPROC
		invoke	wsprintf,buf1,f1,eax
		mov esi,EDIT_WNDPROC
		call proc1
		jmp  wmBYE

	wmCLOSE:
			cmp  [hookFlag],TRUE
			jne  @f
		invoke	mouse_hook_uninstall
		@@:
		invoke	EndDialog,esi,ebx
			jmp  wmBYE

	wmINITDIALOG: mov edi,esp
		invoke	GetWindowRect,esi,edi;rect
		invoke	SetWindowPos,esi,HWND_TOPMOST,[edi+RECT.left],[edi+RECT.top],[edi+RECT.right],[edi+RECT.bottom],SWP_SHOWWINDOW
			jmp  wmBYE

	wmCOMMAND:	mov  eax,dword[wParam]
			test eax,eax
			je   wmBYE

			mov  edx,eax
			shr  edx,16
			cmp  dx,BN_CLICKED
			jne  wmBYE
			cmp  ax,BTN_EXIT
			jne   wmCOMMAND_BTN_HOOK

		wmCOMMAND_BTN_EXIT:
			invoke	SendMessage,esi,WM_CLOSE,ebx,ebx
				jmp  wmBYE
		
		wmCOMMAND_BTN_HOOK:
				xor [hookFlag],1;cmp  [hookFlag],TRUE
				jne  BTN_HOOK_FALSE
			invoke	mouse_hook_uninstall
			push ebx
			push ebx
			push ebx
			push txtHook
			or ebx,4
@@:			push [handlers+ebx*4-4]
			push esi
			call  dword[edi]
			dec ebx
			jnz @b
				jmp  wmBYE

			BTN_HOOK_FALSE:
				invoke	mouse_hook_install,esi
					test  eax,eax
					je   wmBYE
				push txtUnhook
				push BTN_HOOK
				push esi
				call  dword[edi]
		
	wmBYE:	leave
		xor eax,eax
		retn 10h

proc proc1
	invoke	lstrcmpi,buf1,buf2
	test  eax,eax
	je   @f
	push buf1
	push esi
	push dword[hDlg]
	call  dword[edi]
	@@: retn
endp
	handlers dd  EDIT_WNDPROC,EDIT_HANDLE,EDIT_CLSNAME,BTN_HOOK
	hookFlag	dd FALSE
	txtUnhook	db '&Unhook',0
	txtHook 	db '&Hook',0

	buf1	rb 128
	buf2	rb 128
	f1	db '0x%lX',0
data import
    library	KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL',\
		FTUT_24A,  'fTUT_24A.DLL'
    
    import	KERNEL32,\
		lstrcmpi,		'lstrcmpiA'

    import	USER32,\
		SetDlgItemText, 	'SetDlgItemTextA',\
		SendMessage,		'SendMessageA',\
		wsprintf,		'wsprintfA',\
		DialogBoxParam, 	'DialogBoxParamA',\
		GetWindowRect,		'GetWindowRect',\
		GetClassName,		'GetClassNameA',\
		GetClassLong,		'GetClassLongA',\
		EndDialog,		'EndDialog',\
		GetDlgItemText, 	'GetDlgItemTextA',\
		SetWindowPos,		'SetWindowPos'

   import	FTUT_24A,\
		mouse_hook_install,	'mouse_hook_install',\
		mouse_hook_uninstall,	'mouse_hook_uninstall'

end data
section '.rsrc' resource data readable
	directory	RT_DIALOG,appDialog
	
	resource	appDialog,\
			DLG_MAIN,LANG_NEUTRAL,dlgMain

	dialog dlgMain,'Iczelion Tutorial #24: Mouse Hook Demo',0,0,229,85,\
		WS_CAPTION + WS_POPUP + WS_SYSMENU + DS_MODALFRAME
		dialogitem	'BUTTON','Window Information',-1,7,7,214,67,WS_VISIBLE + BS_GROUPBOX
		dialogitem	'STATIC','Class Name :',-1,21,22,42,8,SS_LEFT + WS_VISIBLE
		dialogitem	'EDIT','',EDIT_CLSNAME,69,20,139,12,ES_LEFT + ES_AUTOHSCROLL + ES_READONLY + WS_VISIBLE + WS_BORDER + WS_TABSTOP
		dialogitem	'STATIC','Handle :',-1,36,37,28,8,SS_LEFT + WS_VISIBLE
		dialogitem	'EDIT','',EDIT_HANDLE,69,36,76,12,ES_LEFT + ES_AUTOHSCROLL + ES_READONLY + WS_VISIBLE + WS_BORDER + WS_TABSTOP
		dialogitem	'STATIC','Window Proc :',-1,15,52,48,8,SS_LEFT + WS_VISIBLE
		dialogitem	'EDIT','',EDIT_WNDPROC,69,52,76,12,ES_LEFT + ES_AUTOHSCROLL + ES_READONLY + WS_VISIBLE + WS_BORDER + WS_TABSTOP
		dialogitem	'BUTTON','&Hook',BTN_HOOK,159,35,50,14,BS_DEFPUSHBUTTON + WS_VISIBLE + WS_TABSTOP
		dialogitem	'BUTTON','&Exit',BTN_EXIT,159,51,50,15,BS_PUSHBUTTON + WS_VISIBLE + WS_TABSTOP
	enddialog
