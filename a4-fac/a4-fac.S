#ifdef MACOS
    .global _my_factorial
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_factorial
    _printf: jmp printf
    _scanf: jmp scanf
    #ifdef STANDALONE
        .global main
    #endif
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
input_prompt:
    .asciz "Enter a number: "
input_value:
    .asciz "%ld"
output_result:
    .asciz "%ld! = %ld"

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    input_prompt(%rip), %rdi
    movb    $0, %al
    call    printf

    leaq    input_value(%rip), %rdi
    subq    $16, %rsp
    leaq    -8(%rbp), %rsi
    movb    $0, %al
    call    scanf

    movq    -8(%rbp), %rdi

    call    my_factorial

    movq    -8(%rbp), %rsi

    movq    %rax, %rdx
    leaq    output_result(%rip), %rdi
    movb    $0, %al
    call    printf

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret

# uint64_t my_factorial(uint64_t n)
_my_factorial: 
my_factorial:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $16, %rsp
    movq    %rdi, -8(%rbp)

    movq    %rdi, %rax

    cmpq    $1, %rax
    jle     base_case 

    decq    %rax
    movq    %rax, %rdi
    call    my_factorial 

    movq    -8(%rbp), %rsi 
    mulq    %rsi
    jmp     return

base_case:
    movq    $1, %rax

return:
    movq    %rbp, %rsp
    popq    %rbp

    ret
