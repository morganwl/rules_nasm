; Copyright (c) 2024 Morgan Wajda-Levie.
; 
; Reference a macro that is not defined in this file or any included
; file.
BITS 64

%ifidn __OUTPUT_FORMAT__, macho64
    %define MAIN _main
%else
    %define MAIN main
%endif

global MAIN

section .text
MAIN:
        xor rax, rax
        MYAD rdx, 4, 1
        cmp rdx, 5
        je equal
        mov rax, 1
equal:
        ret
