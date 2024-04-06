start:
    mov     ax, cs                      
    mov     ds, ax                      ; ds:si is the memory address where loadb instruction loads data.
                                        ; set ds segment same as cs segment (flat model). This asm unit should be used by jmp, which can set cs segment 

    ; missing parts of kernel

    mov     si, hello_string
    call    print_string

    jmp     $

print_string:
    mov     ah, 0Eh                     ; specific service: print character on the cursor 
    ; subsequent instructions will be executed sequentially

print_char:
    lodsb                               ; load a byte (character) from memory addressed by ds:si, and store it in al register, which will be printed by 10h:0Eh service

    cmp     al, 0h                       ; C-null termination mechanism
    je      done

    int     10h                         ; vedio related services

    jmp     print_char                  ; loop print

done:
    ret

hello_string    db      'Hello World! From Simple Assembly 539kernel!', 0

