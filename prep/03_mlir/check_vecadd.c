#include <stdint.h>
#include <stdio.h>

typedef struct {
    float *allocated;
    float *aligned;
    int64_t offset;
    int64_t sizes[1];
    int64_t strides[1];
} MemRef1D;

extern void _mlir_ciface_vecadd(MemRef1D *, MemRef1D *, MemRef1D *);

int main(void) {
    float a[4] = {1.0f, 2.0f, 3.0f, 4.0f};
    float b[4] = {0.5f, 2.5f, 4.5f, 6.5f};
    float output[4] = {0.0f};
    float expected[4] = {1.5f, 4.5f, 7.5f, 10.5f};
    MemRef1D da = {a, a, 0, {4}, {1}};
    MemRef1D db = {b, b, 0, {4}, {1}};
    MemRef1D dc = {output, output, 0, {4}, {1}};
    _mlir_ciface_vecadd(&da, &db, &dc);
    for (int i = 0; i < 4; ++i) {
        if (output[i] != expected[i]) {
            fprintf(stderr, "vecadd[%d]: expected %g, got %g\n", i, expected[i], output[i]);
            return 1;
        }
    }
    puts("PASS: generic MLIR vecadd: 1.5 4.5 7.5 10.5");
    return 0;
}

