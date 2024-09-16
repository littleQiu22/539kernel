#include "process.h"

extern int next_sch_pid, curr_sch_pid;

extern process_t *next_process;

void scheduler_init();
process_t *get_next_process();
void scheduler(int eip, int edi, int esi, int ebp, int esp, int ebx, int edx, int ecx, int eax );
void run_next_process();