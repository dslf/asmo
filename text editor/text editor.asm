format PE GUI 4.0

entry start 

include 'win32a.inc' 
include 'encoding\WIN1251.INC'

section '.data' data readable writeable 

    title   db 'Мой Первый Текстовый Редактор',0
    class   db 'FASMWIN32',0
    _edit   db 'EDIT',0
    nofnc   db 'Эта функция не доступна в демо-версии',0
    errtxt  db 'Код ошибки: %u',0
    errbuf  rb $-errtxt+10
    hwnd    dd ?
    hmenu   dd ?
    hedit   dd ?
    hacc    dd ?
    font    dd ?

    wc WNDCLASS 0,WindowProc,0,0,0,0,0,COLOR_BTNFACE+1,0,class
    msg MSG
    client RECT
    menuinfo MENUITEMINFO sizeof.MENUITEMINFO,MIIM_STATE

section '.code' code readable executable 

start:
    invoke  GetModuleHandle,0 
    mov     [wc.hInstance],eax
    invoke  LoadIcon,[wc.hInstance],IDI_MAIN
    mov     [wc.hIcon],eax
    invoke  LoadCursor,0,IDC_ARROW
    mov     [wc.hCursor],eax
    
    invoke  RegisterClass,wc 
    cmp     eax,0
    je      error
    
    invoke  LoadAccelerators,[wc.hInstance],IDA_MAIN 
    mov     [hacc],eax
    invoke  LoadMenu,[wc.hInstance],IDM_MAIN
    mov     [hmenu],eax
    
    invoke  CreateWindowEx,0,class,title,WS_VISIBLE+WS_OVERLAPPEDWINDOW,\ 
            CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,\
            0,eax,[wc.hInstance],0
    
    cmp     eax,0 
    je      error 
    mov     [hwnd],eax 

msg_loop:
    invoke  GetMessage,msg,0,0,0 
    cmp     eax,0
    je      end_loop
    invoke  TranslateAccelerator,[hwnd],[hacc],msg
    cmp     eax,0
    jne     msg_loop
    invoke  TranslateMessage,msg
    invoke  DispatchMessage,msg
    jmp     msg_loop

error: 
    invoke  GetLastError
    invoke  wsprintf,errbuf,errtxt,eax
    invoke  MessageBox,0,errbuf,0,MB_OK

end_loop: 
    invoke  ExitProcess,[msg.wParam]

proc WindowProc hwnd,wmsg,wparam,lparam

    push    ebx esi edi
    cmp     [wmsg], WM_COMMAND
    je      .wmcommand
    cmp     [wmsg], WM_CREATE
    je      .wmcreate
    cmp     [wmsg], WM_SIZE
    je      .wmsize
    cmp     [wmsg], WM_SETFOCUS
    je      .wmsetfocus
    cmp     [wmsg], WM_DESTROY
    je      .wmdestroy

.defwndproc:
        invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
        jmp     .finish

.wmcommand: 
    mov     eax,[wparam]

    cmp     ax, IDM_NEW
    je      .NEW

    cmp     ax, IDM_OPEN
    je      .OPEN

    cmp     ax, IDM_SAVE
    je      .SAVE

    cmp     ax, IDM_SAVEAS
    je      .SAVEAS

    cmp     ax, IDM_EXIT
    je      .EXIT

    cmp     ax, IDM_UNDO
    je      .UNDO

    cmp     ax, IDM_CUT
    je      .CUT

    cmp     ax, IDM_COPY
    je      .COPY

    cmp     ax, IDM_PASTE
    je      .PASTE

    cmp     ax, IDM_DELETE
    je      .DELETE

    cmp     ax, IDM_SELECTALL
    je      .SELECTALL

    cmp     ax, IDM_ABOUT
    je      .ABOUT

    jmp     .finish 

; обработчики сообщений меню файл: 

.NEW: 

invoke MessageBox,0,nofnc,title,MB_OK 

jmp .finish 

.OPEN: 
    invoke MessageBox,0,nofnc,title,MB_OK 
    jmp .finish 

.SAVE: 
    invoke MessageBox,0,nofnc,title,MB_OK 
    jmp .finish 

.SAVEAS: 

    invoke MessageBox,0,nofnc,title,MB_OK 
    jmp .finish 

