module alu (
    input_a, input_b,
    alu_function,

    alu_output, 
    zero
);
    input signed [31:0] input_a, input_b;
    input [2:0] alu_function;

    output [31:0] alu_output;
    output zero;
    assign zero = ~(|alu_output);

    assign alu_output = 
        (alu_function == 3'b000) ? input_a + input_b :
        (alu_function == 3'b001) ? input_a - input_b :
        (alu_function == 3'b010) ? input_a & input_b :
        (alu_function == 3'b011) ? input_a | input_b :
        (alu_function == 3'b100) ? input_a < input_b :
        (alu_function == 3'b101) ? input_a ^ input_b :
        32'b0;
endmodule
