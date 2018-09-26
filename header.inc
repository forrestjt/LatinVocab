;LatinVocab header

IDD_LATINVOCAB = 1000
IDC_STUDY      = 1001
IDC_TEST       = 1002
IDC_A1	       = 1003
IDC_A2	       = 1004
IDC_A3	       = 1005
IDC_A4	       = 1006
IDC_QUESTION   = 1007
IDC_TIME       = 1008
IDT_TIMER      = 1121
IDC_RIGHT      = 1001
IDC_WRONG      = 1009
IDC_INDEX      = 1010

STAT_STUDY     = 0
STAT_TEST      = 1

include 'win32ax.inc'
include './MACRO/MASM.INC'

struct VWORD
  latinstr   dd ?
  englishstr dd ?
  next	     dd ?
ends

macro qalloc size
{
  push ebp
  invoke GetProcessHeap
  invoke HeapAlloc,eax,HEAP_ZERO_MEMORY\
		   or HEAP_GENERATE_EXCEPTIONS,size
  pop ebp
}
macro qfree ptr
{
  push ebp
  invoke GetProcessHeap
  invoke HeapFree,eax,0,ptr
  pop ebp
}	 

macro HideWindow hwnd
{
  mov edx,hwnd
  push edx
  invoke GetWindowLong,edx,GWL_STYLE
  mov ebx,WS_VISIBLE
  not ebx
  and eax,ebx
  pop edx
  invoke SetWindowLong,edx,GWL_STYLE,eax
}
macro ShowWindow hwnd
{
  mov edx,hwnd
  push edx
  invoke GetWindowLong,edx,GWL_STYLE
  or eax,WS_VISIBLE
  pop edx
  invoke SetWindowLong,edx,GWL_STYLE,eax
}
macro SetFont hdc
{
  mov eax,hdc
  push eax
  invoke CreateFont,16,8,0,0,600,0,0,0,OEM_CHARSET,\
				       OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
				       DEFAULT_QUALITY,DEFAULT_PITCH \;or FF_SCRIPT,\
				       FontName
  pop edx
  invoke SelectObject,edx,eax
  mov [OrigFont],eax
}
