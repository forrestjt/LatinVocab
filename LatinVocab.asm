;LatinVocab
;Copyright (c) 2008 Forrest Tait
format pe gui 4.0
entry start

include 'header.inc'

section '.data' data readable writable
status	 dd 0
numWords dd 0
vocab	 VWORD
wordlist dd 0
randlist dd 0
virgin	 dd 0

answerlist rb 20
randomanswerlist rb 20

qnumber dd 0
wrongstr db 'Wrong! the correct answer was:',0xD,0xA,'%s',0
donestr  db 'You finished in %s! with %d right, and %d wrong',0
nwrong dd 0
nright dd 0
hseconds dd 0
seconds  dd 0
minutes  dd 0
timestr1 db '%d.%d',0
timestr2 db '%d:%d.%d',0
nrightstr db 'Right: %d',0
nwrongstr db 'Wrong: %d',0
indexstr db '%d / %d',0

filename db 'words.txt',0

str2 rb 256
str3 rb 256
answerstr rb 256
teststr db 'Amo, Amare, Amavi, Amarus',0


printstr db '<~%s~>',0
printstr2 db '<~%d~>',0

errormsg db 'A file opening error has occured',0


;Font Variables
BigFont  dd 0
OrigFont dd 0
FontName db "script",0

assume eax:VWORD

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
  cmp [umsg],WM_TIMER
  je timer
  cmp [umsg],WM_CLOSE
  je close

  jmp ender

  close:
    stdcall FreeVocab
    invoke EndDialog,[hdlg],0
    mov eax,1
    jmp ender

  init:
    invoke  GetModuleHandle,NULL
    invoke LoadIcon,eax,666
    invoke SendMessage,[hdlg],WM_SETICON,ICON_BIG,eax
    cinvoke time,0
    cinvoke srand,eax

    ;stdcall ReadNumLines,filename
    stdcall ReadInFile,filename

    jmp processed

  command:
    cmp [wparam],IDC_TEST
    jne .skip_test
      cmp [status],0
      mov [virgin],1
      jne @f
      mov [status],1
      invoke SetDlgItemText,[hdlg],IDC_TEST,"Stop!"
      mov [nright],0
      mov [nwrong],0
      invoke SetTimer,[hdlg],IDT_TIMER,100,0
      mov [hseconds],0
      mov [seconds],0
      mov [minutes],0
      mov eax,[numWords]
      mov ebx,4
      mul ebx
      qalloc eax
      mov [randlist],eax

      stdcall RandomNumberOrder,[numWords],[numWords],[randlist]
      mov [qnumber],0
      mov eax,[randlist]
      mov ebx,[eax]	 ;ebx is the index of the first question
      push ebx
      cinvoke sprintf,str2,indexstr,[qnumber],[numWords]
      invoke SetDlgItemText,[hdlg],IDC_INDEX,str2
      cinvoke sprintf,str2,nrightstr,[nright]
      invoke SetDlgItemText,[hdlg],IDC_RIGHT,str2
      cinvoke sprintf,str2,nwrongstr,[nwrong]
      invoke SetDlgItemText,[hdlg],IDC_WRONG,str2

      pop ebx
      .next_question:	;Must Set ebx to the proper index for
			;this to work correctly
      push ebx
      mov ecx,[wordlist]
      mov eax,[ecx+ebx*4] ;eax is a pointer to the question structure
      push eax
      cinvoke strcpy,answerstr,[eax.englishstr]
      pop eax

      invoke SetDlgItemText,[hdlg],IDC_QUESTION,[eax.latinstr]
      pop ebx

      .answer_finder1:
	push ebx
	cinvoke rand
	and edx,0
	div [numWords]
	mov eax,edx
	pop ebx        ;question index
	cmp eax,ebx
      je .answer_finder1

      mov ecx,eax
      ;Original question index is still in EBX while first
      ;answer choice index is in ECX

      .answer_finder2:
	push ebx ecx
	cinvoke rand
	and edx,0
	div [numWords]
	mov eax,edx
	pop ecx ebx
	cmp eax,ebx
	je .answer_finder2
	cmp eax,ecx
      je .answer_finder2

      mov edx,eax

      .answer_finder3:
	push ebx ecx edx
	cinvoke rand
	and edx,0
	div [numWords]
	mov eax,edx
	pop edx ecx ebx
	cmp eax,ebx
	je .answer_finder3
	cmp eax,ecx
	je .answer_finder3
	cmp eax,edx
      je .answer_finder3

      mov esi,answerlist
      mov [esi],ebx
      mov [esi+4],ecx
      mov [esi+8],edx
      mov [esi+12],eax
      stdcall RandomNumberOrder,4,4,randomanswerlist

      mov esi,answerlist
      mov edi,randomanswerlist
      mov ebx,[edi]
      mov ecx,[esi+ebx*4] ;Get word structure
      mov ebx,[wordlist]
      mov eax,[ebx+ecx*4]
      invoke SetDlgItemText,[hdlg],IDC_A1,[eax.englishstr]

      mov esi,answerlist
      mov edi,randomanswerlist
      mov ebx,[edi+4]
      mov ecx,[esi+ebx*4] ;Get word structure
      mov ebx,[wordlist]
      mov eax,[ebx+ecx*4]
      invoke SetDlgItemText,[hdlg],IDC_A2,[eax.englishstr]

      mov esi,answerlist
      mov edi,randomanswerlist
      mov ebx,[edi+8]
      mov ecx,[esi+ebx*4] ;Get word structure
      mov ebx,[wordlist]
      mov eax,[ebx+ecx*4]
      invoke SetDlgItemText,[hdlg],IDC_A3,[eax.englishstr]

      mov esi,answerlist
      mov edi,randomanswerlist
      mov ebx,[edi+12]
      mov ecx,[esi+ebx*4] ;Get word structure
      mov ebx,[wordlist]
      mov eax,[ebx+ecx*4]
      invoke SetDlgItemText,[hdlg],IDC_A4,[eax.englishstr]

      jmp processed
      @@:
      ._stop_test:
      mov [status],0
      invoke KillTimer,[hdlg],IDT_TIMER
      invoke SetDlgItemText,[hdlg],IDC_TEST,"Test!"


      jmp processed
    .skip_test:

      cmp [wparam],IDC_A1
      jl .skip_A
      cmp [wparam],IDC_A4
      jg .skip_A
      cmp [virgin],0
      je ._special
      cmp [status],0
      je .skip_A

      invoke GetDlgItemText,[hdlg],[wparam],str2,256
      cinvoke strcmp,str2,answerstr
      cmp eax,0
      je @f
	inc [nwrong]
	cinvoke sprintf,str2,wrongstr,answerstr
	invoke MessageBox,[hdlg],str2,"Wrong",MB_APPLMODAL
	jmp ._go_nextq
      @@:
	inc [nright]
      ._go_nextq:
	cinvoke sprintf,str2,nrightstr,[nright]
	invoke SetDlgItemText,[hdlg],IDC_RIGHT,str2
	cinvoke sprintf,str2,nwrongstr,[nwrong]
	invoke SetDlgItemText,[hdlg],IDC_WRONG,str2
	inc [qnumber]
	cinvoke sprintf,str2,indexstr,[qnumber],[numWords]
	invoke SetDlgItemText,[hdlg],IDC_INDEX,str2
	mov eax,[qnumber]
	cmp eax,[numWords]
	jl @f
	   invoke KillTimer,[hdlg],IDT_TIMER
	   invoke GetDlgItemText,[hdlg],IDC_TIME,str3,256
	   cinvoke sprintf,str2,donestr,str3,[nright],[nwrong]
	   invoke MessageBox,[hdlg],str2,"Finished",MB_APPLMODAL
	   jmp ._stop_test
	@@:
	mov ecx,[randlist]
	mov ebx,[ecx+eax*4]

	jmp .next_question
      .skip_A:
    jmp processed

  ._special:
    cmp [wparam],IDC_A1
    jne @f
      invoke MessageBox,[hdlg],"I'm glad you feel that way, you will live a long an prosperous life.","Happiness",MB_APPLMODAL
    @@:
    cmp [wparam],IDC_A2
    jne @f
      invoke MessageBox,[hdlg],"Why don't you just go to vocational school and let other people do the thinking for you.","Meaningless",MB_APPLMODAL
    @@:
    cmp [wparam],IDC_A3
    jne @f
      invoke MessageBox,[hdlg],"Well, if you aren't being productive in latin, might as well admire the higher beings","Good for you",MB_APPLMODAL
    @@:
    cmp [wparam],IDC_A4
    jne @f
      invoke MessageBox,[hdlg],"I hope you suffer a long and painful death in die Deutche Holle!!","Go Away! we don't need your kind..",MB_APPLMODAL
    @@:


  jmp processed


  timer:
   cmp [wparam],IDT_TIMER
   jne ender
   add [hseconds],1
   cmp [hseconds],10
   jl .done_time
   add [seconds],1
   mov [hseconds],0
   cmp [seconds],60
   jl .done_time
   add [minutes],1
   mov [seconds],0

   .done_time:

   cmp [minutes],0
   jne @f
     cinvoke sprintf,str2,timestr1,[seconds],[hseconds]
     invoke SetDlgItemText,[hdlg],IDC_TIME,str2
     jmp processed
   @@:
     cinvoke sprintf,str2,timestr2,[minutes],[seconds],[hseconds]
     invoke SetDlgItemText,[hdlg],IDC_TIME,str2

  jmp processed

  processed:
    mov eax,1

  ender:
  pop edi esi ebx
  ret
