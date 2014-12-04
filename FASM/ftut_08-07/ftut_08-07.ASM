format PE GUI 4.0
include 'win32ax.inc'
; import data in the same section
ZZZ_TEST equ 0
ZZZ_OPEN equ 1
ZZZ_SAVE equ 2
ZZZ_EXIT equ 3
TBSTYLE_BUTTON	equ 00h
TBSTYLE_SEP	equ 01h
TBSTYLE_CHECK	equ 02h
TBSTYLE_GROUP	equ 04h
TBSTYLE_CHECKGROUP equ TBSTYLE_GROUP OR TBSTYLE_CHECK
TBSTYLE_TOOLTIPS equ 0100h
TBSTYLE_WRAPABLE equ 0200h
TBSTYLE_ALTDRAG  equ 0400h
TBSTYLE_FLAT	 equ 0800h
TBSTYLE_LIST	 equ 1000h
TBSTYLE_CUSTOMERASE		 equ 2000h
TBSTYLE_REGISTERDROP		 equ 4000h
TBSTYLE_TRANSPARENT		 equ 8000h
TBSTYLE_DROPDOWN	equ 0008h
TBSTYLE_NOPREFIX	equ 0020h
TBSTYLE_EX_DRAWDDARROWS equ 00000001h
TBSTYLE_EX_MIXEDBUTTONS        equ 00000008h
TBSTYLE_EX_HIDECLIPPEDBUTTONS  equ 00000010h
TBSTYLE_AUTOSIZE equ 10h
BTNS_BUTTON		equ TBSTYLE_BUTTON
BTNS_SEP		equ TBSTYLE_SEP
BTNS_CHECK		equ TBSTYLE_CHECK
BTNS_GROUP		equ TBSTYLE_GROUP
BTNS_CHECKGROUP 	equ TBSTYLE_CHECKGROUP
BTNS_DROPDOWN		equ TBSTYLE_DROPDOWN
BTNS_AUTOSIZE		equ TBSTYLE_AUTOSIZE
BTNS_NOPREFIX		equ TBSTYLE_NOPREFIX
BTNS_WHOLEDROPDOWN	equ 0080h	    ; draw drop-down arrow, but without split arrow section
I_IMAGENONE equ -2
;=========================================================
	xchg ebx,eax
	sub esp,sizeof.INITCOMMONCONTROLSEX
	mov [esp+INITCOMMONCONTROLSEX.dwSize],sizeof.INITCOMMONCONTROLSEX
	mov [esp+INITCOMMONCONTROLSEX.dwICC],ICC_BAR_CLASSES
	invoke InitCommonControlsEx,esp
	add esp,sizeof.INITCOMMONCONTROLSEX
	invoke GlobalAlloc,40h,\  ; uFlags
			   1024  ; memory buffer size
	xchg esi,eax
	mov edi, esi
	mov dword [edi],WS_OVERLAPPED+WS_SYSMENU+DS_CENTER+40h
	mov word [edi+8],1	  ; number of controls
	mov word [edi+0Ah],50 ; x y co-ordinates
	mov word [edi+0Ch],50
	mov word [edi+0Eh],230
	mov word [edi+10h],100
	add edi, 16h
	invoke MultiByteToWideChar,ebx,\  ;CodePage=0
				   1,\	  ;dwFlags
				   wTitle,\ ;caption
				   -1,\   ;cchMultiByte
				   edi,\  ;lpWideCharStr
				   aMsSansSerif-wTitle	      ;cchWideChar
	add edi,(aMsSansSerif-wTitle)*2; 1Ah
	mov word [edi],10 ;pointsize
	inc edi;add edi, 2
	inc edi
	invoke MultiByteToWideChar,ebx,\    ; CodePage=0
				   1,\	    ; dwFlags
				   aMsSansSerif,\ ; font
				   -1,\     ; cchMultiByte
				   edi,\    ; lpWideCharStr
				   aMsctls_statusb-aMsSansSerif; cchWideChar
	add edi,(aMsctls_statusb-aMsSansSerif)*2+4-1
	and edi,-4 ;align 4 = add edi,4-1 /and edi,-4
	mov	dword [edi], 50000000h
	mov	word [edi+10h],150  ;DlgStatus=150
	add	edi, 12h
	invoke MultiByteToWideChar,ebx,\	    ; CodePage=0
				   1,\		    ; dwFlags
				   aMsctls_statusb,\; lpMultiByteStr
				   -1,\      ; cchMultiByte
				   edi,\	     ; lpWideCharStr
				   aToolbarwindow3-aMsctls_statusb   ; cchWideChar
	invoke DialogBoxIndirectParam,400000h,\    ; hInstance
				       esi,\	    ; hDialogTemplate
				       ebx,\	    ; hWndParent= 0
				       DialogFunc,\ ; lpDialogFunc
				       ebx	    ; dwInitParam=0
	invoke GlobalFree,esi		  ; hMem
	retn
