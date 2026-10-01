module register_file (
    clk,
    reset,

    reg1_address,
    reg2_address,
    
    write_reg_address,
    write_data,
    reg_write,

    reg1_data,
    reg2_data
);
    input clk, reset;
    reg [31:0] register_file_data [0:31];
    assign register_file_data[0] = 32'd0;
    // SP could be also pointed to the last block of memory

    input [4:0] reg1_address, reg2_address, write_reg_address;
    input reg_write;
    input [31:0] write_data;

    output [31:0] reg1_data, reg2_data;
    assign reg1_data = register_file_data[reg1_address];
    assign reg2_data = register_file_data[reg2_address];

    integer i; //TODO: probable issue
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                register_file_data[i] <= {32{1'b0}};
            end
        end else if (reg_write) begin
            register_file_data[write_reg_address] <= write_data;
        end
    end
endmodule