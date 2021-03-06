format PE GUI
include 'win32ax.inc'
; import data in the same section
	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke CreateSolidBrush,0FF0000h,ebx,edi;����� �����
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
	  invoke SetTimer,eax,ebx,50,ebx;������� ������ #0 �� 50mSec
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
wmTIMER:	 cmp [angle],3600; ���������� ���� � 360 ���������
		 sbb edx,edx;���� ���� ����� 360 ������ ���� ������ 0
		 and [angle],edx
		 invoke InvalidateRect,edi,ebx,1;������������� ����� � ������� ��������� ����
		 add [angle],16 ;���������� ���� �� 1,6 �������
		 jmp wmBYE
wmPAINT:	 invoke BeginPaint,edi,esp
		 mov ecx,[angle]
		 invoke    CreateFont,26,12,ecx,ecx,400,ebx,ebx,ebx,\;������� ����� �����
				   -1,\;OEM_CHARSET
				   ebx,\;OUT_DEFAULT_PRECIS
				   ebx,\;CLIP_DEFAULT_PRECIS
				   ebx,\;DEFAULT_QUALITY
				   DEFAULT_PITCH or FF_SCRIPT,\
				   "script",eax ;default font object
		 invoke    SelectObject,dword[esp+4],eax
		 lea esi,[expRect]
		 invoke GetClientRect,edi,esi
;---------������ �����
		 invoke SetTextColor,dword[esp+4],0x32C8C8;RGB=50,200,200 ���������� �����
		 invoke SetBkColor,dword[esp+4],0xFF0000;RGB=0,0,255 �� ����� ����
		 lea eax,[expSize];�������� ������� ������ �� ��������� � �����������
		 invoke GetTextExtentPoint32,dword[esp+12],expTxt,Num-expTxt,eax
		 push Num-expTxt ;���������� ���� � ������
		 push expTxt;����� ������ � �������
;---------���������� ��������� ������ ������
		 finit
		 push 0.0017453292519943295769236907684886;=pi/1800 � ����� ��� Y-����������
		 push eax;����� ��� X-����������
		 fld dword[esp+4];������ � FPU ����������� pi/1800
		 mov eax,[angle]
		 add eax,1800;�������� �������� ����
		 mov [esp+4],eax
		 fimul dword[esp+4];�������� ������� � �������
		 fsincos;� st(0) ����� ����, � st(1) �������
		 mov eax,[expSize+SIZE.cy]
		 mul eax ;�������� ������� ������ ������
		 mov [esp+4],eax
		 mov eax,[expSize+SIZE.cx]
		 mul eax ;�������� ������� ������ ������
		 add [esp+4],eax;����� ��������� �������
		 shr dword[esp+4],2
		 fild dword[esp+4];������� ����������=SQR(SIZE.cy)/4 + SQR(SIZE.cx)/4
		 fsqrt
		 fistp dword[esp+4];�������� ����������
		 fimul dword[esp+4];���������� * sin = x
		 fistp dword[esp]
		 fimul dword[esp+4];���������� * cos = y
		 fchs;������ ���� y
		 fistp dword[esp+4];-y
		 mov eax,[esi+RECT.bottom]
		 shr eax,1;y-���������� �������� ������
		 add [esp+4],eax;y-���������� ������ ������
		 mov ecx,[esi+RECT.right]
		 shr ecx,1;x-���������� �������� ������
		 add [esp],ecx;x-���������� ������ ������
		 invoke TextOut,dword[esp+16]
;---------------------------------------------------------------------
		 invoke EndPaint,edi,esp
;------------------------------------------------------------------
wmBYE:		 leave
		 retn 0x10
;-------------------------------------------------------------------
wmDESTROY:	invoke KillTimer,ebx;���������� ������ #0
		invoke ExitProcess,eax;��������� ���������
;������---------------------------------------------------------------------
      wTitle	db   'Iczelion Tutorial #4-1:Painting with Rotation Text',0 ;name of our window
      expTxt	db   'Win32 assembly with FASM is great and easy'
      Num	db   0
      angle	dd   0
      ;delta     dd   1767
      buffer	rb   30
      form	db '������=%d',0
;������--------------------------------------------------------
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