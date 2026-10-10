    # Independently written RV64GC / LP64D assembly for features.sy.
    .option nopic
    .section .rodata
    .p2align 2
limit:
    .word 12
    .section .bss
    .p2align 2
calls:
    .zero 4
    .text
    .p2align 2
    .globl bump
    .type bump, @function
bump:
    la t0, calls
    lw t1, 0(t0)
    addiw t1, t1, 1
    sw t1, 0(t0)
    li a0, 1
    ret
    .size bump, .-bump

    .globl factorial
    .type factorial, @function
factorial:
    li t0, 1
    li t1, 1
.Lfactorial_loop:
    bgt t1, a0, .Lfactorial_exit
    mulw t0, t0, t1
    addiw t1, t1, 1
    j .Lfactorial_loop
.Lfactorial_exit:
    mv a0, t0
    ret
    .size factorial, .-factorial

    .globl arithmetic
    .type arithmetic, @function
arithmetic:
    negw t0, a0
    li t1, 3
    mulw t2, a0, t1
    addw t2, t2, t0
    li t3, 2
    divw t2, t2, t3
    remw t0, a0, t1
    addw a0, t2, t0
    ret
    .size arithmetic, .-arithmetic

    .globl control
    .type control, @function
control:
    li t0, 0
    li t1, 0
.Lcontrol_loop:
    bge t0, a0, .Lcontrol_exit
    addiw t0, t0, 1
    li t2, 3
    beq t0, t2, .Lcontrol_loop
    li t2, 9
    bge t0, t2, .Lcontrol_exit
    addw t1, t1, t0
    j .Lcontrol_loop
.Lcontrol_exit:
    mv a0, t1
    ret
    .size control, .-control

    .globl scope
    .type scope, @function
scope:
    addiw t0, a0, 7
    addw a0, t0, a0
    ret
    .size scope, .-scope

    .globl logic
    .type logic, @function
logic:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    mv s0, a0
    la t0, calls
    sw zero, 0(t0)
    blez s0, .Llogic_zero_check
    call bump
    bnez a0, .Llogic_first_true
.Llogic_zero_check:
    call bump
    beqz a0, .Llogic_first_end
.Llogic_first_true:
    la t0, calls
    lw t1, 0(t0)
    addiw t1, t1, 10
    sw t1, 0(t0)
.Llogic_first_end:
    bltz s0, .Llogic_second_end
    bgez s0, .Llogic_second_true
    call bump
    beqz a0, .Llogic_second_end
.Llogic_second_true:
    la t0, calls
    lw t1, 0(t0)
    addiw t1, t1, 100
    sw t1, 0(t0)
.Llogic_second_end:
    la t0, calls
    lw a0, 0(t0)
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
    .size logic, .-logic

    .globl main
    .type main, @function
main:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    call getint
    mv s0, a0
    bltz s0, .Lmain_invalid
    la t0, limit
    lw t0, 0(t0)
    bgt s0, t0, .Lmain_invalid
    call factorial
    call putint
    li a0, 32
    call putch
    mv a0, s0
    call arithmetic
    call putint
    li a0, 32
    call putch
    mv a0, s0
    call control
    call putint
    li a0, 32
    call putch
    mv a0, s0
    call scope
    call putint
    li a0, 32
    call putch
    mv a0, s0
    call logic
    call putint
    li a0, 10
    call putch
    j .Lmain_return
.Lmain_invalid:
    li a0, -1
    call putint
    li a0, 10
    call putch
.Lmain_return:
    li a0, 0
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret
    .size main, .-main
    .section .note.GNU-stack,"",@progbits

