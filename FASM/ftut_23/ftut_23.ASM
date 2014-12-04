format PE GUI
include 'win32ax.inc'
WUM_SHELLNOTIFY equ WM_USER + 5
MI_RESTORE	equ 0
MI_EXIT 	equ 1001
SBI_TRAY	equ 0
start:		xchg ebx,eax
		mov edi,wTitle
		mov esi,400000h
		; +------------------------------+
		; | registering the window class |
		; +------------------------------+
		invoke RegisterClass,esp,ebx,window_procedure,ebx,\
		ebx,esi,10011h,10011h,COLOR_BTNFACE+1,ebx,edi
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
		invoke	CreatePopupMenu
			mov  [menuH],eax
		invoke	AppendMenu,eax,ebx,ebx,miRESTORE
		invoke	AppendMenu,[menuH],ebx,MI_EXIT,miEXIT
		mov ebp,esp
   ;+---------------------------+
   ;| entering the message loop |
   ;+---------------------------+
   window_message_loop_start:
		invoke	GetMessage,ebp,ebx,ebx,ebx
		invoke	DispatchMessage,ebp
		jmp	window_message_loop_start

   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
window_procedure:
hWnd	equ ebp+8h
uMsg	equ ebp+0Ch
wParam	equ ebp+10h
lParam	equ ebp+14h
menuPt	equ ebp-sizeof.POINT
		enter sizeof.POINT,0
		mov esi,[hWnd]
		lea edi,[statBarData]
		mov eax,[uMsg]
		dec  eax;cmp  [uMsg],WM_DESTROY
		dec eax
		je   wmDESTROY
		sub eax,WM_SIZE-WM_DESTROY;cmp  [uMsg],WM_SIZE
		je   wmSIZE
		sub eax,WM_COMMAND-WM_SIZE;cmp  [uMsg],WM_COMMAND
		je   wmCOMMAND
		sub eax,WUM_SHELLNOTIFY-WM_COMMAND;cmp  [uMsg],WUM_SHELLNOTIFY
		je   wumSHELLNOTIFY
	wmDEFAULT: leave
		jmp  [DefWindowProc]

	wumSHELLNOTIFY:
			cmp  dword[wParam],SBI_TRAY
			jne  wmBYE
			cmp  dword[lParam],WM_RBUTTONDOWN
			je   wumSHELLNOTIFY_WM_RBUTTONDOWN
			cmp  dword[lParam],WM_LBUTTONDBLCLK
			je   wumSHELLNOTIFY_WM_LBUTTONDBLCLK
			jmp  wmBYE
		
		wumSHELLNOTIFY_WM_LBUTTONDBLCLK:
			invoke	SendMessage,esi,WM_COMMAND,MI_RESTORE,0
				jmp  wmBYE
		
		wumSHELLNOTIFY_WM_RBUTTONDOWN:
			lea edi,[menuPt]
			invoke	GetCursorPos,edi
			invoke	SetForegroundWindow,esi
			invoke	TrackPopupMenu,[menuH],TPM_RIGHTALIGN + TPM_RIGHTBUTTON,\
				[edi+POINT.x],[edi+POINT.y],ebx,esi,ebx
			invoke	PostMessage,esi,WM_NULL,ebx,ebx
				jmp  wmBYE
		
	wmCOMMAND:
			cmp  [lParam],ebx	  ;message is not from control
			jne  wmBYE
		invoke	Shell_NotifyIcon,NIM_DELETE,edi
			cmp  word[wParam],bx;MI_RESTORE
			je   wmCOMMAND_MI_RESTORE
		invoke	DestroyWindow,esi
			jmp  wmBYE
		
		wmCOMMAND_MI_RESTORE:
			invoke	ShowWindow,esi,SW_RESTORE
				jmp  wmBYE
	wmSIZE:
			cmp  dword[wParam],SIZE_MINIMIZED
			jne  wmBYE
			mov  [edi+NOTIFYICONDATA.cbSize],sizeof.NOTIFYICONDATA
			mov  [edi+NOTIFYICONDATA.hWnd],esi
			mov  [edi+NOTIFYICONDATA.uID],ebx
			mov  [edi+NOTIFYICONDATA.uFlags],NIF_ICON + NIF_MESSAGE + NIF_TIP
			mov  [edi+NOTIFYICONDATA.uCallbackMessage],WUM_SHELLNOTIFY
			mov  [edi+NOTIFYICONDATA.hIcon],10011h;eax
		invoke	lstrcpy,statBarData.szTip,wTitle
		invoke	ShowWindow,esi,SW_HIDE
		invoke	Shell_NotifyIcon,NIM_ADD,edi
	wmBYE:	leave
		retn 10h
	wmDESTROY: invoke  DestroyMenu,[menuH]
		invoke	ExitProcess,0
;=================================================================
	wTitle		db 'Iczelion Tutorial 23: Tray Icon',0
	menuH		dd ?
	menuRect	RECT
	miRESTORE	db '&Restore',0
	miEXIT		db '&Exit',0
	
	statBarData	NOTIFYICONDATA

data import
library     KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL',\
		SHELL32,  'SHELL32.DLL'
    
    import	KERNEL32,\
		lstrcpy,		'lstrcpyA',\
		ExitProcess,		'ExitProcess'
    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		MessageBox,		'MessageBoxA',\
		CreatePopupMenu,	'CreatePopupMenu',\
		DestroyMenu,		'DestroyMenu',\
		AppendMenu,		'AppendMenuA',\
		GetCursorPos,		'GetCursorPos',\
		SetForegroundWindow,	'SetForegroundWindow',\
		TrackPopupMenu, 	'TrackPopupMenu',\
		PostMessage,		'PostMessageA',\
		ShowWindow,		'ShowWindow',\
		DestroyWindow,		'DestroyWindow',\
		DispatchMessage,	'DispatchMessageA',\
		LoadIcon,		'LoadIconA'
   import	SHELL32,\
		Shell_NotifyIcon,	'Shell_NotifyIcon'
end data