;==================================================================
proc DialogFunc hDlg:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	xor ebx,ebx
	mov eax,[uMsg]
	mov edi,[hDlg]
	sub eax,WM_CLOSE ;cmp uMsg,10h
	jz wmCLOSE
	sub eax,WM_INITDIALOG-WM_CLOSE;cmp uMsg,110h
	jz wmINITDIALOG
	dec eax 	;cmp uMsg,111h
	jnz wmBye
wmCOMMAND: mov ebx,[wParam]
	cmp ebx,ZZZ_EXIT;03
	je wmCLOSE;menu_exit
show_msg: invoke MessageBox,edi,[menu_handlers+ebx*4],menu_name,eax
	jmp short wmBye
wmINITDIALOG: lea esi,dword [SendMessage]
	push ebx	     ;hIcon
	push 1		     
	push -128;WM_SETICON
	push edi;      ; hDlg
	call dword [esi];SendMessageA
	invoke GetStockObject,SYSTEM_FIXED_FONT
	push TRUE;1               
	push eax	;hFont
	push WM_SETFONT;30h             
	push edi      ; hWndParent
	call text_bar
	push eax	;hToolbar
	call dword [esi];SendMessageA
	jmp short wmBye
;---------------------------------------------------------------------------
wmCLOSE: invoke EndDialog,edi,ebx
wmBye:	xchg eax,ebx
	leave
	retn	10h
endp
;-------------------------------------------------------------
text_bar: invoke CreateWindowEx,ebx,aToolbarwindow3,ebx,WS_CHILD+WS_VISIBLE+\
	TBSTYLE_TOOLTIPS+TBSTYLE_FLAT+TBSTYLE_LIST+TBSTYLE_TRANSPARENT,ebx,ebx,\
	500,20,dword [esp+10h],ebx,400000h,ebx
	mov edi,eax;edi:=[TBhWnd]
	push ebx;0               
	push sizeof.TBBUTTON;14h
	push TB_BUTTONSTRUCTSIZE;41Eh    
	push eax;TBhWnd      
	call dword [esi]

	push ebx;0               
	push 5		     
	push TB_SETINDENT;42Fh
	push dword edi
	call dword [esi]

	;esp=&tbb
	sub esp,sizeof.TBBUTTON;создаем буфер под структуру TBBUTTON
	mov [esp+TBBUTTON.iBitmap],I_IMAGENONE;dword [edi],-2
	mov [esp+TBBUTTON.dwData],ebx
	mov [esp+TBBUTTON.iString],ebx
	mov [esp+TBBUTTON.fsStyle],BTNS_BUTTON or BTNS_AUTOSIZE;byte [edi+9],10h;
	mov [esp+TBBUTTON.fsState],TBSTATE_ENABLED
