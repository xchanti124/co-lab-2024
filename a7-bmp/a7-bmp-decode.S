#ifdef MACOS
    .global _bmp_decode
    printf: jmp _printf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    fopen: jmp _fopen
    fread: jmp _fread
    fwrite: jmp _fwrite
    fclose: jmp _fclose
    strcpy: jmp _strcpy
    strlen: jmp _strlen
    strncpy: jmp _strncpy
    strnlen: jmp _strnlen
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global bmp_encode
    _printf: jmp printf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    _fopen: jmp fopen
    _fread: jmp fread
    _fwrite: jmp fwrite
    _fclose: jmp fclose
    _strcpy: jmp strcpy
    _strlen: jmp strlen
    _strncpy: jmp strncpy
    _strnlen: jmp strnlen
    #ifdef STANDALONE
        .global main
    #endif
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
read:
    .asciz "r"

# usage ./a7-bmp-decode src key
_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $64, %rsp

    movq    %rdi, -8(%rbp)      # argc
    movq    %rsi, -16(%rbp)     # argv

    movq    8(%rsi), %rdx
    movq    %rdx, -24(%rbp)     # -24 now points to the image path

    movq    16(%rsi), %rcx
    movq    %rcx, -32(%rbp)     # -32 now points to the key

    movq    %rdx, %rdi
    leaq    read(%rip), %rsi

    call    fopen               # fopen now called with image path and "r" mode
    movq    %rax, -40(%rbp)     # image pointer now at -40

    # 451 -> 464 to be stack aligned 
    subq    $528, %rsp
    leaq    -528(%rbp), %rdi    # first argument bmp_decode (buffer with 464 bytes of space)
    movq    -32(%rbp), %rsi     # second argument, the key
    movq    -40(%rbp), %rdx     # third argument, result from fopen, file pointer

    call    bmp_decode

    movq    -40(%rbp), %rdi
    call    fclose

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret

# int bmp_decode(char *buf, const char *key, FILE* file)
_bmp_decode:
bmp_decode:
    push    %rbp
    movq    %rsp, %rbp

    movq    

    movq    %rbp, %rsp
    popq    %rbp
    ret

_rle_decode:
rle_decode:
    pushq   %rbp
    movq    %rsp, %rbp

    # 

    movq    %rbp, %rsp
    popq    %rbp
