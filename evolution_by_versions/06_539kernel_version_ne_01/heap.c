#include "heap.h"

unsigned int heap_base;

void heap_init()
{
    heap_base = 0x100000;
}

unsigned int kalloc(int byte_size)
{
    unsigned int new_object_address = heap_base;
    heap_base += byte_size;
    return new_object_address;
}