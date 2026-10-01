.data
array: .word 10, 25, 3, 40, 7

.text
la x8, array


addi x9, x0, 0 

loop1:
    slti x5, x9, 76
    beq x5, x0, end_loop1
    
    addi x18, x0, 0 
    
    sub x5, x0, x9
    addi x19, x5, 76 

    loop2:
        bge x18, x19, end_loop2 
        add x28, x18, x8
        lw x5, 0(x28)
        lw x6, 4(x28)
        
        bge x6, x5, end_if 
        
        sw x6, 0(x9)
        sw x5, 4(x28)
        end_if:
            addi x18, x18, 4 
            j loop2
    end_loop2:
    addi x9, x9, 4 
    j loop1
end_loop1:

