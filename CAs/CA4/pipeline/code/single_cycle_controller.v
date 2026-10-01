module single_cycle_controller (
    // Datapath outputs
    opcode,
    f3,
    f7,

    // Datapath inputs
    imm_src,
    reg_write,
    alu_src,
    alu_function,
    mem_write,
    result_src,
    beq,
    bne,
    jump,
    jalr
);
    input [6:0] opcode;
    input [2:0] f3;
    input [6:0] f7;

    output [2:0] imm_src;
    output reg_write;
    output alu_src;
    output [2:0] alu_function;
    output mem_write;
    output [1:0] result_src;
    output beq;
    output bne;
    output jump;
    output jalr;

    wire [1:0] alu_op;

    controller_main cm (
        .opcode(opcode),
        .f3(f3),
        .f7(f7),

        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .result_src(result_src),

        .beq(beq),
        .bne(bne),
        .alu_op(alu_op),
        .jump(jump),
        .jalr(jalr)
    );

    controller_alu ca (
        .f3(f3),
        .f7(f7),
        .alu_op(alu_op),
        .alu_function(alu_function)
    );
endmodule
