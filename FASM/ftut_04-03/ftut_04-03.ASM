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
wTitle	  db   'Iczelion Tutorial #5-2:Вывод текста всеми способами в FASM',0 ;name of our window
Page	       dd 0
;---------------------------------------------------------------------------------------------
expTxt0   db   '1) Вывод текста при помощи STATIC',10,'Понимает символы перевода и табуляции строки',10,\
      'автоматически переносит слова, не требует обработки сообщения WM_PAINT',0
;---------------------------------------------------------------------------------------------
expTxt1   db   '5) Для вывода нескольких строк текста в пределах границ заданной прямоугольной области используют DrawText API',10,'Описание:',10,\
'function DrawText (DC: HDC; Str: PChar; Count: Integer; var Rect: TRect; Format: Word): Integer;',10,\
'Рисует фоpматиpованный текст. Тип фоpматиpования указывается паpаметpом Format. Если не указано явно dt_NoClip,',10,\
'текст выpезается в огpаничивающий пpямоугольник.',10,'Паpаметpы:',10,\
'DC: Идентификатоp контекста устpойства.',10,'Str: Рисуемая стpока. Если Count=-1, то должна заканчиваться пустым символом.',10,\
'Rect: TRect, огpаничивающий текст.',10,'Format: Одна или несколько констант: dt_Bottom, dt_CalcRect, dt_Center, dt_ExpandTabs,',10,\
'dt_ExternalLeading, dt_Left, dt_NoClip, dt_NoPrefix, dt_Right, dt_SingleLine, dt_TabStop, dt_Top, dt_VCenter и',10,\
'dt_WordBreak. См. pаздел "Флаги фоpматиpования текста пpи pисовании, dt_" в главе 1.',10,\
'Возвpащаемое значение:     Высота текста.',10,' функция находится в файле user32.dll',0
;---------------------------------------------------------------------------------------------
      expTxt2	db   '7) Функция ExtTextOut позволяет осуществлять вывод ',9,\
      'текстовой строки в заданную прямоугольную обдасть с использованием текущего шрифта и ',\
      'управляет режимами отображения фона',0;разобраться