endp


;pusha
;  cinvoke sprintf,str2,printstr2,ebx
;  invoke MessageBox,0,str2,0
;popa


;This Function just counts
;The number of lines in a
;file, returns the number
;in eax
proc ReadNumLines,filename
push ebx esi edi
  local hfile:DWORD

  invoke CreateFile,[filename],GENERIC_READ,FILE_SHARE_READ,\
		      0,OPEN_EXISTING,0
  cmp eax,-1
  je .rnl_error

  mov [hfile],eax

  and edx,0

  .rnl_loop:
    push edx
    stdcall ReadLine,[hfile],str2,255
    pop edx
    cmp eax,-1
    jle .rnl_done
    inc edx
  jmp .rnl_loop

  .rnl_done:
    push edx
    invoke CloseHandle,[hfile]
    pop eax ; move edx into eax
  jmp @f
  .rnl_error:
    mov eax,-1
  @@:

pop edi esi ebx
ret
endp

proc ReadInFile,filename
push ebx esi edi
  local hfile:DWORD,temp:DWORD,hwords:DWORD,hwords2:DWORD
  local count:DWORD,wordlistp:DWORD

  mov [hwords2],0
  mov [count],0

  stdcall ReadNumLines,[filename]
  cmp eax,-1
  je @f
     push eax
     mov ebx,4
     mul ebx
     qalloc eax
     mov [wordlist],eax
     pop eax
     and edx,0
     mov ebx,2
     div ebx
     mov [numWords],eax
     cmp edx,0
     je @f
     invoke MessageBox,0,"the words.txt file has undefined word(s)(an odd number of lines)","File Error",MB_APPLMODAL
     invoke  ExitProcess,-1
  @@:

  invoke CreateFile,[filename],GENERIC_READ,FILE_SHARE_READ,\
		      0,OPEN_EXISTING,0
  cmp eax,-1
  jne @f
    invoke MessageBox,0,errormsg,0,0
    jmp processed
  @@:

  mov [hfile],eax
  mov [temp],0
  mov eax,[wordlist]
  mov [wordlistp],eax



  @@:
  stdcall ReadLine,[hfile],str2,255
  cmp eax,-1
  je .rif_done
  cinvoke strlen,str2
  cmp eax,0
  je .rif_done

  qalloc sizeof.VWORD
  mov [hwords],eax
  ;cmp [hwords2],0
  ;jne .rln_skip
  ;  mov [hwords2],eax
  ;.rln_skip:
  mov edx,[wordlistp]
  mov [edx],eax
  add [wordlistp],4
  push eax
  qalloc 255
  mov ebx,eax
  pop eax
  mov [eax.latinstr],ebx
  push eax
  cinvoke strcpy,ebx,str2
  pop eax

  stdcall ReadLine,[hfile],str2,255

  cmp eax,-1
  je .rif_error
  cinvoke strlen,str2
  cmp eax,0
  je .rif_error

  mov eax,[hwords]
  push eax
  qalloc 255
  mov ebx,eax
  pop eax
  push eax ;EAX->EBX (see below)
  mov [eax.englishstr],ebx
  mov [eax.next],0
  cinvoke strcpy,ebx,str2
  pop ebx  ;EAX->EBX

  ;cmp [temp],0
  ;je .go_temp
  ;    mov eax,[temp]
  ;    mov [eax.next],ebx
  ;.go_temp:
  ;    mov [temp],ebx

  ;inc [count]

  jmp @b


  .rif_done:
   ;cinvoke sprintf,str3,printstr,"erre esse hominus"
   ; invoke MessageBox,0,str3,0,0
   invoke CloseHandle,[hfile]

   ;mov eax,[nwordsp]
   ;mov ebx,[count]
   ;mov [eax],ebx

  mov eax,[hwords2]
  jmp @f
  .rif_error:
    ;mov eax,[nwordsp]
    mov dword [eax],0

    mov eax,-1
  @@:

