global _start

extern cmdList

global argv

section .bss
inputBuf: resb 256
argv: resq 64
env: resq 256
cwd: resb 256
file: resb 64
brkLocation: resq 1

section .data
prompt: db ">"
cmd_cd_str: db "cd",0x0
path: db "/bin/", 0x0
execveFailStr: db "execve has failed for some reason",0xa
execveFailStrLen: equ $-execveFailStr

section .text
_start:
; get brk location
	mov rax, 0xc ; brk
	mov rdi, 0
	syscall
	mov qword [brkLocation], rax

; skip args
	mov rax, 0x1
	mov rdi, 0x1
	mov rdx, 0x1
	pop rcx ; argc
argLoop:
	cmp rcx, 0x0
	je argLoopEnd
	dec rcx
	pop rsi
	jmp argLoop
argLoopEnd:

; copy envp
	pop rsi
	mov rcx, 0x0
	lea rbx, [env]
	mov rdi, qword [brkLocation]
envLoop:
	pop rsi
	cmp rsi, 0x0
	je envLoopEnd
; get strlen of current env variable
	mov rcx, rsi
envLenLoop:
	inc rcx
	cmp byte [rcx], 0x0
	jne envLenLoop
	inc rcx ; for the last null byte
	sub rcx, rsi
	; allocate space for the env var
brkDebug:
	add rdi, rcx
	mov rax, 0xc ; brk
	push rcx
	syscall
	pop rcx
	sub rdi, rcx
	; put the pointer to that into env
	mov qword [rbx], rdi
	; copy that into the new space
	repe movsb
	add rbx, 8
	jmp envLoop
envLoopEnd:

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
	cmp byte [rdi], 0xa ; \n
	jne notNewline
	mov byte [rdi], 0x0
	jmp endOfArgs
notNewline:

	cmp byte [rdi], ' '
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
	jmp shellLoop
commandCheckEnd:

; if starting with / or . skip path check
	lea rdi, [file] ; loading file address since it needs to be set for both paths
	movzx rax, byte [inputBuf]
	cmp rax, '/'
	je skipPath
	cmp rax, '.'
	je skipPath

; strcat path and argv[0]
	lea rsi, [path]
	mov rcx, 5
	repe movsb

skipPath:
	; get length of argv[0]
	mov rsi, qword [argv]
	xor rcx, rcx
argvSizeLoop:
	movzx rax, byte [rsi]
	inc rsi
	inc rcx
	cmp rax, 0x0
	jne argvSizeLoop


	mov rsi, qword [argv]
	repe movsb

	mov byte [rdi], 0x0

; fork
	mov rax, 0x39
	syscall

; if fork, execve to program specified by stdin
	cmp rax, 0x0
	jne notForked
forked:
	mov rax, 0x3b
	mov rdi, file
	mov rsi, argv
	mov rdx, env
	syscall
	; exit if execve fails
	mov rax, 0x1
	mov rdi, 0x1
	mov rsi, execveFailStr
	mov rdx, execveFailStrLen
	syscall
	mov rax, 0x3c
	mov rdi, 69
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



