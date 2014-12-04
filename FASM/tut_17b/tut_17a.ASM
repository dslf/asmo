format PE GUI 4.0 DLL
entry DllMain
include 'win32ax.inc'
section '.data' data readable writeable
	DllErrBoxTitle	db 'DllMsgBox - Error',0

section '.code' code readable executable
	proc	DllMain, hinstDll, fdwReason, lpvReserved
		mov  eax,TRUE
		leave
		retn 10h
	endp
	
	proc	DllErrBox, hWnd, errMsg
		invoke	MessageBox,[hWnd],[errMsg],DllErrBoxTitle,MB_OK + MB_ICONERROR
		leave
		retn 8
	endp

section '.idata' import data readable
	library USER32, 'USER32.DLL'

	import	USER32,\
		MessageBox,	'MessageBoxA'

section '.edata' export data readable
	export	'TUT_17.DLL',\
		DllErrBox,	'DllErrBox'

section '.reloc' fixups data discardable

