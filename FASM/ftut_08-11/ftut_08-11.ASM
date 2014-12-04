format PE GUI
include 'win32ax.inc'
; import data in the same section
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  call [InitCommonControls]
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_BTNFACE+1,600,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,WS_EX_LEFT,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi,ebx,ebx
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
hwnd	equ ebp+8
uMsg	equ ebp+0Ch
wParam	equ ebp+10h
lParam	equ ebp+14h
caW	equ ebp-4
caH	equ caW-4
Rct	equ caH-sizeof.RECT
tbb	equ Rct-sizeof.TBBUTTON
Tba	equ tbb-sizeof.TBADDBITMAP
	enter sizeof.RECT+sizeof.TBBUTTON+sizeof.TBADDBITMAP+\
	sizeof.PAINTSTRUCT+8,0
	xor ebx,ebx
	lea esi,[SendMessage]
	mov eax,[uMsg]
	dec eax;cmp eax,WM_CREATE=1
	je short wmCREATE
	dec eax;cmp eax,WM_DESTROY=2
	je wmDESTROY
	sub eax,WM_SIZE-WM_DESTROY;cmp eax,WM_SIZE=5
	je wmSIZE
	sub eax,WM_PAINT-WM_SIZE;cmp eax,WM_PAINT=0Fh
	je wmPAINT
	dec eax;cmp eax,WM_CLOSE=10h
	je short wmCLOSE
	sub eax,WM_COMMAND-WM_CLOSE;cmp eax,WM_COMMAND=111h
	je wmCOMMAND
;все сообщения, не обрабатываемые в функции 
;WndProc, направляются на обработку по умолчанию
default:leave
	jmp [DefWindowProc]
wmCLOSE: push MB_YESNO;   4
	push	wTitle
	push	aPleaseConfirmE ; "Please Confirm Exit"
	push	dword [hwnd]
	call [MessageBox]
	cmp	eax,IDNO; 7
	jnz	default
end_wm_check: leave
	retn 10h
wmPAINT: push esp;&Paint
	push dword [hwnd]
	call [BeginPaint]
	push eax
	push dword [hwnd]
	call	Paint_Proc
	push esp;i;&Paint
	push dword [hwnd]
	call [EndPaint] 	  ;Освобождаем контекст отображения
	jmp end_wm_check
