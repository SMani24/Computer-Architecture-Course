module increamenter(
    enable_output,
    in,
    out,
    carry_out
);
    parameter N = 3;
    input enable_output;
    input [N-1:0] in;
    output [N-1:0] out;
    output carry_out;

    assign {carry_out, out} = enable_output ? in + 1'b1 : {1'b0, in}; 
endmodule
