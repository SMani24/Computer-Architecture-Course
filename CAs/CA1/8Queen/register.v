module register (
    clk,
    reset,
    load,
    bus_in,
    bus_out
);
    parameter SIZE = 6;
    input clk, reset, load;
    input [SIZE-1:0] bus_in;
    output reg [SIZE-1:0] bus_out;

    always @(posedge clk) begin
        if (reset)
            bus_out <= {SIZE{1'b0}};
        else if (load)
            bus_out <= bus_in;
    end
endmodule