; eq_x86.asm
; A trivial implementation of comparing two integers.
;

%include "libadd/x86/x86util.asm"

SECTION .text

;
; int eq_asm(int edi, int esi)
;
cglobal eq_asm
    xor eax, eax
    cmp edi, esi
    jne done
    mov eax, 1
done:
    ret
