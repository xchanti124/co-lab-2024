#ifdef MACOS
    .global _my_diff
    printf: jmp _printf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    fopen: jmp _fopen
    fclose: jmp _fclose
    fgets: jmp _fgets
    fread: jmp _fread
    fprintf: jmp _fprintf
    fscanf: jmp _fscanf
    strcasecmp: jmp _strcasecmp
    strcmp: jmp _strcmp
    strcpy: jmp _strcpy
    strlen: jmp _strlen
    strncasecmp: jmp _strncasecmp
    strncmp: jmp _strncmp
    strncpy: jmp _strncpy
    strnlen: jmp _strnlen
    memset: jmp _memset
#else 
    .global my_diff
    _printf: jmp printf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    _fopen: jmp fopen
    _fclose: jmp fclose
    _fgets: jmp fgets
    _fread: jmp fread
    _fprintf: jmp fprintf
    _fscanf: jmp fscanf
    _strcasecmp: jmp strcasecmp
    _strcmp: jmp strcmp
    _strcpy: jmp strcpy
    _strlen: jmp strlen
    _strncasecmp: jmp strncasecmp
    _strncmp: jmp strncmp
    _strncpy: jmp strncpy
    _strnlen: jmp strnlen
    _memset: jmp memset
#endif

.bss
# [unitialized static variables]

.data
read:
    .asciz "r"
# [initialized static variables]

.text
changestring:
    .ascii "%dc%d\n"
    .ascii "< %s"
    .ascii "---\n"
    .asciz "> %s"
new_line:
    .asciz "\n"
# [constants/strings]

# int my_diff(const char *a, const char *b, bool flag_i, bool flag_B)
_my_diff:
my_diff:
    pushq   %rbp
    movq    %rsp, %rbp

    # file_a = %rdi
    # file_b = %rsi
    # flag_i = %rdx
    # flag_B = %rcx

    subq    $112, %rsp

    movq    %rdi, -8(%rbp)      # file_a
    movq    %rsi, -16(%rbp)     # file_b
    movq    %rdx, -24(%rbp)     # flag_i
    movq    %rcx, -32(%rbp)     # flag_B

    leaq    read(%rip), %rsi
    movb    $0, %al
    call    fopen               # %rax = fopen(file_a, "r"); returns FILE*
    movq    %rax, -40(%rbp)
    cmpq    $0, %rax
    jne     elsecode1

    movq    $-1, %rax
    jmp     return

_elsecode1:
elsecode1:
    # char current_line_a[1025]
    subq    $1032, %rsp         # creating a buffer of characters with length of 1025
    # bool file_a_end = false
    movq    $0, -48(%rbp)       # file_a_end

    movq    -16(%rbp), %rdi     # move file_b into %rdi (first arg for fopen)
    leaq    read(%rip), %rsi    # move "r" opening mood into second argument
    movb    $0, %al
    call    fopen
    movq    %rax, -56(%rbp)
    cmpq    $0, %rax
    jne     elsecode2

    # fclose(file_a);
    # return -1;
    leaq    -8(%rbp), %rdi      # move file_a into %rdi
    call    fclose              # close file_a
    movq    $-1, %rax      
    jmp     return 

_elsecode2:
elsecode2:
    # char current_line_b[1025]
    subq    $1032, %rsp
    # bool file_b_end = false
    movq    $0, -64(%rbp)       # file_b_end

    # int cur_line = 0;
    # bool return_value = 0;
    movq    $0, -72(%rbp)       # cur_line = 0
    movq    $0, -80(%rbp)       # return_value = 0

