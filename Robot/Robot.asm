format PE GUI 4.0 DLL
entry DllEntry

include 'win32a.inc' ;*
include 'win32.inc'  ;*
include '%ASMHOME%winasm\inc\WAAddInFasm.inc' ;*

section '.code' code readable executable

;proc FrameWindowProc, hWnd, uMsg, wParam, lParam
;
;    xor eax,eax
;    ret
;endp

;proc ChildWindowProc, hWnd, uMsg, wParam, lParam
;
;    xor eax,eax
;    ret
;endp

;proc ProjectExplorerProc, hWnd, uMsg, wParam, lParam
;
;    xor eax,eax
;    ret
;endp

;proc OutWindowProc, hWnd, uMsg, wParam, lParam
;
;    xor eax,eax
;    ret
;endp

proc WAAddInLoad, pWinAsmHandles, features

    xor eax,eax
    ret
endp

WAAddInUnload:
    ret

;proc WAAddInConfig, pWinAsmHandles, features
;
;    xor eax,eax
;    ret
;endp

;================================================

proc DllEntry, hInst, reason, reserved1
    cmp [reason],DLL_PROCESS_ATTACH
    jne @F
    mov eax,[hInst]
    mov [hInstance],eax
@@:
    mov eax,TRUE		       ; successful initialization
    ret
endp

proc GetWAAddInData, lpFriendlyName, lpDescription
    invoke lstrcpy, [lpDescription],  szDescription
    invoke lstrcpy, [lpFriendlyName], szFriendlyName	  ; Name of Add-In
    ret
endp

;================================================

include 'data.inc'
include 'idata.inc'
include 'edata.inc'

section '.reloc' fixups data readable discardable
