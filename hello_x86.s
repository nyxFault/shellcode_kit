section .text
global _start

_start:
    ; Clear registers efficiently
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    
    ; write(1, msg, 14)
    mov al, 4        ; sys_write
    inc ebx          ; stdout = 1 (instead of mov bl, 1)
    
    jmp short get_msg
    
ret_msg:
    pop ecx          ; msg address
    
    mov dl, 14       ; length
    
    int 0x80

    ; exit(0)
    xor eax, eax
    mov al, 1        ; sys_exit
    xor ebx, ebx     ; exit code 0
    int 0x80

get_msg:
    call ret_msg
    msg db 'Hello, World!', 0x0A
