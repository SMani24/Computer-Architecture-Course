module controller (
    // Datapath outputs
    opcode,
    f3,
    f7,
    zero,

    // Datapath inputs
    pc_src,
    imm_src,
    reg_write,
    alu_src,
    alu_function,
    mem_write,
    result_src
);
    input [6:0] opcode;
    input [2:0] f3;
    input [6:0] f7;
    input zero;

    output [1:0] pc_src;
    output [2:0] imm_src;
    output reg_write;
    output alu_src;
    output [2:0] alu_function;
    output mem_write;
    output [1:0] result_src;

    wire branch;
    wire jalr;
    wire jump;
    wire [1:0] alu_op;

    controller_main cm (
        .opcode(opcode),

        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),

        .branch(branch),
        .alu_op(alu_op),
        .jump(jump),
        .jalr(jalr)
    );

    controller_pc_source cps (
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .zero(zero),
        .f3(f3),
        .pc_src(pc_src)
    );

    controller_alu ca (
        .f3(f3),
        .f7(f7),
        .alu_op(alu_op),
        .alu_function(alu_function)
    );
endmodule