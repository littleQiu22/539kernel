; job of starter:
; - prepare GDT (global descriptor table), interrupt service, vedio mode
; - switch to 32-bit protected mode
; - transfer control to main kernel 

bits 16                         ; explicitly state the asm works for 16bit mode(real-mode), otherwise 32bit instruction will be generated when the asm is compiled to elf32 format
extern kernel_main              ; declare, for later link
extern interrupt_handler        ; declare, for later link
extern scheduler
extern run_next_process
extern page_directory
global load_page_directory
global enable_paging
global dev_write
global dev_write_word
global dev_read

start:
    ; copy code segment value to data segment value
    mov     ax, cs
    mov     ds, ax

    call    load_gdt
    call    init_video_mode
    call    setup_interrupts
    call    enter_protected_mode
	call	load_task_register
    ; far jump after entering into protected mode
    call    08h:start_kernel

setup_interrupts:
	call remap_pic				; remap programmable interrupt controller, prevent from mixing software and hardware interrupts
	call load_idt				; set interrupt descriptor table
    ret

; pic is port-mapped I/O. Use 'out' instruction to communicate with it
remap_pic:
	; initialization command for pic
	mov al, 11h					
	send_init_cmd_to_pic_master:
		out 0x20, al			
	send_init_cmd_to_pic_slave: 	
		out 0xa0, al
	; new starting offset of IRQs
	make_irq_starts_from_intr_32_in_pic_master:		
		mov al, 32d
		out 0x21, al
	make_irq_starts_from_intr_40_in_pic_slave:
		mov al, 40d
		out 0xa1, al
	; tell slots of master/slave pic
	tell_pic_master_where_pic_slave_is_connected:
		mov al, 04h				; IRQ2 is 0b00000100 for master pic, which is 04h
		out 0x21, al
	tell_pic_slave_where_pic_master_is_connected:
		mov al, 02h				; IRQ2 is just 02h for slave pic
		out 0xa1, al
	; tell arch
	mov al, 01h
	tell_pic_master_the_arch_is_x86:
		out 0x21, al
	tell_pic_slave_the_arch_is_x86:
		out 0xa1, al
	; ... ;
	mov al, 0h
	make_pic_master_enables_all_irqs:
		out 0x21, al
	make_pic_slave_enables_all_irqs:
		out 0xa1, al
	ret

load_idt:
	lidt [idtr - start]
	ret

load_task_register:
	mov ax, 40d
	ltr ax
	ret

load_gdt:
    cli                         ; disable the interrupts before starting the process of switching to protected-mode
    lgdt    [gdtr - start]      ; load value in ds:[gdtr - start] into register GTDR. label "start" is the initial address of data segment, so substract it from gdtr label to produce offset
    ret

enter_protected_mode:
    ; when the value of register cr0's bit 0 is 1, that means protected-mode is enabled
    mov eax, cr0
	or eax, 1
	mov cr0, eax
	
	ret

init_video_mode:
    ; 10h:0h with al=03h set video mode to text mode with 16 colors
	mov ah, 0h
	mov al, 03h
	int 10h
	
    ; 10h:0h with cx=2000h set text cursor to be disabled
	mov ah, 01h
	mov cx, 2000h
	int 10h
	
	ret

; protected-mode is 32-bit 
bits 32

load_page_directory:
	mov eax, [page_directory]
	mov cr3, eax
	ret

enable_paging:
	mov eax, cr0
	or eax, 80000000h
	mov cr0, eax
	ret

; void dev_write(int port, int cmd)
dev_write:
	; copy registers first and to restore them later
	push edx
	push eax

	; clear register to zero
	xor edx, edx
	xor eax, eax

	; copy <port> to dx
	; copy <cmd> to al
	mov dx, [esp+12]
	mov al, [esp+16]

	out dx, al

	; restore influenced registers
	pop eax
	pop edx

	ret

; void dev_write_word(int port, short w)
dev_write_word:
	; copy registers first and to restore them later
	push edx
	push eax

	; clear register to zero
	xor edx, edx
	xor eax, eax

	; copy <port> to dx
	; copy <word> to ax
	mov dx, [esp+12]
	mov ax, [esp+16]

	out dx, ax

	; restore influenced registers
	pop eax
	pop edx

	ret

; short dev_read( int port )
dev_read:
	push edx
	
	xor edx, edx
	xor eax, eax

	mov dx, [esp + 8]

	; eax register should be changed as this function's return value
	; so no need to restore eax register
	in ax, dx

	pop edx

	ret

start_kernel:
    ; set data and stack selector to 0x10 (16d)
	mov eax, 10h
	mov ds, eax
	mov ss, eax
    
    ; rest selector are set to null descriptor, so they are not used
	mov eax, 0h
	mov es, eax
	mov fs, eax
	mov gs, eax
	; recover interrupt service
	sti
	; C procedure of kernel
	call kernel_main

%include "gdt.asm"
%include "idt.asm"

tss:
	dd 0