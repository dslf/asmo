format PE GUI
include 'win32ax.inc'
;------------------------------------------------
   start:	xchg ebx,eax
		mov edi,wTitle
		mov esi,400000h
		; +------------------------------+
		; | registering the window class |
		; +------------------------------+
		invoke RegisterClass,esp,ebx,window_procedure,ebx,\
		ebx,esi,ebx,10011h,COLOR_BTNFACE+1,ebx,edi
		; +--------------------------+
		; | creating the main window |
		; +--------------------------+
		push ebx
		push esi
		shl esi,9
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,edi,edi,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
		esi,esi,200,400,ebx,ebx
		mov ebp,esp
   ;+---------------------------+
   ;| entering the message loop |
   ;+---------------------------+
   window_message_loop_start:
	invoke	GetMessage,ebp,ebx,ebx,ebx
	invoke	DispatchMessage,ebp
		jmp	window_message_loop_start

   window_message_loop_end:
   ;+----------------------+
   ;| the window procedure |
   ;+----------------------+
window_procedure:
hWnd		equ ebp+8
uMsg		equ ebp+0Ch
wParam		equ ebp+10h
lParam		equ ebp+14h
tv1Insert	equ ebp - sizeof.TV_INSERTSTRUCT - 4
tv1HitInfo	equ tv1Insert - sizeof.TV_HITTESTINFO
imgl1DragH	equ tv1HitInfo-4
		enter sizeof.TV_INSERTSTRUCT+sizeof.TV_HITTESTINFO+8,0
		mov esi,[tv1H]
		mov eax,[uMsg]
		dec eax
		je   wmCREATE
		dec eax;cmp  [uMsg],WM_DESTROY
		je   wmDESTROY
		sub eax,WM_NOTIFY-WM_DESTROY;cmp  [uMsg],WM_NOTIFY
		je   wmNOTIFY
		sub eax,WM_MOUSEMOVE-WM_NOTIFY;cmp  [uMsg],WM_MOUSEMOVE
		je   wmMOUSEMOVE
		dec eax
		dec eax;cmp  [uMsg],WM_LBUTTONUP
		je   wmLBUTTONUP

wmDEFAULT:	leave
		jmp [DefWindowProc]

wmMOUSEMOVE:	cmp  dword[imgl1Drag],ebx
		je  wmDEFAULT
		movzx  eax,word[lParam]
		movzx  ecx,word[lParam+2]
		lea edi,[tv1HitInfo]
		mov  [edi+TV_HITTESTINFO.pt.x],eax
		mov  [edi+TV_HITTESTINFO.pt.y],ecx
		invoke	ImageList_DragMove,eax,ecx
		invoke	ImageList_DragShowNolock,ebx
		invoke	SendMessage,esi,TVM_HITTEST,ebx,edi
		xchg eax,ecx
		jecxz	@f
		invoke	SendMessage,esi,TVM_SELECTITEM,TVGN_DROPHILITE,ecx
  @@:		invoke	ImageList_DragShowNolock,TRUE
		jmp  wmBYE

wmNOTIFY:	mov  edi,[lParam]
		cmp  [edi + NM_TREEVIEW.hdr.code],TVN_BEGINDRAG
		jne  wmBYE
		invoke	SendMessage,esi,TVM_CREATEDRAGIMAGE,ebx,[edi + NM_TREEVIEW.itemNew.hItem]
		mov  [imgl1DragH],eax
		invoke	ImageList_BeginDrag,eax,ebx,ebx,ebx;dword[imgl1DragH],ebx,ebx,ebx
		invoke	ImageList_DragEnter,esi,[edi + NM_TREEVIEW.ptDrag.x],[edi + NM_TREEVIEW.ptDrag.y]
		invoke	SetCapture,dword[hWnd];eax
		or  dword[imgl1Drag],TRUE
		jmp  wmBYE

wmLBUTTONUP:	cmp [imgl1Drag],ebx
		jz  wmBYE
		invoke	ImageList_DragLeave,esi
		invoke	ImageList_EndDrag
		invoke	ImageList_Destroy,dword[imgl1DragH]
		invoke	SendMessage,esi,TVM_GETNEXTITEM,TVGN_DROPHILITE,ebx
		invoke	SendMessage,esi,TVM_SELECTITEM,TVGN_CARET,eax
		invoke	SendMessage,esi,TVM_SELECTITEM,TVGN_DROPHILITE,ebx
		invoke	ReleaseCapture
		and [imgl1Drag],ebx
		jmp  wmBYE

