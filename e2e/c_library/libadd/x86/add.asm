; add.asm
; A trivial implementation of adding two integers observing C ABI.
;

%include "libadd/x86/x86util.asm"

SECTION .text

;
; int add_asm(int edi, int esi)
;
cglobal add_asm
    mov eax, edi
    add eax, esi
    pop rbx
    ret
