module riscv_pipeline (
    clk,
    reset
);
    input clk, reset;

    wire [6:0] opcode;
    wire ZeroE;
    wire FlushD;
    wire [1:0] ResultSrcE;
    wire jalrE;
    wire [2:0] ALUControlE;
    wire ALUSrcE;
    wire MemWriteM;
    wire [1:0] ResultSrcW;

    wire clear, StallF; 
    wire PCSrcE;
    wire RegWriteM;
    wire RegWriteW;
    wire [2:0] ImmSrcD;
    wire StallD;
    wire FlushE;
    wire [1:0] ForwardAE, ForwardBE;

    wire [14:12] funct3; 
    wire [31:25] funct7;
    wire [19:15] Rs1D;
    wire [24:20] Rs2D;
    wire [19:15] Rs1E;
    wire [24:20] Rs2E;
    wire [11:7] RdE;
    wire [11:7] RdM;
    wire [11:7] RdW;

    controller riscv_pipeline_controller(
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .f3(funct3),
        .f7(funct7),
        .ZeroE(ZeroE),
        .FlushD(FlushD),
        .ImmSrcD(ImmSrcD),
        .PCSrcE(PCSrcE),
        .ALUControlE(ALUControlE),
        .ResultSrcE(ResultSrcE),
        .jalrE(jalrE),
        .RegWriteM(RegWriteM),
        .ALUSrcE(ALUSrcE),
        .MemWriteM(MemWriteM),
        .ResultSrcW(ResultSrcW),
        .RegWriteW(RegWriteW)
    );

    datapath riscv_pipeline_datapath(
        .clk(clk), 
        .reset(reset),
        .clear(clear),
        .StallF(StallF),
        .FlushD(FlushD),
        .StallD(StallD),
        .PCSrcE(PCSrcE),
        .RegWriteW(RegWriteW),
        .ImmSrcD(ImmSrcD),
        .ALUSrcE(ALUSrcE),
        .jalrE(jalrE),
        .ALUControlE(ALUControlE),
        .MemWriteM(MemWriteM),
        .ResultSrcW(ResultSrcW),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .ZeroE(ZeroE),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .RdM(RdM),
        .RdW(RdW),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

    hazard_uint riscv_pipeline_hazard_unit(
        .RegWriteM(RegWriteM),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdM(RdM),
        .RegWriteW(RegWriteW),
        .RdW(RdW),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdE(RdE),
        .PCSrcE(PCSrcE),
        .ResultSrcE(ResultSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallD(StallD),
        .StallF(StallF),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

endmodule