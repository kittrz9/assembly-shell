bits 64

global setupSignalHandler

extern forkedPID
extern inputBuf

section .data
newAction:
sa_handler: dq intHandler
sa_flags: dq 0x04000000
sa_restorer: dq restore
sa_mask: db 128 dup (0) ; 128 zero bytes


section .text
setupSignalHandler:
	; sigaction(SIGINT, newAction, NULL)
	mov rax, 0xd
	mov rdi, 2
	lea rsi, newAction
	mov rdx, 0
	mov r10, 0x8
	syscall

	ret

intHandler:
	; make inputBuf string empty so it doesn't end up doing the same command any time an interrupt happens
	mov byte [inputBuf], 0

	; write newline
	mov rax, 0xa
	push rax
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, rsp
	mov rdx, 1
	syscall
	pop rax

	cmp qword [forkedPID], 0
	je leaveInterrupt

	; TODO: fix processes not actually stopping until the entire shell is exited
	mov rax, 0x3e ; sys_kill
	mov rdi, qword [forkedPID]
	mov rsi, 15 ; SIG_TERM
	syscall

	cmp rax, 0
	je leaveInterrupt
	int3 ; just to be able to debug stuff in the coredump
leaveInterrupt:
	ret

restore:
	mov rax, 0xf
	syscall
