format PE GUI 4.0
include 'win32ax.inc'
dummy = InitCommonControls
;start:
	xchg	 ebx,eax			 ; NULL
	mov	esi,400000h			    ; [hinstance]
	invoke	LoadIcon,esi,4
	push eax
	push _class
	push ebx
	push COLOR_BTNFACE+1
	invoke	LoadCursor,esi,1		; 0,IDC_ARROW
	push eax
	invoke	LoadIcon,esi,2
	invoke	RegisterClassEx,esp,sizeof.WNDCLASSEX,ebx,WindowProc,\
	ebx,ebx,esi,eax
	push esi
	push ebx
	push esi
	shl esi,9;esi=CW_USEDEFAULT
	invoke	CreateWindowEx,WS_EX_CONTROLPARENT,_class,_title,\
		WS_VISIBLE OR WS_SYSMENU OR WS_CLIPSIBLINGS,esi,esi,256,177,ebx,ebx
	pop esi
	mov	[mainhwnd],eax
	invoke	SetTimer,eax,1,10,0

	invoke	CreateWindowEx,ebx,_Edit,_class,\
			WS_CHILD OR WS_VISIBLE OR WS_TABSTOP OR WS_BORDER OR ES_CENTER,5,3,240,20,[mainhwnd],2,esi,ebx
	mov	[myedithwnd],eax

	invoke	CreateWindowEx,ebx,_Edit,message,\
			WS_CHILD OR WS_VISIBLE OR WS_TABSTOP OR ES_CENTER,5,26,240,20,[mainhwnd],3,esi,ebx
	mov	[myedit2hwnd],eax

	invoke	CreateWindowEx,WS_EX_STATICEDGE,_Button,ebx,\
			WS_CHILD OR WS_VISIBLE OR WS_TABSTOP OR BS_ICON OR BS_PUSHBUTTON,5,49,240,38,[mainhwnd],1,esi,ebx
	mov	[mybuttonhwnd],eax

	invoke	CreateWindowEx,ebx,_Button,_icons,\
			WS_CHILD OR WS_VISIBLE OR BS_GROUPBOX OR BS_CENTER,5,87,240,55,[mainhwnd],4,esi,ebx
	mov	[mybutton2hwnd],eax

	invoke	CreateWindowEx,ebx,_Static,ebx,\
			WS_CHILD OR WS_VISIBLE OR SS_ICON,10,105,0,0,[mainhwnd],5,esi,ebx
	mov	[mystatichwnd],eax

	invoke	CreateWindowEx,ebx,_Static,ebx,\
			WS_CHILD OR WS_VISIBLE OR SS_ICON,109,105,0,0,[mainhwnd],6,esi,ebx
	mov	[mystatic2hwnd],eax

	invoke	LoadIcon,esi,1
	invoke	SendMessage,[mystatichwnd],STM_SETIMAGE,IMAGE_ICON,eax
	mov ebp,esp
msg_loop: invoke  TranslateMessage,ebp
	invoke	DispatchMessage,ebp
	invoke	GetMessage,ebp,ebx,ebx,ebx
	jmp	msg_loop

factor	EQU	16
ALIGN	factor

proc WindowProc hwnd,wmsg,wparam,lparam
local	protection:DWORD

	mov	eax,[wmsg]
	dec eax;WM_CREATE=1
	dec eax;WM_DESTROY=2
	je	.wmdestroy
	sub eax,WM_TIMER-WM_DESTROY
	je	.moveProc
	sub eax,WM_COMMAND-WM_TIMER
	je	.wmcommand


.defwndproc: leave
	jmp	[DefWindowProc]

.wmdestroy: invoke  KillTimer,[hwnd],1
	invoke	ExitProcess,0

.wmcommand: mov     eax,[wparam]
	cmp	al,1
	jne	.defwndproc

	mov	esi,clicked			; flag address
	mov	edi,[esi]			; flag value
	rdtsc
	shr	eax,2
	and	eax,11b
	lea	eax,[eax+1]
	invoke	LoadIcon,[hinstance],eax
	invoke	SendMessage,[mybuttonhwnd],BM_SETIMAGE,IMAGE_ICON,eax
	test	edi,edi
	jnz	.clicked!

	invoke	LoadImage,[hinstance],_IconFileName,IMAGE_ICON,32,32,LR_LOADFROMFILE
	invoke	SendMessage,[mystatic2hwnd],STM_SETIMAGE,IMAGE_ICON,eax

	inc	edi
	mov	[esi],edi
	jmp	.moveProc

.clicked!: xor	   ebx,ebx
	invoke	SendMessage,[mystatic2hwnd],STM_SETIMAGE,IMAGE_ICON,ebx
	mov	[esi],ebx

