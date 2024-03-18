#ifdef MACOS
    .global _my_printf
    putchar: jmp _putchar
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_printf
    _putchar: jmp putchar
    #ifdef STANDALONE
        .global main
    #endif
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
percentage_sign:
    .asciz "%"
test_string:
    .asciz "abcd"
null_terminator:
    .asciz "\0"

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    test_string(%rip), %rdi
    # movb  $0, %al
    call    my_printf  

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret

# int my_printf(const char *fmt, ...)
_my_printf:
my_printf:
    # while formatstring[char] != "%", putc()
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $16, %rsp
    movq    %rdi, -8(%rbp)      # move the pointer to the format string into memory location -8(%rbp)
    movq    $0, -16(%rbp)       # the counter (to be use as index in the loop) initialized to 0 and stored at -16(%rbp)

    _start_while:
    start_while:
        # while code                 
        movq    -16(%rbp), %rcx                # since the loop will contain function calls, at the beginning we restore ptr
        movq    -8(%rbp), %rdi

        movb    percentage_sign(%rip), %sil    # one char is one byte so we move the "%" char into %sil register
        xorb    %dl, %dl                       # zeroing out the rest of the register
        movb    (%rdi, %rcx, 1), %dl           # move one character at a time (1 byte) into %sil for upcoming comparison
        cmpb    %sil, %dl                      # we compare each format string character to "%"
        je      end_while                      # if the character is equal to "%", we exit the loop (execute some logic)
        movb    null_terminator(%rip), %sil
        cmpb    %sil, %dl
        je      return

        movb    %dl, %dil
        call    putchar                         # putchar will now be called with dil
        incq    -16(%rbp)
        jmp     start_while
    _end_while:
    end_while:

_return:
return:
    movq    %rbp, %rsp
    popq    %rbp
    ret
    