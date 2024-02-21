#ifdef MACOS
    .global _main
    printf: jmp _printf
#else 
    .global main
    _printf: jmp printf
#endif

.bss
# [unitialized static variables]

.data
# [initialized static variables]

.text
hello_world:
    .asciz "Computer Organization 2024\nAssignment 1 - hello\nby Chantal Ariu"

_main:
main:
    # prologue
    pushq   %rbp                        # push value of base pointer onto the stack
    movq    %rsp, %rbp                  # move value of stack pointer into the base pointer (to establish a new stack frame)

    leaq    hello_world(%rip), %rdi     # load effective address of "hello world" string into `%rdi` register (to set up arg for printf function) 
    movb    $0, %al                     # move value 0 into `%al` register; indicates no variable arguments
    call    printf                      # call printf functions with args set above

    # epilogue
    movq    %rbp, %rsp                  # move value of base pointer back into the stack pointer in order to deallocate the stack frame
    popq    %rbp                        # pop base pointer to restore its original value
    movq    $0, %rax                    # move value 0 into the `%rax` register to indicate success of the function
    ret