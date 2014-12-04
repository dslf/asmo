format PE GUI
include 'win32ax.inc'
; import data in the same section
;константы
ID_1	 equ	0
ID_2	 equ	1
ID_3	 equ	2
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h;hInstance
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi,esi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi,ebx,ebx
	  mov edi,eax		  ;hWnd
	  pop esi
	  invoke LoadImage,esi,aMybp1,ebx,ebx,ebx,LR_LOADFROMFILE
	  mov edx,sizeof.TBBUTTON
	  or ebx,2
	  lea ecx,[tbb+edx*2]
a1:	  mov [ecx+TBBUTTON.iBitmap],ebx
	  mov [ecx+TBBUTTON.idCommand],ebx;ID_1 ID_2 ID_3
	  mov [ecx+TBBUTTON.fsState],TBSTATE_ENABLED
	  test ebx,ebx
	  jz a3
	  sub ecx,edx
	  dec ebx
	  jmp a1
a3:	  invoke CreateToolbarEx,edi,WS_CHILD+WS_BORDER+WS_VISIBLE+TBSTYLE_TOOLTIPS,\
	  -1,3,ebx,eax,ecx,3,16,16,16,16,edx
	  lea esi,[hBlueBrush]
	  lea edi,[CreateSolidBrush]
	  mov ebp,0FF0000h
	  push ebp;синий=0FF0000h
	  call dword[edi]
	  mov [esi],eax;hBlueBrush
	  shr ebp,8
	  push ebp;зеленый=0FF00h
	  call dword[edi]
	  mov [esi+4],eax;hGreenBrush
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
hWnd	equ ebp+8
uMsg	equ ebp+0Ch
wParam	equ ebp+10h
lParam	equ ebp+14h
lpttt equ ebp-4

	 enter 4+sizeof.PAINTSTRUCT,0
	 mov eax,[uMsg]
	 mov edi,[hWnd]
	 dec eax; cmp uMsg,WM_DESTROY
	 dec eax
	 je wmDESTROY
	 sub eax,WM_SIZE-WM_DESTROY;cmp eax,WM_SIZE
	 je wmSIZE
	 sub eax,WM_PAINT-WM_SIZE;cmp eax,WM_PAINT
	 je wmPAINT
	 sub eax,WM_NOTIFY-WM_PAINT;cmp eax,WM_NOTIFY=4Eh
	 je wmNOTIFY
	 sub eax,WM_COMMAND-WM_NOTIFY; cmp uMsg,WM_COMMAND
	 je wmCOMMAND
	 leave
	 jmp dword [DefWindowProc]
wmPAINT: invoke BeginPaint,edi,esp;&Paint
	 mov ecx,[sw]
	 jecxz a6
	 invoke FillRect,eax,Rect,dword[hBlueBrush+ecx*4-4];hBlueBrush
a6:	 invoke EndPaint,edi,esp	   ;ќсвобождаем контекст отображени€
	 jmp end_wm_check
wmNOTIFY: mov edx,[lParam]   ;if( LPNMHDR(lParam)->code ==TTN_NEEDTEXT)
	  cmp [edx+NMHDR.code],TTN_NEEDTEXTA;dword ptr [edx+8],TTN_NEEDTEXTA
	  jnz end_wm_check
	  mov [lpttt],edx	  ;LPTOOLTIPTEXT lpttt = (LPTOOLTIPTEXT) lParam;
	mov eax,[edx+NMHDR.idFrom];[edx+4]       ;switch (lpttt->hdr.idFrom) {
	cmp eax,ID_3	      ;case ID_1:strcpy(lpttt->szText,"синий");break;
	ja end_wm_check ;case ID_2:strcpy(lpttt->szText,"зеленый");break;
	;case ID_3:strcpy(lpttt->szText,"выход");
	lea edx,[edx+TOOLTIPTEXT.szText]
	invoke lstrcpy,edx,dword[ps+eax*4]
	jmp end_wm_check
wmSIZE: mov eax,[lParam]
	mov word [Rect.right],ax
	shr eax,16
	mov [Rect.bottom],eax
	jmp end_wm_check
wmCOMMAND: mov eax,[wParam]
	jmp [handler+eax*4]
a2:	inc eax
	mov [sw],eax
	invoke InvalidateRect,edi,ebx,1
end_wm_check: leave
	retn 10h
wmDESTROY: invoke ExitProcess,ebx;завершение программы
;=================================================
handler dd a2,a2,wmDESTROY
wTitle	  db   'Iczelion Tutorial #8-10:инструментальна€ панель и всплывающие подсказки в FASM',0 ;name of our window
hBlueBrush	dd	?,?
sw	dd	0
tbb	TBBUTTON 0
	TBBUTTON 0
	TBBUTTON 0
aMybp1	db "btns.bmp",0
Rect	RECT 0
szText1 db '«аполнить синим',0
szText2 db '«аполнить зеленым',0
szText3 db '¬ыход',0
ps	dd szText1,szText2,szText3
data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 comctl32, 'comctl32.dll',\
	 gdi32,    'gdi32.dll'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess',\
	       lstrcpy, 	   'lstrcpyA'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		DispatchMessage,    'DispatchMessageA',\
		LoadImage,	    'LoadImageA',\
		BeginPaint,	    'BeginPaint',\
		EndPaint,	    'EndPaint',\
		InvalidateRect,     'InvalidateRect',\
		FillRect,	    'FillRect'

 import gdi32,\
		CreateSolidBrush,   'CreateSolidBrush'
 import comctl32,\
		CreateToolbarEx,    'CreateToolbarEx'
end data





