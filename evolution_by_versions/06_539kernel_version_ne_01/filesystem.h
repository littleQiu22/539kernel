#define BASE_BLOCK_ADDRESS 100
#define FILENAME_LENGTH 256

typedef struct 
{
    int head, tail;
} base_block_t;

typedef struct 
{
    char filename[FILENAME_LENGTH];
    int next_file_address;
} metadata_t;

base_block_t *base_block;

void filesystem_init();
void create_file(char* filename, char* buffer);
char **list_files();
char *read_file(char* filename);
void delete_file( char *filename );

// auxiliary functions
metadata_t *load_metadata(int address);
int get_address_by_filename(char* filename);
int get_prev_file_address(int address);
int get_files_number();
void update_base_block(int new_head, int new_tail);
void print_fs();
