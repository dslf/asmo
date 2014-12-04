format PE GUI
include 'win32ax.inc'
; import data in the same section
;константы
ID_1	 equ	0
ID_2	 equ	1
ID_3	 equ	2
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  push ebx
	  push ebx
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi
	  mov edi,eax		  ;hWnd
	  push LR_LOADFROMFILE
	  push ebx		  ;0
	  push ebx		  ;0
	  push ebx		  ;IMAGE_BITMAP
	  push aMybp1
	  push esi		  ;hInstance
	  call [LoadImage]
	  mov edx,sizeof.TBBUTTON
	  or ebx,2
	  lea ecx,[tbb+edx*2]
a1:	  mov [ecx+TBBUTTON.iBitmap],ebx
	  mov [ecx+TBBUTTON.idCommand],ebx
	  mov [ecx+TBBUTTON.fsState],TBSTATE_ENABLED
	  test ebx,ebx
	  jz a3
	  sub ecx,edx
	  dec ebx
	  jmp a1
a3:	  push edx;size TBBUTTON  ;размер структуры TBBUTTON
	  push 16		  ;ширина и высота
	  push 16		  ;изображения на каждой кнопке
	  push 16		  ;ширина и высота
	  push 16		  ;каждой кнопки
	  push 3		  ;число кнопок
	  push ecx;offset tbb     ;адрес массива структуры типа TBBUTTON
	  push eax		  ;идентификатор ресурса с изображением кнопок
	  push ebx		  ;0
	  push 3		  ;число изображений кнопок в файле bmp
	  push -1;идентификатор всей инструментальной панели, который в программе не используется и может быть равен -1
	  push WS_CHILD+WS_BORDER+WS_VISIBLE;стиль инструментальной панели
	  push edi		  ;дескриптор главного окна
	  call [CreateToolbarEx]
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
	 enter sizeof.PAINTSTRUCT,0
	 mov eax,[uMsg]
	 mov edi,[hWnd]
	 dec eax; cmp uMsg,WM_DESTROY
	 dec eax
	 je wmDESTROY
	 sub eax,WM_SIZE-WM_DESTROY;cmp eax,WM_SIZE
	 je wmSIZE
	 sub eax,WM_PAINT-WM_SIZE;cmp eax,WM_PAINT
	 je wmPAINT
	 sub eax,WM_COMMAND-WM_PAINT; cmp uMsg,WM_COMMAND
	 je wmCOMMAND
	 leave
	 jmp dword [DefWindowProc]
wmPAINT: push esp;&Paint
	 push edi;hwnd
	 call [BeginPaint]
	 mov ecx,[sw]
	 jecxz a6
	 push dword[hBlueBrush+ecx*4-4];hBlueBrush
	 push Rect
	 push eax
	 call [FillRect]
a6:	 push esp  ;&Paint
	 push edi;hWnd
	 call [EndPaint]	   ;Освобождаем контекст отображения
	 jmp end_wm_check
wmSIZE:  mov eax,[lParam]
	 mov word [Rect.right],ax
	 shr eax,16
	 mov [Rect.bottom],eax
	 jmp short end_wm_check
wmCOMMAND: mov eax,[wParam]
	 jmp [handler+eax*4]
a2:	 inc eax
	 mov [sw],eax
	 push 1
	 push ebx;0
	 push edi;hwnd
	 call [InvalidateRect]
end_wm_check: leave
	 retn 0x10
wmDESTROY: invoke ExitProcess,ebx;завершение программы
;==================================================
handler dd a2,a2,wmDESTROY
wTitle	  db   'Iczelion Tutorial #8-9:инструментальная панель в FASM',0 ;name of our window
hBlueBrush	dd	?,?
sw		dd	0
tbb	TBBUTTON 0
	TBBUTTON 0
	TBBUTTON 0
aMybp1	db "btns.bmp",0
Rect	RECT <0>

data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 comctl32, 'comctl32.dll',\
	 gdi32,    'gdi32.dll'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
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





