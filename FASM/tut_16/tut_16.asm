format PE GUI
include 'win32ax.inc'
; +-----------------------+
; | menu item declaration |
; +-----------------------+
MI_THREAD_RUN	     equ    0
MI_THREAD_STOP	     equ    1
MI_EXIT 	     equ    2

WMU_THREAD_FINISH    equ    WM_USER + 0x100

INFINITE	     equ    0xFFFFFFFF

start:		xchg ebx,eax
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
		push ebx
		push ebx
		shl esi,9
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
		esi,esi,300,200
		mov    [hWindow],eax
		invoke	GetMenu,eax;[hWnd]
		mov	[hMenu],eax
		mov ebp,esp
		; +---------------------------+
		; | entering the message loop |
		; +---------------------------+
message_loop:	invoke GetMessage,ebp,ebx,ebx,ebx
		invoke DispatchMessage,ebp
		jmp message_loop
	      ; +----------------------+
	      ; | the window procedure |
	      ; +----------------------+
window_procedure:
hWnd		equ esp+4
uMsg		equ esp+8
wParam		equ esp+0Ch
lParam		equ esp+10h
		     mov eax,[uMsg]
		     mov esi,[hMenu]
		     dec eax;cmp    [uMsg],WM_CREATE
		     je wmCREATE
		     dec eax;cmp    [uMsg],WM_DESTROY
		     je     wmDESTROY
		     sub eax,WM_COMMAND-WM_DESTROY;cmp    [uMsg],WM_COMMAND
		     je     wmCOMMAND
		     sub eax,WMU_THREAD_FINISH-WM_COMMAND;cmp    [uMsg],WMU_THREAD_FINISH
		     je     wmuTHREAD_FINISH
		     jmp [DefWindowProc]
wmuTHREAD_FINISH:    invoke MessageBox,ebx,info1,wTitle,ebx
		     jmp    wmBYE

wmCREATE:	     invoke CreateEvent,ebx,ebx,ebx,ebx
		     mov    [hEvent],eax
		     mov    eax,thread_procedure
		     invoke CreateThread,ebx,ebx,eax,ebx,NORMAL_PRIORITY_CLASS,tId
		     invoke CloseHandle,eax
		     jmp    wmBYE
		     
wmCOMMAND:	     movzx eax,word [wParam]
		     cmp [lParam],ebx
		     jnz wmBYE
		     jmp dword [menu_handlers+eax*4]
		     
wmCOMMAND_MI_THREAD_RUN:    invoke SetEvent,[hEvent]
			    push ebx;MF_ENABLED
			    push MF_GRAYED
			    jmp    a2

wmCOMMAND_MI_THREAD_STOP:   or	  [tEventState],1      ;stop
			    push MF_GRAYED
			    push ebx;MF_ENABLED
a2:			    invoke EnableMenuItem,esi,ebx;MI_THREAD_RUN
			    invoke EnableMenuItem,esi,MI_THREAD_STOP
			    jmp    wmBYE

wmCOMMAND_MI_EXIT:	    invoke DestroyWindow,dword[hWnd]
wmBYE:			    retn 10h

wmDESTROY:		    invoke ExitProcess,ebx
menu_handlers dd wmCOMMAND_MI_THREAD_RUN,wmCOMMAND_MI_THREAD_STOP,wmCOMMAND_MI_EXIT

	      ; +------------------+
	      ; | thread procedure |
	      ; +------------------+
proc   thread_procedure
		     invoke WaitForSingleObject,[hEvent],INFINITE
		     or    ecx,0FFFFFFh
loopINIT:	     cmp    [tEventState],ebx	   ;runnable
		     jne    b2
		     add    eax,eax
		     loop loopINIT
		     invoke PostMessage,[hWindow],WMU_THREAD_FINISH,ebx,ebx
		     invoke EnableMenuItem,[hMenu],ebx,ebx;MI_THREAD_RUN,MF_ENABLED
		     invoke EnableMenuItem,[hMenu],MI_THREAD_STOP,MF_GRAYED
		     jmp    thread_procedure
b2:		     invoke MessageBox,[hWindow],info2,wTitle,ebx;MB_OK
		     mov    [tEventState],ebx;runnable
		     jmp    thread_procedure
		     retn
endp

       wTitle	     db     'Iczelion Tutorial 16: Event Object',0
       hWindow	     dd     ?
       hMenu	     dd     ?
       hThread	     dd     ?
       hEvent	     dd     ?
       
       tId	     dd     ?	   ;thread id
       tEventState   dd     0	   ;thread event state, 0 = runnable, 1 = stop
       
       info1	     db     'The Calculation is Completed!',0
       info2	     db     'The Thread is Stop!',0

data import
       library	     KERNEL32,	   'KERNEL32.DLL',\
		     USER32,	   'USER32.DLL'

       import KERNEL32,\
		     CreateThread,	  'CreateThread',\
		     CloseHandle,	  'CloseHandle',\
		     CreateEvent,	  'CreateEventA',\
		     SetEvent,		  'SetEvent',\
		     WaitForSingleObject, 'WaitForSingleObject',\
		     ExitProcess,	  'ExitProcess'

       import USER32,\
		     RegisterClass,	  'RegisterClassA',\
		     CreateWindowEx,	  'CreateWindowExA',\
		     DefWindowProc,	  'DefWindowProcA',\
		     GetMenu,		  'GetMenu',\
		     EnableMenuItem,	  'EnableMenuItem',\
		     MessageBox,	  'MessageBoxA',\
		     PostMessage,	  'PostMessageA',\
		     GetMessage,	  'GetMessageA',\
		     DestroyWindow,	  'DestroyWindow',\
		     DispatchMessage,	  'DispatchMessageA'
end data
section '.rsrc' resource data readable
       directory     RT_MENU,appMenu
       
       resource      appMenu,\
		     30,LANG_NEUTRAL,menuMain

       menu   menuMain
	      menuitem	    '&Thread',0,MFR_POPUP + MFR_END
	      menuitem		   '&Run Thread',MI_THREAD_RUN
	      menuitem		  '&Stop Thread',MI_THREAD_STOP,,MF_GRAYED
				   menuseparator
	      menuitem		   'E&xit',MI_EXIT,MFR_END