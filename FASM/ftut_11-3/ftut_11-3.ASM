format PE GUI
include 'win32ax.inc'
MI_OPEN   equ  1
MI_EXIT   equ  2
MAXSIZE 	equ 260
OUTPUTSIZE	equ 512

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
	  invoke DispatchMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
window_procedure:
hWnd	equ ebp+8h
uMsg	equ ebp+0Ch
wParam	equ ebp+10h
lParam	equ ebp+14h
	       enter MAXSIZE,0
	       mov eax,[uMsg]
	       mov ebx,[hWnd]
	       lea esi,[dlgOpenOfn]
	       dec eax
	       je   wmCREATE
	       dec eax;cmp  [uMsg],WM_DESTROY
	       je   wmDESTROY
	       sub eax,WM_COMMAND-WM_DESTROY;cmp  [uMsg],WM_COMMAND
	       je   wmCOMMAND
	       leave
	       jmp [DefWindowProc]
wmCOMMAND:     mov ecx,OUTPUTSIZE/4
	       mov edi,strMsg
	       rep stosd;invoke    RtlZeroMemory,strMsg,OUTPUTSIZE
	       mov eax,[wParam]
	       dec ax	       ;cmp ax,IDM_OPEN=1
	       jnz short a2
	       push esi
	       call [GetOpenFileName]
	       xchg eax,ecx
	       jecxz wmBYE
	       mov ecx,OUTPUTSIZE
	       lea edi,[strMsg]
	       mov esi,FullPathName
	       call StringOut1
	       mov esi,[dlgOpenOfn.lpstrFile]
	       call StringOut1
	       mov esi,FullName
	       call StringOut1
	       movzx esi,[dlgOpenOfn.nFileOffset]
	       add esi,[dlgOpenOfn.lpstrFile]
	       call StringOut1
	       mov esi, ExtensionName
	       call StringOut1
	       movzx esi,[dlgOpenOfn.nFileExtension]
	       add esi,[dlgOpenOfn.lpstrFile]
	       call StringOut1
	       push 0
	       push wTitle
	       push strMsg
	       push ebx;dword[hWnd]
	       call [MessageBox]
	       jmp   wmBYE
a2:	       invoke DestroyWindow,ebx;dword[hWnd]
wmBYE:	       leave
	       retn 10h
wmCREATE:      mov  [esi+OPENFILENAME.lStructSize],sizeof.OPENFILENAME
	       mov  [esi+OPENFILENAME.hwndOwner],ebx;[hWnd]
	       mov  [esi+OPENFILENAME.hInstance],400000h
	       mov  [esi+OPENFILENAME.lpstrFilter],dlgOpenFilter
	       mov  [esi+OPENFILENAME.lpstrFile],esp;dlgOpenBuffer
	       mov  [esi+OPENFILENAME.nMaxFile],256
	       mov  [esi+OPENFILENAME.Flags],OFN_FILEMUSTEXIST or\
	       OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
	       OFN_EXPLORER or OFN_HIDEREADONLY
	       jmp  wmBYE

wmDESTROY:		      invoke  ExitProcess,ebx
proc StringOut1
a10:	movsb
	cmp byte [esi],0
	jz short a20
	loop a10
a20:	retn
endp


     wTitle	    db	 'Iczelion Tutorial 11: More about Dialog Box',0

     dlgOpenTitle   db	 'Open File',0
     dlgOpenOfn     OPENFILENAME
     dlgOpenFilter  db	 'All Files (*.*)',0,'*.*',0
		    db	 'Text Files (*.txt)',0,'*.txt',0,0
     FullPathName   db	 'The Full Filename with Path is : ',0
     FullName	    db	 10,'The Filename is : ',0
     ExtensionName  db	 10,'The Extension is : ',0
     strMsgSize     equ  512
     strMsg:	    times strMsgSize db 0
data import
     library   KERNEL32, 'KERNEL32.DLL',\
	       USER32,	 'USER32.DLL',\
	       COMDLG32, 'COMDLG32.DLL'

     import    KERNEL32,\
	       ExitProcess,	   'ExitProcess'

     import    USER32,\
	       RegisterClass,	   'RegisterClassA',\
	       CreateWindowEx,	   'CreateWindowExA',\
	       DefWindowProc,	   'DefWindowProcA',\
	       MessageBox,	   'MessageBoxA',\
	       GetMessage,	   'GetMessageA',\
	       DestroyWindow,	   'DestroyWindow',\
	       DispatchMessage,    'DispatchMessageA'

     import    COMDLG32,\
	       GetOpenFileName,    'GetOpenFileNameA'
end data
section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       30,LANG_NEUTRAL,menuMain

     menu menuMain
	  menuitem  '&File',0,MFR_POPUP + MFR_END
	  menuitem	 'Op&en',MI_OPEN,0
			 menuseparator
	  menuitem	 'E&xit',MI_EXIT,MFR_END
