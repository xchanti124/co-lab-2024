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
    .asciz "ab%cd%"
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

    pushq   %rdi
    pushq   %rsi
    pushq   %rdx
    pushq   %rcx
    pushq   %r8
    pushq   %r9

    subq    $16, %rsp
    movq    %rdi, 8(%rsp)       # move the pointer to the format string into memory location 8(%rsp)
    movq    $0, -8(%rbp)        # the counter to keep track of the amount of "%" (args) that
    movq    $0, -16(%rbp)       # the counter (to be use as index in the loop) initialized to 0 and stored at -16(%rbp)

    _start_while_char_not_percentage:
    start_while_char_not_percentage:
        # while code                 
        movq    -16(%rbp), %rcx                # since the loop will contain function calls, at the beginning we restore ptr
        movq    8(%rsp), %rdi

        movb    null_terminator(%rip), %sil    # this block checks whether char == '\0'
        xorb    %dl, %dl                       # zeroing out the rest of the register
        movb    (%rdi, %rcx, 1), %dl           # move one character at a time (1 byte) into %sil for upcoming comparison
        cmpb    %sil, %dl
        je      return

        movb    percentage_sign(%rip), %sil    # one char is one byte so we move the "%" char into %sil register
        cmpb    %sil, %dl                      # we compare each format string character to "%"
        jne     char_not_percentage            # if the character is equal to "%", we have to increment a counter (for now)
        incq    -8(%rbp)
        incq    -16(%rbp)
        jmp     start_while_char_not_percentage

    _char_not_percentage:
    char_not_percentage:
        movb    %dl, %dil
        call    putchar                         # putchar will now be called with dil
        incq    -16(%rbp)
        jmp     start_while_char_not_percentage
    _end_while_char_not_percentage:
    end_while_char_not_percentage: 

_return:
return:
    movq    %rbp, %rsp
    popq    %rbp
    ret