;TxtItem  0,  0, "Test"
	mov [esp+TBBUTTON.idCommand],ebx ;0
	push esp	     ; &tbb
	push 1		     ; wParam
	push TB_ADDBUTTONS;414h
	push edi      ; hWnd
	call dword [esi]
	push aTest
	push ebx;0
	push TB_ADDSTRING;41Ch
	push edi
	call dword [esi]
;TxtItem  1,  1, "Open"
	inc [esp+TBBUTTON.idCommand]
	inc [esp+TBBUTTON.iString]
	push esp	     ; &tbb
	push 1		     ; wParam
	push TB_ADDBUTTONS;414h            ; Msg
	push edi      ; hWnd
	call dword [esi]
	push aOpen
	push ebx;0               ; wParam
	push TB_ADDSTRING;41Ch            ; Msg
	push edi      ; hWnd
	call dword [esi]
;TxtItem  2,  2, "Save"
	inc [esp+TBBUTTON.idCommand]
	inc [esp+TBBUTTON.iString]
	push esp	     ; &tbb
	push 1		     ; wParam
	push TB_ADDBUTTONS;414h            ; Msg
	push edi      ; hWnd
	call dword [esi]
	push aSave
	push ebx;0               ; wParam
	push TB_ADDSTRING;41Ch            ; Msg
	push edi      ; hWnd
	call dword [esi]
;TxtSeperator
	mov [esp+TBBUTTON.idCommand],ebx; 0
	mov [esp+TBBUTTON.fsStyle],BTNS_SEP;byte [edi+9],1;
	push esp	     ; &tbb
	push 1		     ; wParam
	push TB_ADDBUTTONS;414h            ; Msg
	push edi      ; hWnd
	call dword [esi]
;TxtItem  4,  3, "Exit"
	add [esp+TBBUTTON.idCommand], 3h
	mov [esp+TBBUTTON.fsStyle],BTNS_BUTTON or BTNS_AUTOSIZE
	inc [esp+TBBUTTON.iString]
	push esp	     ; &tbb
	push 1		     ; wParam
	push TB_ADDBUTTONS;414h            ; Msg
	push edi      ; hWnd
	call dword [esi]
	push aExit    ;
	push ebx;0               ; wParam
	push TB_ADDSTRING;41Ch            ; Msg
	push edi      ; hWnd
	call dword [esi]
	mov eax,edi
	add esp,sizeof.TBBUTTON;уничтожаем буфер
	retn	4
;----------------------------------------
wTitle db 'Iczelion Tutorial #8-7:Иммитация меню через toolbar в FASM',0 ;name of our window
aMsSansSerif	db	'MS Sans Serif',0
aMsctls_statusb db	'msctls_statusbar32',0
aToolbarwindow3 db	'ToolbarWindow32',0  
aTest  db    'Test',0
aOpen  db    'Open',0
aSave  db    'Save',0
aExit  db    'Exit',0
     ;exp = experiment
menu_name db 'ZZZ_Menu',0
test_msg  db 'You select menu item TEST',0
open_msg  db 'You select menu item OPEN',0
save_msg  db 'You select menu item SAVE',0
menu_handlers dd test_msg, open_msg, save_msg


data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 gdi32,    'gdi32.dll',\
	 comctl32, 'comctl32.dll'
 import KERNEL32,\
	       GlobalAlloc,	   'GlobalAlloc',\
	       MultiByteToWideChar,'MultiByteToWideChar',\
	       GlobalFree,	   'GlobalFree'
 import user32,\
		DialogBoxIndirectParam,'DialogBoxIndirectParamA',\
		LoadIcon,	    'LoadIconA',\
		EndDialog,	    'EndDialog',\
		SendMessage,	    'SendMessageA',\
		CreateWindowEx,     'CreateWindowExA',\
		MessageBox,	    'MessageBoxA'
  import gdi32,\
		GetStockObject,     'GetStockObject'
  import comctl32,\
		InitCommonControlsEx, 'InitCommonControlsEx'

end data