wmCREATE: lea edi,[tbb]
	mov [edi+TBBUTTON.iBitmap],ebx
	mov [edi+TBBUTTON.idCommand],ebx
	mov [edi+TBBUTTON.fsState],TBSTATE_ENABLED
	mov [edi+TBBUTTON.fsStyle],TBSTYLE_SEP
	mov [edi+TBBUTTON.dwData],ebx
	mov [edi+TBBUTTON.iString],ebx
	push sizeof.TBBUTTON ;размер структуры TBBUTTON
	push ebx	     ;ширина и высота 
	push ebx;0           ;изображения на каждой кнопке
	push 10h	  ;ширина и высота 
	push 10h	  ;каждой кнопки
	push 1		  ;число кнопок
	push edi	  ;адрес массива структуры типа TBBUTTON
	push ebx;   0        ;идентификатор ресурса с изображением кнопок
	push ebx;   0
	push 1	     ;число изображений кнопок в файле bmp
	push 300;   12Ch;идентификатор всей инструментальной панели, который в программе не используется и может быть равен -1
	push WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE;   44000000h ;стиль инструментальной панели
	push dword [hwnd] ;дескриптор главного окна
	call [CreateToolbarEx]
	mov [hToolBar],eax

	lea ecx,[Tba]
	mov [ecx+TBADDBITMAP.hInst],HINST_COMMCTRL; 0FFFFFFFFh
	mov [ecx+TBADDBITMAP.nID], 1; btnsize 1=big 2=small
	push ecx
	push 1
	push TB_ADDBITMAP;   413h
	push eax;hToolBar
	call dword [esi]

	mov [edi+TBBUTTON.iBitmap],STD_FILENEW; 6
	mov [edi+TBBUTTON.fsStyle],TBSTYLE_BUTTON; 0
	mov [edi+TBBUTTON.idCommand],50
	push edi
	push 1
	push TB_ADDBUTTONS
	push [hToolBar]
	call dword [esi]

	mov [edi+TBBUTTON.iBitmap],STD_FILEOPEN; 7
	inc [edi+TBBUTTON.idCommand]
	push edi
	push 1
	push TB_ADDBUTTONS
	push [hToolBar]
	call dword [esi]
	mov [edi+TBBUTTON.iBitmap],STD_FILESAVE; 8
	inc [edi+TBBUTTON.idCommand];52
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.idCommand],ebx ;0
	mov	[edi+TBBUTTON.fsStyle],TBSTYLE_SEP; 1
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

	mov	[edi+TBBUTTON.iBitmap],STD_REDOW; 0Eh
	mov	[edi+TBBUTTON.idCommand],53
	mov	[edi+TBBUTTON.fsStyle],TBSTYLE_BUTTON
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_DELETE; 0Eh
	inc [edi+TBBUTTON.idCommand];54
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],ebx;STD_CUT; 0
	inc [edi+TBBUTTON.idCommand];55
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_COPY; 1
	inc [edi+TBBUTTON.idCommand];56
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_PASTE; 2
	inc [edi+TBBUTTON.idCommand];57
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_UNDO; 3
	inc [edi+TBBUTTON.idCommand];58
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],ebx; 0
	mov	[edi+TBBUTTON.idCommand],ebx; 0
	mov	[edi+TBBUTTON.fsStyle],TBSTYLE_SEP; 1
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

	mov	[edi+TBBUTTON.iBitmap],STD_FIND; 0Ch
	mov	[edi+TBBUTTON.idCommand],59
	mov	[edi+TBBUTTON.fsStyle],TBSTYLE_BUTTON; 0
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_REPLACE; 0Dh
	inc [edi+TBBUTTON.idCommand];60
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

	mov	[edi+TBBUTTON.iBitmap],ebx; 0
	mov	[edi+TBBUTTON.idCommand],ebx; 0
	mov	[edi+TBBUTTON.fsStyle],TBSTYLE_SEP; 1
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

	mov	[edi+TBBUTTON.iBitmap],STD_PRINT; 0Eh
	mov	[edi+TBBUTTON.idCommand],61
	mov	[edi+TBBUTTON.fsStyle],TBSTYLE_BUTTON
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

	mov	[edi+TBBUTTON.iBitmap],STD_PRINTPRE; 0Eh
	inc [edi+TBBUTTON.idCommand];62
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

	mov	[edi+TBBUTTON.iBitmap],STD_PROPERTIES; 0Eh
	inc [edi+TBBUTTON.idCommand];63
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

	mov	[edi+TBBUTTON.iBitmap],STD_HELP; 0Eh
	inc [edi+TBBUTTON.idCommand];64
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]

; Create the status bar
	push	200
	push	dword[hwnd]
	push	ebx;0
	push	WS_CHILD or WS_VISIBLE or SBS_SIZEGRIP;50000010h
	call [CreateStatusWindow]
	mov	[hStatus], eax
	jmp default
wmSIZE: push ebx;   0
	push ebx;   0
	push TB_AUTOSIZE;   421h
	push [hToolBar]
	call dword  [esi]
	push dword[caW]
	pop dword[lParam+0]
	push dword[caH]
	pop dword[lParam+2]
	lea edi,[Rct]
	push edi
	push [hStatus]
	call [GetWindowRect]
	mov eax,[edi+RECT.bottom]
	sub eax,[edi+RECT.top]
	sub [caH],eax
	push	TRUE;1
	push	dword[caH]
	push	dword[caW]
	push	dword[caH]
	push	ebx;0
	push	[hStatus]
	call [MoveWindow]
	jmp	default 
wmCOMMAND: mov edi,[wParam]
	sub edi,50
	cmp edi,14
	ja short a1
	push [handler+edi*4]
	push ebx;0               ; wParam
	push SB_SETTEXT;401h            ; Msg
	push [hStatus]	    ; hWnd
	call dword  [esi];  SendMessageA
	push ebx;   0;MB_OK ; uType
	push	aYouHaveSelecte ; lpCaption
	push [handler+edi*4] ; lpText
	push dword [hwnd]      ; hWnd
	call [MessageBox]
	jmp default
a1:	cmp edi,15
	jnz a2
	push ebx
	push SC_CLOSE
	push WM_SYSCOMMAND
	push dword[hwnd]
	call dword  [esi];  SendMessageA
	jmp default
a2:	push ebx;   0
	push	wTitle ; "Comctl32 Demo"
	push	aAssemblerPureS ; "Assembler, Pure & Simple"
	push	dword [hwnd]
	call [MessageBox]
	jmp default
