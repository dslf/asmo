format PE GUI 4.0 DLL
entry DllMain
include 'win32ax.inc'
struct MOUSEHOOKSTRUCT
	.pt		POINT
	.hwnd		dd ?
	.wHitTestCode	dd ?
	.dwExtraInfo	dd ?
ends

WMU_MOUSEHOOK equ WM_USER + 6
section '.data' data readable writeable
	insH		dd ?			;handle for instance

section '.sdata' readable writeable shareable
	hookH	dd ?
	wndH	dd ?

section '.code' code readable executable
   proc DllMain, hinstDll, fdwReason, lpvReserved
		push [hinstDll]
		pop  [insH]
		mov  eax,TRUE
		leave
		retn 12
   endp
	
   proc mouse_procedure,nCode,wParam,lParam
	invoke	CallNextHookEx,[hookH],[nCode],[wParam],[lParam]
		mov  edx,[lParam]
	invoke	WindowFromPoint,dword[edx + POINT.x],dword[edx + POINT.y]
	invoke	PostMessage,[wndH],WMU_MOUSEHOOK,eax,0
		xor  eax,eax		;must clear eax here
		leave
		retn 12
   endp
   
   proc mouse_hook_install,wndTempH
		push [wndTempH]
		pop  [wndH]
	invoke	SetWindowsHookEx,WH_MOUSE,mouse_procedure,[insH],NULL
		mov  [hookH],eax
		leave
		retn 4
   endp

   proc mouse_hook_uninstall
	invoke	UnhookWindowsHookEx,[hookH]
		retn
   endp

section '.idata' import data readable
	library USER32, 'USER32.DLL'

	import	USER32,\
		CallNextHookEx, 	'CallNextHookEx',\
		WindowFromPoint,	'WindowFromPoint',\
		PostMessage,		'PostMessageA',\
		SetWindowsHookEx,	'SetWindowsHookExA',\
		UnhookWindowsHookEx,	'UnhookWindowsHookEx'

section '.edata' export data readable
	export	'TUT_24A.DLL',\
		mouse_procedure,	'mouse_procedure',\
		mouse_hook_install,	'mouse_hook_install',\
		mouse_hook_uninstall,	'mouse_hook_uninstall'

section '.reloc' fixups data discardable
