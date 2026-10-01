module datapath (
    clk,
    reset,

    // Controller outputs
    pc_src,
    imm_src,
    reg_write,
    alu_src,
    alu_function,
    mem_write,
    result_src,

    // Controller inputs
    opcode, f3, f7,
    zero
);
    input clk, reset;
    input [1:0] pc_src;
    input [2:0] imm_src;
    input reg_write;
    input alu_src;
    input [2:0] alu_function;
    input mem_write;
    input [1:0] result_src;

    output [6:0] opcode;
    output [14:12] f3;
    output [31:25] f7;
    output zero;
    
    wire [31:0] pc_input;
    wire [31:0] instruction_address;
    register pc (
        .clk(clk), 
        .reset(reset),
        .data_in(pc_input),
        .data_out(instruction_address)
    );

    wire [31:0] instruction;
    
    assign opcode = instruction[6:0];
    assign f3 = instruction[14:12];
    assign f7 = instruction[31:25];

    rom instruction_memory (
        .address(instruction_address),
        .data(instruction)
    );

    wire [4:0] reg1_address;
    assign reg1_address = instruction[19:15];
    wire [4:0] reg2_address;
    assign reg2_address = instruction[24:20];
    wire [4:0] write_reg_address;
    assign write_reg_address = instruction[11:7];

    wire [31:0] write_data;
    
    wire [31:0] reg1_data;
    wire [31:0] reg2_data;

    register_file rf (
        .clk(clk),
        .reset(reset),

        .reg1_address(reg1_address),
        .reg2_address(reg2_address),
        
        .write_reg_address(write_reg_address),
        .write_data(write_data),
        .reg_write(reg_write),

        .reg1_data(reg1_data),
        .reg2_data(reg2_data)
    );

    wire [31:0] alu_input_b;
    wire [31:0] immediate;
    wire [31:0] alu_mux_inputs [0:1];
    assign alu_mux_inputs[0] = reg2_data;
    assign alu_mux_inputs[1] = immediate;

    multiplexer alu_mux (
        .select(alu_src),
        .inputs(alu_mux_inputs),
        .out(alu_input_b)
    );

    wire [31:0] alu_output;
    alu alu_instance (
        .input_a(reg1_data),
        .input_b(alu_input_b),
        .alu_function(alu_function),
        .alu_output(alu_output), 
        .zero(zero)
    );

    wire [31:0] memory_output;
    memory main_memory (
        .clk(clk),
        .reset(reset),
        .address(alu_output),
        .write_data(reg2_data),
        .mem_write(mem_write),
        .read_data(memory_output)
    );

    wire [31:0] next_pc;
    
    wire [31:0] result_mux_inputs [0:3];
    assign result_mux_inputs[0] = alu_output;
    assign result_mux_inputs[1] = memory_output;
    assign result_mux_inputs[2] = next_pc;
    assign result_mux_inputs[3] = immediate;

    multiplexer #(2, 32) result_mux (
        .select(result_src),
        .inputs(result_mux_inputs),
        .out(write_data)
    );

    immediate_extender ie (
        .immediate_source(imm_src),
        .instruction(instruction[31:7]),
        .out(immediate)
    );

    adder next_pc_adder (
        .n1(instruction_address), 
        .n2(32'd4),
        .result(next_pc),
        .carry_out()
    );

    wire [31:0] jump_address;
    adder jump_adder(
        .n1(instruction_address), 
        .n2(immediate),
        .result(jump_address),
        .carry_out()
    );

    wire [31:0] pc_mux_inputs [0:3];
    assign pc_mux_inputs[0] = next_pc;
    assign pc_mux_inputs[1] = jump_address;
    assign pc_mux_inputs[2] = write_data;

    // Selecting between jal, jalr, and pc+4
    multiplexer #(2, 32) pc_mux (
        .select(pc_src),
        .inputs(pc_mux_inputs),
        .out(pc_input)
    );
endmodule