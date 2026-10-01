module datapath (
    clk,
    reset,

    // Controller outputs
    adr_src,
    mem_write,
    ir_write,
    imm_src,
    alu_src_a,
    alu_src_b,
    alu_function,
    result_src,
    reg_write,
    pc_write,
    old_pc_write,

    // Controller inputs
    opcode, f3, f7,
    zero
);
    input clk, reset;

    input adr_src;
    input mem_write, ir_write, reg_write, pc_write, old_pc_write;
    input [2:0] imm_src;
    input [1:0] alu_src_a, alu_src_b;
    input [2:0] alu_function;
    input [1:0] result_src;

    output [6:0] opcode;
    output [14:12] f3;
    output [31:25] f7;
    output zero;

    wire [31:0] result;
    wire [31:0] pc_out;
    controlled_register pc (
        .clk(clk), 
        .reset(reset),
        .data_in(result),
        .data_out(pc_out),
        .enable(pc_write)
    );

    wire [31:0] old_pc_out;
    controlled_register old_pc (
        .clk(clk), 
        .reset(reset),
        .data_in(pc_out),
        .data_out(old_pc_out),
        .enable(old_pc_write)
    );
    

    wire [31:0] memory_address;
    wire [31:0] memory_src_mux_inputs [0:1];
    assign memory_src_mux_inputs[0] = pc_out;
    assign memory_src_mux_inputs[1] = result;

    multiplexer memory_src_mux (
        .select(adr_src),
        .inputs(memory_src_mux_inputs),
        .out(memory_address)
    );

    wire [31:0] memory_output;
    wire [31:0] reg_b_out;
    memory mem (
        .clk(clk),
        .reset(reset),
        .address(memory_address),
        .write_data(reg_b_out),
        .mem_write(mem_write),
        .read_data(memory_output)
    );

    wire [31:0] instruction;
    assign opcode = instruction[6:0];
    assign f3 = instruction[14:12];
    assign f7 = instruction[31:25];
    controlled_register ir (
        .clk(clk), 
        .reset(reset),
        .data_in(memory_output),
        .data_out(instruction),
        .enable(ir_write)
    );

    wire [31:0] memory_data;
    register mdr (
        .clk(clk), 
        .reset(reset),
        .data_in(memory_output),
        .data_out(memory_data)
    );



    wire [31:0] write_data;
    wire [31:0] reg1_data;
    wire [31:0] reg2_data;

    wire [4:0] reg1_address;
    assign reg1_address = instruction[19:15];
    wire [4:0] reg2_address;
    assign reg2_address = instruction[24:20];
    wire [4:0] write_reg_address;
    assign write_reg_address = instruction[11:7];

    register_file rf (
        .clk(clk),
        .reset(reset),
        .reg1_address(reg1_address),
        .reg2_address(reg2_address),
        .write_reg_address(write_reg_address),
        .write_data(result),
        .reg_write(reg_write),
        .reg1_data(reg1_data),
        .reg2_data(reg2_data)
    );

    wire [31:0] reg_a_out;
    register A (
        .clk(clk), 
        .reset(reset),
        .data_in(reg1_data),
        .data_out(reg_a_out)
    );

    register B (
        .clk(clk), 
        .reset(reset),
        .data_in(reg2_data),
        .data_out(reg_b_out)
    );

    wire [31:0] alu_a_mux_output;

    wire [31:0] alu_src_a_mux_inputs [0:3];
    assign alu_src_a_mux_inputs[0] = pc_out;
    assign alu_src_a_mux_inputs[1] = old_pc_out;
    assign alu_src_a_mux_inputs[2] = reg_a_out;

    multiplexer #(2, 32) alu_src_a_mux (
        .select(alu_src_a),
        .inputs(alu_src_a_mux_inputs),
        .out(alu_a_mux_output)
    );

    wire [31:0] alu_b_mux_output;
    wire [31:0] immediate_extender_output;
    wire [31:0] alu_src_b_mux_inputs [0:3];
    assign alu_src_b_mux_inputs[0] = reg_b_out;
    assign alu_src_b_mux_inputs[1] = immediate_extender_output;
    assign alu_src_b_mux_inputs[2] = 32'd4;

    multiplexer #(2, 32) alu_src_b_mux (
        .select(alu_src_b),
        .inputs(alu_src_b_mux_inputs),
        .out(alu_b_mux_output)
    );

    immediate_extender ie (
        .immediate_source(imm_src),
        .instruction(instruction[31:7]),
        .out(immediate_extender_output)
    );

    wire [31:0] alu_output;
    alu alu_instance (
        .input_a(alu_a_mux_output),
        .input_b(alu_b_mux_output),
        .alu_function(alu_function),
        .alu_output(alu_output),
        .zero(zero)
    );

    wire [31:0] alu_register_output;
    register alu_out_register (
        .clk(clk), 
        .reset(reset),
        .data_in(alu_output),
        .data_out(alu_register_output)
    );

    wire [31:0] result_mux_output [0:3];
    assign result_mux_output[0] = alu_register_output;
    assign result_mux_output[1] = memory_data;
    assign result_mux_output[2] = alu_output;
    assign result_mux_output[3] = immediate_extender_output;

    multiplexer #(2, 32) result_mux (
        .select(result_src),
        .inputs(result_mux_output),
        .out(result)
    );
endmodule