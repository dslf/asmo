format PE GUI

include '%fasminc%\win32ax.inc'

.data
    string db 'homos homani lopus est ',0
    len    dd ?
    
.code 
start:    
    xor eax, eax
    ;inc eax

.calc_len:
    cmp byte [string+eax], 0
    je .finish_calc
    inc eax
    loop .calc_len

.finish_calc:    
    mov dword [len], eax
    
     
  
    invoke MessageBox,0,string,'',MB_OK
    invoke ExitProcess, 0

.end start    
    