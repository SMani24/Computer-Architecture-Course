module controller (
    clk,
    reset,

    // DataPath output
    opcode,
    f3,
    f7,
    ZeroE,

    // Hazard Unit outputs
    FlushD,

    // Hazard Unit inputs
    ResultSrcE,

    // DataPath input
    ImmSrcD,
    ALUControlE,
    PCSrcE,
    jalrE,
    ALUSrcE,
    MemWriteM,
    ResultSrcW,
    RegWriteM,
    RegWriteW
);
    input clk, reset;
    input [6:0] opcode;
    input [14:12] f3;
    input [31:25] f7;
    input ZeroE;
    input FlushD;

    output [2:0] ImmSrcD;
    output PCSrcE;
    output jalrE;
    output [1:0] ResultSrcE;
    output [2:0] ALUControlE;
    output ALUSrcE;
    output MemWriteM;
    output RegWriteM;
    output [1:0] ResultSrcW;
    output RegWriteW;


    // Decode
    wire RegWriteD;
    wire [1:0] ResultSrcD;
    wire MemWriteD;
    wire JumpD;
    wire BeqD;
    wire BneD;
    wire [2:0] ALUControlD;
    wire ALUSrcD;
    wire jalrD;

    single_cycle_controller scc (
        .opcode(opcode),
        .f3(f3),
        .f7(f7),
        .imm_src(ImmSrcD),
        .reg_write(RegWriteD),
        .alu_src(ALUSrcD),
        .alu_function(ALUControlD),
        .mem_write(MemWriteD),
        .result_src(ResultSrcD),
        .beq(BeqD),
        .bne(BneD),
        .jump(JumpD),
        .jalr(jalrD)
    );

    // Execute
    wire GND;
    assign GND = 1'b0;

    wire RegWriteE;
    controlled_register #(1) EReg_RegWriteE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(RegWriteD),
        .data_out(RegWriteE),
        .enable(GND)
    );

    controlled_register #(2) EReg_ResultSrcE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(ResultSrcD),
        .data_out(ResultSrcE),
        .enable(GND)
    );

    wire MemWriteE;
    controlled_register #(1) EReg_MemWriteE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(MemWriteD),
        .data_out(MemWriteE),
        .enable(GND)
    );

    wire JumpE;
    controlled_register #(1) EReg_JumpE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(JumpD),
        .data_out(JumpE),
        .enable(GND)
    );

    wire BneE;
    controlled_register #(1) EReg_BneE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(BneD),
        .data_out(BneE),
        .enable(GND)
    );

    wire BeqE;
    controlled_register #(1) EReg_BeqE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(BeqD),
        .data_out(BeqE),
        .enable(GND)
    );

    controlled_register #(3) EReg_ALUControlE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(ALUControlD),
        .data_out(ALUControlE),
        .enable(GND)
    );

    controlled_register #(1) EReg_ALUSrcE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(ALUSrcD),
        .data_out(ALUSrcE),
        .enable(GND)
    );

    wire [2:0] ImmSrcE;
    controlled_register #(3) EReg_ImmSrcE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(ImmSrcD),
        .data_out(ImmSrcE),
        .enable(GND)
    );

    controlled_register #(1) EReg_jalrE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(jalrD),
        .data_out(jalrE),
        .enable(GND)
    );

    // PC controller logic:
    assign PCSrcE = JumpE || jalrE 
                    || (ZeroE && BeqE) 
                    || (~ZeroE && BneE);
    
    // Memory
    wire RegWriteM;
    controlled_register #(1) EReg_RegWriteM (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(RegWriteE),
        .data_out(RegWriteM),
        .enable(GND)
    );

    wire [1:0] ResultSrcM;
    controlled_register #(2) EReg_ResultSrcM (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(ResultSrcE),
        .data_out(ResultSrcM),
        .enable(GND)
    );

    controlled_register #(1) EReg_MemWriteM (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(MemWriteE),
        .data_out(MemWriteM),
        .enable(GND)
    );

    // WriteBack
    controlled_register #(1) EReg_RegWriteW (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(RegWriteM),
        .data_out(RegWriteW),
        .enable(GND)
    );

    controlled_register #(2) EReg_ResultSrcW (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(ResultSrcM),
        .data_out(ResultSrcW),
        .enable(GND)
    );

endmodule