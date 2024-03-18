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
unsigned_int:
    .asciz "u"
signed_int:
    .asciz "d"
string:
    .asciz "s"
test_string:
    .asciz "my name: %s %s %s %s %s %s %s\n" # 31 
name:
    .asciz "chanti" # 7
age:
    .asciz "I am nineteen" # 14
hobby:
    .asciz "i like reading," # 28
color:
    .asciz "favorite color is blue," # 24
hair:
    .asciz "my hair is brown," # 18 
eyes:
    .asciz "my eyes are brown" # 18 
test:
    .asciz "this is a test" # 15

null_terminator:
    .asciz "\0"

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    test_string(%rip), %rdi
    leaq    name(%rip), %rsi
    leaq    age(%rip), %rdx
    leaq    hobby(%rip), %rcx
    leaq    color(%rip), %r8
    leaq    hair(%rip), %r9
    leaq    test(%rip), %r12
    leaq    eyes(%rip), %r13
    pushq   %r12
    pushq   %r13
    

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

    subq    $32, %rsp
    movq    $0, -8(%rbp)        # the counter to keep track of the amount of "%" (args) that
    movq    $0, -16(%rbp)       # the counter (to be use as index in the loop) initialized to 0 and stored at -16(%rbp)

    pushq   %r9
    pushq   %r8
    pushq   %rcx
    pushq   %rdx
    pushq   %rsi
    pushq   %rdi

    _start_while_char_not_arg:
    start_while_char_not_arg:
        # while code                 
        movq    -16(%rbp), %rcx                # since the loop will contain function calls, at the beginning we restore ptr
        movq    0(%rsp), %rdi

        movb    null_terminator(%rip), %sil    # this block checks whether char == '\0'
        xorb    %dl, %dl                       # zeroing out the rest of the register
        movb    (%rdi, %rcx, 1), %dl           # move one character at a time (1 byte) into %dl for upcoming comparison
        movb    %dl, -25(%rbp)
        movb    -25(%rbp), %dl
        cmpb    %sil, %dl
        je      return

        movb    percentage_sign(%rip), %sil    # one char is one byte so we move the "%" char into %sil register
        cmpb    %sil, %dl                      # we compare each format string character to "%"
        jne     char_not_arg                   # if the character is equal to "%", we have to increment arg counter

            incq    -16(%rbp)                   # increment index (to check str[i+1])
            movq    -16(%rbp), %rcx
            movb    (%rdi, %rcx, 1), %dl        # move str[i+1] into dl for comparison
            decq    -16(%rbp)                   # decrement it to get back to normal
            movq    -16(%rbp), %rcx
            cmpb    %sil, %dl                   # is str[i+1] == '%' ?
            jne     char_arg                    # if it is not, it is a format specifier
            incq    -16(%rbp)                   # if it is, we skip over the next one and just jump to the printchar call
            jmp     char_not_arg

    _char_arg:
    char_arg:
        incq    -8(%rbp)

        # in here we will add logic for format specifiers:
        # 1. we need to get the next character following '%' and match it with its corresponding argument (either d,u,s)
        # 2. we reach the argument by doing rsp - 8 * counter (if arg_counter <= 5) REGISTERS
        # 3. we reach the argument by doing rbp + 8 + counter * 8 (if arg_counter > 5) ON STACK
        cmpq    $5, -8(%rbp)
        jle     arg_in_registers
        jg      arg_on_stack

            _arg_in_registers:
            arg_in_registers:
                movb    %dl, -24(%rbp)
                movq    -8(%rbp), %rcx
                movq    (%rsp, %rcx, 8), %rdi
                jmp     dealing_with_format

            _arg_on_stack:
            arg_on_stack:
                movb    %dl, -24(%rbp)
                movq    -8(%rbp), %rcx
                subq    $5, %rcx
                movq    %rbp, %rdi
                addq    $8, %rdi
                movq    (%rdi, %rcx, 8), %rdi

            _dealing_with_format:
            dealing_with_format:
                movb    -24(%rbp), %dl              # mulq changed rdx as a side effect so we need to restore it
                movb    string(%rip), %sil          # move "s" format specifier into sil for comparison
                cmpb    %sil, %dl                   # is char == "s"
                je      call_string_handler         

                movb    signed_int(%rip), %sil      # move "d" format specifier into sil for comparison
                cmpb    %sil, %dl                   # is char == "d"
                je      call_signed_int_handler

                movb    unsigned_int(%rip), %sil    # move "u" format specifier into sil for comparison
                cmpb    %sil, %dl                   # is char == "u"    
                je      call_unsigned_int_handler

                incq    -16(%rbp)
                jmp     start_while_char_not_arg

                _call_string_handler:
                call_string_handler:
                    call    string_handler
                    incq    -16(%rbp)
                    jmp     next_iteration

                _call_signed_int_handler:
                call_signed_int_handler:
                    call    signed_int_handler
                    incq    -16(%rbp)
                    jmp     next_iteration

                _call_unsigned_int_handler:
                call_unsigned_int_handler:
                    call    unsigned_int_handler
                    incq    -16(%rbp)
                    jmp     next_iteration

    _next_iteration:
    next_iteration:
        incq    -16(%rbp)
        jmp     start_while_char_not_arg

    _char_not_arg:
    char_not_arg:
        movb    %dl, %dil
        call    putchar                         # putchar will now be called with dil
        incq    -16(%rbp)
        jmp     start_while_char_not_arg
    _end_while_char_not_arg:
    end_while_char_not_arg: 

_return:
return:
    movq    %rbp, %rsp
    popq    %rbp
    ret


_unsigned_int_handler:
unsigned_int_handler:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rbp, %rsp
    popq    %rbp
    ret

_signed_int_handler:
signed_int_handler:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    %rbp, %rsp
    popq    %rbp
    ret

_string_handler:
string_handler:
    pushq   %rbp
    movq    %rsp, %rbp
    # %rdi holds a null terminated string, so we just putchar as long as char != '\0'

    subq    $16, %rsp
    movq    %rdi, -8(%rbp)
    movq    $0, -16(%rbp)

    _start_while_char_not_null:
    start_while_char_not_null:
        movq    -16(%rbp), %rcx
        movq    -8(%rbp), %rdi

        movb    null_terminator(%rip), %sil    # this block checks whether char == '\0'
        xorb    %dl, %dl                       # zeroing out the rest of the register
        movb    (%rdi, %rcx, 1), %dl           # move one character at a time (1 byte) into %sil for upcoming comparison
        cmpb    %sil, %dl
        je      end_while_char_not_null
        xor     %rdi, %rdi
        movb    %dl, %dil
        call    putchar                         # putchar will now be called with dil
        incq    -16(%rbp)
        jmp     start_while_char_not_null

    _end_while_char_not_null:
    end_while_char_not_null:

    movq    %rbp, %rsp
    popq    %rbp
    ret
