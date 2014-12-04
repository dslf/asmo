format PE GUI
include 'win32ax.inc'
; +-----------------------+
; | menu item declaration |
; +-----------------------+
MI_CALCULATE_PRIMARY_THREAD equ    0
MI_EXIT 		    equ    1
WMU_CALCULATE_FINISH	    equ    WM_USER + 0x100

start:	      xchg ebx,eax
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
	      mov    [hWindow],eax
	      invoke  GetMenu,eax;[hWnd]
	      mov     [hMenu],eax
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
hWnd	      equ esp+4
uMsg	      equ esp+8
wParam	      equ esp+0Ch
lParam	      equ esp+10h

	      mov eax,[uMsg]
	      dec eax;cmp [uMsg],WM_DESTROY
	      dec eax
	      je     wmDESTROY
	      sub eax,WM_COMMAND-WM_DESTROY;cmp [uMsg],WM_COMMAND
	      je     wmCOMMAND
	      sub eax,WMU_CALCULATE_FINISH-WM_COMMAND;cmp [uMsg],WMU_CALCULATE_FINISH
	      je     wmuCALCULATE_FINISH
	      jmp [DefWindowProc]
wmuCALCULATE_FINISH: invoke MessageBox,ebx,wTitle,wTitle,ebx
	      jmp    wmBYE
wmCOMMAND:    mov ax,word [wParam]
	      cmp [lParam],ebx
	      jnz wmBYE
	      jmp dword [menu_handlers+eax*4]
wmCOMMAND_MI_CALCULATE_PRIMARY_THREAD: call   calculate_procedure
	      jmp    wmBYE
wmCOMMAND_MI_EXIT: invoke DestroyWindow,dword[hWnd]
wmBYE:	      retn 10h
wmDESTROY:    invoke ExitProcess,ebx
	      ; +------------------+
	      ; | thread procedure |
	      ; +------------------+
proc   calculate_procedure
	      mov    ecx,30000000
loopSTART:    add    eax,eax
	      loop     loopSTART
	      invoke SendMessage,[hWindow],WMU_CALCULATE_FINISH,ebx,ebx
	      retn
endp
menu_handlers dd wmCOMMAND_MI_CALCULATE_PRIMARY_THREAD, wmCOMMAND_MI_EXIT
wTitle	      db     'Iczelion Tutorial 15B: Multithreading Programming',0
hWindow       dd     ?
hMenu	      dd     ?

data import
       library	     KERNEL32,	   'KERNEL32.DLL',\
		     USER32,	   'USER32.DLL'
       import KERNEL32,\
		     CreateThread,	  'CreateThread',\
		     GetExitCodeProcess,  'GetExitCodeProcess',\
		     GetStartupInfo,	  'GetStartupInfoA',\
		     CreateProcess,	  'CreateProcessA',\
		     TerminateProcess,	  'TerminateProcess',\
		     CloseHandle,	  'CloseHandle',\
		     ExitProcess,	  'ExitProcess'
       import USER32,\
		     RegisterClass,	  'RegisterClassA',\
		     CreateWindowEx,	  'CreateWindowExA',\
		     DefWindowProc,	  'DefWindowProcA',\
		     GetMenu,		  'GetMenu',\
		     MessageBox,	  'MessageBoxA',\
		     SendMessage,	  'SendMessageA',\
		     GetMessage,	  'GetMessageA',\
		     DestroyWindow,	  'DestroyWindow',\
		     DispatchMessage,	  'DispatchMessageA'
end data
section '.rsrc' resource data readable
       directory     RT_MENU,appMenu
       resource      appMenu,\
		     30,LANG_NEUTRAL,menuMain
       menu   menuMain
	      menuitem	    '&Process',0,MFR_POPUP + MFR_END
	      menuitem	    '&Calculate in Primary Thread',MI_CALCULATE_PRIMARY_THREAD,0
	      menuseparator
	      menuitem	    'E&xit',MI_EXIT,MFR_END