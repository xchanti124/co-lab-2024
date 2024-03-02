#ifdef MACOS
    .global _my_fib
    printf: jmp _printf
    scanf: jmp _scanf
#else 
    .global my_fib
    _printf: jmp printf
    _scanf: jmp scanf
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
# [constants/strings]

# uint64_t my_fib(uint64_t n)
_my_fib:
my_fib:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $16, %rsp
    movq    %rdi, -8(%rbp)

    cmpq    $1, %rdi
    jle     base_case

    decq    %rdi
    call    my_fib # my_fib(index - 1)
    movq    -8(%rbp), %rdi # move index back into rdi
    movq    %rax, %rsi
    movq    %rsi, -16(%rbp)
    subq    $2, %rdi
    call    my_fib # my_fib(index - 2)
    movq    -16(%rbp), %rsi
    addq    %rsi, %rax
    jmp     return

    movq    -8(%rbp), %rdi
    
base_case:
    movq    %rdi, %rax

return:
    movq    %rbp, %rsp
    popq    %rbp
    ret

    # 0, 1, 2, 3, 4, 5, 6, 7
    # 0, 1, 1, 2, 4, 6, 10, segfault