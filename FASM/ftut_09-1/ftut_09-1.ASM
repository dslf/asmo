format PE GUI
include 'win32ax.inc'
; import data code in the same section
ButtonID	equ 1
EditID		equ 2
IDM_HELLO	equ 0
IDM_CLEAR	equ 1
IDM_GETTEXT	equ 2
IDM_EXIT	equ 3
;=======================================================
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_BTNFACE+1,30,edi,esi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  push ebx
	  push ebx
	  shl esi,9
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,390,200
	  mov edi,eax
	  pop esi; mov esi,hInstance;400000h
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE,EditClassName,ebx,\
	  WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,\
	  50,35,200,25,edi,EditID,esi,ebx
	  mov [hwndEdit],eax
	  invoke SetFocus,eax
	  invoke CreateWindowEx,ebx,ButtonClassName,ButtonText,\
	  WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,75,70,140,25,edi,\
	  ButtonID,esi,ebx
	  mov ebp,esp
	  ; +---------------------------+
	  ; | entering the message loop |
	  ; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke TranslateMessage,ebp
	  invoke DispatchMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
window_procedure:
hWnd	equ esp+4
uMsg	equ esp+8
wParam	equ esp+0Ch
lParam	equ esp+10h
	mov eax,[uMsg]
	dec eax; cmp uMsg,WM_CREATE
	dec eax; cmp uMsg,WM_DESTROY
	je wmDESTROY
	sub eax,WM_COMMAND-WM_DESTROY;cmp eax,WM_COMMAND=111h
	je wmCOMMAND
	jmp [DefWindowProc]   ;направл€ютс€ на обработку по умолчанию
wmDESTROY: invoke ExitProcess,ebx ;завершение программы
wmCOMMAND: movzx eax,word [wParam]
	cmp [lParam],ebx;0
	jnz a2
	mov esi,[hwndEdit]
	lea edi,[SetWindowText]
	jmp dword [menu_handlers+eax*4]
a2:	dec eax 	;cmp ax,ButtonID where ButtonID=1
	jne wmBye
	mov eax,[hWnd]
	push ebx
	push IDM_GETTEXT
	push WM_COMMAND
	push eax
	jmp a3
HELLO:	push  TestString
	push esi	;hwndEdit
	call dword[edi];[SetWindowText]
	push ebx
	push VK_END
	push WM_KEYDOWN
	push esi	;hwndEdit
a3:	call [SendMessage]
	jmp wmBye
CLEAR:	push ebx
	push esi	;hwndEdit
	call dword[edi];SetWindowText
	jmp wmBye
GETTEXT:sub esp,92
	mov ebp,esp;&buffer
	invoke GetWindowText,esi,ebp,92
	invoke MessageBox,ebx,ebp,MenuName,ebx
	add esp,92
wmBye:	retn 10h

menu_handlers	dd HELLO, CLEAR, GETTEXT, wmDESTROY;, EXIT
wTitle	    db '9-1:—оздание кнопки и окна редактировани€',0
MenuName	db "FirstMenu",0
ButtonClassName db "button",0
ButtonText	db "Get Text",0
EditClassName	db "edit",0
TestString	db "Wow! I'm in an edit box now",0
hwndEdit	dd ?
section '.idata' import data readable writeable
     library   KERNEL32, 'KERNEL32.DLL',\
	       USER32,	 'USER32.DLL'

     import    KERNEL32,\
	       ExitProcess,	   'ExitProcess'

     import    USER32,\
	       RegisterClass,	   'RegisterClassA',\
	       CreateWindowEx,	   'CreateWindowExA',\
	       DefWindowProc,	   'DefWindowProcA',\
	       SetFocus,	   'SetFocus',\
	       SetWindowText,	   'SetWindowTextA',\
	       GetWindowText,	   'GetWindowTextA',\
	       GetMessage,	   'GetMessageA',\
	       SendMessage,	   'SendMessageA',\
	       MessageBox,	   'MessageBoxA',\
	       TranslateMessage,   'TranslateMessage',\
	       DispatchMessage,    'DispatchMessageA'

;section '.rsrc' resource from 'ftut_09-1.res' data readable
section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       30,LANG_NEUTRAL,menuMain

     menu menuMain
	  menuitem  '&Test Controls',10,MFR_POPUP or MFR_END
	  menuitem	 'Say Hello',0,MFT_STRING
	  menuitem	 'Clear Edit Box',1,MFT_STRING
	  menuitem	 'Get Text',2,MFT_STRING
			 menuseparator
	  menuitem	 'E&xit',3,MFR_END