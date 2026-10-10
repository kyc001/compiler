    # LP64D: float arguments/results use fa0; int and pointer arguments use a0/a1.
    .option nopic
    .data
    .p2align 2
    .globl weights
weights:
    .float 1.5, 2.0, 3.25, 4.0

    .text
    .p2align 2
    .globl row_sum
    .type row_sum, @function
row_sum:
    slli t0, a1, 3
    add t0, a0, t0
    flw fa0, 0(t0)
    flw ft0, 4(t0)
    fadd.s fa0, fa0, ft0
    ret
    .size row_sum, .-row_sum

    .globl main
    .type main, @function
main:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    call getint
    mv s0, a0
    bltz s0, .Larray_invalid
    li t0, 2
    bge s0, t0, .Larray_invalid
    la a0, weights
    mv a1, s0
    call row_sum
    fcvt.w.s s1, fa0, rtz
    fcvt.s.w ft0, s0
    fadd.s fa0, fa0, ft0
    call putfloat
    li a0, 32
    call putch
    mv a0, s1
    call putint
    li a0, 10
    call putch
    j .Larray_return
.Larray_invalid:
    li a0, -1
    call putint
    li a0, 10
    call putch
.Larray_return:
    li a0, 0
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret
    .size main, .-main
    .section .note.GNU-stack,"",@progbits

