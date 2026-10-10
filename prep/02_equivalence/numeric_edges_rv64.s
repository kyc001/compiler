    # Independently written RV64GC / LP64D implementation of numeric_edges.sy.
    .option nopic
    .section .rodata
    .p2align 2
.Lconstants:
    .float 2.0, 0.25, 1.0, 4.0
    .text
    .p2align 2
    .globl sumdown
    .type sumdown, @function
sumdown:
    beqz a0, .Lsum_base
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    mv s0, a0
    addiw a0, a0, -1
    call sumdown
    addw a0, a0, s0
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
.Lsum_base:
    ret
    .size sumdown, .-sumdown

    .globl update
    .type update, @function
update:
    lw t0, 4(a0)
    addw t0, t0, a1
    sw t0, 4(a0)
    lw t1, 8(a0)
    lw t2, 0(a0)
    addw t1, t1, t2
    subw t1, t1, t0
    sw t1, 8(a0)
    ret
    .size update, .-update

    .globl calculate
    .type calculate, @function
calculate:
    la t0, .Lconstants
    fneg.s fa0, fa0
    flw ft0, 0(t0)
    fdiv.s fa0, fa0, ft0
    flw ft1, 4(t0)
    fsub.s fa0, fa0, ft1
    flw ft1, 8(t0)
    fadd.s fa0, fa0, ft1
    fmul.s fa0, fa0, ft0
    flw ft1, 12(t0)
    fdiv.s fa0, fa0, ft1
    ret
    .size calculate, .-calculate

    .globl main
    .type main, @function
main:
    addi sp, sp, -80
    sd ra, 72(sp)
    sd s0, 64(sp)
    sd s1, 56(sp)
    sd s2, 48(sp)
    sd s3, 40(sp)
    sd s4, 32(sp)
    call getint
    mv s0, a0
    call getint
    mv s1, a0
    li t0, -12
    blt s0, t0, .Lnumeric_invalid
    li t0, 12
    bgt s0, t0, .Lnumeric_invalid
    beqz s1, .Lnumeric_invalid
    li t0, -3
    blt s1, t0, .Lnumeric_invalid
    li t0, 3
    bgt s1, t0, .Lnumeric_invalid
    sw s0, 0(sp)
    sw zero, 4(sp)
    sw zero, 8(sp)
    mv a0, sp
    mv a1, s1
    call update
    mv s2, s0
    bgez s2, .Lmagnitude_ready
    negw s2, s2
.Lmagnitude_ready:
    fcvt.s.w fa0, s0
    call calculate
    fsw fa0, 16(sp)
    fcvt.w.s s3, fa0, rtz
    fmv.w.x ft0, zero
    flt.s s4, fa0, ft0
    divw a0, s0, s1
    call putint
    li a0, 32
    call putch
    remw a0, s0, s1
    call putint
    li a0, 32
    call putch
    flw fa0, 16(sp)
    call putfloat
    li a0, 32
    call putch
    mv a0, s3
    call putint
    li a0, 32
    call putch
    mv a0, s4
    call putint
    li a0, 32
    call putch
    mv a0, s2
    call sumdown
    call putint
    li a0, 32
    call putch
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    li t3, 2
    mulw t1, t1, t3
    li t3, 3
    mulw t2, t2, t3
    addw a0, t0, t1
    addw a0, a0, t2
    call putint
    li a0, 10
    call putch
    j .Lnumeric_return
.Lnumeric_invalid:
    li a0, -1
    call putint
    li a0, 10
    call putch
.Lnumeric_return:
    li a0, 0
    ld s4, 32(sp)
    ld s3, 40(sp)
    ld s2, 48(sp)
    ld s1, 56(sp)
    ld s0, 64(sp)
    ld ra, 72(sp)
    addi sp, sp, 80
    ret
    .size main, .-main
    .section .note.GNU-stack,"",@progbits
