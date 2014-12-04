format PE GUI ; on 'null'
entry Start
include '%fasminc%\win32axp.inc'
BUFSIZE = 1048576

section 'text' code readable writable executable
sa2ch	    sockaddr_in AF_INET, $5000, $2C482E4E    ;here ip addres to connect old dvache $420694D5
_cc db 13,10,'Connection: Close',13,10,0
_Str rb 26
_SearchStr db ': <a target="_blank" href="'
_ss:
Start:
       xor ebx, ebx
    invoke GetCommandLine			    ; get full path like
@@:						    ; ""z:\tralala\2pg" /s/res/72345.html"        
       inc eax
       cmp byte [eax], '/'			    ; scroll to get /s/res/72345.html
       jne @B
       mov dword [Buf2], 'GET ' 		    ; move to buf2 'GET '
       mov byte [Buf2+4], 0			    ; ADD ZERO TERMINAROR TO END
    invoke lstrcat, Buf2, eax			    ; append buff to eax -- 'GET ' + '/s/res/72345.html'
    invoke lstrcat, eax, _cc			    ; 'GET /s/res/72345.html' + 13,10,'Connection: Close',13,10,0                        
    invoke WSAStartup, $101, Buf		    ; init socket
    invoke socket, 2, 1, ebx			    ; [af = address family = 2 (AF_INET) The Internet Protocol version 4 (IPv4) address family]
						    ; type 1 (SOCK_STREAM) ebx = 0 [If a value of 0 is specified, the caller does not wish to specify a protocol and the service provider will choose the protocol to use. ]                             
       mov [hSocket], eax			    ; save handle of socket to hSocket
    invoke connect, eax, sa2ch, 16		    ; hSocket, addr, len
	or eax, eax
       jnz Exit
    invoke lstrlen, Buf2			    ; get length of buf2
    invoke send, [hSocket], Buf2, eax, ebx	    ; send to socket buf2, len of buf, 0
       mov edi, Buf				    ; save buf to edi
@@:
    invoke recv, [hSocket], edi, 1024, ebx	    ; Read socket to edi, 1024 byte
       add edi, eax
	or eax, eax
       jnz @B
       mov esi, Buf
       mov [_bs], edi
    invoke closesocket, [hSocket]		    ; Close all operation with socket
FN:
       mov edi, _Str				    ; rb 26
       mov edx, _SearchStr			    ; _SearchStr db ': <a target="_blank" href="'
Search:
       cmp esi, [_bs]				    ; _bs dd ?
	    je Exit
       mov al, [esi]
       cmp al, [edx]				    ; edx are ": <a targ... etc"
       jne Ag
       inc edx
       inc esi
       cmp edx, _ss
       jne Search
       mov edi, _Str
@@:
       mov al, [esi]
       cmp al, '"'
	     je @F
       mov [edi], al
       inc esi
       inc edi
       jmp @B
@@:
       mov edi, _Str+7
       cmp byte [edi-1], '/'
	    je @F
       inc edi
@@:
       mov byte [edi+17], 0
    invoke CreateFile, edi, GENERIC_WRITE, ebx, ebx, CREATE_NEW, ebx, ebx
      test eax, eax
	    js FN
       mov [hFile], eax
    invoke socket, 2, 1, ebx
       mov [hSocket], eax
    invoke connect, [hSocket], sa2ch, 16
       mov dword [Buf2], 'GET '
       mov byte [Buf2+4], 0
    invoke lstrcat, Buf2, _Str
    invoke lstrcat, eax, _cc
    invoke lstrlen, eax
    invoke send, [hSocket], Buf2, eax, 0
@@:
    invoke recv, [hSocket], Buf2, 65536, 0
      test eax, eax
	jz @F
    invoke WriteFile, [hFile], Buf2, eax, tmp, ebx
       jmp @B
@@:
    invoke closesocket, [hSocket]
    invoke CloseHandle, [hFile]
       jmp FN
Ag:
       mov edx, _SearchStr
       inc esi
       jmp Search

Exit:
    invoke WSACleanup
    invoke ExitProcess, ebx

data import
library kernel32, 'kernel32.dll',\
	wsock32, 'wsock32.dll'
include '%fasminc%\api\kernel32.inc'
include '%fasminc%\api\wsock32.inc'
end data

section 'bss' data readable writable
Buf rb BUFSIZE
_bs dd ?
Buf2 rb 65536
hSocket dd ?
hFile dd ?
tmp dd ?