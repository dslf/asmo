format PE GUI
include 'win32ax.inc'
; import data in the same section
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  call [InitCommonControls]
	  invoke RegisterClassEx,esp,sizeof.WNDCLASSEX,ebx,window_procedure,\
	  ebx,ebx,esi,ebx,10011h,COLOR_BTNFACE+1,600,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  push ebx
	  push ebx
	  shl esi,9
	  invoke CreateWindowEx,WS_EX_LEFT,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,500,300
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
ofn	equ Tba-sizeof.OPENFILENAME
buffer	equ ofn-256
psd	equ buffer-sizeof.PAGESETUPDLG
pd	equ psd-sizeof.PRINTDLG
	enter sizeof.RECT+sizeof.TBBUTTON+sizeof.TBADDBITMAP+\
	sizeof.PAINTSTRUCT+8+sizeof.OPENFILENAME+256+sizeof.PAGESETUPDLG+\
	sizeof.PRINTDLG+2,0
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
	jnz	short default
end_wm_check: leave
	retn 10h
wmPAINT: push esp;i;&Paint
	push dword [hwnd]
	call [BeginPaint]
	push eax
	push dword [hwnd]
	call Paint_Proc
	push esp;&Paint
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
	mov [edi+TBBUTTON.fsStyle],bl;TBSTYLE_BUTTON=0
	mov [edi+TBBUTTON.idCommand],50
	push edi
	push 1
	push TB_ADDBUTTONS
	push [hToolBar]
	call dword [esi]

	mov [edi+TBBUTTON.iBitmap],STD_FILEOPEN; 7
	inc [edi+TBBUTTON.idCommand];51
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
	mov	[edi+TBBUTTON.iBitmap],ebx;STD_CUT; 0
	mov [edi+TBBUTTON.idCommand],53
	mov [edi+TBBUTTON.fsStyle],bl;TBSTYLE_BUTTON=0
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_COPY; 1
	inc [edi+TBBUTTON.idCommand];54
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_PASTE; 2
	inc [edi+TBBUTTON.idCommand];55
	push edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_UNDO; 3
	inc [edi+TBBUTTON.idCommand];56
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
	mov	[edi+TBBUTTON.idCommand],57
	mov	[edi+TBBUTTON.fsStyle],bl;TBSTYLE_BUTTON; 0
	push	edi
	push	1
	push   TB_ADDBUTTONS
	push	[hToolBar]
	call	dword [esi]
	mov	[edi+TBBUTTON.iBitmap],STD_PRINTPRE; 0Dh
	inc [edi+TBBUTTON.idCommand];58
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
	mov	[edi+TBBUTTON.idCommand],59
	mov	[edi+TBBUTTON.fsStyle],bl;TBSTYLE_BUTTON=0
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
wmDESTROY: invoke ExitProcess,ebx;завершение программы
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
	push [handlers+edi*4];aPrint
	push ebx;0               ; wParam
	push SB_SETTEXT;401h            ; Msg
	push [hStatus]	    ; hWnd
	call dword [esi];  SendMessageA
	jmp [handler+edi*4]
NewFile:
	jmp default
OpenFile:	
SaveFile: lea edi,[ofn]
	mov ecx,(sizeof.OPENFILENAME)/4
	xor eax,eax
	rep stosd
	lea edi,[ofn]
	mov [ofn+OPENFILENAME.lStructSize],sizeof.OPENFILENAME
	push dword [hwnd]
	pop [edi+OPENFILENAME.hwndOwner]
	mov [edi+OPENFILENAME.hInstance],400000h
	mov [edi+OPENFILENAME.lpstrFilter],ASMFilterString
	mov [edi+OPENFILENAME.lpstrFile],FileName
	mov byte [FileName],0
	mov [edi+OPENFILENAME.nMaxFile],100h;sizeof.FileName
	mov [edi+OPENFILENAME.Flags],OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	push edi
	cmp dword[wParam],52
	jnz short a1
	call [GetSaveFileName]
	jmp default
a1:	call [GetOpenFileName]
	jmp default
Cut:
Copy:
Paste:
Undo:
Search: jmp default
Preview: push 750
	push 1000
	push 750
	push 1000
	push ebx
	lea eax,[psd]
	push eax
	push dword[hwnd]
	call PageSetupDialog
	jmp default
Print:	;push aPrint
	;push ebx;0               ; wParam
	;push SB_SETTEXT;401h            ; Msg
	;push [hStatus]      ; hWnd
	;call dword [esi];  SendMessageA
	push PD_SHOWHELP
	lea eax,[pd]
	push eax
	push dword[hwnd]      ; hWnd
	call PrintDialog
	jmp default
About:	push 10003h;hIcon
	push aAssemblerPureS ; "Assembler, Pure & Simple"
	push wTitle ;'Iczelion Tutorial 8-12: инструментальная панель'
	push dword [hwnd]
	call [ShellAbout]
	jmp default
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
	add esp,sizeof.RECT+10h;освобождаем буфер
	retn 8
