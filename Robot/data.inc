section '.data' data readable writeable

szFriendlyName	db "FASM template Add-In",0
szDescription	db "Template WinAsm Add-In, written in FASM.",0

;=======================================================================

align 4

hInstance		dd ?	;DLL instance
hMain			dd ?
pHandles		dd ?
MenuID			dd ?
