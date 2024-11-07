; hello.asm
; Print hello world to stdout.
;

%include "hello/x86util.asm"

    cextern puts

SECTION .text

cglobal main
    ; mov rdi, s0
    lea rdi, [rel s0]
    ccall puts wrt ..plt
    xor rax, rax
    ret

SECTION .data

s0: db  "Hello.", 0