;=================================================================
PrintDialog:
hWin equ esp+sizeof.PRINTDLG+6
lppd equ esp+sizeof.PRINTDLG+0Ah
flags equ esp+sizeof.PRINTDLG+0Eh
pd    equ esp+2
  ; ------------------------------------------------------------------
  ; Parameters
  ; 1. hWin  = parent handle
  ; 2. lppd  = address of PRINTDLG to receive info
  ; 3. flags = additional styes from the PRINTDLG reference material
  ;
  ; EXAMPLE: invoke PrintDialog,hWin,ADDR pd,PD_SHOWHELP
  ; ------------------------------------------------------------------
    sub esp,sizeof.PRINTDLG+2;место под структуру PRINTDLG и pd

    mov [pd+PRINTDLG.lStructSize],sizeof.PRINTDLG
    push dword[hWin]
    pop [pd+PRINTDLG.hwndOwner]
    mov [pd+PRINTDLG.hDevMode], ebx
    mov [pd+PRINTDLG.hDevNames],ebx
    mov [pd+PRINTDLG.hDC],ebx
    mov eax, [flags]
    or	eax, PD_PAGENUMS    ; "or" default value with extra flags
    mov [pd+PRINTDLG.Flags], eax
    mov [pd+PRINTDLG.nFromPage],1
    mov [pd+PRINTDLG.nToPage],1
    mov [pd+PRINTDLG.nMinPage],bx;0
    mov [pd+PRINTDLG.nMaxPage],65535
    mov [pd+PRINTDLG.nCopies],1
    mov [pd+PRINTDLG.hInstance],ebx;0
    mov [pd+PRINTDLG.lCustData],ebx;0
    mov [pd+PRINTDLG.lpfnPrintHook],ebx;0
    mov [pd+PRINTDLG.lpfnSetupHook],ebx;0
    mov [pd+PRINTDLG.lpPrintTemplateName],ebx;0
    mov [pd+PRINTDLG.lpSetupTemplateName],ebx;0
    mov [pd+PRINTDLG.hPrintTemplate],ebx;0
    mov [pd+PRINTDLG.hSetupTemplate],ebx;0
    lea eax,[pd+PRINTDLG.lStructSize]
    push eax
    call [PrintDlg]

    mov ecx, sizeof.PRINTDLG
    lea esi, [pd]
    mov edi, [lppd];
    rep movsb

    add esp,sizeof.PRINTDLG+2;очистили буфер
    retn 0Ch
; endp PrintDialog
PageSetupDialog:
hWin	equ esp+sizeof.PAGESETUPDLG+4;ebp+8
lppsd	equ esp+sizeof.PAGESETUPDLG+8;ebp+0Ch
style	equ esp+sizeof.PAGESETUPDLG+0Ch;ebp+10h
lMargin equ esp+sizeof.PAGESETUPDLG+10h;ebp+14h
tMargin equ esp+sizeof.PAGESETUPDLG+14h;ebp+18h
rMargin equ esp+sizeof.PAGESETUPDLG+18h;ebp+1Ch
bMargin equ esp+sizeof.PAGESETUPDLG+1Ch;ebp+20h

    ; Parameters.
    ; ~~~~~~~~~~
    ; 1. hWin    = Parent window handle.
    ; 2. lppsd   = address of PAGESETUPDLG structure for return parameters
    ; 3. style   = Default is 0, else styles from PAGESETUPDLG reference.
    ; 4. lMargin = 0 defaults to 500, inch = 1000 
    ; 4. tMargin = 0 defaults to 500, inch = 1000 
    ; 4. rMargin = 0 defaults to 500, inch = 1000 
    ; 4. bMargin = 0 defaults to 500, inch = 1000 

    ; EXAMPLE : invoke PageSetupDialog,hWin,ADDR psd,0,1000,750,1000,750
;psd equ ebp-sizeof.PAGESETUPDLG
    sub esp,sizeof.PAGESETUPDLG
    lea esi,[style]
    lodsd;mov eax,[style]
    test eax,eax
    jnz short a10
    or dword[style], PSD_DEFAULTMINMARGINS or PSD_MARGINS or \
	       PSD_INTHOUSANDTHSOFINCHES		 ; default styles
a10: lodsd;mov eax,[lMargin]
     test eax,eax
     jnz a20
     mov dword[lMargin],500
a20: lodsd;mov eax, [tMargin]
     test eax,eax
     jnz a30
     mov dword[tMargin],500
a30: lodsd;mov eax, [rMargin]
     test eax,eax
     jnz a40
     mov dword[rMargin],500
a40: lodsd;mov eax, [bMargin]
     test eax,eax
     jnz a50
     mov dword[bMargin],500
