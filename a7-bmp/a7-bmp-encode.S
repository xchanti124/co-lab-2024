#ifdef MACOS
    .global _bmp_encode
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
write:
    .asciz "w"
BM:
    .ascii "BM"

null_terminator:
    .asciz "\0"

# usage: ./a7-bmp-encode dst key msg
_main:
main:
    pushq   %rbp
    movq    %rsp, %rbp

    # rsi points to a buffer that holds as many arguments as argc (stored in rdi) holds
    subq    $64, %rsp

    movq    %rdi, -8(%rbp)              # argc
    movq    %rsi, -16(%rbp)             # argv

    movq    8(%rsi), %rdx
    movq    %rdx, -24(%rbp)             # -24(%rbp) now points to the image path

    movq    16(%rsi), %rcx
    movq    %rcx, -32(%rbp)             # -32(%rbp) now points to the key

    movq    24(%rsi), %r8
    movq    %r8, -40(%rbp)              # -40(%rbp) now points to the message

    movq    -24(%rbp), %rdi             # pass image path into rdi (for fopen)
    leaq    write(%rip), %rsi           # move 'w' char 
    call    fopen
    movq    %rax, -48(%rbp)             # -48(%rbp) now points to the file pointer of the image

    movq    -40(%rbp), %rdi             # msg goes into first arg
    movq    -32(%rbp), %rsi             # key goes into second arg
    movq    %rax, %rdx                  # file ptr goes into third arg

    call    bmp_encode

    movq    -32(%rbp), %rdi             # after function call is done, we need to close the file
    call    fclose

    movq    %rbp, %rsp
    popq    %rbp
    movq    $0, %rax
    ret

# int bmp_encode(const char *msg, const char *key, FILE* file)
_bmp_encode:
bmp_encode:
    pushq   %rbp
    movq    %rsp, %rbp

    subq    $32, %rsp
    movq    %rdi, -8(%rbp)
    movq    %rsi, -16(%rbp)
    movq    %rdx, -24(%rbp)

    call    rle

    movq    %rsp, %rbp
    popq    %rbp
    ret

_white_noise:
white_noise:
    pushq   %rbp
    movq    %rsp, %rbp



    movq    %rbp, %rsp
    popq    %rbp
    ret


# - increment character (%rcx)
# - check if character points at null, if so break out of the algorithm
# - check if previous char and current char are equal
# -- if so increment counter (%r8)
# -- check if counter is 9, if it is
# --- move 9 to array (counter + 48)
# --- move former character to the index after that
# --- reset counter to 1
# --- repeat loop
# -- if the counter isn't then
# --- repeat loop
# -- if the characters aren't equal
# --- move counter to array
# --- move former character to the index after the array
# --- repeat loop

# rle takes *msg as an argument
_rle:
rle:
    pushq   %rbp
    movq    %rsp, %rbp
    # rdi holds *msg
    subq    $16, %rsp
    xorq    %rsi, %rsi
    xorq    %rdx, %rdx
    movq    %rdi, -8(%rbp)

    movq    $902, %rdi
    call    malloc          # rax now holds pointer to a buffer of size 902 (worst case compressed msg will be 451*2 chars long)
    movq    %rax, -16(%rbp) # store pointer in -16

    movq    -8(%rbp), %rdi 
    movq    $0, %rcx        # counter used for checking each char
    movq    $1, %r8         # counter used to keep track of same chars

    _start_loop:
    start_loop:
    # this loop will compare char_arr[index] with char_arr[index - 1] 
        incq    %rcx 
        movb    null_terminator(%rip), %sil     # \0 -> rsi
        xorb    %dl, %dl
        movb    (%rdi, %rcx, 1), %dl            # cur_char -> rdx
        cmpb    %sil, %dl
        je      char_is_null

        xorb    %sil, %sil                      # clear out sil
        movb    -1(%rdi, %rcx, 1), %sil         # prev_char -> sil
        cmpb    %sil, %dl                       # prev_char == cur_char ?
        jne     adding_to_buffer

        incq    %r8
        cmpq    $9, %r8
        je      adding_to_buffer

    _adding_to_buffer:
    adding_to_buffer:
        addq    $48, %r8
        movq    %r8, (%rax)
        movb    %sil, 1(%rax)
        
        addq    $2, %rax

        movq    $1, %r8
        movb    %dl, %sil
        jmp     start_loop

    _char_is_null:
    char_is_null:
    movq    -16(%rbp), %rax
    movq    %rbp, %rsp
    popq    %rbp
    ret

    # order : white noise, lead and trail, RLE, xor, hide data 
