# Init array
# The array is [7, 25, -17, -15, 4, -14, 7, -32, -30, 13]
# Expected result: -32
    addi s0, s0, 0

    li t0, 7
    sw t0, 0(s0)
    li t0, 25
    sw t0, 4(s0)
    li t0, -17
    sw t0, 8(s0)
    li t0, -15
    sw t0, 12(s0)
    li t0, 4
    sw t0, 16(s0)
    li t0, -14
    sw t0, 20(s0)
    li t0, 7
    sw t0, 24(s0)
    li t0, 0
    sw t0, 28(s0)
    li t0, -30
    sw t0, 32(s0)
    li t0, 13
    sw t0, 36(s0)

main:
    addi s0, zero, 0 # 0 is the start of array 
    lw s1, 0(s0)
    addi s2, zero, 1
    addi s0, s0, 4
loop:
    slti t0, s2, 10
    beq t0, zero, end_loop
    lw t0, 0(s0)
    slt t1, s1, t0
    bne t1, zero, else
    add s1, t0, zero
else:
addi s2, s2, 1
addi s0, s0, 4
jal loop
end_loop:
addi s4, zero, 0