.EXIT: 
    invoke DestroyWindow,[hwnd] 
    jmp .finish 

; обработчики сообщений меню правка: 

.UNDO: 
    mov     eax,EM_UNDO 
    jmp     .send2editbox 

.CUT: 

    mov     eax,WM_CUT 
    jmp     .send2editbox 

.COPY: 

    mov     eax,WM_COPY 
    jmp     .send2editbox 

.PASTE: 

    mov     eax,WM_PASTE 
    jmp     .send2editbox 

.DELETE: 

    mov eax,WM_CLEAR 
    jmp .send2editbox 
    .send2editbox: 
    invoke SendMessage,[hedit],eax,0,0 
    jmp .finish 

.SELECTALL: 

    invoke SendMessage,[hedit],EM_SETSEL,0,-1 
    jmp .finish 

.ABOUT: 

    invoke DialogBoxParam,[wc.hInstance],IDD_ABOUT,[hwnd],AboutDialog,0 

jmp .finish 




.wmcreate: 

invoke GetClientRect,[hwnd],client 

invoke CreateWindowEx,WS_EX_CLIENTEDGE,_edit,0,WS_VISIBLE+WS_CHILD+WS_HSCROLL+WS_VSCROLL+ES_AUTOHSCROLL+ES_AUTOVSCROLL+ES_MULTILINE,[client.left],[client.top],[client.right],[client.bottom],[hwnd],0,[wc.hInstance],NULL 

cmp eax,0 

je .failed 

mov [hedit],eax 

invoke CreateFont,16,0,0,0,0,FALSE,FALSE,FALSE,RUSSIAN_CHARSET,OUT_RASTER_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FIXED_PITCH+FF_DONTCARE,NULL 

cmp eax,0 

je .failed 

mov [font],eax 

invoke SendMessage,[hedit],WM_SETFONT,eax,FALSE 

mov eax,0 

jmp .finish 

.failed: 

mov eax,-1 

jmp .finish 

.wmsize: 

invoke GetClientRect,[hwnd],client 

invoke MoveWindow,[hedit],[client.left],[client.top],[client.right],[client.bottom],TRUE 

mov eax,0 

jmp .finish 

.wmsetfocus: 

invoke SetFocus,[hedit] 

mov eax,0 

jmp .finish 

.wmdestroy: 

invoke PostQuitMessage,0 

mov eax,0 

.finish: 

pop edi esi ebx 

ret 

endp 




proc AboutDialog hwnd,msg,wparam,lparam 

push ebx esi edi 

cmp [msg],WM_COMMAND 

je .close 

cmp [msg],WM_CLOSE 

je .close 

mov eax,0 

jmp .finish 

.close: 

invoke EndDialog,[hwnd],0 

.processed: 

mov eax,1 

.finish: 

pop edi esi ebx 

ret 

endp 




section '.idata' import data readable writeable 




library kernel32,'KERNEL32.DLL',\ 
user32,'USER32.DLL',\
gdi32,'GDI32.DLL'




include 'api\kernel32.inc' 

include 'api\user32.inc' 

include 'api\gdi32.inc' 




section '.rsrc' resource data readable 




IDM_MAIN = 101 

IDA_MAIN = 201 

IDD_ABOUT = 301 

IDI_MAIN = 401 




IDM_NEW = 1101 

IDM_OPEN = 1102 

IDM_SAVE = 1103 

IDM_SAVEAS = 1104 

IDM_EXIT = 1109 




IDM_UNDO = 1201 

IDM_CUT = 1202 

IDM_COPY = 1203 

IDM_PASTE = 1204 

IDM_DELETE = 1205 

IDM_SELECTALL = 1206 




IDM_ABOUT = 1401 










directory RT_MENU,menus,\ 
RT_ACCELERATOR,accelerators,\
RT_DIALOG,dialogs,\
RT_GROUP_ICON,group_icons,\
RT_ICON,icons,\
RT_VERSION,versions




resource menus,\ 
IDM_MAIN,LANG_RUSSIAN+SUBLANG_DEFAULT,main_menu


resource accelerators,\ 
IDA_MAIN,LANG_ENGLISH+SUBLANG_DEFAULT,main_keys


