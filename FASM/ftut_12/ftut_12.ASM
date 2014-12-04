format PE GUI
include 'win32ax.inc'
MI_OPEN   equ  0
MI_SAVE   equ  1
MI_EXIT   equ  2
MAXSIZE   equ  260
MEM_SIZE  equ  65535
EDIT_ID   equ  1

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
	  invoke TranslateMessage,ebp
	  invoke DispatchMessage,ebp
	  jmp message_loop
	  ; +----------------------+
	  ; | the window procedure |
	  ; +----------------------+
window_procedure:
hWnd		equ ebp+8h
uMsg		equ ebp+0Ch
wParam		equ ebp+10h
lParam		equ ebp+14h
hMem		equ ebp-4 ;handle to the allocated memory block
pMem		equ hMem-4;pointer to the allocated memory block
szReadWrite	equ pMem-4;number of bytes actually read or write
	  enter 12,0
	  mov eax,[uMsg]
	  lea edi,[dOpenOfn]
	  mov esi,[hEdit]
	  dec eax;cmp  [uMsg],WM_CREATE
	  je   wmCREATE
	  dec eax;cmp  [uMsg],WM_DESTROY
	  je   wmDESTROY
	  sub eax,WM_SIZE-WM_DESTROY;cmp  [uMsg],WM_SIZE
	  je   wmSIZE
	  sub eax,WM_COMMAND-WM_SIZE;     cmp  [uMsg],WM_COMMAND
	  je   wmCOMMAND
	  leave
	  jmp	 [DefWindowProc]
wmSIZE:   push TRUE
	  mov  ax,word[lParam+2]
	  push eax
	  mov  ax,word[lParam]
	  invoke    MoveWindow,esi,ebx,ebx,eax
	  jmp  wmBYE
OPEN:	  mov  [edi+OPENFILENAME.Flags],OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or\
	  OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
	  invoke    GetOpenFileName,edi
	  test eax,eax
	  je a4
	  invoke CreateFile,dOpenBuffer,GENERIC_READ or GENERIC_WRITE,\
	  FILE_SHARE_READ or FILE_SHARE_WRITE,\
	  ebx,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,ebx
	  mov  edi,eax;handle to file
	  invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEM_SIZE
	  mov  [hMem],eax
	  invoke GlobalLock,eax
	  mov  [pMem],eax
	  lea eax,[szReadWrite]
	  invoke ReadFile,edi,dword[pMem],MEM_SIZE-1,eax,ebx
	  invoke SendMessage,esi,WM_SETTEXT,ebx,dword[pMem]
	  jmp a5
SAVE:	  mov  [edi+OPENFILENAME.Flags],OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
	  invoke GetSaveFileName,edi;dOpenOfn
	  test eax,eax
	  je a4
	  invoke  CreateFile,dOpenBuffer,GENERIC_READ or GENERIC_WRITE,\
	  FILE_SHARE_READ or FILE_SHARE_WRITE,ebx,CREATE_NEW,\
	  FILE_ATTRIBUTE_ARCHIVE,ebx
	  mov  edi,eax;hFile
	  invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEM_SIZE
	  mov  [hMem],eax
	  invoke GlobalLock,eax
	  mov  [pMem],eax
	  invoke SendMessage,esi,WM_GETTEXT,MEM_SIZE-1,eax;dword[pMem]
	  lea ecx,[szReadWrite]
	  invoke WriteFile,edi,dword[pMem],eax,ecx,ebx
a5:	  invoke CloseHandle,edi;hFile
	  invoke GlobalUnlock,dword[pMem]
	  invoke GlobalFree,dword[hMem]
a4:	  invoke    SetFocus,esi
	  jmp  wmBYE
EXIT:	  invoke DestroyWindow,dword[hWnd]
wmBYE:	  leave
	  retn 10h
wmCREATE: mov esi,400000h
	  invoke CreateWindowEx,ebx,CLSNAME_EDIT,ebx,WS_VISIBLE or \
	  WS_CHILD or ES_LEFT or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or\
	  ES_AUTOHSCROLL or ES_AUTOVSCROLL,ebx,ebx,ebx,ebx,dword[hWnd],\
	  EDIT_ID,esi,ebx
	  mov  [hEdit],eax
	  invoke SetFocus,eax
	  mov  [edi+OPENFILENAME.lStructSize],sizeof.OPENFILENAME
	  mov  [edi+OPENFILENAME.hInstance],esi;400000h
	  mov  [edi+OPENFILENAME.lpstrFilter],dOpenFilter
	  mov  [edi+OPENFILENAME.lpstrFile],dOpenBuffer
	  mov  [edi+OPENFILENAME.nMaxFile],MAXSIZE;260
	  jmp  wmBYE
wmCOMMAND: mov ax,word[wParam]
	  cmp  dword[lParam],ebx
	  jne  wmBYE
	  jmp  dword[menu_handlers+eax*4]
wmDESTROY: invoke    ExitProcess,ebx;0

menu_handlers dd OPEN,SAVE,EXIT
     wTitle	    db	 'Iczelion Tutorial 12: Memory Management and File I/O',0
     hEdit	    dd	 ?    ;handle for edit control
     CLSNAME_EDIT   db	 'edit',0
     dOpenFilter    db 'All Files (*.*)',0,'*.*',0
		    db "Text Files (*.txt)",0,"*.txt",0,0
     dOpenOfn	    OPENFILENAME
     dOpenBuffer:   times MAXSIZE db 0

data import
     library   KERNEL32, 'KERNEL32.DLL',\
	       USER32,	 'USER32.DLL',\
	       COMDLG32, 'COMDLG32.DLL'

     import    KERNEL32,\
	       CreateFile,	   'CreateFileA',\
	       GlobalAlloc,	   'GlobalAlloc',\
	       GlobalFree,	   'GlobalFree',\
	       GlobalLock,	   'GlobalLock',\
	       GlobalUnlock,	   'GlobalUnlock',\
	       ReadFile,	   'ReadFile',\
	       WriteFile,	   'WriteFile',\
	       CloseHandle,	   'CloseHandle',\
	       ExitProcess,	   'ExitProcess'

     import    USER32,\
	       RegisterClass,	   'RegisterClassA',\
	       CreateWindowEx,	   'CreateWindowExA',\
	       DefWindowProc,	   'DefWindowProcA',\
	       SendMessage,	   'SendMessageA',\
	       SetFocus,	   'SetFocus',\
	       GetMessage,	   'GetMessageA',\
	       MoveWindow,	   'MoveWindow',\
	       DestroyWindow,	   'DestroyWindow',\
	       TranslateMessage,   'TranslateMessage',\
	       DispatchMessage,    'DispatchMessageA'

     import    COMDLG32,\
	       GetOpenFileName,    'GetOpenFileNameA',\
	       GetSaveFileName,    'GetSaveFileNameA'
end data
section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       30,LANG_NEUTRAL,menuMain

     menu menuMain
	  menuitem  '&File',0,MFR_POPUP + MFR_END
	  menuitem	 'Op&en',MI_OPEN,0
	  menuitem	 '&Save',MI_SAVE,0
			 menuseparator
	  menuitem	 'E&xit',MI_EXIT,MFR_END
