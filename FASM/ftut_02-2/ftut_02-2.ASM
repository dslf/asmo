format PE GUI
include 'win32ax.inc'
; import data in the same section

  invoke    MessageBox,eax,"Win32 Assembly with FASM is Great!",\
   "Iczelion Tutorial #2-2:MessageBox",eax
   retn
data import

 library user32,'USER32.DLL'
 import user32,\
	MessageBox,'MessageBoxA'

end data