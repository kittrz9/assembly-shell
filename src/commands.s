global cmdList

extern argv

section .data
cmdList: 
	dq cmdCdStr, cmdCdLen, cmdCdFunc
	dq cmdAsdfStr, cmdAsdfLen, cmdAsdfFunc
	dq 0x0

section .text
cmdCdFunc:
	mov rax, 0x50 ; chdir
	mov rdi, [argv + 8]
	syscall
	ret

section .data
cmdCdStr:
	db "cd",0x0
cmdCdLen: equ $-cmdCdStr

section .text
cmdAsdfFunc:
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, cmdAsdfStr
	mov rdx, cmdAsdfLen
	syscall
	ret

section .data
cmdAsdfStr:
	db "asdf",0x0
cmdAsdfLen: equ $-cmdAsdfStr
