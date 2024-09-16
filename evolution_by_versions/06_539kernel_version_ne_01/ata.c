#include "ata.h"

// ********* parameters of read command
// port number      purpose (in CHS schema)
// base_port + 2    number of sectors to read
// base_port + 3    sector number to read from
// base_port + 4    lower part of cylinder number
// base_port + 5    higher part of cylinder number
// base_port + 6    bits (0-3) the head to read
//                  bit 4: drive to use (0 = Master, 1 = Slave)
//                  bit 5: always 1
//                  bit 6: addressing mode (0 = CHS)
//                  bit 7: always 1
// base_port + 7    read command (0x20); device status

void *read_disk_chs(int sector)
{
    dev_write(BASE_PORT + 2, 1);
    dev_write(BASE_PORT + 3, sector);
    dev_write(BASE_PORT + 4, 0);
    dev_write(BASE_PORT + 5, 0);
    dev_write(BASE_PORT + 6, 0xa0);
    dev_write(BASE_PORT + 7, 0x20);

    wait_drive_until_ready();

    short *buffer = kalloc(SECTOR_SIZE);
    for(int currByte = 0; currByte < (SECTOR_SIZE / 2); currByte++)
    {
        buffer[currByte] = dev_read(BASE_PORT);
    }
    return buffer;
}

void wait_drive_until_ready()
{
    int status = 0;
    do{
        status = dev_read(BASE_PORT + 7);
    }while ((status & 0x80) == 0);
    
}

// ********* parameters of read command
// port number      purpose (in LBA schema)
// base_port + 2    number of blocks to read
// base_port + 3    bits 0-7 from logic block address
// base_port + 4    bits 8-15 from logic block address
// base_port + 5    bits 16-23 from logic block address
// base_port + 6    bits (0-3) bits 24-27 from logic block address
//                  bit 4: drive to use (0 = Master, 1 = Slave)
//                  bit 5: always 1
//                  bit 6: addressing mode (1 = LBA)
//                  bit 7: always 1
// base_port + 7    read command (0x20); device status

void *read_disk(unsigned int address)
{
    dev_write(BASE_PORT + 2, 1);
    dev_write(BASE_PORT + 3, address & 0x000000FF);
    dev_write(BASE_PORT + 4, (address >> 8) & 0x000000FF);
    dev_write(BASE_PORT + 5, (address >> 16) & 0x000000FF);
    dev_write(BASE_PORT + 6, (0xe0 | (address >> 24 ) & 0x000000F0));
    dev_write(BASE_PORT + 7, 0x20);

    wait_drive_until_ready();

    short *buffer = kalloc(SECTOR_SIZE);
    for(int currByte = 0; currByte < (SECTOR_SIZE / 2); currByte++)
    {
        buffer[currByte] = dev_read(BASE_PORT);
    }
    return buffer;

}

void write_disk_chs(int sector, short* buffer)
{
    dev_write(BASE_PORT + 2, 1);
    dev_write(BASE_PORT + 3, sector);
    dev_write(BASE_PORT + 4, 0);
    dev_write(BASE_PORT + 5, 0);
    dev_write(BASE_PORT + 6, 0xa0);
    dev_write(BASE_PORT + 7, 0x30);

    wait_drive_until_ready();

    for(int currByte = 0; currByte < (SECTOR_SIZE / 2); currByte++)
    {
        dev_write_word(BASE_PORT, buffer[currByte]);
    }

    wait_drive_until_ready();
}


void write_disk(unsigned int address, short *buffer)
{
    dev_write(BASE_PORT + 2, 1);
    dev_write(BASE_PORT + 3, address & 0x000000FF);
    dev_write(BASE_PORT + 4, (address >> 8) & 0x000000FF);
    dev_write(BASE_PORT + 5, (address >> 16) & 0x000000FF);
    dev_write(BASE_PORT + 6, (0xe0 | (address >> 24 ) & 0x000000F0));
    dev_write(BASE_PORT + 7, 0x30);

    wait_drive_until_ready();

    for(int currByte = 0; currByte < (SECTOR_SIZE / 2); currByte++)
    {
        dev_write_word(BASE_PORT, buffer[currByte]);
    }

    wait_drive_until_ready();
}