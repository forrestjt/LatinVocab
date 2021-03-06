;LatinVocab
;Copyright (c) 2008 Forrest Tait
format pe gui 4.0
entry start

include 'header.inc'

section '.data' data readable writable
status	 dd 0
numWords dd 0

teststr db 'Amo, Amare, Amavi, Amarus',0


;Font Variables
BigFont  dd 0
OrigFont dd 0
FontName db "script",0

section '.code' code readable executable

start:
  invoke  GetModuleHandle,0
  invoke  DialogBoxParam,eax,IDD_LATINVOCAB,HWND_DESKTOP,DialogProc,0
  invoke  ExitProcess,eax

proc DialogProc,hdlg,umsg,wparam,lparam
  push ebx esi edi
  xor eax,eax

  cmp [umsg],WM_INITDIALOG
  je init
  cmp [umsg],WM_COMMAND
  je command
  cmp [umsg],WM_PAINT
  je paint
  cmp [umsg],WM_CLOSE
  je close

  jmp ender

  close:
    invoke EndDialog,[hdlg],0
    mov eax,1
    jmp ender

  init:
    invoke GetDlgItem,[hdlg],IDC_A1
    HideWindow eax

    invoke GetDlgItem,[hdlg],IDC_A2
    HideWindow eax

    invoke GetDlgItem,[hdlg],IDC_A3
    HideWindow eax

    invoke GetDlgItem,[hdlg],IDC_A4
    HideWindow eax

    invoke GetDlgItem,[hdlg],IDC_QUESTION
    HideWindow eax

    jmp processed
  paint:

    local ps:PAINTSTRUCT
    local hdc:DWORD
    invoke BeginPaint,[hdlg],addr ps
    push eax
    invoke SetBkMode,eax,TRANSPARENT
    pop eax
    push eax
    SetFont eax
    pop eax
    push eax
    invoke TextOut,eax,80,80,teststr,25
    pop eax
    invoke ReleaseDC,eax

    jmp processed


  command:


    jmp processed

  processed:
    mov eax,1

  ender:
  pop edi esi ebx
  ret
endp
section '.idata' import data readable writable
library kernel,'KERNEL32.DLL',\
	 gdi,'GDI32.DLL',\
	  user,'USER32.DLL'

import kernel,\
	 GetModuleHandle,'GetModuleHandleA',\
	 LoadLibrary,'LoadLibraryA',\
	 ExitProcess,'ExitProcess',\
	 CreateFile, 'CreateFileA',\
	 ReadFile,'ReadFile'

import user,\
	 MessageBox,'MessageBoxA',\
	 DialogBoxParam,'DialogBoxParamA',\
	 GetDlgItem,	'GetDlgItem',\
	 GetWindowLong, 'GetWindowLongA',\
	 SetWindowLong, 'SetWindowLongA',\
	 BeginPaint, 'BeginPaint',\
	 EndPaint,   'EndPaint',\
	 EndDialog,'EndDialog'

import gdi,\
	 GetDC,'GdiGetDC',\
	 ReleaseDC,'GdiReleaseDC',\
	 SetBkMode,'SetBkMode',\
	 CreateFont,'CreateFontA',\
	 SelectObject,'SelectObject',\
	 TextOut,'TextOutA'

;include 'API\gdi32.inc'

section '.rcrs' readable resource from 'latinvocabres.rc.res'
