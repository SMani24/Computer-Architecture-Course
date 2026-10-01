module controller (
    clk,
    reset,

    // Datapath inputs
    adr_src,
    mem_write,
    ir_write,
    imm_src,
    alu_src_a,
    alu_src_b,
    alu_function,
    result_src,
    reg_write,
    pc_write_result,
    old_pc_write,

    // Datapath outputs
    opcode, f3, f7,
    zero
);
    input clk, reset;

    input [6:0] opcode;
    input [2:0] f3;
    input [6:0] f7;
    input zero;

    output [1:0] alu_src_a;
    output [1:0] alu_src_b;
    output pc_write_result;
    output [2:0] imm_src;
    output reg_write;
    output [2:0] alu_function;
    output mem_write;
    output [1:0] result_src;
    output ir_write;
    output old_pc_write;
    output adr_src;
    
    wire pc_write, bne, beq;
    wire [1:0] alu_op;

    controller_main cm (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .f3(f3),
        .adr_src(adr_src),
        .mem_write(mem_write),
        .ir_write(ir_write),
        .old_pc_write(old_pc_write),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .result_src(result_src),
        .alu_op(alu_op),
        .pc_write(pc_write),
        .beq(beq),
        .bne(bne)
    );

    controller_pc_source cps (
        .pc_write(pc_write),
        .zero(zero),
        .beq(beq),
        .bne(bne),
        .pc_write_result(pc_write_result)
    );

    controller_alu ca (
        .f3(f3),
        .f7(f7),
        .alu_op(alu_op),
        .alu_function(alu_function)
    );
endmodule