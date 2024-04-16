number_of_sectors_to_load   db  15d
curr_sector_to_load         db  2d

; load_kernel_from_disk routine will be executed multiple times until all sectors are loaded
load_kernel_from_disk:
    ; calculate gp-to-load sector's offset (stored in bx register) relative to base address (stored in es register) in memory
    mov ax, [curr_sector_to_load]
    sub ax, 2
    mov bx, 512d
    mul bx
    mov bx, ax

    ; determine base address of kernel
    mov ax, 0900h
    mov es, ax

    ; use read service
    mov ah, 02h
    mov al, 1h
    mov ch, 0h
    mov cl, [curr_sector_to_load]
    mov dh, 0h
    mov dl, 80h
    int 13h

    jc kernel_load_error

    ; addjust number_of_sectors_to_load and curr_sector_to_load
    sub byte [number_of_sectors_to_load],   1
    add byte [curr_sector_to_load],         1

    ; check whether all sectors are loaded
    cmp byte [number_of_sectors_to_load],   0
    jne load_kernel_from_disk

    ret
