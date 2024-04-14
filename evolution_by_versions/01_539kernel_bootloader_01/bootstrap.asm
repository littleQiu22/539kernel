start:
    mov     ax, 07C0h                   ; 07C0h is the address where firmware will load bootloader into. This address is used as base address for loading data and jumping instruction of bootloader               
    mov     ds, ax                      ; ds:si is the memory address where loadb instruction loads data 

    mov     si, title_string
    call    print_string

    mov     si, message_string
    call    print_string

    call    load_kernel_from_disk
    jmp     0900h:0000h                 ; if no error, 0900h:0000 is the physical address of kernel's start

load_kernel_from_disk:
    mov     ax, 0900h
    mov     es, ax                      ; es:bx is the memory address which service 13h:02h writes content read from disk into

    mov     ah, 02h                     ; read service
    mov     al, 01h                     ; number of sectors to read
    mov     ch, 0h                      ; track number to read from
    mov     cl, 02h                     ; starting sector number to read
    mov     dh, 0h                      ; header number
    mov     dl, 80h                     ; type of disk to read from (00h means floppy disk, 80h means hard disk #0, 81h means hard disk #1)
    mov     bx, 0h                      ; offset address the kernel will be written into
    int     13h                         ; disk related services

    jc      kernel_load_error           ; jump to kernel_load_error if carriy flag is 1, which is setted after int instruction failed      

    ret

kernel_load_error:
    mov     si, load_error_string
    call    print_string

    jmp     $                           ; infinite loop

print_string:
    mov     ah, 0Eh                     ; specific service: print character on the cursor 
    ; subsequent instructions will be executed sequentially

print_char:
    lodsb                               ; load a byte (character) from memory addressed by ds:si, and store it in al register, which will be printed by 10h:0Eh service

    cmp     al, 0h                       ; C-null termination mechanism
    je      printing_finished

    int     10h                         ; vedio related services

    jmp     print_char                  ; loop print

printing_finished:
    ; print new line
    mov     al, 10d                     
    int     10h

    ; Reading current cursor position
    mov     ah, 03h
    mov     bh, 0h
    int     10h

    ; Move the cursor to the beginning
    mov     ah, 02h
    mov     dl, 0h                      ; position of cursor
    int     10h

    ret

title_string            db      'The Bootloader of 539kernel.', 0
message_string          db      'The kernel is loading...', 0
load_error_string       db      'The kernel cannot be loaded.', 0

; fill middle space of bootloader with 0, to reach magic position of boot sector
times   510 - ($ - $$)  db      0
dw      0xAA55