.moveProc:
	lea	esi,[moveFlag]
	lea	edi,[procPlace] 		; procPlace
	mov	ebx,[esi]			; moveFlag

	inc	ebx
	xor	eax,eax
	cmp	ebx,2
	cmove	ebx,eax
	mov	[esi],ebx

	lea	eax,[protection]
	mov	esi,wndProcSize 		; wndProcSize
	push	eax
	push	eax
	invoke	VirtualProtect,DWORD [edi],esi,PAGE_EXECUTE_READWRITE
	invoke	VirtualProtect,DWORD [edi+4],esi,PAGE_EXECUTE_READWRITE

	push esi;mov     eax,esi
	push edi;mov     edx,edi

	mov	ecx,esi
	neg	ebx
	mov	esi,[edi+ebx*4+4]
	neg	ebx
	mov	edi,[edi+ebx*4]
	rep	movsb
	pop edi;mov     edi,edx
	pop esi;mov     esi,eax


	invoke	SetWindowLong,[mainhwnd],GWL_WNDPROC,DWORD [edi+ebx*4]

	neg	ebx
	mov	eax,[edi+ebx*4+4]

	inc	DWORD [edi+ebx*4+4]
	test	BYTE [edi+ebx*4+4],factor-1
	jnz	@F
	sub	DWORD [edi+ebx*4+4],factor
@@:	neg	ebx

	mov	edi,eax
	xor	eax,eax
	mov	ecx,here
	rep	stosb
here = $ - WindowProc

	lea	eax,[protection]
	push	eax
	push	eax
	invoke	VirtualProtect,DWORD [edi],esi,PAGE_EXECUTE_READ
	invoke	VirtualProtect,DWORD [edi+4],esi,PAGE_EXECUTE_READ
.finish: ret
endp

wndProcSize = $ - WindowProc
section '.data' data readable writable
	DB	factor DUP (?)
_title	DB	'Win32 program template',0
_class	DB	'FASMWIN32',0
_Edit	DB	'EDIT',0
_Static DB	'STATIC',0
_Button DB	'Button',0
_icons	DB	'i c o n s',0
_IconFileName	DB "d:\Ассемблеры\Fasm\Mikl's lessons\New\rsrc\east32.ico",0
message DB	'Click the Button below to load icons',0

ALIGN	4
procPlace	DD	WindowProc
		DD	400000h
moveFlag	DD	?
clicked 	DD	?
hinstance	DD	400000h
mainhwnd	DD	?
mybuttonhwnd	DD	?
mybutton2hwnd	DD	?
myedithwnd	DD	?
myedit2hwnd	DD	?
mystatichwnd	DD	?
mystatic2hwnd	DD	?

data import

library kernel32,'KERNEL32.DLL',\
	user32,'USER32.DLL',\
	comctl32,'COMCTL32.DLL'

	import	    comctl32,\
		InitCommonControls,	'InitCommonControls'

	import	    kernel32,\
		ExitProcess,		'ExitProcess',\
		VirtualProtect, 	'VirtualProtect'

	import	    user32,\
		LoadIcon,		'LoadIconA',\
		LoadCursor,		'LoadCursorA',\
		RegisterClassEx,	'RegisterClassExA',\
		CreateWindowEx, 	'CreateWindowExA',\
		SendMessage,		'SendMessageA',\
		TranslateMessage,	'TranslateMessage',\
		DispatchMessage,	'DispatchMessageA',\
		GetMessage,		'GetMessageA',\
		DefWindowProc,		'DefWindowProcA',\
		SetTimer,		'SetTimer',\
		KillTimer,		'KillTimer',\
		LoadImage,		'LoadImageA',\
		SetWindowLong,		'SetWindowLongA'
end data
;section '.rsrc' data resource readable
DATA	RESOURCE
directory	RT_GROUP_ICON,group_icons,\
		RT_ICON,icons,\
		RT_GROUP_CURSOR,group_cursors,\
		RT_CURSOR,cursors

resource	group_icons,\
		1,LANG_NEUTRAL,First_icon,\
		2,LANG_NEUTRAL,Second_icon,\
		3,LANG_NEUTRAL,Third_icon,\
		4,LANG_NEUTRAL,Fourth_icon
; The lowest icon number will be used as the main window Icon, other icons can be used for
; the Window small icon or for other controls.

resource	icons,\
		1,LANG_NEUTRAL,First_icon_data,\
		2,LANG_NEUTRAL,Second_icon_data,\
		3,LANG_NEUTRAL,Third_icon_data,\
		4,LANG_NEUTRAL,Fourth_icon_data

resource	group_cursors,\
		1,LANG_NEUTRAL,main_cursor

resource	cursors,\
		1,LANG_NEUTRAL,main_cursor_data


icon	First_icon,First_icon_data,"Images\radiation2.ico"
icon	Second_icon,Second_icon_data,"Images\radiation3.ico"
icon	Third_icon,Third_icon_data,"Images\radiation.ico"
icon	Fourth_icon,Fourth_icon_data,"Images\check.ico"

cursor	main_cursor,main_cursor_data,"Images\cur.cur"

END	DATA