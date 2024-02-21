#ifdef MACOS
    .global _my_pow
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_pow
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
prompt_base:
    .asciz "Enter a base: "
input_base:
    .asciz "%ld"
prompt_exponent:
    .asciz "Enter an exponent: "
input_exponent:
    .asciz "%lu"
output:
    .asciz "%ld^%ld = %ld"

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    prompt_base(%rip), %rdi
    movb    $0, %al
    call    printf
    
    leaq    input_base(%rip), %rdi
    subq    $16, %rsp
    leaq    -8(%rbp), %rsi
    movb    $0, %al
    call    scanf

    leaq    prompt_exponent(%rip), %rdi
    movb    $0, %al
    call    printf
    
    leaq    input_exponent(%rip), %rdi
    leaq    -16(%rbp), %rsi
    movb    $0, %al
    call    scanf

    movq    -8(%rbp), %rdi
    movq    -16(%rbp), %rsi

    call    my_pow

    movq    -8(%rbp), %rsi
    movq    -16(%rbp), %rdx

    movq    %rax, %rcx
    leaq    output(%rip), %rdi
    call    printf

    movq    %rbp, %rsp
    pop     %rbp
    movq    $0, %rax
    ret

# int64_t my_pow(int64_t base, uint64_t exponent)
_my_pow:
my_pow:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $1, %rax

    loop:
        cmpq    $0, %rsi
        je      end
        mulq    %rdi
        decq    %rsi
        jmp     loop
    end:

    movq    %rbp, %rsp
    pop     %rbp
    ret