_loop:
loop:                           # while(!(file_a_end && file_b_end)) = while(!file_a_end || !file_b_end)
    movq    -64(%rbp), %r8
    andq    -48(%rbp), %r8      # %r8 is 1 if either file_a_end = 1 and file_b_end = 1, will be 0 if either one is 0 or both
    # > !%r8 -> !file_a_end || !file_b_end
    cmpq    $1, %r8 
    je     break

    incq    -72(%rbp)           # curr_line++

    cmpq    $0, -48(%rbp)       # if(!file_a_end)
    jne     elsecode3

    # fgets(current_line_a, sizeof(current_line_a), file_a)
    leaq    -1144(%rbp), %rdi
    movq    $1032, %rsi
    movq    -40(%rbp), %rdx

    call    fgets

    movq    %rax, -88(%rbp)     # results (if the result is null then we have no new lines)

    cmpq    $0, -88(%rbp)
    jne     elsecode3
    movq    $1, -48(%rbp)

_elsecode3:
elsecode3:
    cmpq    $0, -64(%rbp)
    jne     elsecode4

    leaq    -2176(%rbp), %rdi
    movq    $1032, %rsi
    movq    -56(%rbp), %rdx

    call    fgets

    movq    %rax, -88(%rbp)     
    
    cmpq    $0, -88(%rbp)
    jne     elsecode4
    movq    $1, -64(%rbp)
    jmp     break

_elsecode4:
elsecode4:
    # !file_a_end ? current_line_a : "\n"
    cmpq    $0, -48(%rbp)
    je      ifcode3
    jmp     elsecode5

_ifcode3:
ifcode3:
    # line_a_to_check = current_line_a
    leaq    -1144(%rbp), %rdi
    movq    %rdi, -96(%rbp) 
    jmp     endif


_elsecode5:
elsecode5:
    # line_a_to_check = "\n"
    leaq    new_line(%rip), %rdi
    movq    %rdi, -96(%rbp)

_endif:
endif:
    # !file_b_end ? current_line_b : "\n"
    cmpq    $0, -64(%rbp)
    je      ifcode4
    jmp     elsecode6

_ifcode4:
ifcode4:
    # line_b_to_check = current_line_b
    leaq    -2176(%rbp), %rdi
    movq    %rdi, -104(%rbp) # line_b_to_check
    jmp     endif2

_elsecode6:
elsecode6:
    # line_b_to_check = "\n"
    leaq    new_line(%rip), %rsi
    movq    %rsi, -104(%rbp)

_endif2:
endif2:
    movq    $0, -112(%rbp)              # are_lines_different

    cmpq    $1, -24(%rbp)               # flag_i = 1?
    jne     elsecode7                   # flag_i != 1 -> jmp elsecode7

    # are_lines_different = strcasecmp(line_a_to_check, line_b_to_check) != 0;
    movq    -96(%rbp), %rdi
    movq    -104(%rbp), %rsi

    call    strcasecmp                  # line 100 in C code, try to make it into 2 statements

    cmpq    $0, %rax
    jne     ifcode
    movq    $0, -112(%rbp)

_ifcode:
ifcode:
    movq    $1, -112(%rbp)

_elsecode7:
elsecode7:
    # are_lines_different = strcmp(line_a_to_check, line_b_to_check) != 0;
    movq    -96(%rbp), %rdi
    movq    -104(%rbp), %rsi 

    call    strcmp

    cmpq    $0, %rax                    # if rax = 0, then the lines are THE SAME
    jne     ifcode2
    movq    $0, -112(%rbp)              # if rax = 0, then are_lines_different = 0
    jmp     idfk

_ifcode2:
ifcode2:
    movq    $1, -112(%rbp)

idfk_:
idfk:
    cmpq    $1, -112(%rbp)              # if(are_lines_different = 1)
    jne     loop                
    
    movq    $1, -80(%rbp)               # return_value = 1

    movq    -72(%rbp), %rsi             # cur_line -> %rsi
    movq    %rsi, %rdx                  # cur_line -> %rdx
    movq    -96(%rbp), %rcx             # line_a_to_check
    movq    -104(%rbp), %r8             # line_b_to_check

    leaq    changestring(%rip), %rdi
    movb    $0, %al
    call printf

_break:
break:
    movq    -40(%rbp), %rdi
    call    fclose
    movq    -56(%rbp), %rdi
    call    fclose

_return:
return:
    movq    -80(%rbp), %rax
    movq    %rbp, %rsp
    popq    %rbp
    ret
