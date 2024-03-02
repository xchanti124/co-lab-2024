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
    jbe     base_case               # jbe instead of jle because we are working with unsigned integers

    decq    %rdi
    call    my_fib                  # my_fib(index - 1)
    movq    -8(%rbp), %rdi          # move index back into rdi
    movq    %rax, -16(%rbp)
    subq    $2, %rdi
    call    my_fib                  # my_fib(index - 2)
    addq    -16(%rbp), %rax
    jmp     return
    
base_case:
    movq    %rdi, %rax

return:
    movq    %rbp, %rsp
    popq    %rbp
    ret