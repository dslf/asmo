section '.idata' import data readable writeable

  library kernel32,'kernel32.dll',\
          user32,'user32.dll'

  import kernel32,\
         ExitProcess,'ExitProcess',\
         GetModuleHandle,'GetModuleHandleA'

  import user32,\
         DialogBoxParam,'DialogBoxParamA',\
         EndDialog,'EndDialog',\
         GetDlgItemText,'GetDlgItemTextA',\
         SetDlgItemText,'SetDlgItemTextA'