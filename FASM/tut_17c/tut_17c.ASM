format PE GUI 4.0
entry start
include 'win32a.inc'
section '.data' data readable writeable
	dllName 	db 'TUT_17A.DLL',0		;dll name that to be loaded
	funcName	db 'DllErrBox',0		;function / proc name that wish to be called
	funcAddr	dd ?				;store function address
	
	msgBoxTitle	db 'Error',0
	msgBoxDll	db 'The Requested DLL not found!',0
	msgBoxProc	db 'The Requested Procedure not found!',0
	
	msg1		db '[code]',13,10
			db '      invoke  LoadLibrary,dllName',13,10
			db '      invoke  GetProcAddress,eax,funcName',13,10
			db '      invoke  funcAddr,HWND_DESKTOP,msg1',13,10
			db '[/code]',0

section '.code' code readable executable
	start:
		invoke	LoadLibrary,dllName
			cmp  eax,NULL			;the dll not found
			je   dll_not_found
		invoke	GetProcAddress,eax,funcName
			cmp  eax,NULL			;requested function not found
			je   proc_not_found
			mov  [funcAddr],eax
		invoke	funcAddr,HWND_DESKTOP,msg1
			jmp  exit
		
		dll_not_found:
			invoke	MessageBox,HWND_DESKTOP,msgBoxDll,msgBoxTitle,MB_OK + MB_ICONERROR
				jmp  exit
		proc_not_found:
			invoke	MessageBox,HWND_DESKTOP,msgBoxProc,msgBoxTitle,MB_OK + MB_ICONERROR
				jmp  exit
	exit:
			invoke	ExitProcess,0

section '.idata' import data readable
	library KERNEL32,'KERNEL32.DLL',\
		USER32,  'USER32.DLL'
	
	import	KERNEL32,\
		GetProcAddress, 'GetProcAddress',\
		LoadLibrary,	'LoadLibraryA',\
		ExitProcess,	'ExitProcess'

	import	USER32,\
		MessageBox,	'MessageBoxA'