resource dialogs,\ 
IDD_ABOUT,LANG_RUSSIAN+SUBLANG_DEFAULT,about_dialog




resource group_icons,\ 
IDI_MAIN,LANG_NEUTRAL,main_icon




resource icons,\ 
1,LANG_NEUTRAL,main_icon_data




resource versions,\ 
1,LANG_NEUTRAL,version




menu main_menu 

menuitem '&Файл',0,MFR_POPUP 

menuitem <'Созд&ать',9,'Ctrl+N'>,IDM_NEW,0,MFS_GRAYED 

menuitem <'&Открыть…',9,'Ctrl+O'>,IDM_OPEN,0,MFS_GRAYED 

menuitem <'&Сохранить',9,'Ctrl+S'>,IDM_SAVE,0,MFS_GRAYED 

menuitem 'Сохранить &как…',IDM_SAVEAS,0,MFS_GRAYED 

menuseparator 

menuitem <'В&ыход',9,'Ctrl+Q'>,IDM_EXIT,MFR_END 




menuitem '&Правка',0,MFR_POPUP 

menuitem <'&Отменить',9,'Ctrl+Z'>,IDM_UNDO 

menuseparator 

menuitem <'&Вырезать',9,'Ctrl+X'>,IDM_CUT 

menuitem <'&Копировать',9,'Ctrl+C'>,IDM_COPY 

menuitem <'Вст&авить',9,'Ctrl+V'>,IDM_PASTE 

menuitem <'&Удалить',9,'Del'>,IDM_DELETE 

menuseparator 

menuitem <'Выделить в&се',9,'Ctrl+A'>,IDM_SELECTALL,MFR_END 




menuitem '&Вид',0 




menuitem '&Справка',0,MFR_POPUP+MFR_END 

menuitem '&О программе',IDM_ABOUT,MFR_END 




accelerator main_keys,\ 
FVIRTKEY+FNOINVERT+FCONTROL,'N',IDM_NEW,\
FVIRTKEY+FNOINVERT+FCONTROL,'O',IDM_OPEN,\
FVIRTKEY+FNOINVERT+FCONTROL,'S',IDM_SAVE,\
FVIRTKEY+FNOINVERT+FCONTROL,'Q',IDM_EXIT,\
FVIRTKEY+FNOINVERT+FCONTROL,'Z',IDM_UNDO,\
FVIRTKEY+FNOINVERT+FCONTROL,'X',IDM_CUT,\
FVIRTKEY+FNOINVERT+FCONTROL,'C',IDM_COPY,\
FVIRTKEY+FNOINVERT+FCONTROL,'V',IDM_PASTE,\
FVIRTKEY+FNOINVERT+FCONTROL,'A',IDM_SELECTALL




dialog about_dialog,'О программе',40,40,172,60,WS_CAPTION+WS_POPUP+WS_SYSMENU+DS_MODALFRAME 

dialogitem 'STATIC',<'Мой Первый Текстовый Редактор',0Dh,0Ah,'Copyright ',0A9h,' BarMentaLisk 2008.'>,-1,27,10,144,40,WS_VISIBLE+SS_CENTER 

dialogitem 'STATIC',IDI_MAIN,-1,8,8,32,32,WS_VISIBLE+SS_ICON 

dialogitem 'STATIC','',-1,4,34,164,11,WS_VISIBLE+SS_ETCHEDHORZ 

dialogitem 'STATIC','Написан при помощи FASM',-1,12,42,100,20,WS_VISIBLE+SS_LEFT 

dialogitem 'BUTTON','OK',IDOK,124,40,42,14,WS_VISIBLE+WS_TABSTOP+BS_DEFPUSHBUTTON 

enddialog 


icon main_icon,main_icon_data,'1.ico'

versioninfo version,VOS_NT_WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_RUSSIAN+SUBLANG_DEFAULT,0,\ 
'Comments','Написан при помощи FASM',\
'CompanyName','BarMentaLisk',\
'FileDescription','Текстовый редактор',\
'ProductName',<'Мой Первый',0Dh,0Ah,'Текстовый Редактор'>,\
'LegalCopyright',<'Copyright ',0A9h, 'BarMentaLisk 2008'>,\
'FileVersion','0.1.0.0',\
'OriginalFilename','editor1.EXE'