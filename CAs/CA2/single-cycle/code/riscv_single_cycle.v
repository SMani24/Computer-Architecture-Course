module riscv_single_cycle (
    clk,
    reset
);
    input clk, reset;

    wire [1:0] pc_src;
    wire [2:0] imm_src;
    wire reg_write;
    wire alu_src;
    wire [2:0] alu_function;
    wire mem_write;
    wire [1:0] result_src;
    wire [6:0] opcode;
    wire [14:12] f3;
    wire [31:25] f7;
    wire zero;

    datapath datapath_instance (
        .clk(clk),
        .reset(reset),
        .pc_src(pc_src),
        .imm_src(imm_src),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_function(alu_function),
        .mem_write(mem_write),
        .result_src(result_src),
        .opcode(opcode),
        .f3(f3),
        .f7(f7),
        .zero(zero)
    );

    controller controller_instance (
        .opcode(opcode),
        .f3(f3),
        .f7(f7),
        .zero(zero),
        .pc_src(pc_src),
        .imm_src(imm_src),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_function(alu_function),
        .mem_write(mem_write),
        .result_src(result_src)
    );
endmodule