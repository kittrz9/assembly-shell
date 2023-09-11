global _start


section .bss
inputBuf: resb 256

section .data
prompt: db ">"
nullStr: db 0x0
argv: dq inputBuf,0x0
env: dq nullStr, 0x0

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

; replace \n with 0
	; rax has the amount of bytes written
	lea rdi, [inputBuf]
	add rdi, rax
	dec rdi
	mov byte [rdi], 0x0

; TODO: parse for argv


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