a50: mov esi,esp;lea esi,[psd]

     mov [esi+PAGESETUPDLG.lStructSize],sizeof.PAGESETUPDLG
     push dword[hWin]
     pop [esi+PAGESETUPDLG.hwndOwner]
     mov [esi+PAGESETUPDLG.hDevMode],ebx
     mov [esi+PAGESETUPDLG.hDevNames],ebx
     mov eax, [style]
     mov [esi+PAGESETUPDLG.Flags],eax
     mov [esi+PAGESETUPDLG.ptPaperSize.x],ebx
     mov [esi+PAGESETUPDLG.ptPaperSize.y],ebx
     mov [esi+PAGESETUPDLG.rtMinMargin.left],ebx
     mov [esi+PAGESETUPDLG.rtMinMargin.top],ebx
     mov [esi+PAGESETUPDLG.rtMinMargin.right],ebx
     mov [esi+PAGESETUPDLG.rtMinMargin.bottom],ebx

     push dword[lMargin]
     pop [esi+PAGESETUPDLG.rtMargin.left]

     push dword[tMargin]
     pop [esi+PAGESETUPDLG.rtMargin.top]

     push dword[rMargin]
     pop [esi+PAGESETUPDLG.rtMargin.right]

     push dword[bMargin]
     pop [esi+PAGESETUPDLG.rtMargin.bottom]

     mov [esi+PAGESETUPDLG.hInstance],ebx
     mov [esi+PAGESETUPDLG.lCustData],ebx
     mov [esi+PAGESETUPDLG.lpfnPageSetupHook],ebx
     mov [esi+PAGESETUPDLG.lpfnPagePaintHook],ebx
     mov [esi+PAGESETUPDLG.lpPageSetupTemplateName],ebx
     mov [esi+PAGESETUPDLG.hPageSetupTemplate],ebx
     push esi
     call [PageSetupDlg]
     mov ecx,sizeof.PAGESETUPDLG
     mov edi,[lppsd]
     rep movsb
     add esp,sizeof.PAGESETUPDLG;очистили буфер
     retn 1Ch
;===============================================================
wTitle db 'Iczelion Tutorial #8-12:инструментальная панель в FASM',0
 aYouHaveSelecte db 'You have selected',0
 aNewFile	 db 'New File',0	 
 aOpenFile	 db 'Open File',0	
 aSaveFile	 db 'Save File',0
 aCut		 db 'Cut',0
 aCopy		 db 'Copy',0		
 aPaste 	 db 'Paste',0		 
 aUndo		 db 'Undo',0		 
 aSearch	 db 'Search',0
 aProperties	 db 'Properties',0
 aPrint 	 db 'Print',0
 aAbout 	 db 'О программе',0
aAssemblerPureS db 'Assembler, Pure & Simple',0
aPleaseConfirmE db 'Please Confirm Exit',0
	hStatus       dd 0
	hToolBar      dd 0
handlers dd aNewFile,aOpenFile,aSaveFile,aCut,aCopy,aPaste,aUndo,aSearch,aProperties,aPrint,0,aAbout
handler  dd NewFile, OpenFile, SaveFile, Cut, Copy, Paste, Undo, Search, Preview, Print, wmDESTROY, About
ASMFilterString 	db "ASM Source code (*.asm)",0,"*.asm",0
			db "All Files (*.*)",0,"*.*",0,0
FileName db 256 dup(?)

data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 comctl32, 'comctl32.dll',\
	 shell32,  'shell32.dll',\
	 ole32,    'ole32.dll',\
	 comdlg32, 'comdlg32.dll'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
 import user32,\
		RegisterClassEx,    'RegisterClassExA',\
		CreateWindowEx,     'CreateWindowExA',\
		DispatchMessage,    'DispatchMessageA',\
		DefWindowProc,	    'DefWindowProcA',\
		BeginPaint,	    'BeginPaint',\
		EndPaint,	    'EndPaint',\
		GetMessage,	    'GetMessageA',\
		SendMessage,	    'SendMessageA',\
		GetWindowRect,	    'GetWindowRect',\
		MoveWindow,	    'MoveWindow',\
		GetClientRect,	    'GetClientRect',\
		DrawEdge,	    'DrawEdge',\
		MessageBox,	    'MessageBoxA'
 import comdlg32,\
		GetSaveFileName,    'GetSaveFileNameA',\
		GetOpenFileName,    'GetOpenFileNameA',\
		PrintDlg,	    'PrintDlgA',\
		PageSetupDlg,	    'PageSetupDlgA',\
		ChooseColor,	    'ChooseColorA',\
		ChooseFont,	    'ChooseFontA'
 import comctl32,\
		InitCommonControls, 'InitCommonControls',\
		CreateToolbarEx,    'CreateToolbarEx',\
		CreateStatusWindow, 'CreateStatusWindowA'
 import shell32,\
		ShellAbout,	   'ShellAboutA',\
		SHBrowseForFolder,  'SHBrowseForFolderA',\
		SHGetPathFromDList, 'SHGetPathFromDListA'
 import ole32,\
		CoTaskMemFree,	    'CoTaskMemFree'
end data
