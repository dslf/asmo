format PE GUI 4.0

include '%fasminc%\win32ax.inc'



entry imageconv

section '.data' data readable writeable
    buf dd ?
    tex db 'eax is %u',0
    im  dw ?
    imp db 'c:\screenshot.bmp'
    gtoken dd ?
    gimput dd ?
    encnum        dd ?
    iimg          dd ?  
    istr          dd ?  
    gdisi dd 1,0,0,0
    
section '.code' code readable executable 
imageconv:
    
  ;  mov [GDISI.GdiplusVersion], 1
  ;  mov [gdisi.DebugEventCallback], 0
  ;  mov [gdisi.SuppressBackgroundThread], 0
  ;  mov [gdisi.SuppressExternalCodecs], 0 
    
  ;  invoke  wsprintf, buf, tex, eax
  ;  invoke  MessageBox,0,buf,'',MB_OK
    lea     edi,[istr]
    lea     eax,[encnum]
    invoke  GdiplusStartup, eax,gdisi,0
    lea     eax,[iimg]
    invoke  GdipLoadImageFromStream,[edi],eax
    
  ;  invoke  GdipLoadImageFromFile,imp,im   
    invoke  ExitProcess,0
     

section '.idata' import data readable writeable

  library       kernel32,   'KERNEL32.DLL',\
	            user32,     'USER32.DLL',\
                gdiplus,    'gdiplus.dll'
    
    import      gdiplus,\
                GdipLoadImageFromFile, "GdipLoadImageFromFile",\
                GdiplusStartup, "GdiplusStartup"
                
                include '%fasminc%\api\kernel32.inc'
                include '%fasminc%\api\user32.inc'
    
        
        