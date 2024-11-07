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

%macro cextern 1
%ifidn __OUTPUT_FORMAT__, mach064
    extern _%1
%else
    extern %1
%endif
%endmacro

%macro ccall 1
%ifidn __OUTPUT_FORMAT__, mach064
    call _%1
%else
    call %1
%endif
%endmacro
