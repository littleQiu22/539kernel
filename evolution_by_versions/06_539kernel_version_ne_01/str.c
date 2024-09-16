#include "str.h"

void strcpy(char *dest, char *src)
{
    while (*src != '/0')
    {
        *dest = *src;
        dest++;
        src++;
    }
}

int strcmp(char *str1, char *str2)
{
    while (*str1 != '\0')
    {
        if(*str1 != *str2)
        {
            return 0;
        }
        str1++;
        str2++;
    }
    if(*str2 != '\0')
    {
        return 0;
    }
    return 1;
}