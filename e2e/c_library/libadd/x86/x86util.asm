; x86util.asm
; macros for portability between x86 operating systems

; cglobal LABEL
; creates a global label which can be called as LABEL from a C source
; file
%macro cglobal 1
%ifidn __OUTPUT_FORMAT__, macho64
    global _%1
_%1:
%else
    global %1
%1:
%endif
%endmacro
