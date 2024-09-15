; job of bootstrap: 
; - load kernel from disk
; - show informative message
; - transfer control to kernel

start:
    mov     ax, 07C0h                   ; 07C0h is the address where standard firmware will load bootloader into. This address is used as base address for loading data and jumping instruction of bootloader               
    mov     ds, ax                      ; ds:si is the memory address where loadb instruction loads data 

    mov     si, title_string
    call    print_string

    mov     si, message_string
    call    print_string

    call    load_kernel_from_disk
    jmp     0900h:0000h                 ; if no error, 0900h:0000 is the physical address of kernel's start


; load_kernel_from_disk routine will be executed by recursive style until all sectors are loaded
load_kernel_from_disk:
    ; calculate the offset in memory to store to-load sector. Store offset in bx. The base address will be stored in es register
    mov ax, [curr_sector_to_load]
    sub ax, 2                           ; ax = ax - 2 (kernel start from sector 2)
    mov bx, 512d                        ; bx = 512d
    mul bx                              ; dx, ax = ax * bx
    mov bx, ax                          ; bx = ax

    ; base address of kernel is 0900h. es:bx is the memory address which service 13h:02h writes content read from disk into
    mov ax, 0900h
    mov es, ax

    ; use read interrupt service
    mov ah, 02h                         ; read service
    mov al, 1h                          ; number of sectors to read
    mov ch, 0h                          ; track number to read from
    mov cl, [curr_sector_to_load]       ; starting sector number to read
    mov dh, 0h                          ; header number
    mov dl, 80h                         ; type of disk to read from (00h means floppy disk, 80h means hard disk #0, 81h means hard disk #1)
    int 13h                             ; disk related services

    jc kernel_load_error                ; jump to kernel_load_error if carriy flag is 1, which is setted after int instruction failed      

    sub byte [number_of_sectors_to_load],   1   ; b[number_of_sectors_to_load] -= 1
    add byte [curr_sector_to_load],         1   ; b[curr_sector_to_load] += 1

    ; if not b[number_of_sectors_to_load] == 0: load_kernel_from_disk
    cmp byte [number_of_sectors_to_load],   0   
    jne load_kernel_from_disk

    ret

kernel_load_error:
	mov si, load_error_string
	call print_string
    ; loop forever
	jmp $

print_string:
    mov     ah, 0Eh                     ; specific service: print character on the cursor

print_char:
    ; al = [ds:si] 
    lodsb                              

    ; if al == 0h: jump to printing_finished
    cmp     al, 0h                       ; C-null termination mechanism
    je      printing_finished

    ; int 10h:0Eh
    int     10h                         ; vedio related services

    ; print char by recursive style
    jmp     print_char                  ; loop print

printing_finished:
    ; al = 10d. Print new line
    mov al, 10d
    int 10h
    
    ; Reading current cursor position
    ; ah = 03h
    ; bh = 0
    mov ah, 03h
	mov bh, 0
	int 10h
	
    ; Move the cursor to the beginning (0-th column)
    ; ah = 02h
    ; dl = 0
	mov ah, 02h
	mov dl, 0
	int 10h

	ret
    
title_string        db  'The Bootloader of 539kernel.', 0
message_string      db  'The kernel is loading...', 0
load_error_string   db  'The kernel cannot be loaded', 0
number_of_sectors_to_load 	db 	10d
curr_sector_to_load 		db 	2d

; fill middle space of bootloader with 0, to reach magic position of boot sector
times 510-($-$$) db 0
dw 0xAA55
