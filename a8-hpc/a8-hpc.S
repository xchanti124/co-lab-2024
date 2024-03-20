#ifdef MACOS
    .global _main
    printf: jmp _printf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    clock_gettime: jmp _clock_gettime
#else 
    .global main
    _printf: jmp printf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    _clock_gettime: jmp clock_gettime
#endif

#ifndef STREAM_ARRAY_SIZE
    #define STREAM_ARRAY_SIZE 75000000
#endif

#ifndef NTIMES
    #define NTIMES 20
#endif

# Use custom values:        $ make a8-hpc/a8-hpc -B STREAM_ARRAY_SIZE=<custom_size> NTIMES=<custom_reps>
# Revert to default values: $ make a8-hpc/a8-hpc -B

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
# Strings for formatted output:
fmt_info: 
    .asciz "Array size = %lu (elements).\nEach kernel will be executed %u times.\n"
    # printf(fmt_info, STREAM_ARRAY_SIZE, NTIMES)
fmt_div: 
    .asciz "-------------------------------------------------------------\n"
fmt_title: 
    .asciz "%-8s  %13s  %11s  %11s  %11s\n"
    # printf(fmt_title, col_title_function, ...)
fmt_row: 
    .asciz "%-10s  %12.1f  0.%.6lu  0.%.6lu  0.%.6lu\n"
    # printf(fmt_row, row_title_copy, 13029.0, ...)
col_title_function: .asciz "Function"
col_title_rate: .asciz "Best Rate MB/s"
col_title_avg: .asciz "Avg time"
col_title_min: .asciz "Min time"
col_title_max: .asciz "Max time"
row_title_copy: .asciz "Copy:"
row_title_scale: .asciz "Scale:"
row_title_add: .asciz "Add:"
row_title_triad: .asciz "Triad:"

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $32, %rsp

    movq    $STREAM_ARRAY_SIZE, %rdi
    call    malloc
    movq    %rax, -8(%rbp)              # Array A

    movq    $STREAM_ARRAY_SIZE, %rdi
    call    malloc
    movq    %rax, -16(%rbp)             # Array B

    movq    $STREAM_ARRAY_SIZE, %rdi
    call    malloc
    movq    %rax, -24(%rbp)             # Array C

    movq    -8(%rbp), %rdi
    movq    -16(%rbp), %rsi
    call    copy

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret

# rdi = array A, rsi = array B
_copy:
copy:
    pushq   %rbp
    movq    %rsp, %rbp
    # A[i] = B[i]
    subq    $32, (%rsp)
    movq    %rdi, -8(%rbp)  # A
    movq    %rsi, -16(%rbp) # B

    subq    $16, (%rsp)
    subq    $16, (%rsp)
    
    movq    $0, %rcx        # this will be the counter that increments until it reacher $STREAM_ARRAY_SIZE
    movq    %rcx, -24(%rbp)
    movq    $0, %rdx        # counter increments until it reaches $NTIMES
    movq    %rdx, -32(%rbp)

    _start_while_copy_outer_loop:
    start_while_copy_outer_loop:
        cmpq    $NTIMES, %rdx
        jle     end_while_copy_outer_loop

        movq    $CLOCK_REALTIME, %rdi
        leaq    -48(%rbp), %rsi         # buffer for two 8 byte
        call    clock_gettime

        _start_while_copy_inner_loop:           # this will copy entire array, char by char
        start_while_copy_inner_loop:
            cmpq    $STREAM_ARRAY_SIZE, %rcx    # is rcx greater than or equal than STREAM_ARRAY_SIZE? jump to end 
            jle     end_while_copy_inner_loop

            movq    (%rdi), %r9
            movq    (%rsi), %r9

            addq    $8, %rdi
            addq    $8, %rsi
            incq    %rcx

            jmp     start_while_copy_inner_loop
        
        _end_while_copy_inner_loop:
        end_while_copy_inner_loop:

            movq    $CLOCK_REALTIME, %rdi
            leaq    -64(%rbp), %rsi         # buffer for two 8 byte
            call    clock_gettime

            # subtract seconds from seconds
            movq    -64(%rbp), %rax
            movq    -48(%rbp), %rsi
            movq    (%rax), %rax
            subq    (%rsi), %rax          # rax (seconds after copy) = rax - rsi (seconds before copy)

            movq    -32(%rbp), %rdx
            incq    %rdx
            jmp     start_while_copy_outer_loop

    _end_while_copy_outer_loop:
    end_while_copy_outer_loop:

    movq    %rbp, %rsp
    popq    %rbp
    ret


_scale:
scale:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rbp, %rsp
    popq    %rbp
    ret   

_add:
add:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rbp, %rsp
    popq    %rbp
    ret

_triad:
triad:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rbp, %rsp
    popq    %rbp
    ret
