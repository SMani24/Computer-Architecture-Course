module controller_pc_source (
    pc_write,
    zero,
    beq,
    bne,
    pc_write_result
);
    input pc_write, zero, beq, bne;
    output pc_write_result;
    
    assign pc_write_result = (beq & zero) | (bne & ~zero) | pc_write;
endmodule