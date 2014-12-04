Format PE GUI 4.0
include '%fasminc%\win32ax.inc'

entry Down

    ;url     equ 'http://imgl.yandex.net/i/www/logo1.png',0
    FName   equ 'c:\downno.png'

section '.data' data readable writeable                         ;here our datas will be stored
    InetHandle      dd ?
    UrlHandle       dd ?
    FileHandle      dd ?
    ReadNext        dd ?
    BytesWritten    dd ?
    Parameter1      rb 128d
    DownloadBuffer  rb 1024d
    url     db 'http://imgl.yandex.net/i/www/logo1.png',0
    
section '.code' code readable executable                        ;code section

Down:
;   invoke  lstrcpy, Parameter1, url
    invoke  InternetOpen,0,0,0,0,0
    cmp     eax, 0
    je      Error
    mov     dword [InetHandle], eax
 
    invoke  InternetOpenUrl, dword [InetHandle], url, 0, 0, 0, 0
    cmp     eax, 0 
    je      Error
 
    invoke  CreateFile,FName,GENERIC_WRITE,FILE_SHARE_WRITE,0,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,0
    cmp     eax, 0
    je      Error
    mov     dword [FileHandle], eax
    inc     dword [ReadNext]

ReadNextBytes:
    cmp     dword [ReadNext], 0
    je      DownloadComplete

    invoke  InternetReadFile, dword [UrlHandle], DownloadBuffer, 1024d, dword [ReadNext]
    mov  ecx, dword [ReadNext]
;    invoke  WriteFile, dword [FileHandle], DownloadBuffer, dword [ReadNext], BytesWritten, 0
    jmp     ReadNextBytes

DownloadComplete:
    invoke  CloseHandle, dword [FileHandle]
    invoke  InternetCloseHandle, dword [UrlHandle]
            
    

    jmp @f    
Error: 
    invoke  MessageBox, 0, 'Download Error', 'Cap', MB_OK

@@:        
    
    
    ret

section '.idata' import data readable writeable                 ;imports 
       library  kernel,                 "kernel32.dll",\
                winsock,                "ws2_32.dll",\
                user,                   "user32.dll",\
                advapi,                 "advapi32.dll",\
                wininet,                "wininet.dll"

        import kernel,\
                lstrcpy,                "lstrcpyA",\
                lstrcpyn,               "lstrcpynA",\
                lstrcat,                "lstrcatA",\
                lstrcmp,                "lstrcmpA",\
                lstrlen,                "lstrlenA",\
                GetTickCount,           "GetTickCount",\
                Sleep,                  "Sleep",\
                CreateFile,             "CreateFileA",\
                WriteFile,              "WriteFile",\
                CloseHandle,            "CloseHandle",\
                CreateProcess,          "CreateProcessA",\
                CreateThread,           "CreateThread",\
                GetExitCodeThread,      "GetExitCodeThread",\
                TerminateThread,        "TerminateThread",\
                GetSystemDirectory,     "GetSystemDirectoryA",\
                ExitProcess,            "ExitProcess"

        import winsock,\
                WSAStartup,             "WSAStartup",\
                socket,                 "socket",\
                inet_addr,              "inet_addr",\
                htons,                  "htons",\
                connect,                "connect",\
                recv,                   "recv",\
                send,                   "send",\
                WSACleanup,             "WSACleanup"

        import advapi,\
                GetUserName,            "GetUserNameA"

        import user,\
                CharLowerBuff,          "CharLowerBuffA",\
                MessageBox,             "MessageBoxA",\
                GetAsyncKeyState,       "GetAsyncKeyState"

        import wininet,\
                InternetOpen,           "InternetOpenA",\
                InternetOpenUrl,        "InternetOpenUrlA",\
                InternetReadFile,       "InternetReadFile",\
                InternetCloseHandle,    "InternetCloseHandle"   