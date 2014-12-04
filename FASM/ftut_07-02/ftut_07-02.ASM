format PE GUI
include 'win32ax.inc'
  ID_CURSOR = 18
; import data in the same section

	  xchg ebx,eax
	  mov edi,wTitle
	  mov esi,400000h
	  invoke LoadCursor,esi, ID_CURSOR,COLOR_WINDOW+1,ebx,edi
	  ; +------------------------------+
	  ; | registering the window class |
	  ; +------------------------------+
	  invoke RegisterClass,esp,ebx,window_procedure,\
	  ebx,ebx,esi,eax,eax
	  ; +--------------------------+
	  ; | creating the main window |
	  ; +--------------------------+
	  push ebx
	  push esi
	  shl esi,9
	  invoke CreateWindowEx,ebx,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
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
window_procedure: cmp dword[esp+0x08],WM_DESTROY
	       je wmDESTROY
	       jmp dword [DefWindowProc]
wmDESTROY: invoke ExitProcess,ebx

      wTitle db   'Iczelion Tutorial #7-2:Создание курсора и иконки из ресурсов в FASM',0 ;name of our window
data import

 library KERNEL32, 'KERNEL32.DLL',\
	 user32,   'USER32.DLL'
 import KERNEL32,\
	       ExitProcess,	   'ExitProcess'
 import user32,\
		RegisterClass,	    'RegisterClassA',\
		CreateWindowEx,     'CreateWindowExA',\
		DefWindowProc,	    'DefWindowProcA',\
		GetMessage,	    'GetMessageA',\
		DispatchMessage,    'DispatchMessageA',\
		LoadCursor,	    'LoadCursorA'
end data
;-------------------------------------------------------------------------------------------
section '.rsrc' resource data readable

    directory RT_CURSOR,cursors,\
	    RT_GROUP_CURSOR,group_cursors

  resource cursors,\
	   2,LANG_NEUTRAL,cursor1_data

  resource group_cursors,\
	   ID_CURSOR,LANG_NEUTRAL,cursor1

  cursor cursor1,cursor1_data,'Images\cursor.cur'