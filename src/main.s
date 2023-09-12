global _start


section .bss
inputBuf: resb 256
argv: resq 64

section .data
prompt: db ">"
nullStr: db 0x0
;argv: dq inputBuf,0x0
env: dq nullStr, 0x0
cmd_cd_str: db "cd",0x0

section .text
_start:
shellLoop:
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

; check if argv[0] is "cd"
	lea rdi, [inputBuf]
	lea rsi, [cmd_cd_str]
	mov rcx, 3
cdCheck:
	movzx rax, byte [rdi]
	movzx rbx, byte [rsi]
	cmp rax, rbx
	jne cdCheckFail
	dec rcx
	cmp rcx, 0x0
	je cdCheckSuccess
	jmp cdCheck
cdCheckSuccess:
	call cmd_cd
cdCheckFail:


; fork
	mov rax, 0x39
	syscall

; if fork, execve to program specified by stdin
	cmp rax, 0x0
	je forked
	jmp notForked
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



cmd_cd:
	push rax
	push rdi
	mov rax, 0x50 ; chdir
	mov rdi, [argv + 8]
	syscall
	pop rdi
	pop rax
	ret

