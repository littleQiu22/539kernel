#define BASE_PORT 0x1F0
#define SECTOR_SIZE 512



void wait_drive_until_ready();

// logic block addressing schema
void *read_disk(unsigned int address);
void write_disk(unsigned int address, short* buffer);

// cylinder-header-sector schema
void *read_disk_chs(int sector);
void write_disk_chs(int sector, short* buffer);

extern void dev_write(int port, int cmd);
extern void dev_write_word(int port, short w);
extern short dev_read(int port);











