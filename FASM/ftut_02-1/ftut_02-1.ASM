format PE GUI
include 'win32ax.inc'
; import data in the same section
section '.plaza' code readable executable
   invoke MessageBox,eax,msgBoxText,msgBoxCaption,eax
   retn
msgBoxText  db "Win32 Assembly with section's name .plaza is Great!",0
msgBoxCaption db "Iczelion Tutorial #2-1:MessageBox",0
data import

 library user32,'USER32.DLL'
 import user32,\
	MessageBox,'MessageBoxA'
end data