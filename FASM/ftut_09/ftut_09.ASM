format PE GUI
include 'win32ax.inc'
; import data in the same section
;controller constant
btnId	  equ  100
editId	  equ  200
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
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi,ebx,ebx
	  mov edi,eax
	  pop esi
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE,editClsName,\
	       ebx,WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL,\
	       50,35,200,25,eax,editId,esi,ebx;dword[hWnd],editId,esi,ebx
	       mov  [editHandle],eax
	       invoke	 SetFocus,eax
	       invoke CreateWindowEx,ebx,btnClsName,btnTxt,\
	       WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
	       75,70,140,25,edi,,btnId,esi,ebx
	       mov  [btnHandle],eax
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
hWnd	equ ebp+8
uMsg	equ ebp+0Ch
wParam	equ ebp+10h
lParam	equ ebp+14h
	       push ebp
	       mov ebp,esp
	       mov eax,[uMsg]
	       dec eax
	       dec eax;cmp [uMsg],WM_DESTROY
	       je wmDESTROY
	       sub eax,WM_COMMAND-WM_DESTROY
	       je   wmCOMMAND
	       leave
	       jmp dword [DefWindowProc]
wmCOMMAND:     mov  eax,[wParam]
	       cmp  dword [lParam],ebx;0
	       je   wmCOMMAND_menu
	       cmp  ax,btnId  ;check whether is button id
	       jne   wmBYE
wmCOMMAND_button: shr  ax,16
	       cmp  ax,0  ;BN_CLICKED = 0
	       jne  wmBYE
button_clicked: invoke	  SendMessage,dword[hWnd],WM_COMMAND,13,0
wmCOMMAND_menu: cmp  ax,11     ;write something to textbox
	       je   menu_writesomething
	       cmp  ax,12     ;clear our textbox
	       je   menu_cleartext
	       cmp  ax,13     ;messagebox our text
	       jne   wmBYE
menu_messagebox: invoke GetWindowText,[editHandle],editBuffer,512
	       invoke MessageBox,NULL,editBuffer,wTitle,MB_OK
	       jmp  wmBYE
menu_writesomething: invoke SetWindowText,[editHandle],editTxt
	       jmp  wmBYE
menu_cleartext: invoke SetWindowText,[editHandle],ebx
wmBYE:	       leave
	       retn 10h
wmDESTROY: invoke ExitProcess,ebx

wTitle	       db   'Iczelion Tutorial 9 : Child Window Controls',0 ;name of our window
     ;controller
btnClsName     db   'button',0
btnTxt	       db   'My First Button',0
editClsName    db   'edit',0
editTxt        db   "Wow! i'm in an edit box now",0
editBuffer:    times 512 db 0
btnHandle      dd   ?
editHandle     dd   ?

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

section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       30,LANG_NEUTRAL,menuMain

     menu menuMain
	  menuitem  '&PopUp',10,MFR_POPUP or MFR_END
	  menuitem	 '&Write Something to Textbox',11,MFT_STRING
	  menuitem	 '&Clear Textbox',12,MFT_STRING
			 menuseparator
	  menuitem	 '&MessageBox my text',13,MFR_END
