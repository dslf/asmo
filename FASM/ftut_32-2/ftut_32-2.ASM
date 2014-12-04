format PE GUI 4.0
entry start
include 'win32a.inc'
MI_EXIT       equ 0
MI_TILEHOR    equ 1
MI_TILEVER    equ 2
MI_CASCADE    equ 3
MI_NEW	      equ 4
MI_CLOSE      equ 5
MI_NEXT       equ 6
MI_PREV       equ 7

start:	xchg ebx,eax
	mov edi,wndCls
	invoke	RegisterClass,edi
	mov  [edi+WNDCLASS.lpszMenuName],ebx
	mov  [edi+WNDCLASS.lpfnWndProc],window_child_procedure
	mov  [edi+WNDCLASS.lpszClassName],wndMdiClsName
	mov  [edi+WNDCLASS.cbWndExtra],ebx
	invoke	RegisterClass,edi
	mov esi,400000h
	push esi
	push ebx
	push esi
	shl esi,9
	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,wndFClsName,wndFTitle,\
		WS_OVERLAPPEDWINDOW + WS_CLIPCHILDREN + WS_VISIBLE,\
		esi,esi,800,600,ebx,ebx
		mov  [wndFH],eax
	pop esi
	invoke	LoadMenu,esi,31
		mov  [wndMdiMenuH],eax
	invoke	GetMenu,[wndFH]
		mov  [wndFMenuH],eax
	invoke	GetSubMenu,eax,1
		mov  [wndCCcs.hWindowMenu],eax
		mov  [wndCCcs.idFirstChild],100
	invoke	CreateWindowEx,ebx,wndCClsName,ebx,WS_CHILD + WS_CLIPCHILDREN + WS_VISIBLE,\
		ebx,ebx,800,600,[wndFH],ebx,esi,wndCCcs
		mov  [wndCH],eax
		mov  [wndMdiCs.szClass],wndMdiClsName
		mov  [wndMdiCs.szTitle],wndMdiTitle
		mov  [wndMdiCs.hOwner],esi
		shl esi,9
		mov  [wndMdiCs.x],esi;CW_USEDEFAULT
		mov  [wndMdiCs.y],esi;CW_USEDEFAULT
		mov  [wndMdiCs.cx],esi;CW_USEDEFAULT
		mov  [wndMdiCs.cy],esi;CW_USEDEFAULT
	;+---------------------------+
	;| entering the message loop |
	;+---------------------------+
	mov ebp,esp
	window_message_loop_start:
		invoke	GetMessage,ebp,ebx,ebx,ebx
		invoke	DispatchMessage,ebp
			jmp  window_message_loop_start
	;+----------------------+
	;| the window procedure |
	;+----------------------+
proc window_procedure hWnd,uMsg,wParam,lParam
	 mov eax,[uMsg]
	 dec eax
	 dec eax
	 je   wmDESTROY
	 sub eax,WM_COMMAND-WM_DESTROY
	 jne   wmDEFAULT
wmCOMMAND:  cmp [lParam],ebx
	jne a8
	mov eax,[wParam]
	cmp eax,MI_CLOSE;5
	ja wmDEFAULT
	jmp [menu_handlers+eax*4]
EXIT:	mov eax,[hWnd];0
	jmp short a7
HORZ:	push ebx;1*4
	push MDITILE_HORIZONTAL;1
	jmp short a6
VERT:	push ebx;2*4
	push ebx;MDITILE_VERTICAL
a6:	push WM_MDITILE;226h
	jmp short a9
CASC:	push ebx;3*4
	push MDITILE_SKIPDISABLED;2
	push WM_MDICASCADE;227h
	jmp short a9
NEW:	push wndMdiCs;4*4
	push ebx
	push WM_MDICREATE;220h
	jmp short a9
CLOZ:	push ebx;5*4
	push ebx
	push WM_MDIGETACTIVE;229h
	push [wndCH]
	call [SendMessage]
a7:	push ebx
	push ebx
	push WM_CLOSE;10h
	push eax
	jmp short a5
PREV:	push ebx
	jmp short a10
NEXT:	push TRUE
a10:	push ebx
	push WM_MDINEXT
a9:	push [wndCH]
a5:	call [SendMessage]
	jmp short a8
