
typedef enum process_state {READY, RUNNING} process_state_t;

typedef struct process_context
{
    int eax, ecx, edx, ebx, esp, ebp, esi, edi, eip;
} process_context_t;

typedef struct process
{
    int pid;
    process_state_t state;
    process_context_t context;
    int *base_address;
} process_t;

extern process_t *processes[15];

extern int processes_count, curr_pid;

void process_init();
process_t* process_create(int *base_address);

