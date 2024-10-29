; Copyright (c) 2024 Morgan Wajda-Levie.
; 
; Add 4 to 1 and return 0 if result is 5, else return 1.
BITS 64
global main

%include "includes_inc.asm"

section .text
main:
        xor rax, rax
        MYAD rdx, 4, 1
        cmp rdx, 5
        je equal
        mov rax, 1
equal:
        ret
