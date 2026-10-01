module memory (
    clk,
    reset,
    address,
    write_data,
    mem_write,
    read_data
);
    parameter SIZE = 256;
    reg [31:0] memory_data [0:SIZE-1];

    input clk, reset;

    input mem_write;
    input [31:0] address, write_data;
    wire [29:0] shifted_address;
    assign shifted_address = address[31:2];

    output [31:0] read_data;
    assign read_data = memory_data[shifted_address];

    integer i; //TODO: probable issue
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < SIZE; i = i + 1) begin
                memory_data[i] <= {32{1'b0}};
            end
        end else if (mem_write) begin
            memory_data[shifted_address] <= write_data;
        end
    end
endmodule