pop edi esi ebx
ret
endp

proc FreeVocab
push ebx esi edi
  ;assume eax:VWORD

  mov ecx,[numWords]
  dec ecx
  @@:
  push ecx

  mov ebx,[wordlist]
  mov eax,[ebx+ecx*4]

  push ebx eax
  qfree dword [eax.latinstr]
  pop eax ebx

  push eax
  qfree dword [eax.englishstr]
  pop eax

  qfree eax

  pop ecx
  dec ecx
  cmp ecx,0
  jge @b

  .freevoc_done:

pop edi esi ebx
ret
endp

proc ReadLine,hfile,hbuf,bufsize
push ebx esi edi
  local Temp:BYTE,nbread:DWORD,goodflag:BYTE

  mov eax,-1
  cmp [bufsize],1
  jle .rl_error

  mov eax,-2
  cmp [hfile],0
  je .rl_error

  mov eax,-3
  cmp [hbuf],0
  je .rl_error

  and al,0
  mov [goodflag],al

  .rl_loop:
    lea edx,[Temp]
    lea eax,[nbread]
    invoke ReadFile,[hfile],edx,1,eax,0
    cmp eax,0
    je .rl_error
    cmp [nbread],0
    jne @f
      cmp [goodflag],1
      jne .rl_error ;Jumps when we hit EOF
      jmp .rl_skiploop
    @@:
    mov eax,[hbuf]
    lea ebx,[Temp]
    cmp byte [Temp],0x0D
    je .rl_loop
    cmp byte [Temp],0x0A
    je .rl_skiploop
    mov cl,[ebx]
    mov [eax],cl
    dec [bufsize]
    inc [hbuf]
    cmp [bufsize],1
    je .rl_skiploop
    mov al,1
    mov [goodflag],al

   jmp .rl_loop


  .rl_skiploop:
    mov eax,[hbuf]
    mov byte [eax],0

  .rl_end:
    ;invoke CloseHandle,[hfile]
    mov eax,0
  jmp @f
  .rl_error:
    mov eax,-1
  @@:
