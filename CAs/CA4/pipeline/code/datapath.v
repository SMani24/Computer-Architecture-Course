module datapath (
    clk, 
    reset,

    // Controller outputs
    clear,
    StallF,
    
    FlushD,
    StallD,

    PCSrcE,

    RegWriteW,

    ImmSrcD,

    ALUSrcE,
    jalrE,
    ALUControlE,

    MemWriteM,

    ResultSrcW,
    
    // Controller inputs
    opcode,
    funct3,
    funct7,
    ZeroE,

    // Hazard Unit Inputs
    Rs1D,
    Rs2D,
    Rs1E,
    Rs2E,
    RdE,
    RdM,
    RdW,

    // Hazard Unit Outputs
    FlushE,
    ForwardAE,
    ForwardBE
);
    input clk, reset;
    input clear, StallF; 
    input PCSrcE;
    input RegWriteW;
    input [2:0] ImmSrcD;
    input StallD;
    input FlushD;
    input FlushE;
    input ALUSrcE;
    input [2:0] ALUControlE;
    input jalrE;
    input MemWriteM;
    input [1:0] ResultSrcW;
    input [1:0] ForwardAE, ForwardBE;


    output [6:0] opcode;
    output [14:12] funct3; 
    output [31:25] funct7;
    output [19:15] Rs1D;
    output [24:20] Rs2D;

    output [19:15] Rs1E;
    output [24:20] Rs2E;
    output [11:7] RdE;

    output ZeroE;
    output [11:7] RdM;
    output [11:7] RdW;
   
    // Fetch:
    wire [31:0] pc_source_mux_inputs [0:1];
    wire [31:0] PCPlus4F;
    wire [31:0] PCTargetE;
    assign pc_source_mux_inputs[0] = PCPlus4F;
    assign pc_source_mux_inputs[1] = PCTargetE;
    
    wire [31:0] PCF_in, PCF;

    multiplexer pc_source_mux (
        .select(PCSrcE),
        .inputs(pc_source_mux_inputs),
        .out(PCF_in)
    );

    controlled_register pc (
        .clk(clk), 
        .reset(reset),
        .clear(clear),
        .data_in(PCF_in),
        .data_out(PCF),
        .enable(StallF)
    );

    wire [31:0] instructionF;
    rom instruction_memory (
        .address(PCF),
        .data(instructionF) 
    );

    adder pc_incrementor (
        .n1(PCF), 
        .n2(32'd4),
        .result(PCPlus4F),
        .carry_out()
    );
    
    // Decode
    wire [31:0] instructionD;
    controlled_register DReg_instruction (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(instructionF),
        .data_out(instructionD),
        .enable(StallD)
    );

    wire [31:0] PCD;
    controlled_register DReg_PC (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(PCF),
        .data_out(PCD),
        .enable(StallD)
    );

    wire [31:0] PCPlus4D;
    controlled_register DReg_PCPlus4D (
        .clk(clk), 
        .reset(reset),
        .clear(FlushD),
        .data_in(PCPlus4F),
        .data_out(PCPlus4D),
        .enable(StallD)
    );

    wire [19:15] reg1_address;
    assign reg1_address = instructionD[19:15];
    wire [24:20] reg2_address;
    assign reg2_address = instructionD[24:20];
    wire [31:0] ResultW;
    wire [31:0] RD1D;
    wire [31:0] RD2D;
    
    wire [11:7] RdD;
    assign RdD = instructionD[11:7];
    assign Rs1D = instructionD[19:15];
    assign Rs2D = instructionD[24:20];
    wire [11:7] RdW;

    register_file rf (
        .clk(clk),
        .reset(reset),
        .reg1_address(reg1_address),
        .reg2_address(reg2_address),
        .write_reg_address(RdW),
        .write_data(ResultW),
        .reg_write(RegWriteW),
        .reg1_data(RD1D),
        .reg2_data(RD2D)   
    );

    wire [31:7] extender_input;
    assign extender_input = instructionD[31:7];
    wire [31:0] ExtImmD;
    immediate_extender immediate_extender_instance(
        .immediate_source(ImmSrcD),
        .instruction(instructionD[31:7]),
        .out(ExtImmD)
    );

    assign opcode = instructionD[6:0];
    assign funct3 = instructionD[14:12];
    assign funct7 = instructionD[31:25];
    
    // Execution
    wire GND;
    assign GND = 1'b0;


    wire [31:0] RD1E;
    controlled_register EReg_RD1E (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(RD1D),
        .data_out(RD1E),
        .enable(GND)
    );

    wire [31:0] RD2E;
    controlled_register EReg_RD2E (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(RD2D),
        .data_out(RD2E),
        .enable(GND)
    );

    wire [31:0] PCE;
    controlled_register EReg_PCE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(PCD),
        .data_out(PCE),
        .enable(GND)
    );

    wire [19:15] Rs1E;
    controlled_register #(5) EReg_Rs1E (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(Rs1D),
        .data_out(Rs1E),
        .enable(GND)
    );

    wire [24:20] Rs2E;
    controlled_register #(5) EReg_Rs2E (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(Rs2D),
        .data_out(Rs2E),
        .enable(GND)
    );

    wire [11:7] RdE;
    controlled_register #(5) EReg_RdE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(RdD),
        .data_out(RdE),
        .enable(GND)
    );

    wire [31:0] ExtImmE;
    controlled_register EReg_ExtImmE (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(ExtImmD),
        .data_out(ExtImmE),
        .enable(GND)
    );

    wire [31:0] PCPlus4E;
    controlled_register EReg_PCPlus4E (
        .clk(clk), 
        .reset(reset),
        .clear(FlushE),
        .data_in(PCPlus4D),
        .data_out(PCPlus4E),
        .enable(GND)
    );

    wire [31:0] SrcAE;
    wire [31:0] ALUResultM;
    wire [31:0] SrcAE_mux_inputs [0:3];
    assign SrcAE_mux_inputs[0] = RD1E;
    assign SrcAE_mux_inputs[1] = ResultW;
    assign SrcAE_mux_inputs[2] = ALUResultM;
    multiplexer #(2, 32) SrcAE_mux (
        .select(ForwardAE),
        .inputs(SrcAE_mux_inputs),
        .out(SrcAE)
    );

    wire [31:0] WriteDataE_mux_inputs [0:3];
    assign WriteDataE_mux_inputs[0] = RD2E;
    assign WriteDataE_mux_inputs[1] = ResultW;
    assign WriteDataE_mux_inputs[2] = ALUResultM;
    wire [31:0] WriteDataE;
    multiplexer #(2, 32) WriteDataE_mux (
        .select(ForwardBE),
        .inputs(WriteDataE_mux_inputs),
        .out(WriteDataE)
    );

    wire [31:0] SrcBE_mux_inputs [0:1];
    wire [31:0] SrcBE;
    assign SrcBE_mux_inputs[0] = WriteDataE; 
    assign SrcBE_mux_inputs[1] = ExtImmE;
    multiplexer SrcBE_mux (
        .select(ALUSrcE),
        .inputs(SrcBE_mux_inputs),
        .out(SrcBE)
    );

    wire [31:0] jump_offset;
    wire [31:0] jump_offset_mux_inputs [0:1];
    assign jump_offset_mux_inputs[0] = PCE;
    assign jump_offset_mux_inputs[1] = RD1E;
    multiplexer jump_offset_mux (
        .select(jalrE),
        .inputs(jump_offset_mux_inputs),
        .out(jump_offset)
    );

    adder PC_jump_adder(
        .n1(jump_offset), 
        .n2(ExtImmE),
        .result(PCTargetE),
        .carry_out()
    );

    wire [31:0] ALUResultE;
    alu the_alu(
        .input_a(SrcAE), 
        .input_b(SrcBE),
        .alu_function(ALUControlE),
        .alu_output(ALUResultE), 
        .zero(ZeroE)
    );

    // Memory
    controlled_register MReg_AluResultM (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(ALUResultE),
        .data_out(ALUResultM),
        .enable(GND)
    );

    wire [31:0] WriteDataM;
    controlled_register MReg_WriteDataM (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(WriteDataE),
        .data_out(WriteDataM),
        .enable(GND)
    );

    controlled_register #(5) MReg_RdM (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(RdE),
        .data_out(RdM),
        .enable(GND)
    );

    wire [31:0] ExtImmM;
    controlled_register EReg_ExtImmM (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(ExtImmE),
        .data_out(ExtImmM),
        .enable(GND)
    );

    wire [31:0] PCPlus4M;
    controlled_register EReg_PCPlus4M (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(PCPlus4E),
        .data_out(PCPlus4M),
        .enable(GND)
    );

    wire [31:0] ReadDataM;
    memory memory_instance (
        .clk(clk),
        .reset(reset),
        .address(ALUResultM),
        .write_data(WriteDataM),
        .mem_write(MemWriteM),
        .read_data(ReadDataM)
    );

    // WriteBack
    wire [31:0] ALUResultW;
    controlled_register WReg_AluResultW (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(ALUResultM),
        .data_out(ALUResultW),
        .enable(GND)
    );

    wire [31:0] ReadDataW;
    controlled_register WReg_ReadDataW (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(ReadDataM),
        .data_out(ReadDataW),
        .enable(GND)
    );

    controlled_register #(5) WReg_RdW (
        .clk(clk), 
        .reset(reset),
        .clear(),
        .data_in(RdM),
        .data_out(RdW),
        .enable(GND)
    );

    wire [31:0] ExtImmW;
    controlled_register WReg_ExtImmW (
        .clk(clk),
        .reset(reset),
        .clear(),
        .data_in(ExtImmM),
        .data_out(ExtImmW),
        .enable(GND)
    );

    wire [31:0] PCPlus4W;
    controlled_register WReg_PCPlus4W (
        .clk(clk),
        .reset(reset),
        .clear(),
        .data_in(PCPlus4M),
        .data_out(PCPlus4W),
        .enable(GND)
    );

    wire [31:0] ResultW_mux_inputs [0:3];
    assign ResultW_mux_inputs[0] = ALUResultW;
    assign ResultW_mux_inputs[1] = ReadDataW;
    assign ResultW_mux_inputs[2] = PCPlus4W;
    assign ResultW_mux_inputs[3] = ExtImmW;
    multiplexer #(2, 32) ResultW_mux (
        .select(ResultSrcW),
        .inputs(ResultW_mux_inputs),
        .out(ResultW)
    ); 

endmodule