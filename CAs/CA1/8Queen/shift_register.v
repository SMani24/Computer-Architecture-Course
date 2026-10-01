module shift_register (
    clk,
    reset,
    shift_right,
    out
);
    input clk, reset, shift_right;
    output reg [7:0] out;

    always @(posedge clk) begin
        if (reset) begin
            out <= {1'b1, {7{1'b0}}};
        end
        else if (shift_right) begin
            out <= {out[0], out[7:1]};
        end
    end

    
endmodule