wmCREATE:
		invoke	CreateWindowEx,ebx,ctlClsNameTv,ebx,\
		WS_VISIBLE + WS_CHILD + WS_BORDER + TVS_HASBUTTONS + TVS_LINESATROOT + TVS_HASLINES,\
		ebx,ebx,200,400,dword[hWnd],ebx,400000h,ebx
		mov  [tv1H],eax
		mov esi,eax
		invoke	ImageList_Create,16,16,ILC_COLOR16,2,10      ;with mask
		mov  edi,eax
		invoke	LoadBitmap,400000h,31
		invoke	ImageList_Add,edi,eax,ebx,eax	      ;with mask
		invoke	DeleteObject
		invoke	SendMessage,esi,TVM_SETIMAGELIST,ebx,edi
		lea edi,[tv1Insert]
		mov  [edi+TV_INSERTSTRUCT.hParent],ebx
		mov  [edi+TV_INSERTSTRUCT.hInsertAfter],TVI_ROOT
		mov  [edi+TV_INSERTSTRUCT.item.mask],TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE
		mov  [edi+TV_INSERTSTRUCT.item.pszText],tv1Txt1
			mov  [edi+TV_INSERTSTRUCT.item.iImage],ebx
			mov  [edi+TV_INSERTSTRUCT.item.iSelectedImage],1
		invoke	SendMessage,[tv1H],TVM_INSERTITEM,ebx,edi
		mov  [edi+TV_INSERTSTRUCT.hParent],eax
		mov  [edi+TV_INSERTSTRUCT.hInsertAfter],TVI_LAST
		mov  [edi+TV_INSERTSTRUCT.item.pszText],tv1Txt2
		invoke	SendMessage,esi,TVM_INSERTITEM,ebx,edi
		mov  [edi+TV_INSERTSTRUCT.item.pszText],tv1Txt3
		invoke	SendMessage,esi,TVM_INSERTITEM,ebx,edi
		and [imgl1Drag],ebx
wmBYE:		leave
		retn 10h
wmDESTROY:		invoke	ExitProcess,ebx


wTitle	      db 'Iczelion Tutorial #19:Tree View Control in FASM',0
	ctlClsNameTv	db 'SysTreeView32',0
	tv1H		rd 1
	tv1Txt1 	db 'Node - Parent',0
	tv1Txt2 	db 'Node - Child 1',0
	tv1Txt3 	db 'Node - Child 2',0
	imgl1Drag	dd FALSE
data import
    library	KERNEL32, 'KERNEL32.DLL',\
		USER32,   'USER32.DLL',\
		GDI32,	  'GDI32.DLL',\
		COMCTL32, 'COMCTL32.DLL'
    
    import	KERNEL32,\
		ExitProcess,		'ExitProcess'

    import	USER32,\
		RegisterClass,		'RegisterClassA',\
		CreateWindowEx, 	'CreateWindowExA',\
		DefWindowProc,		'DefWindowProcA',\
		LoadBitmap,		'LoadBitmapA',\
		SendMessage,		'SendMessageA',\
		GetMessage,		'GetMessageA',\
		MessageBox,		'MessageBoxA',\
		SetCapture,		'SetCapture',\
		ReleaseCapture, 	'ReleaseCapture',\
		GetParent,		'GetParent',\
		DestroyWindow,		'DestroyWindow',\
		DispatchMessage,	'DispatchMessageA'

    import	GDI32,\
		DeleteObject,		'DeleteObject'

    import	COMCTL32,\
		ImageList_Create,	'ImageList_Create',\
		ImageList_Add,		'ImageList_Add',\
		ImageList_AddMasked,	'ImageList_AddMasked',\
		ImageList_GetImageCount,'ImageList_GetImageCount',\
		ImageList_BeginDrag,	'ImageList_BeginDrag',\
		ImageList_EndDrag,	'ImageList_EndDrag',\
		ImageList_DragEnter,	'ImageList_DragEnter',\
		ImageList_DragMove,	'ImageList_DragMove',\
		ImageList_DragLeave,	'ImageList_DragLeave',\
		ImageList_DragShowNolock,'ImageList_DragShowNolock',\
		ImageList_Destroy,	'ImageList_Destroy'
end data

section '.rsrc' resource data readable
	directory	RT_BITMAP, appBmp
	
	resource	appBmp,\
			31,LANG_NEUTRAL,bmpA
	
	bitmap		bmpA, 'Images\list.bmp'
