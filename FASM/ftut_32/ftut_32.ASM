format PE GUI 4.0
entry start
include 'win32a.inc'
;IDD_DIALOG              equ 1000
IDM_MENU		equ 10000
IDM_FILE_EXIT		equ 0
IDM_FILE_NEW		equ 1
IDM_WINDOW_NEXT 	equ 2
IDM_WINDOW_PREVIOUS	equ 3
MI_CLOSE		equ 4
MI_TILEHOR		equ 5
MI_TILEVER		equ 6
MI_CASCADE		equ 7
IDM_HELP_ABOUT		equ 8
MI_CLOSE_ALL		equ 9
start:	xchg eax,ebx
	mov edi,wc
	mov esi,400000h
	invoke RegisterClassEx,edi
	mov [edi+WNDCLASSEX.lpfnWndProc],MdiChildProc
	mov [edi+WNDCLASSEX.cbWndExtra],ebx
	mov [edi+WNDCLASSEX.lpszMenuName],ebx
	mov [edi+WNDCLASSEX.lpszClassName],MdiChildClassName
	invoke RegisterClassEx,edi
	push ebx
	push esi
	shl esi,9
	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,ClassName,wndFTitle,WS_VISIBLE +\
	WS_OVERLAPPEDWINDOW + WS_CLIPCHILDREN,esi,esi,800,600,ebx,ebx
	mov [hWnd],eax
	invoke GetMenu,eax
	mov [hMenu],eax
	invoke GetSubMenu,eax,1
	mov [cc+CLIENTCREATESTRUCT.hWindowMenu],eax
	mov edi,rect
	invoke GetClientRect,[hWnd],edi
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,MdiClientClassName,ebx,\
	WS_CHILD + WS_VISIBLE + WS_VSCROLL + WS_HSCROLL + WS_CLIPCHILDREN,\
	ebx,ebx,[edi+RECT.right],[edi+RECT.bottom],[hWnd],ebx,esi,cc
	mov [hClient],eax
	mov ebp,esp
window_message_loop_start:
	invoke	GetMessage,ebp,ebx,ebx,ebx
	invoke TranslateMDISysAccel,[hClient],ebp
	test eax,eax
	jnz window_message_loop_start
	invoke	DispatchMessage,ebp
	jmp  window_message_loop_start
proc WndProc,hWin,uMsg,wParam,lParam
	mov eax,[uMsg]
	dec eax
	dec eax;cmp eax,WM_DESTROY
	je wmDESTROY
	sub eax,WM_SIZE-WM_DESTROY;cmp eax,WM_SIZE
	je wmSIZE
	sub eax,WM_COMMAND-WM_SIZE
	jz wmCOMMAND
	leave
	jmp dword [DefWindowProc]
wmCOMMAND: mov eax,[wParam]
	cmp eax,MI_CLOSE_ALL;5
	ja wmBYE
	jmp [menu_handlers+eax*4]
New:	mov esi,400000h
	push ebx;NULL
	push esi;hInstance
	shl esi,9
	invoke CreateWindowEx,WS_EX_MDICHILD + WS_EX_CLIENTEDGE,MdiChildClassName,\
	wndMdiTitle,MDIS_ALLCHILDSTYLES,esi,esi,esi,esi,[hClient],ebx
	jmp wmBYE
Exit:	mov eax,[hWin]
	jmp a1
Next:	push TRUE
	jmp a3
Prev:	push ebx
a3:	push ebx
	push WM_MDINEXT
a4:	push [hClient]
	jmp a2
Horiz:	push ebx
	push MDITILE_HORIZONTAL
a5:	push WM_MDITILE
	jmp a4
Vert:	push ebx
	push ebx
	jmp a5
Cascade: push ebx
	push MDITILE_SKIPDISABLED
	push WM_MDICASCADE
	jmp a4
Close:	invoke SendMessage,[hClient],WM_MDIGETACTIVE,ebx,ebx
a1:	push ebx
	push ebx
	push WM_CLOSE
	push eax
a2:	invoke SendMessage
	jmp wmBYE
About:	invoke ShellAbout,[hWin],wndFTitle,AboutMsg,ebx
	jmp wmBYE
CloseAll: invoke SendMessage,[hClient],WM_MDIGETACTIVE,ebx,ebx
	test eax,eax
	je wmBYE
	invoke SendMessage,eax,WM_CLOSE,ebx,ebx
	jmp CloseAll
wmSIZE: mov edi,rect
	invoke GetClientRect,[hWin],edi
	invoke MoveWindow,[hClient],ebx,ebx,[edi+RECT.right],[edi+RECT.bottom],TRUE
