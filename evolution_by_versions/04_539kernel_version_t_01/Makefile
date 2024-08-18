ASM = nasm
CC = gcc
BOOTSTRAP_FILE = bootstrap.asm
INIT_KERNEL_FILES = starter.asm
KERNEL_FILES = main.c
KERNEL_FLAGS = -Wall -m32 -c -ffreestanding -fno-asynchronous-unwind-tables -fno-pie -fno-stack-protector
KERNEL_OBJECT = -o kernel.elf

build: $(BOOTSTRAP_FILE) $(INIT_KERNEL_FILES) $(KERNEL_FILES)
	$(ASM) -f bin $(BOOTSTRAP_FILE) -o bootstrap.o						# no need for linking, just compile to binary file
	$(ASM) -f elf32 $(INIT_KERNEL_FILES) -o starter.o					# need later linking, to elf format file
	$(CC) $(KERNEL_FLAGS) $(KERNEL_FILES) $(KERNEL_OBJECT)				# need later linking, to elf format file
	$(CC) $(KERNEL_FLAGS) screen.c -o screen.elf
	$(CC) $(KERNEL_FLAGS) process.c -o process.elf
	$(CC) $(KERNEL_FLAGS) scheduler.c -o scheduler.elf
	ld -melf_i386 -Tlinker.ld starter.o kernel.elf screen.elf process.elf scheduler.elf -o 539kernel.elf		# link routines and kernel using linker.ld layout script
	objcopy -O binary 539kernel.elf 539kernel.bin						# convert elf format to kernel binary file
	dd if=bootstrap.o of=kernel.img										# pick bootstrap binary file to final image
	dd seek=1 conv=sync if=539kernel.bin of=kernel.img bs=512 count=5	# pick kernel binary file to final image (start from 1 * 512 bytes, size is 5 * 512 bytes)
	dd seek=6 conv=sync if=/dev/zero of=kernel.img bs=512 count=2046	# pad image with zero
	qemu-system-x86_64 -s kernel.img
	