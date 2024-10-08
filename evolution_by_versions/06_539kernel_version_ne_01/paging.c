#include "paging.h"

unsigned int *page_directory;

int create_page_entry(unsigned int base_address, char present, char writable,
char privilege_level, char cache_enabled, char
write_through_cache, char accessed, char page_size, char dirty){
	// note: base_address must be 4KB-aligned
    unsigned int entry = 0;
	
	entry |= present;
	entry |= writable << 1;
	entry |= privilege_level << 2;
	entry |= write_through_cache << 3;
	entry |= cache_enabled << 4;
	entry |= accessed << 5;
	entry |= dirty << 6;
	entry |= page_size << 7;
	return base_address | entry;
}

void paging_init()
{
    // PART 1: 
    // 1. allocate memory for paging directory
    // 2. specify PDE_NUM entries in paging directory
    // 3. allocate memory for PDE_NUM paging tables
    // 4. specify PTE_NUM entries in each paging table

	unsigned int curr_page_frame = 0;
	
	page_directory = kalloc( 4 * 1024 );
		
	for ( int currPDE = 0; currPDE < PDE_NUM; currPDE++ )
	{
		unsigned int *pagetable = kalloc( 4 * PTE_NUM );
		
		for ( int currPTE = 0; currPTE < PTE_NUM; currPTE++, curr_page_frame++ )
			pagetable[ currPTE ] = create_page_entry( curr_page_frame * 4096, 1, 0, 0, 1, 1, 0, 0, 0 );
		
		page_directory[ currPDE ] = create_page_entry( pagetable, 1, 0, 0, 1, 1, 0, 0, 0 );
	}
    
    // ... //
    
    // PART 2
    
	load_page_directory();
	enable_paging();
}