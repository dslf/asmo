;=======================================================================
 format PE GUI 4.0
;=======================================================================
 entry start
;=======================================================================
include 'win32a.inc' ;*
;include 'ENCODING\WIN1251.INC'
;=======================================================================

D_MAIN        = 100
EDIT_1        = 101
EDIT_2        = 102

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
section '.data' data readable writeable
;-----------------------------------------------------------------------
  hInstance dd ?
  txt_buff  rb 520
  ip        rb 16
  host      db 'ya.ru',0  
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
section '.code' code readable executable
;-----------------------------------------------------------------------
  start:

        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,D_MAIN,HWND_DESKTOP,DialogProc,0
        invoke  ExitProcess,0
;=======================================================================
;
;=======================================================================
proc DialogProc hWnd, uMsg, wParam, lParam
;-----------------------------------------------------------------------
        cmp     [uMsg],WM_INITDIALOG
        je      .wminitdialog
        cmp     [uMsg],WM_COMMAND
        je      .wmcommand
        cmp     [uMsg],WM_CLOSE
        je      .wmclose
        xor     eax,eax
        ret
;-----------------------------------------------------------------------
  .wminitdialog:
        jmp     .processed
;-----------------------------------------------------------------------
  .wmcommand:
        cmp     [wParam],IDCANCEL
        je      .wmclose
        cmp     [wParam],IDOK
        jne     .processed
;------------------------------------------------------------\\
        invoke  GetDlgItemText,[hWnd],EDIT_1,txt_buff,256
        invoke  SetDlgItemText,[hWnd],EDIT_2,txt_buff
;------------------------------------------------------------//
        jmp     .processed
;-----------------------------------------------------------------------
  .wmclose:
        invoke  EndDialog,[hWnd],0
;-----------------------------------------------------------------------
  .processed:
        mov     eax,TRUE
;-----------------------------------------------------------------------
  .finish:
        ret
;-----------------------------------------------------------------------
endp
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
include "idata.inc" ;*
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
section '.rsrc' resource data readable
;-----------------------------------------------------------------------
  directory RT_DIALOG,dialogs
;-----------------------------------------------------------------------
  resource dialogs,\
           D_MAIN,LANG_NEUTRAL,d_main
;-----------------------------------------------------------------------
  dialog d_main,'FBASE',0,0,169,44,DS_MODALFRAME+DS_CENTER+WS_POPUP+WS_CAPTION+WS_SYSMENU
    dialogitem "BUTTON","OK",IDOK,110,6,50,14,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON
    dialogitem "BUTTON","Cancel",IDCANCEL,110,23,50,14,WS_VISIBLE+WS_TABSTOP+BS_PUSHBUTTON
    dialogitem "EDIT","",EDIT_1,7,7,90,12,WS_VISIBLE+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL
    dialogitem "EDIT","",EDIT_2,7,24,90,12,WS_VISIBLE+WS_BORDER+WS_TABSTOP+ES_AUTOHSCROLL
  enddialog
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
