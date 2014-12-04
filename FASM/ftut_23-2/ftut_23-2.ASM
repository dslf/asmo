;================================================================================
format	    PE GUI 4.0 ;on 'stub.exe'
entry	    start
;================================================================================
include 'win32ax.inc'
;================================================================================
section     '.code' code readable writeable executable
;================================================================================
data	    resource
directory   RT_ICON,icons,\
	    RT_GROUP_ICON,group_icons,\
	    RT_DIALOG,dialogs
end	    data
;================================================================================
struct		    notifyicondata
      .size	    dd sizeof.notifyicondata	    ;0
      .hwnd	    dd 0			    ;4
      .id	    dd 0			    ;8
      .flags	    dd NIF_ICON+NIF_MESSAGE+NIF_TIP ;12
      .message	    dd WM_USER+5		    ;16
      .hicon	    dd 0			    ;20
      .tip	    db 'project',0		    ;24
      .hinst	    dd 0			    ;32
      .showflag     dd 0			    ;36
      .index	    dd 0			    ;40
      .hicon2	    dd 0			    ;44
      .hicon3	    dd 0			    ;48
      .hicon4	    dd 0			    ;52
      .hicon5	    dd 0			    ;56
      .my	    rb 28			    ;60
ends
node		    notifyicondata
;================================================================================
start:	    invoke  DialogBoxParam,400000h,1,0,dlgproc,0;DialogBoxParam,[node.hinst],1,0,dlgproc,0
	    retn
;================================================================================
proc	    dlgproc,hDlg,msg,wparam,lparam
	    xor ebx,ebx
	    mov eax,[msg]
	    mov edi,[hDlg]
	    sub eax,WM_CLOSE;cmp     [msg],WM_CLOSE;10h
	    je	    close
	    sub eax,WM_INITDIALOG-WM_CLOSE;cmp     [msg],WM_INITDIALOG;110h
	    je	    init
	    sub eax,WM_SYSCOMMAND-WM_INITDIALOG;cmp     [msg],WM_SYSCOMMAND;112h
	    je	    syscmd
	    dec eax;cmp     [msg],WM_TIMER;113h
	    je	    timer
	    sub eax,WM_USER+5-WM_TIMER;cmp     [msg],WM_USER+5;405h
	    je	    shell
;================================================================================
default:    xor     eax,eax
	    ret
;================================================================================
timer:	    mov eax,[node+40];[node.index]
	    inc eax
	    and eax,3
	    mov [node+40],eax
	    mov eax,[node+44+eax*4]
	    mov [node+20],eax ;[node.hicon],eax
	    invoke  SendDlgItemMessage,edi,100,STM_SETIMAGE,IMAGE_ICON,eax
	    invoke  Shell_NotifyIcon,NIM_MODIFY,node
	    jmp     next
;================================================================================
init:	    mov esi,400000h
	    invoke  LoadIcon,esi,1;[node.hinst],1
	    invoke  SendMessage,edi,WM_SETICON,1,eax
	    invoke  LoadImage,esi,2,IMAGE_ICON,16,16,ebx;[node.hinst],2,IMAGE_ICON,16,16,0
	    mov     [node+44],eax;[node.hicon2],eax
	    invoke  LoadImage,esi,3,IMAGE_ICON,16,16,ebx;[node.hinst],3,IMAGE_ICON,16,16,0
	    mov     [node+48],eax;[node.hicon3],eax
	    invoke  LoadImage,esi,4,IMAGE_ICON,16,16,ebx;[node.hinst],4,IMAGE_ICON,16,16,0
	    mov     [node+52],eax;[node.hicon4],eax
	    mov     [node+20],eax;[node.hicon],eax
	    invoke  LoadImage,esi,5,IMAGE_ICON,16,16,ebx;[node.hinst],5,IMAGE_ICON,16,16,0
	    mov     [node+56],eax;[node.hicon5],eax
	    mov     [node+4],edi;[node.hwnd],eax
	    mov     dword[node+8],ebx
	    mov     dword[node+12],NIF_ICON+NIF_MESSAGE+NIF_TIP
	    mov     dword[node+16],WM_USER+5
	    mov     dword[node+20],10011h
	    invoke  Shell_NotifyIcon,NIM_ADD,node
	    mov     dword[node+12],NIF_ICON;[node.flags],NIF_ICON
	    invoke  SetTimer,edi,ebx,500,ebx
	    mov     dword[node+36],1;[node.showflag],1
	    jmp     next
;================================================================================
shell:	    cmp     [lparam],WM_LBUTTONDOWN
	    je	    showhide
	    jmp     next
;================================================================================
syscmd:     cmp     [wparam],SC_MINIMIZE
	    jne     default
;================================================================================
showhide:   cmp     dword[node+36],ebx;[node.showflag],0
	    sete al
	    mov     [node+36],eax
	    lea eax,[eax+eax*4]
	    invoke  ShowWindow,edi,eax
	    jmp     next
;================================================================================
close:	    invoke  KillTimer,edi,ebx
	    invoke  Shell_NotifyIcon,NIM_DELETE,node
	    invoke  EndDialog,edi,ebx
;================================================================================
next:	    ret
endp
;================================================================================
data	    import
library     user32,'user32.dll',\
	    shell32,'shell32.dll'

import	    user32,\
		DialogBoxParam, 	'DialogBoxParamA',\
		EndDialog,		'EndDialog',\
		KillTimer,		'KillTimer',\
		LoadIcon,		'LoadIconA',\
		SendDlgItemMessage,	'SendDlgItemMessageA',\
		SendMessage,		'SendMessageA',\
		SetTimer,		'SetTimer',\
		LoadImage,		'LoadImageA',\
		ShowWindow,		'ShowWindow'

   import	shell32,\
		Shell_NotifyIcon,	'Shell_NotifyIcon'
end	    data
;================================================================================
resource    icons,1,LANG_NEUTRAL,icon1_data,\
		  2,LANG_NEUTRAL,icon2_data,\
		  3,LANG_NEUTRAL,icon3_data,\
		  4,LANG_NEUTRAL,icon4_data,\
		  5,LANG_NEUTRAL,icon5_data
resource    group_icons,1,LANG_NEUTRAL,icon1,\
			2,LANG_NEUTRAL,icon2,\
			3,LANG_NEUTRAL,icon3,\
			4,LANG_NEUTRAL,icon4,\
			5,LANG_NEUTRAL,icon5
resource    dialogs,1,LANG_ENGLISH+SUBLANG_DEFAULT,main
;================================================================================
icon	    icon1,icon1_data,'Images\1.ico'
icon	    icon2,icon2_data,'Images\2.ico'
icon	    icon3,icon3_data,'Images\3.ico'
icon	    icon4,icon4_data,'Images\4.ico'
icon	    icon5,icon5_data,'Images\5.ico'
;================================================================================
dialog	    main,'project',0,0,173,99,\
	    WS_CAPTION+WS_POPUP+WS_SYSMENU+DS_CENTERMOUSE+WS_MINIMIZEBOX
dialogitem  'BUTTON','',-1,1,-3,171,100,WS_VISIBLE+BS_GROUPBOX
dialogitem  'STATIC','',100,153,80,16,16,WS_VISIBLE+SS_ICON+SS_CENTERIMAGE
dialogitem  'EDIT','http://wasm.ru/forum/',-1,7,85,95,8,WS_VISIBLE+WS_DISABLED
enddialog
;================================================================================