wmDEFAULT:    invoke DefFrameProc,[hWnd],[wndCH],[uMsg],[wParam],[lParam]
a8:	leave
	retn 10h
wmDESTROY:	invoke	DestroyMenu,[wndMdiMenuH]
		invoke	ExitProcess,ebx
	endp

proc window_child_procedure,hWnd,uMsg,wParam,lParam
		cmp  [uMsg],WM_MDIACTIVATE
		je   wcmMDIACTIVATE
		cmp  [uMsg],WM_CLOSE
		je   wcmCLOSE
wcmDEFAULT:	leave
		jmp [DefMDIChildProc]

wcmMDIACTIVATE: 	mov  eax,[lParam]
			cmp  eax,[hWnd]
			jne  @f
			invoke	GetSubMenu,[wndMdiMenuH],1
			invoke	SendMessage,[wndCH],WM_MDISETMENU,[wndMdiMenuH],eax
				jmp  wcmMDIACTIVATE_EXIT
@@:			invoke	GetSubMenu,[wndFMenuH],1
			invoke	SendMessage,[wndCH],WM_MDISETMENU,[wndFMenuH],eax

wcmMDIACTIVATE_EXIT:	invoke	DrawMenuBar,[wndFH]
			jmp  wcmBYE

wcmCLOSE:		invoke	MessageBox,[wndCH],msg1,wndFTitle,MB_YESNO
			cmp  eax,IDYES
			jne  wcmBYE
			invoke	SendMessage,[wndCH],WM_MDIDESTROY,[hWnd],0
wcmBYE: 		ret
endp
	menu_handlers dd EXIT, HORZ, VERT, CASC, NEW, CLOZ, NEXT, PREV
	insH		dd 400000h
	wndFH		dd ?
	wndCH		dd ?
	wndFTitle	db 'Iczelion Tutorial #32:Multiple Document Interface (MDI)',0
	wndMdiTitle	db 'Mdi Child',0
	wndFClsName	db 'TUT_32',0
	wndCClsName	db 'MDICLIENT',0
	wndMdiClsName	db 'TUT_32_MDI',0
	wndCCcs 	CLIENTCREATESTRUCT
	wndMdiCs	MDICREATESTRUCT
	wndCls		WNDCLASS CS_HREDRAW or CS_VREDRAW,window_procedure,0,DLGWINDOWEXTRA,400000h,\
			10003h,10011h,COLOR_APPWORKSPACE,30,wndFClsName
	wndFMenuH	dd ?
	wndMdiMenuH	dd ?
	msg1		db 'Are you sure you want to',13,10,'close this window ?',0
data import
	library KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL'
    
	import	KERNEL32,\
		ExitProcess,		'ExitProcess'
	import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		LoadMenu,		'LoadMenuA',\
		DestroyMenu,		'DestroyMenu',\
		GetMenu,		'GetMenu',\
		GetSubMenu,		'GetSubMenu',\
		DrawMenuBar,		'DrawMenuBar',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		MessageBox,		'MessageBoxA',\
		DestroyWindow,		'DestroyWindow',\
		DefFrameProc,		'DefFrameProcA',\
		DefMDIChildProc,	'DefMDIChildProcA',\
		TranslateMDISysAccel,	'TranslateMDISysAccel',\
		DispatchMessage,	'DispatchMessageA'
end data
section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       30,LANG_ENGLISH,IDR_MAINMENU,\
	       31,LANG_ENGLISH,IDR_CHILDMENU

     menu IDR_MAINMENU
	  menuitem '&File',0,MFR_POPUP+MFR_END
	  menuitem '&New',MI_NEW
	  menuseparator
	  menuitem '&Exit',MI_EXIT,MFR_END

     menu IDR_CHILDMENU
	  menuitem '&File (child)',0,MFR_POPUP
	  menuitem '&New',MI_NEW
	  menuitem '&Close',MI_CLOSE
	  menuseparator
	  menuitem '&Exit',MI_EXIT,MFR_END

	  menuitem '&Window (child)',0,MFR_POPUP+MFR_END
	  menuitem 'Tile Horizontal',MI_TILEHOR
	  menuitem 'Tile Vertical',MI_TILEVER
	  menuitem '&Cascade',MI_CASCADE
	  menuitem '&Next',MI_NEXT
	  menuitem '&Previous',MI_PREV,MFR_END