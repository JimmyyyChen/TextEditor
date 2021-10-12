.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

include Irvine32.inc

.data
fileName	BYTE	"C:\Users\mcwin\Documents\ip.txt", 0
fileHandle	HANDLE	?
bufsize = 5000
bytesRead	DWORD	?
buffer	BYTE	bufsize DUP(?)
msg	BYTE	"Text: ", 0ah, 0dh, 0
msg2	BYTE	"Number of characters: ", 0

.code
LoadTxt PROC, file:DWORD
	mov edx, file
	call OpenInputFile

	mov edx, offset buffer
	mov ecx, bufsize
	call ReadFromFile
	mov bytesRead, eax

	mov edx, offset msg
	call WriteString
	mov edx, offset buffer
	call WriteString
	call CrlF
	call CrlF
	mov edx, offset msg2
	call WriteString
	call WriteDec
	call CrlF
	ret
LoadTxt ENDP

main PROC
	invoke LoadTxt, ADDR fileName
	invoke ExitProcess, 0
main ENDP
end main