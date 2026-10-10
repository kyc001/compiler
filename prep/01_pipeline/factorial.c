#include <stdio.h>

#ifndef FIRST_FACTOR
#define FIRST_FACTOR 2
#endif

int factorial(int n) {
    int result = 1;
    int i = FIRST_FACTOR;
    while (i <= n) {
        result = result * i;
        i = i + 1;
    }
    return result;
}

int main(void) {
    int n;
    if (scanf("%d", &n) != 1 || n < 0 || n > 12) {
        return 1;
    }
    printf("%d\n", factorial(n));
    return 0;
}

