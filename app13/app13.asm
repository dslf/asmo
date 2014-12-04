;------------------c0ded by r00tkit ---------------
;--------------virus_online@rediffmail.com---------
;--------------fasm/RadASM/Win32API----------------

format PE GUI 4.0
entry r00tkit

include 'Win32a.inc'; can be found in fasm\include folder
include 'rc.inc'        ;*
section '.data' data readable writeable

gIst dd 0
gWnd dd 0
wsadata WSADATA
saddr sockaddr_in
initcomctl INITCOMMONCONTROLSEX
buffer rb 8000h
errorcap db 'O my',0
errortxt db 'This is a bad hostname',13,10
       db 'plz recheck it',0
       
       hello       db "hello",0
       buf dd ?
form db 'Eax has %u',0

;=======================================================================
align 4
;-----------------------------------------------------------------------
;   uninitialized data here
;

hInstance   dd ?


section '.code' code readable executable

r00tkit:
    mov     [initcomctl.dwSize],sizeof.INITCOMMONCONTROLSEX
        mov     [initcomctl.dwICC],ICC_INTERNET_CLASSES
        invoke  InitCommonControlsEx,initcomctl
        invoke  WSAStartup,0202h,wsadata ;  if  this doesn't work try 0101h in place of 0202h
        or      eax,eax
        jnz     finish
        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,D_MAIN,HWND_DESKTOP,DlgProc,0
        invoke  WSACleanup

ExitApp:
   invoke ExitProcess,0

proc DlgProc,hWnd,uMsg,wParam,lParam
  ;enter
   push edi esi ebx

   mov eax,[uMsg]
   cmp   eax,WM_COMMAND
   je   jCOMMAND
   cmp   eax,WM_INITDIALOG
   je   jINITDIALOG
   cmp   eax,WM_CLOSE
   je   jCLOSE
   xor eax,eax
   jmp finish

jINITDIALOG:
   mov eax,[hWnd]
   mov [gWnd],eax
   mov eax,1
   jmp finish

jCOMMAND:

;	invoke	wsprintf,\
;		buf,\;
		;form,\
		;eax

;	invoke	MessageBox,\;
		;0,\
		;buf,\
		;'',\
		;MB_OK
;invoke  SendDlgItemMessage,[hWnd],EDIT_2,IPM_SETADDRESS,0,buf		
		
   mov eax,[wParam]
   cmp   eax,B_CAN
   je   a1000
   cmp eax,B_OK
   je a1005
   xor eax,eax
   jmp finish

a1000:
   ;invoke SendMessage,[hWnd],WM_CLOSE,0,0
   invoke   SetDlgItemText,[hWnd], EDIT_2, hello
   ;invoke   SetWindowText, EDIT_2, "xu"
   mov eax,1
   jmp finish

a1005:
      ;  invoke MessageBox, 0, hello, hello, MB_OK
      invoke  GetDlgItemText,[hWnd],EDIT_1,buffer,8000h
     ;invoke 
        invoke  gethostbyname,buffer
        or      eax,eax
        jz      .bad
        virtual at eax
        .host   hostent
        end     virtual
        mov     eax,[.host.h_addr_list]
        mov     eax,[eax]
        mov     eax,[eax]
        bswap   eax
        ;invoke  wsprintf, buf, form, eax
        ;invoke  SetDlgItemText,[hWnd], EDIT_2, buf
        invoke  SendDlgItemMessage,[hWnd],EDIT_2,IPM_SETADDRESS,0,eax
       jmp     processed
.bad:
      xor ebx,ebx
      invoke  SendDlgItemMessage,[hWnd],EDIT_2,IPM_SETADDRESS,0,ebx
      invoke  MessageBox,0,errortxt,errorcap,MB_ICONERROR
      jmp processed

jCLOSE:
   invoke EndDialog,[hWnd],0
   mov eax,1
processed:
   mov eax,1
finish:
   pop ebx esi edi
   ret
endp



section '.idata' import data readable writeable

  library kernel32, 'KERNEL32.DLL',\
     user32,   'USER32.DLL',\
     comctl,'COMCTL32.DLL',\
      winsock,'WSOCK32.DLL'



include 'api\kernel32.inc' 
include 'api\user32.inc' 


  

  import comctl,\
         InitCommonControlsEx,   'InitCommonControlsEx'

  import winsock,\
         WSAStartup,'WSAStartup',\
         WSACleanup,'WSACleanup',\
         WSAAsyncSelect,'WSAAsyncSelect',\
         gethostbyname,'gethostbyname',\
         closesocket,'closesocket'  



;include 'idata.inc'
;include  'data.inc'
;=======================================================================
section '.rsrc' resource data readable
;-----------------------------------------------------------------------
  directory RT_DIALOG,dialogs

;-----------------------------------------------------------------------
include "dialogs.tab"
;-----------------------------------------------------------------------
include "dialogs.dat"
;=======================================================================

