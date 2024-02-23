#ifdef MACOS
    my_fib: jmp _my_fib
    printf: jmp _printf
    scanf: jmp _scanf
    .global _main
#else
    _my_fib: jmp my_fib
    _printf: jmp printf
    _scanf: jmp scanf
    .global main
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
input_prompt:
    .asciz "Enter an index: "
input_index:
    .asciz "%ld"
output_message:
    .asciz "F_%lu = %lu"

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    input_prompt(%rip), %rdi
    movb    $0, %al
    call    printf

    leaq    input_index(%rip), %rdi
    subq    $16, %rsp
    leaq    -8(%rbp), %rsi
    movb    $0, %al
    call    scanf

    movq    -8(%rbp), %rdi

    call    my_fib

    movq    -8(%rbp), %rsi
    movq    %rax, %rdx

    leaq    output_message(%rip), %rdi
    movb    $0, %al
    call printf

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret
