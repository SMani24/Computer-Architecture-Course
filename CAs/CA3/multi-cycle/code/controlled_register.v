module controlled_register (
    clk, 
    reset,
    data_in,
    data_out,
    enable
);
    parameter SIZE = 32;
    input clk, reset, enable;
    input [SIZE-1:0] data_in;
    output reg [SIZE-1:0] data_out;
    always @(posedge clk) begin
        if (reset)
            data_out <= {SIZE{1'b0}};
        else if (enable)
            data_out <= data_in;
    end
    
endmodule