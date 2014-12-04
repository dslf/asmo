;=======================================================================
format PE GUI 4.0
;=======================================================================
include 'win32a.inc'    ;*
include 'rc.inc'        ;*
;=======================================================================
section '.code' code readable executable

entry $

    invoke GetModuleHandle,0
    mov [hInstance],eax
    invoke DialogBoxParam,eax,D_MAIN,0,dlg_proc,0
    invoke ExitProcess,0

;=======================================================================
proc dlg_proc, hWnd, uMsg, wParam, lParam
    cmp [uMsg],WM_CLOSE
    jne @F
.end_dlg:
    invoke EndDialog,[hWnd],0
.exit_true:
    mov eax,TRUE
    ret
@@:
;-----------------------------------------------------------------------
;    cmp [uMsg],WM_INITDIALOG
;    jne @F
;
;    jmp .exit_true
;@@:    
;-----------------------------------------------------------------------
;    cmp [uMsg],?? << add new message
;    jne @F
;    
;    jmp .exit_true
;@@:    
;-----------------------------------------------------------------------
    cmp [uMsg],WM_COMMAND
    jne .exit_false
    cmp [wParam],B_CAN
    je .end_dlg
;-----------------------------------------------------------------------
    cmp [wParam],B_OK
    jne @F
    invoke MessageBox, 0, 'lol', 'nou', MB_OK
    ;-------------------------------------------------------------------
    ;   TODO: Place your code here to be executed when OK pressed   
    ;-------------------------------------------------------------------
    jmp .exit_true
@@:
;-----------------------------------------------------------------------
;    cmp [wParam],?? ; << add new command
;    jne @F
;    jmp .exit_true
;@@:
;-----------------------------------------------------------------------
.exit_false:
    xor eax,eax
    ret
endp
;=======================================================================

;=======================================================================
include 'idata.inc'
include  'data.inc'
;=======================================================================
section '.rsrc' resource data readable
;-----------------------------------------------------------------------
  directory RT_DIALOG,dialogs

;-----------------------------------------------------------------------
include "dialogs.tab"
;-----------------------------------------------------------------------
include "dialogs.dat"
;=======================================================================


