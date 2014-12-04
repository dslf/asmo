format PE GUI 4.0
include '%fasminc%\win32ax.inc'

entry start

.data
    buff        rb  2000h
    local_file  db  'c:\logo1.png',0
    remote_url  db  'http://imgl.yandex.net/i/www/logo1.png',0
    hFile       dd  0
    hInt        dd  0
    hUrl        dd  0
    dwRWfile    dd  0
    dwRWurl     dd  0
    downloader_id   db  'system internet service',0

.code
start:
            
    invoke  InternetOpen, 0, 0, 0, 0, 0
    test    eax, eax
    jz      _exit
    mov     [hInt], eax
    invoke  InternetOpenUrl, eax, remote_url, 0, 0, 0, 0
    test    eax,eax
    jz      _close_inet
    mov     [hUrl], eax
    invoke  CreateFile, local_file, GENERIC_WRITE, FILE_SHARE_READ, NULL,OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL,NULL
    test    eax, eax
    js      _close_inet
    mov     [hFile], eax

@@:
    invoke  InternetReadFile, [hUrl], buff, 2000h, dwRWurl
    test    eax, eax
    jz      @f
    cmp     [dwRWurl], 0
    je      @f
    invoke  WriteFile, [hFile], buff, [dwRWurl], dwRWfile, 0
    jmp     @b

@@:
    invoke  CloseHandle, [hFile]

_close_inet:
    invoke  InternetCloseHandle, [hInt]

_exit:
    invoke  ExitProcess, 0

section '.idata' import data readable writeable         ;imports

library\ 
    kernel,         'KERNEL32.DLL',\
    wininet,        'WININET.DLL',\
    user32,         'USER32.DLL'

import kernel,\
    ExitProcess,    'ExitProcess',\
    CloseHandle,    'CloseHandle',\
    CreateFile,     'CreateFileA',\
    WriteFile,      'WriteFile'

import  wininet,\
    InternetOpen,       'InternetOpenA',\
    InternetOpenUrl,    'InternetOpenUrlA',\
    InternetReadFile,   'InternetReadFile' ,\
    InternetCloseHandle,'InternetCloseHandle'