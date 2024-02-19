#ifdef MACOS
    .global _main
    printf: jmp _printf
#else 
    .global main
    _printf: jmp printf
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
hello_world:
    .asciz "Computer Organization 2024\nAssignment 1 - hello\nby Chantal Ariu"

_main:
main:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    leaq hello_world(%rip), %rdi
    movb $0, %al
    call printf

    # epilogue
    movq %rbp, %rsp
    popq %rbp
    movq $0, %rax
    ret