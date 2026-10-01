module multiplexer (
    select,
    inputs,
    out
);
    parameter SELECT_SIZE = 1, INPUT_SIZE = 32;

    input [SELECT_SIZE-1:0] select;
    input [INPUT_SIZE-1:0] inputs [0:(1<<SELECT_SIZE)-1];
    output [INPUT_SIZE-1:0] out;

    assign out = inputs[select];
endmodule