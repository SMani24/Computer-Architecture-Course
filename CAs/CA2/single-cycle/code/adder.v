module adder (
    n1, n2,
    result,
    carry_out
);
    parameter N = 32;
    input [N-1:0] n1, n2;
    output [N-1:0] result;
    output carry_out;
    assign {carry_out, result} = n1 + n2;
endmodule