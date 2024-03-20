#ifdef MACOS
    printf: jmp _printf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    fopen: jmp _fopen
    fwrite: jmp _fwrite
    fclose: jmp _fclose
    strcpy: jmp _strcpy
    strlen: jmp _strlen
    strncpy: jmp _strncpy
    strnlen: jmp _strnlen
#else 
    _printf: jmp printf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    _fopen: jmp fopen
    _fwrite: jmp fwrite
    _fclose: jmp fclose
    _strcpy: jmp strcpy
    _strlen: jmp strlen
    _strncpy: jmp strncpy
    _strnlen: jmp strnlen
#endif

.global xor_encryption

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
null_terminator:
    .asciz "\0"

# xor_encryption -> rle_msg, key -> modifies rle_msg since we don't need it anymore
xor_encryption:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $16, %rsp
    movq    %rdi, -8(%rbp)
    movq    %rsi, -16(%rbp)

    _start_loop_msg:
    start_loop_msg:
        movb    (%rdi), %r8b
        movb    (%rsi), %r9b
        movb    null_terminator(%rip), %dl
        cmpb    %r8b, %dl                       # check whether encoded msg is at \0
        je      end_loop
        
        cmpb    %r9b, %dl                       # check whether key is at \0
        je      reset_key

        xorb    %r8b, %r9b
        movb    %r9b, (%rdi)
        incq    %rdi
        incq    %rsi
        jmp     start_loop_msg
    
    _reset_key:
    reset_key:
        movq    -16(%rbp), %rsi
        jmp     start_loop_msg

    _end_loop:
    end_loop:
    movq    -8(%rbp), %rax
    movq    %rbp, %rsp
    popq    %rbp
    ret
