global _start

extern cmdList

global argv

section .bss
inputBuf: resb 256
argv: resq 64
cwd: resb 256

section .data
prompt: db ">"
nullStr: db 0x0
;argv: dq inputBuf,0x0
env: dq nullStr, 0x0
cmd_cd_str: db "cd",0x0

section .text
_start:
shellLoop:
; write cwd
	mov rax, 0x4f
	mov rdi, cwd
	mov rsi, 256
	syscall
	; rax should have the amount of bytes written
	mov rdx, rax
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, cwd
	syscall
; write prompt
	mov rax, 0x1 ; write
	mov rdi, 0x1 ; stdout
	mov rsi, prompt
	mov rdx, 1
	syscall

; read from stdin
	mov rax, 0x0 ; read
	mov rdi, 0x0 ; stdin
	mov rsi, inputBuf
	mov rdx, 256
	syscall

; parse for argv
	lea rdi, [inputBuf]
	lea rcx, [argv]
nextArg:
	mov rdx, rdi
spaceCheck:
	inc rdi
	cmp byte [rdi], 0x0
	je endOfArgs
	cmp byte [rdi], 0xa
	jne notNewline
	mov byte [rdi], 0x0
	jmp endOfArgs
notNewline:

	cmp byte [rdi], 0x20
	jne spaceCheck

	mov byte [rdi], 0x0
	mov qword [rcx], rdx
	add rcx, 8
	inc rdi

	jmp nextArg
endOfArgs:
	mov qword [rcx], rdx
	add rcx, 8
	mov qword [rcx], 0x0

; check for builtin commands
	lea rbx, [cmdList]
commandCheck:
	mov rax, qword [rbx]
	cmp rax, 0x0
	je commandCheckEnd
	lea rdi, [inputBuf]
	lea rax, [rbx + 8]
	mov rsi, qword [rbx]
	movzx rcx, byte [rax]
	repe cmpsb
	je commandCheckSuccess
	add rbx, 24
	jmp commandCheck
commandCheckSuccess:
	lea rax, [rbx + 16]
	mov rbx, qword [rax]
	call rbx
commandCheckEnd:

; check if the provided program exists
	mov rax, 0x15 ; access
	mov rdi, inputBuf
	mov rsi, 1 ; test for execute permission
	syscall
	cmp rax, 0x0
	jne shellLoop
	; currently still forks if argv[0] is a directory, should probably use the stat syscall


; fork
	mov rax, 0x39
	syscall

; if fork, execve to program specified by stdin
	cmp rax, 0x0
	jne notForked
forked:
	mov rax, 0x3b
	mov rdi, inputBuf
	mov rsi, argv
	mov rdx, env
	syscall

notForked:
; wait 
	mov rdi, rax
	mov rax, 0x3d
	mov rsi, -1
	mov rdx, 0x0
	mov r10, 0x0 
	syscall
	
	jmp shellLoop



