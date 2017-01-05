.386P
.model flat, stdcall
option   casemap:none

    include D:\masm32\INCLUDE\WINDOWS.INC
    include D:\masm32\INCLUDE\KERNEL32.INC
    include D:\masm32\INCLUDE\USER32.INC
    include D:\masm32\INCLUDE\SHELL32.INC
    include D:\masm32\INCLUDE\ADVAPI32.INC
    include D:\masm32\INCLUDE\GDI32.INC
    include D:\masm32\INCLUDE\comdlg32.inc
    include my.inc

    includelib D:\masm32\lib\masm32.lib
    includelib D:\masm32\lib\comdlg32
    includelib D:\masm32\lib\user32.lib
    includelib D:\masm32\lib\shell32.lib
    includelib D:\masm32\lib\gdi32.lib
    includelib D:\masm32\lib\kernel32.lib
    includelib D:\masm32\lib\user32.lib
    includelib D:\masm32\lib\advapi32.lib


.data
  HWND_Look    DD       NULL
  HINST_DLL    DD       NULL
	HHOOK_Key    DWORD    NULL
	result       DWORD    NULL
	uScanCode    DWORD    NULL
	Char         DWORD    NULL
	KeyState     db	  5   dup (NULL)


.code
DLLENTRY@12:

	MAIN_DLL_FUNC PROC hinstDLL :DWORD, hReason:DWORD , ReservedParam:DWORD

			mov EAX,hReason

			CMP EAX,DLL_PROCESS_ATTACH
			je $_ATTACH_

			CMP EAX, DLL_THREAD_ATTACH
			je FINISH

			CMP EAX, DLL_THREAD_DETACH
			je FINISH

			CMP EAX, DLL_PROCESS_DETACH
			je FINISH

	$_ATTACH_:
			mMOV   HINST_DLL, hinstDLL
			jmp   FINISH

	FINISH:
			mov EAX, TRUE
			RET 12
	MAIN_DLL_FUNC ENDP

	DLL_Key_HOOK_proc PROC nCode:DWORD, wParam:DWORD, lParam:DWORD

			push lParam
			push wParam
			push nCode
			push HHOOK_Key
			call CallNextHookEx
			mov   result,  EAX

			mov EAX,nCode
			CMP EAX, HC_ACTION
            JNE $_FINISH_

						mov EBX, lParam
						TEST EBX, 80000000h
					    jz $_FINISH_

						shr EBX, 16
						and EBX, 000000FFh
						mov uScanCode, EBX

						push offset KeyState
						call GetKeyboardState

            push null
						push offset Char
						push offset KeyState
						push uScanCode
						push wParam
						call ToAscii

						push lParam
						push Char
						push WM_NULL
						push HWND_Look
						call PostMessage

	$_FINISH_:
			mov  EAX,  result
			RET   12
	DLL_Key_HOOK_proc ENDP


	DLL_SET_HOOK_proc PROC export hWnd1:DWORD
		mMOV HWND_Look, hWnd1
		push NULL
		push HINST_DLL
		push offset  DLL_Key_HOOK_proc
		push WH_KEYBOARD
		call SetWindowsHookEx
		mov  HHOOK_Key, EAX
		RET  4
	DLL_SET_HOOK_proc ENDP


	DLL_UNSET_HOOK_proc PROC export
		push HHOOK_Key
		call UnhookWindowsHookEx
		RET
	DLL_UNSET_HOOK_proc ENDP

END DLLENTRY@12
