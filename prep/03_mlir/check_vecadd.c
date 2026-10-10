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

static int check(const char *name, float a[4], float b[4], float output[4],
                 const float expected[4]) {
    MemRef1D da = {a, a, 0, {4}, {1}};
    MemRef1D db = {b, b, 0, {4}, {1}};
    MemRef1D dc = {output, output, 0, {4}, {1}};
    _mlir_ciface_vecadd(&da, &db, &dc);
    for (int i = 0; i < 4; ++i) {
        if (output[i] != expected[i]) {
            fprintf(stderr, "%s[%d]: expected %g, got %g\n", name, i, expected[i], output[i]);
            return 1;
        }
    }
    printf("PASS: %s: %g %g %g %g\n", name, output[0], output[1], output[2], output[3]);
    return 0;
}

int main(void) {
    float a[4] = {1.0f, 2.0f, 3.0f, 4.0f};
    float b[4] = {0.5f, 2.5f, 4.5f, 6.5f};
    float output[4] = {0.0f};
    const float expected[4] = {1.5f, 4.5f, 7.5f, 10.5f};
    if (check("baseline", a, b, output, expected)) return 1;
    float c[4] = {-1.5f, 0.0f, 8.0f, -0.25f};
    float d[4] = {0.5f, -2.0f, -8.0f, 0.125f};
    const float signed_expected[4] = {-1.0f, -2.0f, 0.0f, -0.125f};
    if (check("signed", c, d, output, signed_expected)) return 1;
    if (check("in-place", c, d, c, signed_expected)) return 1;
    return 0;
}

