; Copyright (c) 2024 Morgan Wajda-Levie.
;
; Return 16 from a called function.

global _return_16
section .text
_return_16:
        mov rax, 16
        ret
