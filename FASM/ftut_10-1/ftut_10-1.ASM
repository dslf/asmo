format PE GUI 4.0
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
start: invoke DialogBoxParam,400000h,1,0,dialog_procedure,30
       retn
;experiment variables
     expTxt	 db "Wow! I'm in an edit box now",0
     ;AppName     db '',0
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
	jnz @f
	jmp dword [menu_handlers+eax*4]
@@:	dec eax 	;cmp eax,IDC_BUTTON=1
	jne short @f
	push expTxt
	jmp short a2
@@:	dec eax 	;cmp eax,IDC_EXIT=2
	jne short a1
wmCLOSE:  invoke SendMessage,esi,WM_COMMAND,IDM_EXIT,ebx
	jmp short a1
wmINITDIALOG: invoke GetDlgItem,esi,ebx
	invoke	  SetFocus,eax
	jmp a1
CLEAR:	push ebx
a2:	invoke SetDlgItemText,esi,ebx
	jmp short a1
GETTEXT: sub esp,80
	mov edi,esp
	invoke GetDlgItemText,esi,ebx,edi,80
	invoke MessageBox,ebx,edi,"Our First Dialog Box",ebx
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
section '.rsrc' resource data readable
     directory RT_MENU,appMenu,\
	       RT_DIALOG,dialogs

     resource  appMenu,\
	       30,LANG_NEUTRAL,menuMain

     resource	 dialogs,1,LANG_ENGLISH+SUBLANG_DEFAULT,main
     menu menuMain
	  menuitem  '&Test Controls',10,MFR_POPUP or MFR_END
	  menuitem	 'Say Hello',0,MFT_STRING
	  menuitem	 'Clear Edit Box',1,MFT_STRING
	  menuitem	 'Get Text',2,MFT_STRING
			 menuseparator
	  menuitem	 'E&xit',3,MFR_END
;================================================================================
dialog	    main,'Tutorial 10: Dialog Box as Main Window',10,10,230,60,\
	    0x0004 + DS_CENTER + WS_CAPTION + WS_MINIMIZEBOX + \
WS_SYSMENU + WS_VISIBLE + WS_OVERLAPPED + DS_MODALFRAME + DS_3DLOOK
dialogitem  'EDIT','',0,15,17,111,13,ES_AUTOHSCROLL + ES_LEFT+ WS_VISIBLE + WS_BORDER
dialogitem  'BUTTON','Say Hello',1,141,10,52,13,BS_DEFPUSHBUTTON + WS_VISIBLE
dialogitem  'BUTTON','E&xit',2,141,26,52,13,BS_PUSHBUTTON + WS_VISIBLE

enddialog