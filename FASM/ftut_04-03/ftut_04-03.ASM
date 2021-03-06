format PE GUI
include 'win32ax.inc'
; import data in the same section
ZZZ_STATIC	  equ 1
ZZZ_DRAWTEXTEX	  equ 2
ZZZ_TEXTOUT	  equ 3
ZZZ_TABBEDTEXTOUT equ 4
ZZZ_DRAWTEXT	  equ 5
ZZZ_POLYTEXTOUT   equ 6
ZZZ_EXTTEXTOUT	  equ 7
ZZZ_SETTEXT	  equ 8
ZZZ_EXIT	  equ 9

struc POLYTEXTA {
  .x	        DD ?
  .y	        DD ?
  .n	        DD ?
  .lpStr     DD ?
  .uiFlags   DD ?
  .icl	    RECT
  .pdx	    DD ?
}

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,ebx,\
	  ebx,esi,ebx,10011h,COLOR_BTNFACE+1,ebx,edi
	  invoke    LoadMenu,esi,30
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push esi
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE+WS_VSCROLL ,\
	  esi,esi,esi,esi,ebx,eax
	  pop esi
	  invoke CreateWindowEx,ebx,"STATIC",expTxt0,WS_CHILD + SS_LEFT,\
	  120,180,512,256,eax,ebx,esi,ebx
	  mov [hStaticText],eax
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
expRect equ ebp-sizeof.RECT
expSize equ expRect-sizeof.SIZE
	enter sizeof.RECT+sizeof.SIZE+sizeof.PAINTSTRUCT,0
		  mov eax,[uMsg]
		  mov edi,[hWnd]
		  dec eax; cmp uMsg,WM_DESTROY
		  dec eax
		  je wmDESTROY
		  sub eax,WM_PAINT-WM_DESTROY; cmp uMsg,WM_PAINT
		  je wmPAINT
		  sub eax,WM_COMMAND-WM_PAINT; cmp uMsg,WM_COMMAND=111h
		  je wmCOMMAND
		  sub eax,WM_CTLCOLORSTATIC-WM_COMMAND;WM_CTLCOLORSTATIC=138h
		  je wmCTLCOLORSTATIC
wmDEFAULT:	  leave
		  jmp dword [DefWindowProc]
wmCTLCOLORSTATIC: invoke SetBkColor,dword[wParam],0DEEBEFh
		  invoke GetStockObject,NULL_BRUSH
		  jmp wmBYE
wmPAINT:	  lea esi,[expRect]
		  invoke GetClientRect,edi,esi
		  add [esi+RECT.bottom],400
		  invoke BeginPaint,edi,esp
		  invoke FillRect,eax,esi,COLOR_BTNFACE+1
		  invoke SetBkMode,dword[esp+4],TRANSPARENT
		  mov eax,[Page]
		  jmp [handle+eax*4]
STATICText:	  invoke ShowWindow,[hStaticText],SW_SHOW
		  jmp a1
TextOut1:	  invoke TextOut,dword[esp+4*4],40,100,expTxt3A,expTxt3B-expTxt3A-1
		  invoke TextOut,dword[esp+4*4],40,120,expTxt3B,expTxt3C-expTxt3B-1
		  invoke TextOut,dword[esp+4*4],40,140,expTxt3C,expTxt3D-expTxt3C-1
		  invoke TextOut,dword[esp+4*4],40,160,expTxt3D,expTxt3E-expTxt3D-1
		  invoke TextOut,dword[esp+4*4],40,180,expTxt3E,expTxt4 -expTxt3E-1
		  jmp a1
TabbedTextOut1:   invoke TabbedTextOut,dword[esp+28],40,40,expTxt4,-1,ebx,ebx,ebx
		  jmp a1
DrawText1:	  invoke DrawText,dword[esp+16],expTxt1,-1,esi,DT_WORDBREAK
		  jmp a1
