module decoder (
    enable,
    binary,
    out
);
    parameter WIDTH = 3;
    input enable;
    input [WIDTH-1:0] binary;
    output reg [(1<<WIDTH)-1:0] out; // 2^WIDTH
    
    always @(binary or enable) begin
        out = {(1<<WIDTH){1'b0}};
        if (enable)
            out[(1<<WIDTH) - 1 - binary] = 1'b1;
    end
endmodule