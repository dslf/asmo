format PE GUI
;�������� ������������� ����
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

wmCOMMAND:	  mov eax,[HWNDBTN];���������, �� ������ �� ������
		  cmp [lParam],eax
		  je YES_BUT
		  cmp word [wParam],5;���������, �� ������ �� ����� ���� MENUC - �����
		  je wmDESTROY
		  cmp word [wParam],4;���������, �� ������ �� ����� ���� � ��������������� 5
		  jne FINISH
YES_BUT:;��������� ������� ������. ������� ������� ����� � ���������
		  invoke SendMessage,edi,WM_SETTEXT,ebx,SPACE
		  dec [PRIZN]
		  jns l5
		  add [PRIZN],3;if (PRIZN < 0) PRIZN=2
		  jmp l5

wmCREATE:	  invoke CreateWindowEx,ebx,CLSBUTN,CPBUT,STYLBTN,\
		  10,10,120,25,edi,ebx,esi,ebx
		  mov [HWNDBTN],eax;��������� ���������� ������
l5:		  ;��������� ����������� ����
		  invoke LoadMenu,400000h,[PRIZN]
		  invoke SetMenu,edi,eax;���������� ����
		  jmp FINISH

wmMENUSELECT:	  mov ecx,[lParam]
		  jecxz FINISH;���������� ������ ��������� ��� ��������� � ����
		  test word [wParam+2],MF_POPUP;���������, ��� �������������� - ����� ���� ��� ��������� ����������� ����
		  setne al
;���������� ��������� ��� ������ ������� GetMenuItemInfo
		  lea esi,[MENI]
		  mov [esi+MENUITEMINFO.cbSize],sizeof.MENUITEMINFO
		  mov [esi+MENUITEMINFO.fMask],MIIM_TYPE
		  mov [esi+MENUITEMINFO.hSubMenu],ecx;MENI.hSubMenu:=lParam
		  mov [esi+MENUITEMINFO.dwTypeData],esp;��������� �� �����, ���������� ����������� ������
		  mov [esi+MENUITEMINFO.cch],100;sizeof.buffer;����� ������
		  push esi;�������� ���������� � ��������� ������ ����
		  push eax
;���� 0, �� � lword wParam ������������� ������ ����
;���� 1, �� � lword wParam ����� ��������� ����������� ����
		  movzx eax,word [wParam]
		  invoke GetMenuItemInfo,ecx,eax
;��������� ��������� ���������� �������
		  xchg eax,ecx;cmp eax,0
		  jecxz FINISH
;������� �������� ������ ���� ��� ��������� ����� ����
		  invoke SendMessage,edi,WM_SETTEXT,ebx,[esi+MENUITEMINFO.dwTypeData]
FINISH: 	  leave
		  retn 0x10

wmDESTROY:	 invoke ExitProcess,ebx
;endp
     ;exp = experiment
wTitle	  db   'Iczelion Tutorial 8-5',0 ;name of our window
SPACE db 30 dup(32),0
CLASSNAME db 'CLASS32',0
CPBUT	  db '������� ����',0
CLSBUTN   db 'BUTTON',0
HWNDBTN   dd 0
PRIZN dd 2;���������������� ������� �������
;2- ��������� ���� MENUN
;1- ��������� ���� MENUP
;0- ��������� ���� MENUC

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
	  menuitem '������ �����',10,MFR_POPUP
	  menuitem '������',1,MFT_STRING
	  menuitem '������',2,MFR_END
	  menuitem '������ �����',20,MFR_POPUP+MFR_END
	  menuitem '������',3,MFT_STRING
	  menuitem '���������',4,MFT_STRING
	  menuseparator
	  menuitem '��� �������',30,MFR_POPUP
	  menuitem '�������������� �����',6,MFT_STRING+MFR_END
	  menuitem '�����',5,MFR_END
     menu MENUC
	  menuitem '����� ������',10,MFR_POPUP
	  menuitem '�����',101,MFT_STRING
	  menuitem '�����',102,MFT_STRING
	  menuitem '������',103,MFR_END
	  menuitem '����� ������',30,MFR_POPUP+MFR_END
	  menuitem '�������',104,MFT_STRING
	  menuitem '�����',105,MFT_STRING
	  menuitem '�������',106,MFR_END
      menu MENUN
	  menuitem '',2,MFR_END