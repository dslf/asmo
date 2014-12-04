format PE GUI
include 'win32ax.inc'
; +-----------------------+
; | menu item declaration |
; +-----------------------+
MI_PROCESS_CREATE	equ	0
MI_PROCESS_TERMINATE	equ	1
MI_EXIT 		equ	2

start:	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
		; +------------------------------+
		; | registering the window class |
		; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,30,edi
		; +--------------------------+
		; | creating the main window |
		; +--------------------------+
	  push ebx
	  push esi
	  push ebx
	  push ebx
	  shl esi,9
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,300,200
	  invoke  GetMenu,eax;[hWnd]
	  mov	  [hMenu],eax
	  mov ebp,esp
		; +---------------------------+
		; | entering the message loop |
		; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke DispatchMessage,ebp
	  jmp message_loop
		; +----------------------+
		; | the window procedure |
		; +----------------------+
window_procedure:
hWnd		equ ebp+8h
uMsg		equ ebp+0Ch
wParam		equ ebp+10h
lParam		equ ebp+14h
progStartInfo	equ ebp-sizeof.STARTUPINFO
		enter sizeof.STARTUPINFO,0
			mov eax,[uMsg]
			lea edi,[processInfo]
			lea esi,[proExitCode]
			dec eax
			dec eax;cmp     [uMsg],WM_DESTROY
			je	wmDESTROY
			sub eax,WM_COMMAND-WM_DESTROY;cmp     [uMsg],WM_COMMAND
			je	wmCOMMAND
			sub eax,WM_INITMENUPOPUP-WM_COMMAND;cmp     [uMsg],WM_INITMENUPOPUP
			je	wmINITMENUPOPUP
			leave
			jmp  [DefWindowProc]

wmINITMENUPOPUP:  invoke  GetExitCodeProcess,[edi+PROCESS_INFORMATION.hProcess],esi
		  xchg	eax,ecx
		  jecxz      a2;GetExitCodeProcess_TRUE
		  cmp dword [esi],STILL_ACTIVE;cmp     [proExitCode],STILL_ACTIVE
		  jne a2;     GetExitCodeProcess_STILL_ACTIVE
		  push ebx;MF_ENABLED
		  push MF_GRAYED
		  jmp a5
a2:		  push MF_GRAYED
		  push ebx;MF_ENABLED
a5:		  invoke  EnableMenuItem,[hMenu],ebx;MI_PROCESS_CREATE
		  invoke  EnableMenuItem,[hMenu],MI_PROCESS_TERMINATE
		  jmp	  wmBYE
wmCOMMAND:	  movzx eax,word [wParam]
		  jmp dword [menu_handlers+eax*4]
PROCESS_CREATE:   cmp [edi+PROCESS_INFORMATION.hProcess],ebx
		  je pi_hProcess_IS_0;a3;
		  invoke  CloseHandle,[edi+PROCESS_INFORMATION.hProcess]
		  mov [edi+PROCESS_INFORMATION.hProcess],ebx
pi_hProcess_IS_0:
		  lea esi,[progStartInfo]
		  invoke  GetStartupInfo,esi
		  invoke  CreateProcess,progName,ebx,ebx,ebx,ebx,\
		  NORMAL_PRIORITY_CLASS,ebx,ebx,esi,edi
		  invoke  CloseHandle,[edi+PROCESS_INFORMATION.hThread]
		  jmp	  wmBYE
TERMINATE:	  invoke  GetExitCodeProcess,[edi+PROCESS_INFORMATION.hProcess],esi;proExitCode
		  cmp dword [esi],STILL_ACTIVE
		  jne proExitCode_NOT_STILL_ACTIVE;a4;
		  invoke  TerminateProcess,[edi+PROCESS_INFORMATION.hProcess],ebx
proExitCode_NOT_STILL_ACTIVE:
		  invoke  CloseHandle,[edi+PROCESS_INFORMATION.hProcess]
		  mov [edi+PROCESS_INFORMATION.hProcess],ebx;0
		  jmp	  wmBYE
EXIT:		  invoke  DestroyWindow,dword[hWnd]
wmBYE:		  leave
		  retn 10h
wmDESTROY:	invoke	ExitProcess,ebx;0

menu_handlers  dd PROCESS_CREATE, TERMINATE, EXIT

wTitle		db	'Tutorial 14',0
hMenu		dd	?	;menu handle
proExitCode	dd	?	;process exit code
progName	db	'tut_14.exe',0
processInfo	PROCESS_INFORMATION

data import
	library KERNEL32,	'KERNEL32.DLL',\
		USER32, 	'USER32.DLL'

	import	KERNEL32,\
			GetExitCodeProcess,	'GetExitCodeProcess',\
			GetStartupInfo, 	'GetStartupInfoA',\
			CreateProcess,		'CreateProcessA',\
			TerminateProcess,	'TerminateProcess',\
			CloseHandle,		'CloseHandle',\
			ExitProcess,		'ExitProcess'

	import	USER32,\
			RegisterClass,		'RegisterClassA',\
			CreateWindowEx, 	'CreateWindowExA',\
			DefWindowProc,		'DefWindowProcA',\
			GetMenu,		'GetMenu',\
			EnableMenuItem, 	'EnableMenuItem',\
			GetMessage,		'GetMessageA',\
			DestroyWindow,		'DestroyWindow',\
			DispatchMessage,	'DispatchMessageA'

end data
section '.rsrc' resource data readable
	directory	RT_MENU,appMenu

	resource	appMenu,\
			30,LANG_NEUTRAL,menuMain

	menu	menuMain
		menuitem	'&Process',0,MFR_POPUP + MFR_END
		menuitem		'&Create Process',MI_PROCESS_CREATE,0
		menuitem		'&Terminate Process',MI_PROCESS_TERMINATE,0
					menuseparator
		menuitem		'E&xit',MI_EXIT,MFR_END
