section .text
    global _start

_start:
    jmp short get_message

shellcode:
    ; Get message address using JMP-CALL-POP
    pop rsi
    
    ; write(1, message, 13) - NO NULL BYTES!
    xor rax, rax        ; Clear RAX
    mov al, 1           ; SYS_write = 1 (only sets low byte)
    xor rdi, rdi        ; Clear RDI  
    mov dil, 1          ; fd = 1 (only sets low byte)
    xor rdx, rdx        ; Clear RDX
    mov dl, 13          ; length = 13 (only sets low byte)
    syscall

    ; exit(0) - NO NULL BYTES!
    xor rax, rax        ; Clear RAX
    mov al, 60          ; SYS_exit = 60 (only sets low byte)
    xor rdi, rdi        ; status = 0 (no null bytes!)
    syscall

get_message:
    call shellcode
    message db "Hello World!", 0x0a
