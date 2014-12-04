section '.data' data readable writeable
;-----------------------------------------------------------------------
;   initialized data here
;

hello       db "hello",0

;=======================================================================
align 4
;-----------------------------------------------------------------------
;   uninitialized data here
;

hInstance   dd ?