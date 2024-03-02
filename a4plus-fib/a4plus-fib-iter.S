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

    cmpq    $1, %rdi    # rdi <= 1?
    movq    %rdi, %rax  # rdi -> rax
    jbe     return      # return rax

    movq    $0, %rsi    # num1 
    movq    $1, %rdx    # temp
    movq    $1, %rcx    # sum

    subq    $1, %rdi
    loop:
        cmpq    $0, %rdi
        jbe     end
        # temp = sum
        # sum = sum + num1
        # num1 = temp
        movq    %rcx, %rdx
        addq    %rsi, %rcx
        movq    %rdx, %rsi
        decq    %rdi
        jmp     loop
    end:

    movq    %rcx, %rax

return:
    movq    %rbp, %rsp
    popq    %rbp
    ret