wmBYE:	leave
	retn 10h
wmDESTROY: invoke  ExitProcess,ebx
endp
;--------------------------------------------------------------------------------------
proc MdiChildProc,hChild,uMsg2,wParam2,lParam2
	cmp [uMsg2],WM_MDIACTIVATE
	jz wmMDIACTIVATE
	leave
	jmp [DefMDIChildProc]
wmMDIACTIVATE: mov eax,[lParam2]
	cmp eax,[hChild]
	setne bl;MF_ENABLED=0 MF_GRAYED=1
	invoke EnableMenuItem,[hMenu],MI_CLOSE,ebx
	invoke EnableMenuItem,[hMenu],MI_TILEHOR,ebx
	invoke EnableMenuItem,[hMenu],MI_TILEVER,ebx
	invoke EnableMenuItem,[hMenu],MI_CASCADE,ebx
	invoke EnableMenuItem,[hMenu],IDM_WINDOW_NEXT,ebx
	invoke EnableMenuItem,[hMenu],IDM_WINDOW_PREVIOUS,ebx
	invoke EnableMenuItem,[hMenu],MI_CLOSE_ALL,ebx
	xor ebx,ebx
	leave
	retn 10h
endp
;-----------------------------------------------------------------------------------------
ClassName  db 'MDI',0
wc	WNDCLASSEX   sizeof.WNDCLASSEX,CS_HREDRAW or CS_VREDRAW,WndProc,0,\
	DLGWINDOWEXTRA,400000h,0,10011h,COLOR_APPWORKSPACE,10000,ClassName,0
cc	CLIENTCREATESTRUCT 0,2000
hWnd	 rd 1
hClient  rd 1
hMenu	 rd 1
MdiChildClassName  db 'MDICHILD',0
MdiClientClassName db 'MDICLIENT',0
menu_handlers dd Exit,New,Next,Prev,Close,Horiz,Vert,Cascade,About,CloseAll
wndMdiTitle db 'Mdi Child',0
wndFTitle   db 'Iczelion Tutorial #32:Multiple Document Interface (MDI)',0
AboutMsg    db 'Mikl__ 2008',0
rect	  RECT
data import
	library KERNEL32, 'KERNEL32.DLL',\
		shell32,  'shell32.dll',\
		USER32,   'USER32.DLL'
	import	shell32,\
		ShellAbout,	'ShellAboutA'
	import	KERNEL32,\
		ExitProcess,		'ExitProcess'
	import	USER32,\
		RegisterClassEx,	'RegisterClassExA',\
		CreateWindowEx, 	'CreateWindowExA',\
		GetMenu,		'GetMenu',\
		TranslateMDISysAccel,	'TranslateMDISysAccel',\
		EnableMenuItem, 	'EnableMenuItem',\
		GetSubMenu,		'GetSubMenu',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		DestroyWindow,		'DestroyWindow',\
		DefMDIChildProc,	'DefMDIChildProcA',\
		GetClientRect,		'GetClientRect',\
		DefWindowProc,		'DefWindowProcA',\
		MoveWindow,		'MoveWindow',\
		DispatchMessage,	'DispatchMessageA'
end data
section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       IDM_MENU,LANG_ENGLISH,IDR_MAINMENU

     _ equ ,09h,
     menu IDR_MAINMENU
	  menuitem  '&File',0,MFR_POPUP
	  menuitem  '&New',IDM_FILE_NEW,MFT_STRING
	  menuitem  '&Close' _ 'Ctrl+F4',MI_CLOSE,MFT_STRING,MF_GRAYED
	  menuseparator
	  menuitem  'E&xit',IDM_FILE_EXIT,MFR_END

	  menuitem  '&Window',0,MFR_POPUP
	  menuitem  'Tile Horizontal',MI_TILEHOR,MFT_STRING,MF_GRAYED
	  menuitem  'Tile Vertical',MI_TILEVER,MFT_STRING,MF_GRAYED
	  menuitem  '&Cascade',MI_CASCADE,MFT_STRING,MF_GRAYED
	  menuitem  '&Next' _ 'Ctrl+F6',IDM_WINDOW_NEXT,MFT_STRING,MF_GRAYED
	  menuitem  '&Previous' _ 'Shift+Ctrl+F6',IDM_WINDOW_PREVIOUS,MFT_STRING,MF_GRAYED
	  menuitem  '&Close All',MI_CLOSE_ALL,MFR_END,MF_GRAYED

	  menuitem  '&Help',0,MFR_POPUP or MFR_END
	  menuitem  '&About',IDM_HELP_ABOUT,MFR_END