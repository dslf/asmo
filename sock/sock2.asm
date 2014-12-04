format PE console

include "%fasminc%\win32ax.inc"

entry Start

section '.data' data readable writeable

    Server          equ "213.180.204.8"
    Port            equ 80
    CRLF            equ 13,10
    WSAData         WSADATA
    SocketDesc      dd ?
    SockAddr        dw AF_INET
    SockAddr_Port   dw ?
    SockAddr_IP     dd ?
    SendBuffer      rb 32
    ByteBuffer      rb 2
    ReturnBuffer    rb 32
     

section '.code' code readable executable

Start:

    invoke  WSAStartup, 0101h, WSAData        
    cmp     eax, 0
    jne     Exit
    invoke  socket, AF_INET, SOCK_STREAM, 0         
    cmp     eax, -1
    je      Exit
    mov     dword [SocketDesc], eax
    invoke  inet_addr, Server
    mov     dword [SockAddr_IP], eax
    invoke  htons, Port
    mov     word [SockAddr_Port], ax
    invoke  connect, dword [SocketDesc], SockAddr, 16            
    cmp     eax, 0
    jne     Exit
    invoke  lstrcpy, SendBuffer, "GET / HTTP/1.1"
    invoke  lstrcat, SendBuffer, CRLF
    invoke  lstrcat, SendBuffer, "host: ya.ru"
    invoke  lstrcat, SendBuffer, CRLF
    invoke  lstrcat, SendBuffer, CRLF   
    call    SendLine
    call    ReadLine
    invoke  Sleep, 2500                            
    
Exit:

    invoke  closesocket, [SocketDesc]
    invoke  WSACleanup     
    invoke  ExitProcess, 0

ReadLine:

    mov     dword [ReturnBuffer], 0

GetLine:

    invoke  recv, dword [SocketDesc], ByteBuffer, 1, 0
    cmp     eax, 0
    je      HaveByte  
    cmp     byte [ByteBuffer], 10
    je      HaveByte      
    invoke  lstrcat, ReturnBuffer, ByteBuffer
    jmp     GetLine

HaveByte:

    ccall   [printf], ReturnBuffer
    ret    
            
    
SendLine:

    invoke  lstrlen, SendBuffer
    invoke  send, [SocketDesc], SendBuffer, eax, 0
    cmp     eax, -1
    je      Exit    
    ret


section '.idata' import data readable writeable
    
    library kernel32, 'kernel32.dll',\
            wsock32,  'wsock32.dll',\
            msvcrt,   'msvcrt.dll'  
    
    import  msvcrt,\
            printf,'printf',\
            getchar,'_fgetchar'
    
    include '%fasminc%\api\kernel32.inc'
    include '%fasminc%\api\wsock32.inc' 