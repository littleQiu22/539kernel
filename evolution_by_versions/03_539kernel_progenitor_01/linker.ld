SECTIONS
{
    /* text section's initial address: 0x09000 */
    .text 0x09000:
    {
        /* denote code, _code, __code as the start address of this section */
        code = .; _code = .; __code = .;
        /* put all text sections in all input files to this place */
        *(.text)
    }

    .data:
    {
        data = .; _data = .; __data = .;
        *(.data)
        *(.rodata)
    }

    .bss:
    {
        bss = .; _bss = .; __bss = .;
        *(.bss)
    }

    end = .; _end = .; __end = .;
}