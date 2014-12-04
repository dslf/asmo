format PE GUI 4.0
entry start
include 'win32a.inc'
IDD_DIALOG		equ 1000
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

start:	xchg eax,ebx
	invoke InitCommonControls
	mov edi,wc
	mov esi,400000h
	invoke RegisterClassEx,edi
	mov [edi+WNDCLASSEX.lpfnWndProc],MdiChildProc
	mov [edi+WNDCLASSEX.cbWndExtra],ebx
	mov [edi+WNDCLASSEX.lpszMenuName],ebx
	mov [edi+WNDCLASSEX.lpszClassName], MdiChildClassName
	invoke RegisterClassEx,edi
	invoke CreateDialogParam,esi,IDD_DIALOG,ebx,WndProc,ebx
@@:	invoke GetMessage,edi,ebx,ebx,ebx
	invoke DispatchMessage,edi
	jmp @b

proc WndProc,hWin,uMsg,wParam,lParam
local cc:CLIENTCREATESTRUCT
local rect:RECT
	mov esi,400000h
	xor ebx,ebx
	mov eax,[uMsg]
wmDESTROY: dec eax;cmp eax,WM_DESTROY
	dec eax
	jne wmSIZE
	invoke ExitProcess,ebx
	jmp wmDEFAULT
wmSIZE: sub eax,WM_SIZE-WM_DESTROY;cmp eax,WM_SIZE
	jne wmCLOSE
	lea edi,[rect]
	invoke GetClientRect,[hWin],edi
	invoke MoveWindow,[hClient],ebx,ebx,[edi+RECT.right],[edi+RECT.bottom],TRUE
	jmp wmDEFAULT
wmCLOSE: sub eax,WM_CLOSE-WM_SIZE
	jne wmINITDIALOG
	invoke DestroyWindow,ebx
	jmp wmDEFAULT
wmINITDIALOG: sub eax,WM_INITDIALOG-WM_CLOSE
	jnz wmCOMMAND
	invoke GetMenu,[hWin]
	invoke GetSubMenu,eax,1
	lea ecx,[cc]
	mov [ecx+CLIENTCREATESTRUCT.hWindowMenu],eax
	mov [ecx+CLIENTCREATESTRUCT.idFirstChild],2000
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,MdiClientClassName,ebx,\
	WS_CHILD + WS_VISIBLE + WS_VSCROLL + WS_HSCROLL + WS_CLIPCHILDREN,ebx,ebx,ebx,ebx,\
	[hWin],ebx,esi,ecx
	mov [hClient],eax
	jmp wmDEFAULT
wmCOMMAND: dec eax;cmp eax,WM_COMMAND
	jne wmDEFAULT
	mov eax,[wParam]
	cmp eax,IDM_HELP_ABOUT;5
	ja wmDEFAULT
	jmp [menu_handlers+eax*4]
New:	push ebx;NULL
	push esi;hInstance
	shl esi,9
	invoke CreateWindowEx,WS_EX_MDICHILD + WS_EX_CLIENTEDGE,MdiChildClassName,\
	wndMdiTitle,MDIS_ALLCHILDSTYLES,esi,esi,esi,esi,[hClient],ebx
	jmp wmDEFAULT
Exit:	invoke SendMessage,[hWin],WM_CLOSE,ebx,ebx
	jmp wmDEFAULT
Next:	invoke SendMessage,[hClient],WM_MDINEXT,ebx,TRUE
	jmp wmDEFAULT
Prev:	invoke SendMessage,[hClient],WM_MDINEXT,ebx,ebx
	jmp wmDEFAULT
Horiz:	invoke SendMessage,[hClient],WM_MDITILE,MDITILE_HORIZONTAL,ebx
	jmp wmDEFAULT
Vert:	invoke SendMessage,[hClient],WM_MDITILE,ebx,ebx
	jmp wmDEFAULT
Cascade: invoke SendMessage,[hClient],WM_MDICASCADE,MDITILE_SKIPDISABLED,ebx
	jmp wmDEFAULT
Close:	 invoke SendMessage,[hClient],WM_MDIGETACTIVE,ebx,ebx
	 invoke SendMessage,eax,WM_CLOSE,ebx,ebx
	jmp wmDEFAULT
About:	 invoke ShellAbout,[hWin],wndFTitle,AboutMsg,ebx
wmDEFAULT: invoke DefFrameProc,[hWin],[hClient],[uMsg],[wParam],[lParam]
	ret
endp

proc MdiChildProc,hWin,uMsg,wParam,lParam
wcmDEFAULT:	leave
		jmp [DefMDIChildProc]
endp
ClassName		db 'DLGCLASS',0
AboutMsg		db 'Mikl__ 2008',0
MdiClientClassName	db 'MDICLIENT',0
MdiChildClassName	db 'MDICHILD',0
wndMdiCs	MDICREATESTRUCT
wc	WNDCLASSEX   sizeof.WNDCLASSEX,CS_HREDRAW or CS_VREDRAW,WndProc,0,\
	DLGWINDOWEXTRA,400000h,0,10011h,COLOR_BTNFACE+1,10000,ClassName,0
hClient  dd ?
menu_handlers dd Exit,New,Next,Prev,Close,Horiz,Vert,Cascade,About
wndMdiTitle	db 'Mdi Child',0
wndFTitle	db 'Iczelion Tutorial #32:Multiple Document Interface (MDI)',0

data import
	library KERNEL32, 'KERNEL32.DLL',\
		comctl32, 'comctl32.dll',\
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
		LoadMenu,		'LoadMenuA',\
		GetSubMenu,		'GetSubMenu',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		DestroyWindow,		'DestroyWindow',\
		DefFrameProc,		'DefFrameProcA',\
		DefMDIChildProc,	'DefMDIChildProcA',\
		CreateDialogParam,	'CreateDialogParamA',\
		GetClientRect,		'GetClientRect',\
		MoveWindow,		'MoveWindow',\
		DispatchMessage,	'DispatchMessageA'
	 import  comctl32,\
		InitCommonControls,	'InitCommonControls'
end data
section '.rsrc' resource from 'ftut_32-1.res' data readable




