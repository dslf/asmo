format PE GUI
include 'win32ax.inc'
; import data in the same section
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke CreateSolidBrush,0FF0000h,ebx,edi;синяя кисть
	  invoke RegisterClass,esp,CS_HREDRAW or CS_VREDRAW,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,eax
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
	  esi,esi,esi,esi,ebx,ebx
	  invoke SetTimer,eax,ebx,50,ebx;создаем таймер #0 на 50mSec
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
	hWnd	 equ ebp+8
	uMsg	 equ ebp+0xC
	expRect  equ ebp - sizeof.RECT
	expSize  equ expRect - sizeof.SIZE
		 enter sizeof.PAINTSTRUCT + sizeof.RECT + sizeof.SIZE,0
		 mov eax,[uMsg]
		 mov edi,[hWnd]
		 dec eax; cmp uMsg,WM_DESTROY
		 dec eax
		 je wmDESTROY
		 sub eax,WM_TIMER-WM_DESTROY; cmp uMsg,WM_PAINT
		 je   wmTIMER
		 sub eax,WM_PAINT-WM_TIMER; cmp uMsg,WM_PAINT
		 je   wmPAINT
		 leave
		 jmp dword [DefWindowProc]
wmTIMER:	 cmp [angle],3600; сравниваем угол с 360 градусами
		 sbb edx,edx;если угол равен 360 делаем угол равным 0
		 and [angle],edx
		 invoke InvalidateRect,edi,ebx,1;перерисовывам текст с текущим значением угла
		 add [angle],16 ;увеличивам угол на 1,6 градуса
		 jmp wmBYE
wmPAINT:	 invoke BeginPaint,edi,esp
		 mov ecx,[angle]
		 invoke    CreateFont,26,12,ecx,ecx,400,ebx,ebx,ebx,\;создаем новый шрифт
				   -1,\;OEM_CHARSET
				   ebx,\;OUT_DEFAULT_PRECIS
				   ebx,\;CLIP_DEFAULT_PRECIS
				   ebx,\;DEFAULT_QUALITY
				   DEFAULT_PITCH or FF_SCRIPT,\
				   "script",eax ;default font object
		 invoke    SelectObject,dword[esp+4],eax
		 lea esi,[expRect]
		 invoke GetClientRect,edi,esi
;---------вывожу текст
		 invoke SetTextColor,dword[esp+4],0x32C8C8;RGB=50,200,200 золотистые буквы
		 invoke SetBkColor,dword[esp+4],0xFF0000;RGB=0,0,255 на синем фоне
		 lea eax,[expSize];получаем размеры текста по вертикали и горизонтали
		 invoke GetTextExtentPoint32,dword[esp+12],expTxt,Num-expTxt,eax
		 push Num-expTxt ;количество букв в тексте
		 push expTxt;адрес строки с текстом
;---------расчитываю положение начала текста
		 finit
		 push 0.0017453292519943295769236907684886;=pi/1800 и место для Y-координаты
		 push eax;место для X-координаты
		 fld dword[esp+4];грузим в FPU коэффициент pi/1800
		 mov eax,[angle]
		 add eax,1800;получили истинный угол
		 mov [esp+4],eax
		 fimul dword[esp+4];перевели градусы в радианы
		 fsincos;в st(0) синус угла, в st(1) косинус
		 mov eax,[expSize+SIZE.cy]
		 mul eax ;получили квадрат высоты текста
		 mov [esp+4],eax
		 mov eax,[expSize+SIZE.cx]
		 mul eax ;получили квадрат ширины текста
		 add [esp+4],eax;сумма квадратов катетов
		 shr dword[esp+4],2
		 fild dword[esp+4];квадрат гипотенузы=SQR(SIZE.cy)/4 + SQR(SIZE.cx)/4
		 fsqrt
		 fistp dword[esp+4];получили гипотенузу
		 fimul dword[esp+4];гипотенуза * sin = x
		 fistp dword[esp]
		 fimul dword[esp+4];гипотенуза * cos = y
		 fchs;меняем знак y
		 fistp dword[esp+4];-y
		 mov eax,[esi+RECT.bottom]
		 shr eax,1;y-координата середины экрана
		 add [esp+4],eax;y-координата начала текста
		 mov ecx,[esi+RECT.right]
		 shr ecx,1;x-координата середины экрана
		 add [esp],ecx;x-координата начала текста
		 invoke TextOut,dword[esp+16]
;---------------------------------------------------------------------
		 invoke EndPaint,edi,esp
;------------------------------------------------------------------
wmBYE:		 leave
		 retn 0x10
;-------------------------------------------------------------------
wmDESTROY:	invoke KillTimer,ebx;уничтожаем таймер #0
		invoke ExitProcess,eax;завершаем программу
;данные---------------------------------------------------------------------
      wTitle	db   'Iczelion Tutorial #4-1:Painting with Rotation Text',0 ;name of our window
      expTxt	db   'Win32 assembly with FASM is great and easy'
      Num	db   0
      angle	dd   0
      ;delta     dd   1767
      buffer	rb   30
      form	db 'ширина=%d',0
;импорт--------------------------------------------------------
data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL',\
	 gdi32,    'gdi32.dll'
 import KERNEL32,\
		ExitProcess,	    'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		BeginPaint,	    'BeginPaint',\
		GetClientRect,	    'GetClientRect',\
		EndPaint,	    'EndPaint',\
		SetTimer,	    'SetTimer',\
		KillTimer,	    'KillTimer',\
		InvalidateRect,     'InvalidateRect',\
\;        MessageBox,         'MessageBoxA',\
		wsprintf,	    'wsprintfA',\
		DispatchMessage,    'DispatchMessageA'
  import gdi32,\
		TextOut,	    'TextOutA',\
		CreateFont,	    'CreateFontA',\
		SetTextColor,	    'SetTextColor',\
		SetBkColor,	    'SetBkColor',\
		GetTextExtentPoint32,'GetTextExtentPoint32A',\
		GetCurrentObject,   'GetCurrentObject',\
		SelectObject,	    'SelectObject',\
		CreateSolidBrush,   'CreateSolidBrush'
end data