;---------------------------------------------------------------------------------------------
expTxt3A db '3) Вывод текста при помощи TextOut. Функция выводит текст в заданных координатах,',0
expTxt3B db 'которые всегда указываются относительно начала (верхнего левого угла) рабочей',0
expTxt3C db 'области окна. Не понимает символы переноса и табуляции строки. При перерисовке',0
expTxt3D db 'рабочей области потребуется предусмотреть обработку WM_PAINT.',0
expTxt3E db 'Чтобы вывести эти строки функция TextOut вызывалась пять раз!',0
;---------------------------------------------------------------------------------------------
expTxt4	db   '4) Чтобы создать многоколонную таблицу с выровненными столбцами текста используют',9,' TabbedTextOut API',0
;---------------------------------------------------------------------------------------------
expTxt5   db   '2) Для вывода нескольких строк текста в пределах границ заданной прямоугольной области используют DrawTextEx. Функция рисует отформатированный текст в заданном прямоугольнике. ',\
'Текст форматируется согласно заданному методу (дополнительная табуляция, выравнивание символов, переносы строк, и т. д).',10,9,9,'DrawTextEx(hdc,lpchText,cchText,lprc,dwDTFormat,lpDTParams)',10,\
'Параметры:',10,'hdc',9,9,'дескриптор контекста устpойства, в котором происходит прорисовка.',10,\
'lpchText',9,9,'Указатель на строку, которая содержит текст для рисования. Строка должна быть с нулевым символом в конце,',\
' если параметр cchText= -1. ',10,\
'cchText',9,9,'длина строки, если cchText=-1 и строка закончена нулевым символом - длина строки расчитается автоматически.',10,\
'lprc',9,9,'Указатель на структуру RECT, содержащую прямоугольник (в логических координатах), в котором текст, должен быть отформатирован',10,\
'dwDTFormat',9,'Определяет параметры форматирования. Этот параметр может быть один или несколько нижеследующих значений.',10,\
'Значение',9,9,'Предназначение',10,\
'DT_BOTTOM',9,9,'Выравнивает текст по основанию прямоугольника. Это значение используется только со значением DT_SINGLELINE.',10,\
'DT_CALCRECT',9,9,'Выясняет ширину и высоту прямоугольника. Если имеется несколько строк текста, функция DrawTextEx использует ширину прямоугольника, указанную параметром lprc и продлевает основу прямоугольника, чтобы ограничить последнюю строку текста.  Если есть только одна строка текста, DrawTextEx изменяет правую сторону прямоугольника так, чтобы она ограничивала последнюю букву в строке. И в том, и в другом случае, DrawTextEx возвращает значение высоты отформатированного текста, но не выводит текст.',10,\
'DT_CENTER',9,9,'Центрует текст в прямоугольнике по горизонтали.',10,\
'DT_EDITCONTROL',9,'Дублирует характеристики отображения текста в многострочном поле редактирования текста. А именно, средняя ширина символа рассчитывается в той же самой манере, как и для поля редактирования текста, и функция не показывает на экране частично видимую последнюю строку.',10,\
'DT_END_ELLIPSIS',9,'В отображаемом на экране тексте заменяется конец строки  эллипсисами так, чтобы результат вместился в заданном прямоугольнике. Любое слово (не в конце строки) которое выходит за пределы прямоугольника, обрезается без эллипсисов (тире). Строка не модифицируется, если флажок DT_MODIFYSTRING не установлен.',10,\
'Сравнивается с DT_PATH_ELLIPSIS и DT_WORD_ELLIPSIS.',10,\
'DT_EXPANDTABS',9,'Увеличивает число символов в табуляции. Заданное по умолчанию число символов в табуляции - восемь.',10,\
'DT_EXTERNALLEADING',9,'Включает межстрочное расстояние шрифта в высоту строки. Обычно, межстрочное расстояние не включается в высоту строки текста.',10,\
'DT_HIDEPREFIX',9,9,'Windows 2000/XP: Игнорирует префиксный символ && (амперсанд) в тексте. Буква, которая следует за ним, не будет подчеркнута, но другие мнемонически-префиксные буквы все еще обрабатываются. Например:',10,\
'введенная строка:    "A&&bc&&&&d"',10,\
'обычно:                    "A&bc&&d"',10,\
'DT_HIDEPREFIX:      "Abc&&d"',10,\
'Сравнивается с DT_NOPREFIX и DT_PREFIXONLY.',10,\
'DT_INTERNAL',9,9,'Использует системный шрифт, чтобы рассчитать метрики текста.',10,\
'DT_LEFT',9,9,'Выравнивает текст слева.',10,\
'DT_MODIFYSTRING',9,'Изменяет заданную строку, чтобы согласовать отображаемый на экране текст. Это значение не имеет никакого действия, если не установлен флажок DT_END_ELLIPSIS или DT_PATH_ELLIPSIS.',10,\
'DT_NOCLIP',9,9,'Рисует без отсечения по границам. Функция  DrawTextEx становится несколько быстрее, когда используется флажок DT_NOCLIP',10,\
'DT_NOFULLWIDTHCHARBREAK  Windows 98/Me, Windows 2000/XP: Не допускает перенос строки в DBCS (символьная строка двойной ширины), так, чтобы правило переноса строки было эквивалентно SBCS строкам. Например, это свойство может быть использовано в окнах с корейским языком, для большей удобочитаемости иероглифов. Это значение не имеет никакого действия, если флажок DT_WORDBREAK не установлен.',10,\
'DT_NOPREFIX',9,9,'Выключает обработку префиксных символов. Обычно, функция DrawTextEx воспринимает мнемонически-префиксный символ && как директиву, чтобы подчеркнуть букву, которая следует после, а  мнемонически-префиксные символы && как директиву, чтобы печатать (отобразить на экране) единственную &. Устанавливая флажок DT_NOPREFIX, эта обработка отключается. Сравнивает с флажком DT_HIDEPREFIX и DT_PREFIXONLY.',10,\
'DT_PATH_ELLIPSIS',9,'Для отображаемого на экране текста, заменяет буквы (символы) в середине строки на тире так, чтобы результат вместился в заданном прямоугольнике. Если строка содержит знак наклонной черты влево (\), флажок DT_PATH_ELLIPSIS сохраняет в максимально возможной степени текст после последней наклонной черты влево. Строка не модифицируется, если флажок DT_MODIFYSTRING не установлен.',10,\
'Сравнивается с флажками DT_END_ELLIPSIS и DT_WORD_ELLIPSIS.',10,\
'DT_PREFIXONLY',9,'Windows 2000/XP: Рисует только подчеркивание в позиции буквы, следующей за префиксным символом && (амперсант)). Не выводит никакие другие символы в строке. Например,',10,\
'введенная строка:    "A&&bc&&&&d"',10,\
'обычно:                    "A&bc&&d"',10,\
'DT_PREFIXONLY:     " _   "',10,\
'Сравнивает с флажками DT_HIDEPREFIX и DT_NOPREFIX.',10,\
'DT_RIGHT',9,9,'Выравнивает текст справа.',10,\
'DT_RTLREADING',9,'Компонует порядок чтения справа налево  для двунаправленного текста, когда шрифт, выбранный в hdc - шрифт еврейского или арабского языка.   Заданный по умолчанию порядок чтения для всех текстов - слева направо.',10,\
'DT_SINGLELINE',9,9,'Показывает на экране текст только в единственной строке. Возвраты каретки и переводы строки не разрывают строку.',10,\
'DT_TABSTOP',9,9,'Устанавливает шаги табуляции. Структура DRAWTEXTPARAMS указывает, что  параметр lpDTParams задает число символов средней ширины на шаг табуляции.',10,\
'DT_TOP',9,9,9,'Выравнивает текст по верху прямоугольника.',10,\
'DT_VCENTER',9,9,'Центрирует текст по вертикали. Это значение используется только со  значением DT_SINGLELINE.',10,\
'DT_WORDBREAK',9,'Делит слова. Строки автоматически делятся по словам, если слово выходит за края прямоугольника, заданного параметром lprc . Возврат каретки - последовательность перевода строки также делит строку.',10,\
'DT_WORD_ELLIPSIS',9,'Обрезает любое слово, которое не вмещается в прямоугольнике и добавляет эллипсисы.',10,\
'Сравнивается с флажками DT_END_ELLIPSIS и DT_PATH_ELLIPSIS.',10,\
'lpDTParams',9,9,'Указатель на структуру DRAWTEXTPARAMS, которая устанавливает дополнительные параметры форматирования. Этот параметр может иметь значение ПУСТО (NULL).',10,\
'Возвращаемые значения',10,\
'Если функция завершается успешно, возвращаемое значение - высота текста в логических единицах измерения. Если установлены флажки DT_VCENTER или DT_BOTTOM, возвращаемое значение - смещение в lprc->top в основании выводимого текста.',10,\
'Если функция завершается с ошибкой, величина возвращаемого значения - ноль.',0
expTxt7   db   'Вывод текста в заголовок окна через SendMessage',0
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