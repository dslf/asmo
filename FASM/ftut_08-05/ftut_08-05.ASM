format PE GUI
;Создание динамического меню
include 'win32ax.inc'
; import data in the same section
STYLBTN equ BS_DEFPUSHBUTTON+WS_VISIBLE+WS_CHILD

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,CS_VREDRAW+CS_HREDRAW,\
	  window_procedure,ebx,ebx,esi,ebx,10011h,COLOR_WINDOW+1,ebx,edi
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,SPACE,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
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
hWnd	equ ebp+8
uMsg	equ ebp+0xC
wParam	equ ebp+10h
lParam	equ ebp+14h
MENI	equ ebp-sizeof.MENUITEMINFO
buffer	equ MENI-100
		  enter 100+sizeof.MENUITEMINFO,0
		  mov eax,[uMsg]
		  mov edi,[hWnd]
		  dec eax; cmp uMsg,WM_CREATE
		  je wmCREATE
		  dec eax; cmp uMsg,WM_DESTROY
		  je wmDESTROY
		  sub eax,WM_COMMAND-WM_DESTROY; cmp uMsg,WM_PAINT
		  je wmCOMMAND
		  sub eax,WM_MENUSELECT-WM_COMMAND
		  je wmMENUSELECT
wmDEFAULT:	  leave
		  jmp dword [DefWindowProc]

wmCOMMAND:	  mov eax,[HWNDBTN];проверить, не нажата ли кнопка
		  cmp [lParam],eax
		  je YES_BUT
		  cmp word [wParam],5;проверить, не выбран ли пункт меню MENUC - выход
		  je wmDESTROY
		  cmp word [wParam],4;проверить, не выбран ли пункт меню с идентификатором 5
		  jne FINISH
YES_BUT:;обработка нажатия кнопки. сначала стереть текст в заголовке
		  invoke SendMessage,edi,WM_SETTEXT,ebx,SPACE
		  dec [PRIZN]
		  jns l5
		  add [PRIZN],3;if (PRIZN < 0) PRIZN=2
		  jmp l5

wmCREATE:	  invoke CreateWindowEx,ebx,CLSBUTN,CPBUT,STYLBTN,\
		  10,10,120,25,edi,ebx,esi,ebx
		  mov [HWNDBTN],eax;запомнить дескриптор кнопки
l5:		  ;загрузить необходимое меню
		  invoke LoadMenu,400000h,[PRIZN]
		  invoke SetMenu,edi,eax;установить меню
		  jmp FINISH

wmMENUSELECT:	  mov ecx,[lParam]
		  jecxz FINISH;пропускаем первое сообщение при обращении к меню
		  test word [wParam+2],MF_POPUP;проверяем, что активизировано - пункт меню или заголовок выпадающего меню
		  setne al
;заполнение структуры для вызова функции GetMenuItemInfo
		  lea esi,[MENI]
		  mov [esi+MENUITEMINFO.cbSize],sizeof.MENUITEMINFO
		  mov [esi+MENUITEMINFO.fMask],MIIM_TYPE
		  mov [esi+MENUITEMINFO.hSubMenu],ecx;MENI.hSubMenu:=lParam
		  mov [esi+MENUITEMINFO.dwTypeData],esp;указатель на буфер, получающий необходимую строку
		  mov [esi+MENUITEMINFO.cch],100;sizeof.buffer;длина буфера
		  push esi;получить информацию о выбранном пункте меню
		  push eax
;если 0, то в lword wParam идентификатор пункта меню
;если 1, то в lword wParam номер заголовка выпадающего меню
		  movzx eax,word [wParam]
		  invoke GetMenuItemInfo,ecx,eax
;проверить результат выполнения функции
		  xchg eax,ecx;cmp eax,0
		  jecxz FINISH
;вывести название пункта меню как заголовок всего окна
		  invoke SendMessage,edi,WM_SETTEXT,ebx,[esi+MENUITEMINFO.dwTypeData]
FINISH: 	  leave
		  retn 0x10

wmDESTROY:	 invoke ExitProcess,ebx
;endp
     ;exp = experiment
wTitle	  db   'Iczelion Tutorial 8-5',0 ;name of our window
SPACE db 30 dup(32),0
CLASSNAME db 'CLASS32',0
CPBUT	  db 'Сменить меню',0
CLSBUTN   db 'BUTTON',0
HWNDBTN   dd 0
PRIZN dd 2;инициализировали счетчик двойкой
;2- загружено меню MENUN
;1- загружено меню MENUP
;0- загружено меню MENUC

data import
 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL'
 import KERNEL32,\
		ExitProcess,	    'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		DispatchMessage,    'DispatchMessageA',\
		MessageBox,	    'MessageBoxA',\
		LoadMenu,	    'LoadMenuA',\
		SetMenu,	    'SetMenu',\
		SendMessage,	    'SendMessageA',\
		GetMenuItemInfo,    'GetMenuItemInfoA'
end data
section '.rsrc' resource data readable
     directory RT_MENU,appMenu
macro du [args]
 { common local ..times,..size,..char 
   virtual at 0 
      db args 
      ..size = $ 
   end virtual 
   repeat ..size 
      virtual at 0 
	db args 
	load ..char byte from $ - ..size + % - 1 
      end virtual 
      if ..char > 127 
	db ..char-0b0h, 04h 
      else 
	du ..char 
      end if 
   end repeat } 

struc du [args] { common du args }

     resource  appMenu,\
	       2,LANG_ENGLISH+SUBLANG_ENGLISH_US,MENUN,\
	       1,LANG_ENGLISH+SUBLANG_ENGLISH_US,MENUP,\
	       0,LANG_ENGLISH+SUBLANG_ENGLISH_US,MENUC
     menu MENUP
	  menuitem 'Первый пункт',10,MFR_POPUP
	  menuitem 'Первый',1,MFT_STRING
	  menuitem 'Второй',2,MFR_END
	  menuitem 'Второй пункт',20,MFR_POPUP+MFR_END
	  menuitem 'Третий',3,MFT_STRING
	  menuitem 'Четвертый',4,MFT_STRING
	  menuseparator
	  menuitem 'Еще подменю',30,MFR_POPUP
	  menuitem 'Дополнительный пункт',6,MFT_STRING+MFR_END
	  menuitem 'Выход',5,MFR_END
     menu MENUC
	  menuitem 'Набор первый',10,MFR_POPUP
	  menuitem 'Белый',101,MFT_STRING
	  menuitem 'Серый',102,MFT_STRING
	  menuitem 'Черный',103,MFR_END
	  menuitem 'Набор второй',30,MFR_POPUP+MFR_END
	  menuitem 'Красный',104,MFT_STRING
	  menuitem 'Синий',105,MFT_STRING
	  menuitem 'Зеленый',106,MFR_END
      menu MENUN
	  menuitem '',2,MFR_END