pop edi esi ebx
ret
endp

proc RandomNumberOrder,n,range,addr
push esi edi ebx

  and ecx,0
  mov edx,[addr]
  .RNO_Order1:
  push ecx
    mov dword [edx+ecx*4],0
  pop ecx
  inc ecx
  cmp ecx,[n]
  jl .RNO_Order1

  and ecx,0
  .RNO_Order2:
  push ecx

    mov ebx,[addr]
    @@:
     push ebx
     cinvoke rand
     and edx,0
     div [n]
     pop ebx
    cmp dword [ebx+edx*4],0
    jne @b

  pop ecx
  mov [ebx+edx*4],ecx
  inc ecx
  mov eax,[n]
  ;dec eax
  cmp ecx,eax
  jl .RNO_Order2

pop ebx edi esi
ret
endp

section '.idata' import data readable writable
library kernel,'KERNEL32.DLL',\
	 gdi,'GDI32.DLL',\
	  user,'USER32.DLL',\
	  msvcrt,'MSVCRT.DLL'

import kernel,\
	 GetModuleHandle,'GetModuleHandleA',\
	 LoadLibrary,'LoadLibraryA',\
	 GetProcessHeap, 'GetProcessHeap',\
	 HeapAlloc,	 'HeapAlloc',\
	 HeapFree,	 'HeapFree',\
	 ExitProcess,'ExitProcess',\
	 CreateFile, 'CreateFileA',\
	 CloseHandle,'CloseHandle',\
	 ReadFile,'ReadFile'

import user,\
	 MessageBox,'MessageBoxA',\
	 DialogBoxParam,'DialogBoxParamA',\
	 GetDlgItem,	'GetDlgItem',\
	 SetDlgItemText,'SetDlgItemTextA',\
	 GetDlgItemText,'GetDlgItemTextA',\
	 GetWindowLong, 'GetWindowLongA',\
	 SetWindowLong, 'SetWindowLongA',\
	 BeginPaint, 'BeginPaint',\
	 EndPaint,   'EndPaint',\
	 SetTimer,   'SetTimer',\
	 KillTimer,  'KillTimer',\
	 LoadIcon,   'LoadIconA',\
	 SendMessage,'SendMessageA',\
	 EndDialog,'EndDialog'

import gdi,\
	 GetDC,'GdiGetDC',\
	 ReleaseDC,'GdiReleaseDC',\
	 SetBkMode,'SetBkMode',\
	 CreateFont,'CreateFontA',\
	 SelectObject,'SelectObject',\
	 TextOut,'TextOutA'

import msvcrt,\
	 sprintf, 'sprintf',\
	 strlen,  'strlen',\
	 strcpy,  'strcpy',\
	 rand,	  'rand',\
	 srand,   'srand',\
	 time,	  'time',\
	 strcmp,  'strcmp'

;include 'API\gdi32.inc'

section '.rcrs' readable resource from 'latinvocabresv3.rc.res'
