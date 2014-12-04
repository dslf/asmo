format PE GUI
include 'win32ax.inc'
IDM_EXIT	equ 1
IDM_ABOUT	equ 2
IDC_EDIT	equ 0
IDC_BUTTON	equ 32
IDC_EXIT	equ 31

start:	  xchg ebx,eax
	  mov edi,AppName
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,MenuName,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  push ebx
	  push ebx
	  shl esi,9
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi
	  mov ebp,esp
	  ; +---------------------------+
	  ; | entering the message loop |
	  ; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  cmp [hwndDlg],ebx
	  jz a6
	  push ebp
	  push [hwndDlg]
	  call [IsDialogMessage]
	  test eax,eax
	  jnz message_loop
a6:	  invoke TranslateMessage,ebp
	  invoke DispatchMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
;ClassName db "SimpleWinClass",0
AppName  db "Our Main Window",0
MenuName db "FirstMenu",0
DlgName db "MyDialog",0
TestString db "Hello, everybody",0
hwndDlg dd 0		; Handle to the dialog box

window_procedure:
hWnd	equ esp+4h
uMsg	equ esp+8h
wParam	equ esp+0Ch
lParam	equ esp+10h
	       mov eax,[uMsg]
	       mov edi,[hWnd]
	       dec eax
	       dec eax;cmp  [uMsg],WM_DESTROY
	       je   wmDESTROY
	       sub eax,WM_COMMAND-WM_DESTROY
	       je   wmCOMMAND
	       jmp  [DefWindowProc]

wmDESTROY:     invoke ExitProcess,ebx

wmCOMMAND: mov eax,[wParam]
	cmp ax,IDM_ABOUT
	jnz short a2
	invoke CreateDialogParam,400000h,DlgName,edi,DlgProc,ebx
	mov [hwndDlg],eax
	jmp short a1
a2:	invoke DestroyWindow,edi;hwnd
a1:	retn 10h

DlgProc:
hWnd	equ esp+4h
iMsg	equ esp+8h
wParam	equ esp+0Ch
lParam	equ esp+10h
	;enter 0,0
	mov edi,[hWnd]
	mov eax,[iMsg]
	sub eax,WM_CLOSE	     ;cmp eax,WM_CLOSE=10h
	je wmCLOSE
	sub eax,WM_INITDIALOG-WM_CLOSE		  ;cmp eax,WM_INITDIALOG=110h
	je short wmINITDIALOG
	dec eax 		;cmp eax,WM_COMMAND=111h
	jne short a3
@@WM_COMMAND: movzx eax,word [wParam+2]
	test eax,eax
	jnz short a16
	mov eax,[wParam]
	sub eax,IDC_EXIT	;wParam=IDC_EXIT
	jne short a4
	invoke SendMessage,edi,WM_CLOSE,ebx,ebx
	jmp short a16
a4:	invoke SetDlgItemText,edi,ebx,TestString
	jmp short a16
wmINITDIALOG: invoke GetDlgItem,edi,ebx
	invoke SetFocus,eax
	jmp short a3
wmCLOSE: invoke EndDialog,edi,eax
	mov [hwndDlg],ebx
a3:	xor eax,eax
a16:	retn 10h

data import
     library   KERNEL32, 'KERNEL32.DLL',\
	       USER32,	 'USER32.DLL'

     import    KERNEL32,\
	       ExitProcess,	   'ExitProcess'

     import    USER32,\
	       RegisterClass,	   'RegisterClassA',\
	       CreateWindowEx,	   'CreateWindowExA',\
	       DefWindowProc,	   'DefWindowProcA',\
	       MessageBox,	   'MessageBoxA',\
	       GetMessage,	   'GetMessageA',\
	       DestroyWindow,	   'DestroyWindow',\
	       TranslateMessage,   'TranslateMessage',\
	       DispatchMessage,    'DispatchMessageA',\
	       IsDialogMessage,    'IsDialogMessageA',\
	       CreateDialogParam,  'CreateDialogParamA',\
	       SendMessage,	   'SendMessageA',\
	       SetDlgItemText,	   'SetDlgItemTextA',\
	       GetDlgItem,	   'GetDlgItem',\
	       SetFocus,	   'SetFocus',\
	       EndDialog,	   'EndDialog'

end data
section '.rsrc' resource from 'tut_11-1.res' data readable

