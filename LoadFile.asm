.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include masm32rt.inc

.const 
IDM_OPEN EQU 1 
IDM_EXIT EQU 2 
MAXSIZE EQU 260 
OUTPUTSIZE EQU 512 
MEMSIZE	EQU	5000

.data 
ClassName			db				"SimpleWinClass", 0 
AppName				db				"Main Window", 0 
MenuName			db				"FirstMenu", 0 
FilterString		db				"Text Files", 0, "*.txt", 0, 0
buffer				db              MAXSIZE DUP(0) 
OFNTitle			db				"Choose a TXT file to open",0 

.data? 
ofn					OPENFILENAME	<> 
hInstance			HINSTANCE		? 
CommandLine			LPSTR			? 
hFile				dd				?
fileBuf				dd				?

.code 
start: 
	; Get handle to current process
    invoke GetModuleHandle, NULL 
    mov hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain PROC hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov wc.cbSize, SIZEOF WNDCLASSEX 
    mov wc.style, CS_HREDRAW or CS_VREDRAW 
    mov wc.lpfnWndProc, OFFSET WndProc 
    mov wc.cbClsExtra, NULL 
    mov wc.cbWndExtra, NULL 
    push hInst 
    pop wc.hInstance 
    mov wc.hbrBackground, COLOR_WINDOW+1 
    mov wc.lpszMenuName, OFFSET MenuName 
    mov wc.lpszClassName, OFFSET ClassName 

	; Load the program's icon and cursor
    invoke LoadIcon, NULL, IDI_APPLICATION 
    mov wc.hIcon,eax 
    mov wc.hIconSm,eax 
    invoke LoadCursor, NULL, IDC_ARROW 
    mov wc.hCursor,eax 

	; Register the window class
    invoke RegisterClassEx, addr wc 

	; Create the application's main window
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, ADDR ClassName, ADDR AppName, \ 
           WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, \ 
           CW_USEDEFAULT, 300, 200, NULL, NULL, \ 
           hInst,NULL 
    mov hwnd,eax 

	; Show and draw the window
    invoke ShowWindow, hwnd, SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 

    .WHILE TRUE 
        invoke GetMessage, ADDR msg, NULL, 0, 0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov eax,msg.wParam 
    ret 
WinMain ENDP

WndProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
	LOCAL SizeReadWrite:DWORD
    .IF uMsg == WM_DESTROY		; Quit
        invoke PostQuitMessage,NULL 

    .ELSEIF uMsg==WM_COMMAND	; Choose from menu
        mov eax, wParam 
        .IF ax == IDM_OPEN		; Choose 'Open'
			; Load GetOpenFileName dialog
			mov ofn.lStructSize, SIZEOF ofn 
            push hWnd 
            pop ofn.hwndOwner 
            push hInstance 
            pop ofn.hInstance 
            mov ofn.lpstrFilter, OFFSET FilterString 
            mov ofn.lpstrFile, OFFSET buffer 
            mov ofn.nMaxFile,MAXSIZE 
            mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY 
            mov ofn.lpstrTitle, OFFSET OFNTitle 
            invoke GetOpenFileName, ADDR ofn 
			
			.IF eax==TRUE
				invoke CreateFile, ADDR buffer, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
				mov hFile, eax
				invoke ReadFile, hFile, ADDR fileBuf, MAXSIZE, ADDR SizeReadWrite, NULL
				invoke MessageBox, hWnd, OFFSET fileBuf, ADDR AppName, MB_OK 
				;invoke RtlZeroMemory, offset fileBuf, OUTPUTSIZE 
			.ENDIF
        .ELSE	; Choose 'Exit'
            invoke DestroyWindow, hWnd 
        .ENDIF

	.ELSE		; Exit
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret 
WndProc ENDP 

end start