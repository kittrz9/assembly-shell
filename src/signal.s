bits 64

global setupSignalHandler

extern shellLoop
extern forkedPID

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
	; TODO: fix processes not actually stopping until the entire shell is exited
	mov rax, 0x3e ; sys_kill
	mov rdi, qword [forkedPID]
	mov rsi, 15 ; SIG_TERM
	syscall
	je leaveInterrupt
	int3 ; just to be able to debug stuff in the coredump
leaveInterrupt:
	ret

restore:
	mov rax, 0xf
	syscall