wmDESTROY: invoke ExitProcess,ebx;завершение программы
;=================================================
Paint_Proc:
hWin equ esp+sizeof.RECT+14h;ebp+8
hDC  equ esp+sizeof.RECT+18h;ebp+0Ch
caW  equ esp+sizeof.RECT+8;ebp-4
caH  equ caW-4
tbH  equ caH-4
sbH  equ tbH-4
	sub esp,sizeof.RECT+10h;место под структуру RECT и переменные caW,caH,tbH,sbH
	mov edi,esp;&Rct
	lea esi,[GetWindowRect]
	push edi	     ; lpRect
	push dword[hWin]      ; hWnd
	call [GetClientRect]
	push [edi+RECT.right]
	pop dword[caW]
	push [edi+RECT.bottom]
	pop dword[caH]
	push edi	     ; lpRect
	push [hToolBar]     ; hWnd
	call dword[esi];[GetWindowRect]
	mov eax,[edi+RECT.bottom]
	sub eax,[edi+RECT.top]
	mov [tbH], eax
	push edi	     ; lpRect
	push [hStatus]	    ; hWnd
	call dword[esi];[GetWindowRect]
	mov eax,[edi+RECT.bottom]
	sub eax,[edi+RECT.top]
	mov [sbH], eax
	sub [caH], eax
	mov [edi+RECT.left],ebx;0
	push dword[tbH]
	pop [edi+RECT.top]
	push dword[caW]
	pop [edi+RECT.right]
	push dword[caH]
	pop [edi+RECT.bottom]
	push BF_RECT;   0Fh             ; grfFlags
	push EDGE_SUNKEN;   0Ah             ; edge
	push edi	     ; qrc
	push dword[hDC]       ; hdc
	call [DrawEdge]
	add esp,sizeof.RECT+10h;освобождаем буфер;leave
	retn 8
;=================================================================
wTitle db 'Iczelion Tutorial #8-11:инструментальная панель в FASM',0
 aYouHaveSelecte db 'You have selected',0
 aNewFile	 db 'New File',0	 
 aOpenFile	 db 'Open File',0	
 aSaveFile	 db 'Save File',0
 aRedow 	 db 'Redow',0
 aDelete	 db 'Delete',0
 aCut		 db 'Cut',0
 aCopy		 db 'Copy',0		
 aPaste 	 db 'Paste',0		 
 aUndo		 db 'Undo',0		 
 aSearch	 db 'Search',0		 
 aReplace	 db 'Replace',0
 aPrint 	 db 'Print',0
 aPreview	 db 'Previw',0
 aProperties	 db 'Properties',0
 aHelp		 db 'Help',0
 aAssemblerPureS db 'Assembler, Pure & Simple',0
 aPleaseConfirmE db 'Please Confirm Exit',0
	hStatus       dd 0
	hToolBar      dd 0
handler dd aNewFile,aOpenFile,aSaveFile,aRedow,aDelete,aCut,aCopy
	dd aPaste,aUndo,aSearch,aReplace,aPrint,aPreview,aProperties,aHelp
data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 comctl32, 'comctl32.dll'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DispatchMessage,    'DispatchMessageA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		SendMessage,	    'SendMessageA',\
		BeginPaint,	    'BeginPaint',\
		EndPaint,	    'EndPaint',\
		GetWindowRect,	    'GetWindowRect',\
		MoveWindow,	    'MoveWindow',\
		GetClientRect,	    'GetClientRect',\
		DrawEdge,	    'DrawEdge',\
		MessageBox,	    'MessageBoxA'
 import comctl32,\
		InitCommonControls, 'InitCommonControls',\
		CreateToolbarEx,    'CreateToolbarEx',\
		CreateStatusWindow, 'CreateStatusWindowA'
end data
section '.rsrc' resource data readable

  directory RT_MENU,menus

  IDM_MENU   = 600
  ID_EXIT    = 65
  ID_ABOUT   = 66

  resource menus,\
	   IDM_MENU,LANG_ENGLISH+SUBLANG_DEFAULT,main_menu

  menu main_menu
       menuitem '&File',0,MFR_POPUP
		menuitem '&Exit',ID_EXIT,MFR_END

       menuitem '&Help',0,MFR_POPUP + MFR_END
		menuitem '&About',ID_ABOUT,MFR_END
