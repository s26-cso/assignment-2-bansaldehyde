.data
yes: .string "Yes\n"
no: .string "No\n"
file: .string "input.txt"
read: .string "r"

.text
.globl main
main:
    # make space on the stack
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)       # s0 = file pointer
    sd s1, 8(sp)        # s1 = file size    

    # open input.txt
    la a0, file         # pass the file path in ao
    la a1, read         # pass reading mode in a1
    call fopen
    mv s0, a0           # save file pointer in s0

    # getting total file size
    li a1, 0        # a0 already contains the file pointer
    li a2, 2        # we have pass 2 as the arg to seek end
    call fseek
    
    # ftell(file)
    mv a0, s0
    call ftell
    mv s1, a0       # s1 = file size (n)

    # We compare head (i) and tail (n-1-i)
    li s2, 0        # left index
    addi s3, s1, -1 # right index

.loop:
    # loop until the pointers meet or cross
    bge s2, s3, .is_palindrome
    
    # get character at left index (s2)
    mv a0, s0       # a0=file pointer
    mv a1, s2       # a1=offset value
    li a2, 0        # seek from the start
    call fseek
    mv a0, s0
    call fgetc
    mv t0, a0       # char 1 in t0
    
    # get character at right index (s3)
    mv a0, s0
    mv a1, s3
    li a2, 0        
    call fseek
    mv a0, s0
    call fgetc
    mv t1, a0       # char 2 in t1
    
    # compare characters
    bne t0, t1, .not_palindrome
    
    # move pointers
    addi s2, s2, 1  # increment by 1
    addi s3, s3, -1 # decrement by 1
    j .loop

.is_palindrome:
    la a0, yes
    call printf
    j .close

.not_palindrome:
    la a0, no
    call printf
    j .close

.close:
    mv a0, s0
    call fclose

.exit:
    # close the stack
    li a0, 0
    ld ra, 24(sp)
    ld s0, 16(sp)
    ld s1, 8(sp)
    addi sp, sp, 32
    ret
