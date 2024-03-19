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
minus_sign:
    .asciz "-"
null_terminator:
    .asciz "\0"

test_string_1:
    .asciz "Unsigned Value: %u\n"
test_string_2:
    .asciz "Value: %d\n"
test_string_3:
    .asciz "Negative Value: %d\n"
test_string_4:
    .asciz "String: %s\n"
test_string_5:
    .asciz "100%% Complete\n"

test_arg:
    .asciz "Computer Organization"

_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    leaq    test_string_1(%rip), %rdi
    movq    $95, %rsi
    call    my_printf  

    leaq    test_string_2(%rip), %rdi
    movq    $42, %rsi
    call    my_printf

    leaq    test_string_3(%rip), %rdi
    movq    $-42, %rsi
    call    my_printf

    leaq    test_string_4(%rip), %rdi
    leaq    test_arg(%rip), %rsi
    call    my_printf

    leaq    test_string_5(%rip), %rdi
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
    movq    %rbx, -32(%rbp)

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
        incq    -8(%rbp)    # this counts how many arguments we have
        # in here we will add logic for format specifiers:
        # 1. we need to get the next character following '%' and match it with its corresponding argument (either d,u,s)
        # 2. we reach the argument by doing rsp - 8 * counter (if arg_counter <= 5) REGISTERS
        # 3. we reach the argument by doing rbp + 8 + counter * 8 (if arg_counter > 5) ON STACK
        cmpq    $5, -8(%rbp)
        jle     arg_in_registers
        jg      arg_on_stack

            _arg_in_registers:
            arg_in_registers:
                movb    %dl, -24(%rbp)              # we store the format specifier (u, s, or d) here
                movq    -8(%rbp), %rcx              # move the arg_counter into rcx
                movq    (%rsp, %rcx, 8), %rdi       # this is how we reach the register arguments
                jmp     dealing_with_format

            _arg_on_stack:
            arg_on_stack:
                movb    %dl, -24(%rbp)              # we store the format specifier (u, s, or d) here
                movq    -8(%rbp), %rcx              # move the arg_counter into rcx
                subq    $5, %rcx                    # subtract 5 (since that is the amount we have from register args)
                movq    %rbp, %rdi                  # we move the base pointer into rdi (since base pointer should never change)
                addq    $8, %rdi                    # we need to move the 'start' of rdi up, because the return address is stored first 
                movq    (%rdi, %rcx, 8), %rdi       # this is how we now can reach the stack arguments

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

                incq    -16(%rbp)                   # we increment the general counter (used to go char by char)
                movb    percentage_sign(%rip), %dil # in the case that none of the format specifiers were give, we just print %f for example
                call    putchar
                jmp     start_while_char_not_arg    # jump to beginning of loop (having skipped over % and any following non-specifier)

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
    movq    -32(%rbp), %rbx     # since rbx is callee saved, we need to restore it
    movq    %rbp, %rsp
    popq    %rbp
    ret

_unsigned_int_handler:
unsigned_int_handler:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $16, %rsp
    movl    %edi, %eax         # move rdi to location -8
    movq    $0, -8(%rbp)       # move 0 into location -24 (this will be the counter to keep track of how many digits we got)

    _while_quotient_not_0:
    while_quotient_not_0:
        xorq    %rdx, %rdx      # clearing out rdx
        movq    $10, %rbx       # rbx will be the denominator of the division (always 10 since decimal numbers)
        divq    %rbx            # rax / rbx (floor is taken)
        addq    $48, %rdx       # we turn the remainder into ascii
        pushq   %rdx            # we push it onto the stack
        
        incq    -8(%rbp)       # increment the digit counter
        cmpl    $0, %eax       # we check if the result is 0, if it is we jump
        jne     while_quotient_not_0 # jump to beginning of the loop

    _while_counter_not_0:
    while_counter_not_0:
        popq    %rdi
        call    putchar

        subq    $1, -8(%rbp)    # decrement the counter (we pop, then decrement, then pop...)
        cmpq    $0, -8(%rbp)    # compare it to 0, if it is, loop is over, if it is not, we repeat
        jne     while_counter_not_0
        
    movq    %rbp, %rsp
    popq    %rbp
    ret

_signed_int_handler:
signed_int_handler:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $16, %rsp
    xor     %rax, %rax

    # find out if its negative or not
    movl    %edi, %eax
    roll    $1, %eax    # roll to the left once, now the most significant bit has become the least significant bit
    andl    $1, %eax    # this will ignore all bits except the least significant bit, so we can check whether it is one or zero
    cmpq    $0, %rax    # this now checks excplitly whether the rightmost bit is set or not
    je      print_signed   # if bit not set, just print num

    # print unsigned (multiply by -1)
    movq    %rdi, %rax
    movq    $-1, %rdx
    imulq   %rdx

    pushq   %rax                    # we push the result (unsigned) onto the stack
    movb    minus_sign(%rip), %dil  # load minus sign char into rdi 
    call    putchar                 # call putchar (will output '-')
    popq    %rax                    # this just restores rax (since we had a function call that messed up the register)
    jmp     print_num

    _print_signed:
    print_signed:
    movl    %edi, %eax              # move the value into rax

    _print_num:
    print_num:                      # this procedure is now the same algorithm as for the unsigned ints
    movq    $0, -8(%rbp)            # counter

    _loop_count_push_signed:
    loop_count_push_signed:
        xorl    %edx, %edx          # clear out rdx 
        movl    $10, %ebx           # move 10 (denominator) into rdx
        divl    %ebx                # eax // ebx -> remainder stored in rbx and result of division in rax
        addq    $48, %rdx           # change remainder into ascii char
        pushq   %rdx                # push remainder
        incq    -8(%rbp)            # increment the counter
        cmp     $0, %eax            # check if result of division is 0, if it is, we start putting the number together
        jne     loop_count_push_signed  # if not, we jump to beginning of the loop

    _loop_print_unsigned_signed:
    loop_print_unsigned_signed:
        popq    %rdi
        call    putchar

        subq    $1, -8(%rbp)         # decrement the counter (we pop, then decrement, then pop...)
        cmpq    $0, -8(%rbp)         # compare it to 0, if it is, loop is over, if it is not, we repeat
        jne     loop_print_unsigned_signed

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
