format PE GUI 4.0
entry start
include 'win32a.inc'
section '.data' data readable writeable
	msg1	db '[code]',13,10
		db '      Invoke DllErrBox,HWND_DESKTOP,msg1',13,10,13,10
		db '      import TUT_17A,\',13,10
		db '      DllErrBox,   ''DllErrBox''',13,10
		db '[/code]',0

section '.code' code readable executable
	start:
		invoke	DllErrBox,HWND_DESKTOP,msg1
		invoke	ExitProcess,0

section '.idata' import data readable
	library KERNEL32,'KERNEL32.DLL',\
		TUT_17A, 'TUT_17A.DLL'
	
	import	KERNEL32,\
		ExitProcess,	'ExitProcess'
	
	import	TUT_17A,\
		DllErrBox,	'DllErrBox'