ExtTextOut1:	  invoke ExtTextOut,dword[esp+28],40,40,ebx,esi,expTxt2,expTxt3A-expTxt2-1,ebx
		  jmp a1
PolyTextOut1:	  
            invoke PolyTextOut,dword[esp+28],pptxt,1
		  jmp a1
SetText1:	  invoke SendMessage,dword[hWnd],WM_SETTEXT,ebx,expTxt7
NullText:	  jmp a1
wmCOMMAND:	  mov eax,[wParam]
		  cmp eax,ZZZ_EXIT;03
		  je wmDESTROY;menu_exit
		  mov [Page],eax
		  invoke SendMessage,dword[hWnd],WM_SETTEXT,ebx,wTitle
		  invoke ShowWindow,[hStaticText],SW_HIDE
		  invoke InvalidateRect,edi,ebx,ebx
		  jmp wmBYE
DrawTextEx1:	  invoke DrawTextEx,dword[esp+20],expTxt5,-1,esi,DT_LEFT+DT_WORDBREAK+DT_EXPANDTABS+\
		  DT_END_ELLIPSIS+DT_MODIFYSTRING+DT_WORD_ELLIPSIS,ebx
a1:		  invoke EndPaint,edi,esp
wmBYE:		  leave
		  retn 0x10

wmDESTROY:	 invoke ExitProcess,ebx

handle	dd NullText,STATICText,DrawTextEx1,TextOut1,TabbedTextOut1,DrawText1,PolyTextOut1,ExtTextOut1,SetText1
     ;exp = experiment
hStaticText dd ?
wTitle	  db   'Iczelion Tutorial #5-2:����� ������ ����� ��������� � FASM',0 ;name of our window
Page	       dd 0
;---------------------------------------------------------------------------------------------
expTxt0   db   '1) ����� ������ ��� ������ STATIC',10,'�������� ������� �������� � ��������� ������',10,\
      '������������� ��������� �����, �� ������� ��������� ��������� WM_PAINT',0
;---------------------------------------------------------------------------------------------
expTxt1   db   '5) ��� ������ ���������� ����� ������ � �������� ������ �������� ������������� ������� ���������� DrawText API',10,'��������:',10,\
'function DrawText (DC: HDC; Str: PChar; Count: Integer; var Rect: TRect; Format: Word): Integer;',10,\
'������ ��p����p������� �����. ��� ��p����p������ ����������� ��p����p�� Format. ���� �� ������� ���� dt_NoClip,',10,\
'����� ��p������� � ��p����������� �p�����������.',10,'��p����p�:',10,\
'DC: ������������p ��������� ���p������.',10,'Str: �������� ��p���. ���� Count=-1, �� ������ ������������� ������ ��������.',10,\
'Rect: TRect, ��p����������� �����.',10,'Format: ���� ��� ��������� ��������: dt_Bottom, dt_CalcRect, dt_Center, dt_ExpandTabs,',10,\
'dt_ExternalLeading, dt_Left, dt_NoClip, dt_NoPrefix, dt_Right, dt_SingleLine, dt_TabStop, dt_Top, dt_VCenter �',10,\
'dt_WordBreak. ��. p����� "����� ��p����p������ ������ �p� p��������, dt_" � ����� 1.',10,\
'����p������� ��������:     ������ ������.',10,' ������� ��������� � ����� user32.dll',0
;---------------------------------------------------------------------------------------------
      expTxt2	db   '7) ������� ExtTextOut ��������� ������������ ����� ',9,\
      '��������� ������ � �������� ������������� ������� � �������������� �������� ������ � ',\
      '��������� �������� ����������� ����',0;�����������
