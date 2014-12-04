format PE GUI
include 'win32ax.inc'
; import data code in the same section
entry start
IDC_EDIT	equ 0
IDC_BUTTON	equ 1
IDC_EXIT	equ 2
IDM_GETTEXT	equ 0
IDM_CLEAR	equ 1
IDM_EXIT	equ 2
	  ; +---------------------------+
	  ; | register the window class |
	  ; +---------------------------+
start: xchg eax,ebx
       invoke DialogBoxParam,400000h,DlgName,ebx,dialog_procedure,ebx
       retn
;experiment variables
     DlgName	 db 'MyDialog',0
     expTxt	 db "Wow! I'm in an edit box now",0
     AppName	 db 'Our First Dialog Box',0
	  ; +----------------------+
	  ; | the dialog procedure |
	  ; +----------------------+
dialog_procedure:
hDlg  equ esp+4
uMsg  equ esp+8
wParam equ esp+0Ch
lParam equ esp+10h
	mov eax,[uMsg]
	mov esi,[hDlg]
	sub eax,WM_CLOSE
	je   wmCLOSE
	sub eax,WM_INITDIALOG-WM_CLOSE
	je   wmINITDIALOG
	dec eax;WM_COMMAND
	jne  a1
wmCOMMAND:  movzx eax,word [wParam]
	cmp [lParam],ebx;0
	jnz short a2
	jmp dword [menu_handlers+eax*4]
a2:	dec eax 	;cmp eax,IDC_BUTTON=1
	jne short a3
	push expTxt
	jmp short a4
a3:	dec eax 	;cmp eax,IDC_EXIT=2
	jne short a1
wmCLOSE:  invoke SendMessage,esi,WM_COMMAND,IDM_EXIT,ebx
	jmp short a1
wmINITDIALOG: invoke GetDlgItem,esi,ebx
	invoke	  SetFocus,eax
	jmp a1
CLEAR:	push ebx
a4:	invoke SetDlgItemText,esi,ebx
	jmp short a1
GETTEXT: sub esp,80
	mov edi,esp
	invoke GetDlgItemText,esi,ebx,edi,80
	invoke MessageBox,ebx,edi,AppName,ebx
	add esp,80
	jmp short a1
EXIT:	invoke EndDialog,esi,ebx
a1:	xor eax,eax
	retn 10h
menu_handlers	dd GETTEXT, CLEAR, EXIT
data import
     library   USER32,	 'USER32.DLL'

     import    USER32,\
	       DialogBoxParam,	   'DialogBoxParamA',\
	       GetDlgItem,	   'GetDlgItem',\
	       EndDialog,	   'EndDialog',\
	       SetFocus,	   'SetFocus',\
	       MessageBox,	   'MessageBoxA',\
	       SetDlgItemText,	   'SetDlgItemTextA',\
	       GetDlgItemText,	   'GetDlgItemTextA',\
	       SendMessage,	   'SendMessageA'
end data
section '.rsrc' resource from 'tut_10-1.res' data readable
