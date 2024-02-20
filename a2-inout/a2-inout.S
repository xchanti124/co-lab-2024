#ifdef MACOS
    .global _my_inc
    printf: jmp _printf
    scanf: jmp _scanf
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_inc
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
prompt_text:
    .asciz "Enter a number: "
input_number:
    .asciz "%ld"
output_number:
    .asciz "The incremented number is: %ld"

_main:
main:
    pushq %rbp
    movq %rsp, %rbp
    
    leaq prompt_text(%rip), %rdi
    movb $0, %al
    call printf

    leaq input_number(%rip), %rdi # load effective address of the format string `input_number` into rdi register (will be first arg for scanf)
    subq $8, %rsp # we reserve space on the stack for 8 bytes
    movq %rsp, %rsi # move the address of the reserved space as a second arg to scanf (which is rsi)
    movb $0, %al # need to specify the number of vector registers (in the case of using scanf, this will always be 0), more of a convention
    subq $8, %rsp # since we only reserved 8 bytes, our stack is misaligned by 8 bytes (for subroutine calls, stack needs to be 16-byte aligned)
    call scanf # scanf is called with two arguments: the format string, loaded into %rdi, the address at which the input should be stored at (%rsi)
    addq $8, %rsp # we discard the 8 bytes that we added just for stack alignment, since we did not use them
    popq %rdi

    call my_inc

    movq %rax, %rsi
    leaq output_number(%rip), %rdi
    call printf
    
    movq %rbp, %rsp
    popq %rbp
    movq $0, %rax
    ret

# int64_t my_inc(int64_t n)
_my_inc:
my_inc:
    pushq %rbp
    movq %rsp, %rbp

    inc %rdi
    movq %rdi, %rax

    movq %rbp, %rsp
    popq %rbp
    ret
