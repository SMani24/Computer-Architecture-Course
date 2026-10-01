module counter (
    clk,
    reset,
    load,
    data,
    count_up,
    count_down,

    zero,
    msb,
    value
);
    parameter N = 4;
    input clk, reset, load, count_down, count_up;
    input [N-1:0] data;
    output zero, msb;
    output reg [N-1:0] value;

    always @(posedge clk) begin
        if (reset) value <= {N{1'b0}};
        else if (load) value <= data;
        else if (count_up) value <= value + 1;
        else if (count_down) value <= value - 1;
    end

    assign msb = value[N-1];
    assign zero = ~(|value);
endmodule