;---------------------------------------------------------------------------------------------
expTxt3A db '3) ����� ������ ��� ������ TextOut. ������� ������� ����� � �������� �����������,',0
expTxt3B db '������� ������ ����������� ������������ ������ (�������� ������ ����) �������',0
expTxt3C db '������� ����. �� �������� ������� �������� � ��������� ������. ��� �����������',0
expTxt3D db '������� ������� ����������� ������������� ��������� WM_PAINT.',0
expTxt3E db '����� ������� ��� ������ ������� TextOut ���������� ���� ���!',0
;---------------------------------------------------------------------------------------------
expTxt4	db   '4) ����� ������� ������������� ������� � ������������ ��������� ������ ����������',9,' TabbedTextOut API',0
;---------------------------------------------------------------------------------------------
expTxt5   db   '2) ��� ������ ���������� ����� ������ � �������� ������ �������� ������������� ������� ���������� DrawTextEx. ������� ������ ����������������� ����� � �������� ��������������. ',\
'����� ������������� �������� ��������� ������ (�������������� ���������, ������������ ��������, �������� �����, � �. �).',10,9,9,'DrawTextEx(hdc,lpchText,cchText,lprc,dwDTFormat,lpDTParams)',10,\
'���������:',10,'hdc',9,9,'���������� ��������� ���p������, � ������� ���������� ����������.',10,\
'lpchText',9,9,'��������� �� ������, ������� �������� ����� ��� ���������. ������ ������ ���� � ������� �������� � �����,',\
' ���� �������� cchText= -1. ',10,\
'cchText',9,9,'����� ������, ���� cchText=-1 � ������ ��������� ������� �������� - ����� ������ ����������� �������������.',10,\
'lprc',9,9,'��������� �� ��������� RECT, ���������� ������������� (� ���������� �����������), � ������� �����, ������ ���� ��������������',10,\
'dwDTFormat',9,'���������� ��������� ��������������. ���� �������� ����� ���� ���� ��� ��������� ������������� ��������.',10,\
'��������',9,9,'��������������',10,\
'DT_BOTTOM',9,9,'����������� ����� �� ��������� ��������������. ��� �������� ������������ ������ �� ��������� DT_SINGLELINE.',10,\
'DT_CALCRECT',9,9,'�������� ������ � ������ ��������������. ���� ������� ��������� ����� ������, ������� DrawTextEx ���������� ������ ��������������, ��������� ���������� lprc � ���������� ������ ��������������, ����� ���������� ��������� ������ ������.  ���� ���� ������ ���� ������ ������, DrawTextEx �������� ������ ������� �������������� ���, ����� ��� ������������ ��������� ����� � ������. � � ���, � � ������ ������, DrawTextEx ���������� �������� ������ ������������������ ������, �� �� ������� �����.',10,\
'DT_CENTER',9,9,'�������� ����� � �������������� �� �����������.',10,\
'DT_EDITCONTROL',9,'��������� �������������� ����������� ������ � ������������� ���� �������������� ������. � ������, ������� ������ ������� �������������� � ��� �� ����� ������, ��� � ��� ���� �������������� ������, � ������� �� ���������� �� ������ �������� ������� ��������� ������.',10,\
'DT_END_ELLIPSIS',9,'� ������������ �� ������ ������ ���������� ����� ������  ����������� ���, ����� ��������� ��������� � �������� ��������������. ����� ����� (�� � ����� ������) ������� ������� �� ������� ��������������, ���������� ��� ���������� (����). ������ �� ��������������, ���� ������ DT_MODIFYSTRING �� ����������.',10,\
'������������ � DT_PATH_ELLIPSIS � DT_WORD_ELLIPSIS.',10,\
'DT_EXPANDTABS',9,'����������� ����� �������� � ���������. �������� �� ��������� ����� �������� � ��������� - ������.',10,\
'DT_EXTERNALLEADING',9,'�������� ����������� ���������� ������ � ������ ������. ������, ����������� ���������� �� ���������� � ������ ������ ������.',10,\
'DT_HIDEPREFIX',9,9,'Windows 2000/XP: ���������� ���������� ������ && (���������) � ������. �����, ������� ������� �� ���, �� ����� �����������, �� ������ ������������-���������� ����� ��� ��� ��������������. ��������:',10,\
'��������� ������:    "A&&bc&&&&d"',10,\
'������:                    "A&bc&&d"',10,\
'DT_HIDEPREFIX:      "Abc&&d"',10,\
'������������ � DT_NOPREFIX � DT_PREFIXONLY.',10,\
'DT_INTERNAL',9,9,'���������� ��������� �����, ����� ���������� ������� ������.',10,\
'DT_LEFT',9,9,'����������� ����� �����.',10,\
'DT_MODIFYSTRING',9,'�������� �������� ������, ����� ����������� ������������ �� ������ �����. ��� �������� �� ����� �������� ��������, ���� �� ���������� ������ DT_END_ELLIPSIS ��� DT_PATH_ELLIPSIS.',10,\
'DT_NOCLIP',9,9,'������ ��� ��������� �� ��������. �������  DrawTextEx ���������� ��������� �������, ����� ������������ ������ DT_NOCLIP',10,\
'DT_NOFULLWIDTHCHARBREAK  Windows 98/Me, Windows 2000/XP: �� ��������� ������� ������ � DBCS (���������� ������ ������� ������), ���, ����� ������� �������� ������ ���� ������������ SBCS �������. ��������, ��� �������� ����� ���� ������������ � ����� � ��������� ������, ��� ������� ��������������� ����������. ��� �������� �� ����� �������� ��������, ���� ������ DT_WORDBREAK �� ����������.',10,\
'DT_NOPREFIX',9,9,'��������� ��������� ���������� ��������. ������, ������� DrawTextEx ������������ ������������-���������� ������ && ��� ���������, ����� ����������� �����, ������� ������� �����, �  ������������-���������� ������� && ��� ���������, ����� �������� (���������� �� ������) ������������ &. ������������ ������ DT_NOPREFIX, ��� ��������� �����������. ���������� � ������� DT_HIDEPREFIX � DT_PREFIXONLY.',10,\
'DT_PATH_ELLIPSIS',9,'��� ������������� �� ������ ������, �������� ����� (�������) � �������� ������ �� ���� ���, ����� ��������� ��������� � �������� ��������������. ���� ������ �������� ���� ��������� ����� ����� (\), ������ DT_PATH_ELLIPSIS ��������� � ����������� ��������� ������� ����� ����� ��������� ��������� ����� �����. ������ �� ��������������, ���� ������ DT_MODIFYSTRING �� ����������.',10,\
'������������ � �������� DT_END_ELLIPSIS � DT_WORD_ELLIPSIS.',10,\
'DT_PREFIXONLY',9,'Windows 2000/XP: ������ ������ ������������� � ������� �����, ��������� �� ���������� �������� && (���������)). �� ������� ������� ������ ������� � ������. ��������,',10,\
'��������� ������:    "A&&bc&&&&d"',10,\
'������:                    "A&bc&&d"',10,\
'DT_PREFIXONLY:     " _   "',10,\
'���������� � �������� DT_HIDEPREFIX � DT_NOPREFIX.',10,\
'DT_RIGHT',9,9,'����������� ����� ������.',10,\
'DT_RTLREADING',9,'��������� ������� ������ ������ ������  ��� ���������������� ������, ����� �����, ��������� � hdc - ����� ���������� ��� ��������� �����.   �������� �� ��������� ������� ������ ��� ���� ������� - ����� �������.',10,\
'DT_SINGLELINE',9,9,'���������� �� ������ ����� ������ � ������������ ������. �������� ������� � �������� ������ �� ��������� ������.',10,\
'DT_TABSTOP',9,9,'������������� ���� ���������. ��������� DRAWTEXTPARAMS ���������, ���  �������� lpDTParams ������ ����� �������� ������� ������ �� ��� ���������.',10,\
'DT_TOP',9,9,9,'����������� ����� �� ����� ��������������.',10,\
'DT_VCENTER',9,9,'���������� ����� �� ���������. ��� �������� ������������ ������ ��  ��������� DT_SINGLELINE.',10,\
'DT_WORDBREAK',9,'����� �����. ������ ������������� ������� �� ������, ���� ����� ������� �� ���� ��������������, ��������� ���������� lprc . ������� ������� - ������������������ �������� ������ ����� ����� ������.',10,\
'DT_WORD_ELLIPSIS',9,'�������� ����� �����, ������� �� ��������� � �������������� � ��������� ���������.',10,\
'������������ � �������� DT_END_ELLIPSIS � DT_PATH_ELLIPSIS.',10,\
'lpDTParams',9,9,'��������� �� ��������� DRAWTEXTPARAMS, ������� ������������� �������������� ��������� ��������������. ���� �������� ����� ����� �������� ����� (NULL).',10,\
'������������ ��������',10,\
'���� ������� ����������� �������, ������������ �������� - ������ ������ � ���������� �������� ���������. ���� ����������� ������ DT_VCENTER ��� DT_BOTTOM, ������������ �������� - �������� � lprc->top � ��������� ���������� ������.',10,\
'���� ������� ����������� � �������, �������� ������������� �������� - ����.',0
expTxt7   db   '����� ������ � ��������� ���� ����� SendMessage',0
Numb = $ - expTxt7 - 1

