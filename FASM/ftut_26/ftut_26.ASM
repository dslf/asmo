format PE GUI
include 'win32ax.inc'
start:	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi,esi
	  push ebx
	  push esi
	  shl esi,9;esi=80000000h
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW,\
	  esi,esi,esi,esi,ebx,ebx
	  mov [hwnd],eax
	  pop esi
	  invoke LoadImage,esi,wTitle,ebx,ebx,ebx,LR_LOADFROMFILE,ebx,hwnd
	  invoke CreatePatternBrush,eax

	  invoke RegisterClass,esp,ebx,SplashProc,ebx,\
	  ebx,esi,ebx,10011h,eax,

	  invoke GetSystemMetrics,SM_CYSCREEN,320,400,ebx,ebx,esi,ebx
	  shr eax,1;Y - координата центра экрана
	  sub ax,200;минус половина высоты картинки
	  invoke GetSystemMetrics,ebx,eax
	  shr eax,1;X - координата центра экрана
	  sub eax,160;минус половина ширины картинки
	  invoke CreateWindowEx,ebx,hwnd,ebx,WS_POPUP+WS_VISIBLE,eax
	  ;адpес функции, котоpа€ будет обpабатывать уведомительные сообщени€ от таймеpа
	  ;вpеменной интеpвал в миллисекундах - через 2 секунды закроем splash
	  ;TimerID - заданное пользователем значение, котоpое будет использоватьс€ в качестве ID таймеpа
	  ;сообщени€ таймера пойдут splash-окну
	  invoke SetTimer,eax,1,2000,ebx
	  mov ebp,esp
   ;+---------------------------+
   ;| entering the message loop |
   ;+---------------------------+
   window_message_loop_start:
	  invoke GetMessage,ebp,ebx,ebx,ebx
	  invoke DispatchMessage,ebp
	  jmp window_message_loop_start
   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
window_procedure: cmp dword[esp+8],WM_DESTROY
	  je wmDESTROY
	  jmp dword [DefWindowProc]
wmDESTROY: invoke ExitProcess,ebx
proc SplashProc  hWnd, uMsg, wParam, lParam
	mov edi,[hWnd]
	mov eax,[uMsg]
	cmp eax,WM_TIMER
	je short wmTIMER
	cmp eax,WM_LBUTTONDOWN
	je short wmLBUTTONDOWN
;все сообщени€, не обрабатываемые в функции SplashProc,
	leave
	jmp [DefWindowProc];направл€ютс€ на обработку по умолчанию
wmLBUTTONDOWN: ;по левому клику или по сигналу от таймера закрываем splash
wmTIMER: invoke KillTimer,edi,1;убираем таймер
	invoke DestroyWindow,edi;разрушаем splash
	invoke ShowWindow,[hwnd],SW_SHOWNORMAL;показываем основное окно
	leave
	retn 10h
 endp

	wTitle	       db 'Images\JourneyStart.bmp',0
	hwnd	      dd ?
data import
library     KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL',\
		GDI32,	  'GDI32.DLL'
    
    import	KERNEL32,\
		ExitProcess,		'ExitProcess'

    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		GetMessage,		'GetMessageA',\
		DispatchMessage,	'DispatchMessageA',\
		LoadImage,		'LoadImageA',\
		GetSystemMetrics,	'GetSystemMetrics',\
		SetTimer,		'SetTimer',\
		KillTimer,		'KillTimer',\
		DestroyWindow,		'DestroyWindow',\
		ShowWindow,		'ShowWindow'

    import	GDI32,\
		CreatePatternBrush,	'CreatePatternBrush'
end data