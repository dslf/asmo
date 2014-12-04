;================================================================================
format	    PE GUI 4.0 ;on 'stub.exe'
include 'win32ax.inc'
;section     '.code' code readable writeable executable
;================================================================================
start:	    invoke  DialogBoxParam,400000h,1,eax,dlgproc,eax;DialogBoxParam,[node.hinst],1,0,dlgproc,0
	    retn
;================================================================================
dlgproc:
hDlg	equ esp+4
msg	equ esp+8
wparam	equ esp+0Ch
lparam	equ esp+10h

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
	    retn 10h
;================================================================================
timer:	    mov eax,[index]
	    inc eax
	    and eax,3
	    mov [index],eax
	    mov eax,[hicon2+eax*4]
	    mov [hicon],eax
	    invoke  SendDlgItemMessage,edi,100,STM_SETIMAGE,IMAGE_ICON,eax
	    invoke  Shell_NotifyIcon,NIM_MODIFY,node
	    jmp     next
;================================================================================
init:	    mov esi,400000h
	    invoke  LoadIcon,esi,5
	    invoke  SendMessage,edi,WM_SETICON,1,eax
	    mov ebp,4
@@:	    invoke  LoadImage,esi,ebp,IMAGE_ICON,16,16,ebx
	    dec ebp
	    mov     [hicon2+ebp*4],eax
	    jnz @b
	    mov     [hicon],eax
	    mov     [hwnd],edi
	    invoke  Shell_NotifyIcon,ebx,node;NIM_ADD=0
	    invoke  SetTimer,edi,ebx,500,ebx
	    jmp     next
;================================================================================
shell:	    cmp     dword[lparam],WM_LBUTTONDOWN
	    je	    showhide
	    jmp     next
;================================================================================
syscmd:     cmp     dword[wparam],SC_MINIMIZE
	    jne     default
;================================================================================
showhide:   cmp     [showflag],bl
	    sete al
	    mov     [showflag],al
	    lea eax,[eax+eax*4]
	    invoke  ShowWindow,edi,eax
	    jmp     next
;================================================================================
close:	    invoke  KillTimer,edi,ebx
	    invoke  Shell_NotifyIcon,NIM_DELETE,node
	    invoke  EndDialog,edi,ebx
;================================================================================
next:	    retn 10h
;================================================================================
      node	   dd hicon5+4-node	   ;0
      hwnd	   dd 0 			   ;4
      id	   dd 0 			   ;8
      flags	   dd NIF_ICON+NIF_MESSAGE+NIF_TIP ;12
      message	   dd WM_USER+5 		   ;16
      hicon	   dd 0 			   ;20
      tip	   db 'project',0		   ;24
      showflag	   db 1 			   ;36
      index	   dd 0 			   ;40
      hicon2	   dd 0 			   ;44
      hicon3	   dd 0 			   ;48
      hicon4	   dd 0 			   ;52
      hicon5	   dd 0 			   ;56
;================================================================================
data	    import
library     user32,'user32.dll',\
	    shell32,'shell32.dll'
import	     shell32,\
	     Shell_NotifyIcon,	     'Shell_NotifyIcon'
import	     user32,\
	     DialogBoxParam,		'DialogBoxParamA',\
	     SendDlgItemMessage,	'SendDlgItemMessageA',\
	     SendMessage,		'SendMessageA',\
	     LoadImage, 		'LoadImageA',\
	     LoadIcon,			'LoadIconA',\
	     SetTimer,			'SetTimer',\
	     ShowWindow,		'ShowWindow',\
	     KillTimer, 		'KillTimer',\
	     EndDialog, 		'EndDialog'
end	    data
;================================================================================
data	    resource
directory   RT_ICON,icons,\
	    RT_GROUP_ICON,group_icons,\
	    RT_DIALOG,dialogs
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
icon	    icon1,icon1_data,'Images/1.ico'
icon	    icon2,icon2_data,'Images/2.ico'
icon	    icon3,icon3_data,'Images/3.ico'
icon	    icon4,icon4_data,'Images/4.ico'
icon	    icon5,icon5_data,'Images/5.ico'
;================================================================================
dialog	    main,'project',0,0,173,99,\
	    WS_CAPTION+WS_POPUP+WS_SYSMENU+DS_CENTERMOUSE+WS_MINIMIZEBOX
dialogitem  'BUTTON','',-1,1,-3,171,100,WS_VISIBLE+BS_GROUPBOX
dialogitem  'STATIC','',100,153,80,16,16,WS_VISIBLE+SS_ICON+SS_CENTERIMAGE
dialogitem  'EDIT','http://wasm.ru/forum/',-1,7,85,95,8,WS_VISIBLE+WS_DISABLED
enddialog
;================================================================================
