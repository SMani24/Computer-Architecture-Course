module riscv_multi_cycle (
    clk,
    reset
);
    input clk, reset;


    wire [6:0] opcode;
    wire [2:0] f3;
    wire [6:0] f7;
    wire zero;

    wire [1:0] alu_src_a;
    wire [1:0] alu_src_b;
    wire pc_write_result;
    wire [2:0] imm_src;
    wire reg_write;
    wire [2:0] alu_function;
    wire mem_write;
    wire [1:0] result_src;
    wire ir_write;
    wire old_pc_write;
    wire adr_src;


    controller c (
        .clk(clk),
        .reset(reset),
        .adr_src(adr_src),
        .mem_write(mem_write),
        .ir_write(ir_write),
        .imm_src(imm_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .alu_function(alu_function),
        .result_src(result_src),
        .reg_write(reg_write),
        .pc_write_result(pc_write_result),
        .old_pc_write(old_pc_write),
        .opcode(opcode),
        .f3(f3),
        .f7(f7),
        .zero(zero)
    );

    datapath dp (
        .clk(clk),
        .reset(reset),
        .adr_src(adr_src),
        .mem_write(mem_write),
        .ir_write(ir_write),
        .imm_src(imm_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .alu_function(alu_function),
        .result_src(result_src),
        .reg_write(reg_write),
        .pc_write(pc_write_result),
        .old_pc_write(old_pc_write),
        .opcode(opcode),
        .f3(f3),
        .f7(f7),
        .zero(zero)
    );
endmodule