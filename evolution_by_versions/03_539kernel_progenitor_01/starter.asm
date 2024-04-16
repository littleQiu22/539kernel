bits 16                         ; explicitly state the asm works for 16bit mode(real-mode), otherwise 32bit instruction will be generated when the asm is compiled to elf32 format
extern kernel_main              ; declare, for later link

start:
    ; copy code segment value to data segment value
    mov     ax, cs
    mov     ds, ax

    call    load_gdt
    call    init_video_mode
    call    enter_protected_mode
    call    setup_interrupts

    call    08h:start_kernel

; todo
setup_interrupts:
    ret

load_gdt:
    cli
    lgdt    [gdtr - start]      ; load value in ds:[gdtr - start] into register GTDR. label "start" is the initial address of data segment, so substract it from gdtr label to produce offset

%include "gdt.asm"