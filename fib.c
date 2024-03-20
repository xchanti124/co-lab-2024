#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

uint64_t *fib(uint64_t i, uint64_t *arr, uint64_t size)
{
    if (i < size)
    {
        return arr;
    }

    uint64_t *new_arr = realloc(arr, i + 1);

    for (uint64_t iter = size; iter <= i; iter++)
    {
        if (iter == 0)
        {
            new_arr[iter] = 0;
            continue;
        }
        if (iter <= 2)
        {
            new_arr[iter] = 1;
            continue;
        }
        new_arr[iter] = new_arr[iter - 1] + new_arr[iter - 2];
    }
    return new_arr;
}

int main()
{
    uint64_t *arr = NULL;
    uint64_t size = 0;

    while (1)
    {
        uint64_t index = 0;
        printf("Please enter an index: ");
        uint64_t x = scanf("%llu", &index);

        if (x == 0)
        {
            break;
        }

        arr = fib(index, arr, size);

        if (size < index)
        {
            size = index;
        }

        printf("%llu", arr[index]);
        printf("\n");
    }

    for (uint64_t i = 0; i < size; i++)
    {
        // free(arr[i]);
    }
    return 0;
}