pptxt  dd 40,40,Numb,expTxt7,0,0,0,0,0,0

data import
 library KERNEL32, 'KERNEL32.DLL',\
	 gdi32,    'gdi32.dll',\
	 user32,   'USER32.DLL'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
import gdi32,\
	       TextOut, 	   'TextOutA',\
	       ExtTextOut,	   'ExtTextOutA',\
	       PolyTextOut,	   'PolyTextOutA',\
	       SetTextColor,	   'SetTextColor',\
	       SetBkColor,	   'SetBkColor',\
	       GetStockObject,	   'GetStockObject',\
	       SetTextAlign,	   'SetTextAlign',\
	       SetBkMode,	   'SetBkMode'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		GetClientRect,	    'GetClientRect',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		DispatchMessage,    'DispatchMessageA',\
		DestroyWindow,	    'DestroyWindow',\
		BeginPaint,	    'BeginPaint',\
		EndPaint,	    'EndPaint',\
		FillRect,	    'FillRect',\
		GetDC,		    'GetDC',\
		DrawTextEx,	    'DrawTextExA',\
		DrawText,	    'DrawTextA',\
		ReleaseDC,	    'ReleaseDC',\
		ShowWindow,	    'ShowWindow',\
		InvalidateRect,     'InvalidateRect',\
		TabbedTextOut,	    'TabbedTextOutA',\
		SendMessage,	    'SendMessageA',\
		LoadMenu,	    'LoadMenuA'

end data
section '.rsrc' resource data readable
     directory RT_MENU,appMenu

     resource  appMenu,\
	       30,LANG_ENGLISH,menuMain

     menu menuMain
	  menuitem 'Text Output',0,MFR_POPUP
	  menuitem 'Static',ZZZ_STATIC,MFT_STRING
	  menuitem 'DrawTextEx',ZZZ_DRAWTEXTEX,MFT_STRING
	  menuitem 'TextOut',ZZZ_TEXTOUT,MFT_STRING
	  menuitem 'TabbedTextOut',ZZZ_TABBEDTEXTOUT,MFT_STRING
	  menuitem 'DrawText',ZZZ_DRAWTEXT,MFT_STRING
	  menuitem 'PolyTextOut',ZZZ_POLYTEXTOUT,MFT_STRING
	  menuitem 'ExtTextOut',ZZZ_EXTTEXTOUT,MFT_STRING
	  menuitem 'Settext',ZZZ_SETTEXT,MFT_STRING
	  menuseparator
	  menuitem '&Exit',ZZZ_EXIT,MFR_END

	  menuitem '&Exit',ZZZ_EXIT,MFR_END