format PE GUI
include 'win32ax.inc'
; +-----------------------+
; | menu item declaration |
; +-----------------------+
MI_THREAD_CREATE     equ    0
MI_EXIT 	     equ    1

WMU_THREAD_FINISH    equ    WM_USER + 0x100


start:	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
		; +------------------------------+
		; | registering the window class |
		; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,30,edi
	      ; +--------------------------+
	      ; | creating the main window |
	      ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,450,200,ebx,ebx
	  mov	 [hWindow],eax
	  invoke  GetMenu,eax;[hWnd]
	  mov	  [hMenu],eax
	  mov ebp,esp
	      ; +---------------------------+
	      ; | entering the message loop |
	      ; +---------------------------+
message_loop: invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke DispatchMessage,ebp
	  jmp message_loop
	      ; +----------------------+
	      ; | the window procedure |
	      ; +----------------------+
window_procedure:
hWnd		equ esp+4;8h
uMsg		equ esp+8;0Ch
wParam		equ esp+0Ch;10h
lParam		equ esp+10h;4h
		     mov eax,[uMsg]
		     dec eax
		     dec eax;cmp    [uMsg],WM_DESTROY
		     je     wmDESTROY
		     sub eax,WM_COMMAND-WM_DESTROY;cmp    [uMsg],WM_COMMAND
		     je     wmCOMMAND
		     sub eax,WMU_THREAD_FINISH-WM_COMMAND;cmp    [uMsg],WMU_THREAD_FINISH
		     je     wmuTHREAD_FINISH
		     jmp [DefWindowProc]

wmuTHREAD_FINISH:    invoke MessageBox,ebx,wTitle,wTitle,ebx;MB_OK
		     jmp    wmBYE

wmCOMMAND:	     movzx eax,word [wParam]
		     cmp [lParam],ebx
		     jnz wmBYE
		     jmp dword [menu_handlers+eax*4]
		     
wmCOMMAND_MI_THREAD_CREATE: invoke CreateThread,ebx,ebx,thread_procedure,ebx,NORMAL_PRIORITY_CLASS,tId
		     invoke CloseHandle,eax
		     jmp    wmBYE
		     
wmCOMMAND_MI_EXIT:   invoke DestroyWindow,dword[hWnd]
wmBYE:		     retn 10h
wmDESTROY:	     invoke ExitProcess,ebx

	      ; +------------------+
	      ; | thread procedure |
	      ; +------------------+
proc   thread_procedure
		     mov    ecx,30000000
loopSTART:	     add    eax,eax
		     loop    loopSTART
		     invoke SendMessage,[hWindow],WMU_THREAD_FINISH,ebx,ebx
		     retn
endp

menu_handlers dd wmCOMMAND_MI_THREAD_CREATE,wmCOMMAND_MI_EXIT
wTitle db 'Iczelion Tutorial 15A: Multithreading Programming',0
hMenu	      dd     ?
tId	      dd     ?
hWindow       dd     ?

data import
       library	     KERNEL32,	   'KERNEL32.DLL',\
		     USER32,	   'USER32.DLL'

       import KERNEL32,\
		     CreateThread,	  'CreateThread',\
		     CloseHandle,	  'CloseHandle',\
		     ExitProcess,	  'ExitProcess'

       import USER32,\
		     RegisterClass,	  'RegisterClassA',\
		     CreateWindowEx,	  'CreateWindowExA',\
		     DefWindowProc,	  'DefWindowProcA',\
		     DestroyWindow,	  'DestroyWindow',\
		     GetMenu,		  'GetMenu',\
		     MessageBox,	  'MessageBoxA',\
		     SendMessage,	  'SendMessageA',\
		     GetMessage,	  'GetMessageA',\
		     DispatchMessage,	  'DispatchMessageA'
end data
section '.rsrc' resource data readable
       directory     RT_MENU,appMenu
       
       resource      appMenu,\
		     30,LANG_NEUTRAL,menuMain

       menu   menuMain
	      menuitem	    '&Process',0,MFR_POPUP + MFR_END
	      menuitem		   '&Create Thread',MI_THREAD_CREATE,0
				   menuseparator
	      menuitem		   'E&xit',MI_EXIT,MFR_END
