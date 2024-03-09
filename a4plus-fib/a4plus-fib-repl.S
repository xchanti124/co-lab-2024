#ifdef MACOS
    .global _my_fib
    printf: jmp _printf
    scanf: jmp _scanf
    malloc: jmp _malloc
    calloc: jmp _calloc
    realloc: jmp _realloc
    free: jmp _free
    #ifdef STANDALONE
        .global _main
    #endif
#else 
    .global my_fib
    _printf: jmp printf
    _scanf: jmp scanf
    _malloc: jmp malloc
    _calloc: jmp calloc
    _realloc: jmp realloc
    _free: jmp free
    #ifdef STANDALONE
        .global main
    #endif
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
input_prompt:
    .asciz "Enter an index: "
new_line:
    .asciz "\n"
input_index:
    .asciz "%lu"
output_message:
    .asciz "F_%lu = %lu"
exiting:
    .asciz "Exiting..."

_main:
main:
    pushq   %rbp                          # Prologue
    movq    %rsp, %rbp

    subq    $32, %rsp                     # Allocate 32 bits
    movq    $0, -8(%rbp)                  # Storing null pointer, initialize arr
    movq    $0, -16(%rbp)                 # Initialize the size to 0

_loop_main:                               # Start main loop
loop_main:
    leaq    input_prompt(%rip), %rdi
    movb    $0, %al
    call    printf

    leaq    input_index(%rip), %rdi       
    leaq    -24(%rbp), %rsi               # User input, the index is stored at -24(%rbp)
    movb    $0, %al
    call    scanf

    cmpq    $0, %rax                      # If return value of scanf (number of type matches with user input) is 0
    je      return_main                   # jump to return (exit the loop of continuously asking for user input)

    movq    -24(%rbp), %rdi               # Copy the index from memory location into register %rdi (first arg my_fib)
    movq    -8(%rbp), %rsi                # Copy the beginning of the arr, stored at -8(%rbp) into register %rsi (second arg my_fib)
    movq    -16(%rbp), %rdx               # Copy the size of arr to register %rdx (third arg my_fib) 

    call    my_fib                        # Call my_fib(index)
    
    movq    %rax, -8(%rbp)                # Update the array, which is stored at -8(%rbp)
    movq    -24(%rbp), %rsi               # Store the index in %rsi
    movq    0(%rax, %rsi, 8), %rdx        # Store arr[index] in register %rdx

    cmpq    %rsi, -16(%rbp)               # Is size < index?
    jb      ifcode                        # jump to ifcodde

_ifcode:                                  
ifcode:
    movq    %rsi, -16(%rbp)               # Update size to be index; size = index

    leaq    output_message(%rip), %rdi    # Create output message, currently %rsi is holding the index, %rdx the result
    movb    $0, %al
    call    printf

    leaq    new_line(%rip), %rdi          # Print a new line
    movb    $0, %al
    call    printf
    jmp     loop_main                     # Jump to the beginning of the loop

_return_main:
return_main:
    leaq    exiting(%rip), %rdi           # Creates "elegant" exiting statement
    movb    $0, %al
    call    printf

    movq    -8(%rbp), %rdi                # We move the array into register %rdi (first argument for free)
    call    free                          # Free the memory from the array
    
    movq    %rbp, %rsp                    # Epilogue   
    popq    %rbp
    movq    $0, %rax 
    ret

# uint64_t *my_fib(uint64_t n, uint64_t *arr, uint64_t size)
_my_fib:
my_fib:
    pushq   %rbp                        # Prologue
    movq    %rsp, %rbp

    subq    $32, %rsp                   # Allocate 32 bits of memory on the stack

    incq    %rdi                        # Increment index
    movq    %rdi, -8(%rbp)              # Incremented index stored at -8(%rbp)
    movq    %rsi, -24(%rbp)             # Array pointer stored at -24(%rbp)
    movq    %rdx, -16(%rbp)             # Size stored at -16(%rbp)

    cmpq    %rdi, %rdx                  # Is size (%rdx) > index (%rdi)?
    ja      base_case                   # Jump above (comparison for unsigned int) to base_case
    
    movq    -24(%rbp), %rdi             # We move array pointer into register %rdi (first arg to realloc)
    movq    -8(%rbp), %rsi              # Move incremented index into %rsi
    imulq   $8, %rsi                    # (i + 1) * 8, since the stack works in increments of 8
    call    realloc                     # Call realloc(arr, (index + 1) * 8)

    movq    -8(%rbp), %rdx              # Copy incremented index back into %rdx 
    movq    -16(%rbp), %rcx             # Copy the size in %rcx 

_loop_fib:
loop_fib:
    cmpq    %rcx, %rdx                  # Iterate from size to index (this makes rcx also our counter)
    je      return_fib                  # When they are equal, we exit loop (return), as long as they are not equal (aka size > index)
                                        # We execute the following code

    cmpq    $0, %rcx                    # counter = 0? -> at arr[0] we need to have 0 (first base case)
    je      ifcode_fib_1                # Yes -> jump to ifcode_fib_1
    jne     elsecode_fib_1              # No -> jump to elsecode_fib_1

_ifcode_fib_1:
ifcode_fib_1:
    # arr[0] = index
    movq    $0, (%rax)                  # This line changes arr[0] to be 0
    jmp     continue                    # Since this completes one iteration, we jump to continue

_elsecode_fib_1:
elsecode_fib_1:                         # This code gets reached if counter != 0 and checks whether the second base case condition is met
    cmpq    $1, %rcx                    # counter = 1? -> Second base case
    jbe     ifcode_fib_2                # Yes -> jump to ifcode_fib_2 which deals with the second base case
    ja      elsecode_fib_2              # No -> jump to elsecode_fib_2, which holds the actual logic of calculating the next fib number

_ifcode_fib_2:
ifcode_fib_2:
    movq    $1, (%rax, %rcx, 8)         # This code does the following: arr[counter] = 1
    jmp     continue                    # After we have added this base case to the arr, we need to continue again (skip to next iteration)

_elsecode_fib_2:
elsecode_fib_2:
    movq    -8(%rax, %rcx, 8), %rsi     # Move arr[index - 1] into register %rsi 
    addq    -16(%rax, %rcx, 8), %rsi    # Add arr[index - 1] and arr[index - 2]; %rsi = %rsi + arr[index - 2]
    movq    %rsi, (%rax, %rcx, 8)       # arr[index] = arr[index - 1] + arr[index - 2]

_continue:
continue:                               # The purpose of a continue label is to finish one iteration, therefore increment the                                     
    incq    %rcx                        # counter and jump to the top of the loop again
    jmp     loop_fib

_base_case:
base_case:
    movq    -24(%rbp), %rax             # This case is reached if the arr we have already contains the calculation for the index given

_return_fib:
return_fib:
    movq    %rbp, %rsp                  # Epilogue
    popq    %rbp
    ret
