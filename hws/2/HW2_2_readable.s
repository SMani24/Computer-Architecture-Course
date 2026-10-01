main:
# Init array
# The array is [7, 25, -17, -15, 4, -14, 7, -32, -30, 13, 11, 10, 22, -18, 17, -1, -14, -6, -12, 12]
# Expected result: [-32, -30, -18, -17, -15, -14, -14, -12, -6, -1, 4, 7, 7, 10, 11, 12, 13, 17, 22, 25]
    addi sp, sp, -80

    li t0, 7
    sw t0, 0(sp)
    li t0, 25
    sw t0, 4(sp)
    li t0, -17
    sw t0, 8(sp)
    li t0, -15
    sw t0, 12(sp)
    li t0, 4
    sw t0, 16(sp)
    li t0, -14
    sw t0, 20(sp)
    li t0, 7
    sw t0, 24(sp)
    li t0, -32
    sw t0, 28(sp)
    li t0, -30
    sw t0, 32(sp)
    li t0, 13
    sw t0, 36(sp)
    li t0, 11
    sw t0, 40(sp)
    li t0, 10
    sw t0, 44(sp)
    li t0, 22
    sw t0, 48(sp)
    li t0, -18
    sw t0, 52(sp)
    li t0, 17
    sw t0, 56(sp)
    li t0, -1
    sw t0, 60(sp)
    li t0, -14
    sw t0, 64(sp)
    li t0, -6
    sw t0, 68(sp)
    li t0, -12
    sw t0, 72(sp)
    li t0, 12
    sw t0, 76(sp)


# Saving start address of array in s0
add s0, sp, zero

# loop1 iteration variable (i)
addi s1, zero, 0 
loop1:
    slti t0, s1, 76
    beq t0, zero, end_loop1

    # loop2 iteration variable (j)
    addi s2, zero, 0 # s2 = zero + 0
    
    sub t0, zero, s1
    addi s3, t0, 76 # s3 = t0 + 76

    loop2:
        bge s2, s3, end_loop2 
        add t3, s2, s0
        lw t0, 0(t3)
        lw t1, 4(t3)
        
        bge t1, t0, end_if
        # swap
        sw t1, 0(t3)
        sw t0, 4(t3)
        end_if:
            addi s2, s2, 4 
            j loop2
    end_loop2:
        addi s1, s1, 4 
        j loop1
end_loop1:
    # This line is just for putting breakpoint.
    addi s11, zero, 0 #0x7FFFFFA0