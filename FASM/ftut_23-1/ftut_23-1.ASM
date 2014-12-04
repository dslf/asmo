format PE GUI
include 'win32ax.inc'
; constants
WM_SHELLNOTIFY = WM_USER+5
IDI_TRAY       = 0
IDM_SHOWHIDE   = 100
IDM_EXIT       = 101
; code section
	 ; initialise main window
	xchg ebx,eax
	mov edi,wTitle
	mov esi,400000h
		; +------------------------------+
		; | registering the window class |
		; +------------------------------+
	invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	ebx,esi,10011h,10011h,COLOR_BTNFACE+1,ebx,edi
	push ebx
	push esi
	shl esi,9
	invoke	CreateWindowEx,ebx,edi,edi,\
	WS_VISIBLE+WS_OVERLAPPEDWINDOW,esi,esi,400,240,HWND_DESKTOP,ebx
	mov edi,eax
	mov	[hWnd],edi
	invoke	Shell_NotifyIcon, NIM_ADD,cbSize	  ; show icon ton system tray
	invoke	CreatePopupMenu 					;
	mov [hTrayMenu],eax					    ; create popup menu
	invoke	AppendMenu, eax,ebx,IDM_SHOWHIDE,szShowHide	  ;
	invoke	AppendMenu, [hTrayMenu],ebx,IDM_EXIT,szExit	  ;
	mov ebp,esp
message_loop:
	invoke	GetMessage, ebp,ebx,ebx,ebx
	invoke	DispatchMessage, ebp
	jmp	message_loop

proc window_procedure hwnd,uMsg,wparam,lparam
local pt:POINT
	mov eax,[uMsg]
	mov edi,[hwnd]
	dec eax;cmp [uMsg],WM_CREATE
	dec eax;cmp [uMsg],WM_DESTROY
	je .wmdestroy
	sub eax,WM_COMMAND-WM_DESTROY;cmp [uMsg], 111h
	je .wmcommand
	dec eax;cmp [uMsg],WM_SYSCOMMAND;112h
	je .wmsyscommand
	sub eax,WM_SHELLNOTIFY-WM_SYSCOMMAND;cmp [uMsg],WM_SHELLNOTIFY=405h
	je .wmshellnotify
.defwndproc: leave
	jmp [DefWindowProc]
.wmcommand: cmp [lparam],ebx; WM_COMMAND handler - here we handle clicks on tray icon
	jne .finish
	mov eax,[wparam]
	sub eax,IDM_SHOWHIDE;cmp eax,IDM_SHOWHIDE;=64h
	je .showhide
	dec eax;cmp eax,IDM_EXIT;=65h
	jne .finish
.idm_exit: invoke DestroyWindow,edi
	jmp .finish

.wmsyscommand: cmp [wparam],SC_MINIMIZE; when user presses "minimize" button, main window
	jne	.defwndproc; should be hidden
.showhide: xor [showflag],1
	mov al,[showflag]
	lea eax,[eax+4*eax];if al=0 SW_HIDE=0 if al=1 SW_SHOW=5
	invoke	ShowWindow,edi,eax
	jmp	.finish
  .wmshellnotify: cmp [wparam],eax;IDI_TRAY=0; WM_SHELLNOTIFY handler - here we handle actions
	jne	.finish; like clicking on our icon
	cmp	[lparam],WM_LBUTTONDOWN;=201h
	je	.showhide
	cmp	[lparam],WM_RBUTTONDOWN;=204h
	jne	.finish
 .show_tray_popup:
	invoke	GetCursorPos, esp;eax
	invoke	SetForegroundWindow, edi
	invoke	TrackPopupMenu,[hTrayMenu],TPM_RIGHTALIGN,\
	[pt.x],[pt.y],ebx,edi,ebx
	invoke	PostMessage, edi,ebx,ebx,ebx
.finish: ret
.wmdestroy:
	invoke	Shell_NotifyIcon, NIM_DELETE,cbSize
	invoke	DestroyMenu,[hTrayMenu]
	invoke	ExitProcess,ebx
endp

  wTitle db "Iczelion Tutorial 23-1: Tray Icon", 0
  szShowHide db "&Show/Hide", 0
  szExit     db "&Exit", 0
  hTrayMenu dd ?
  showflag  db 1   ;if main window is visible showflag=1
  ; fill NOTIFYICONDATA structure
  cbSize	   dd sizeof.NOTIFYICONDATA
  hWnd		   dd ?
  uID		   dd IDI_TRAY
  uFlags	   dd NIF_ICON+NIF_MESSAGE+NIF_TIP
  uCallbackMessage dd WM_SHELLNOTIFY
  hIcon 	   dd 10011h
  szTip 	   db "Tray Demo",0
		   rb 54
;=================================================================
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