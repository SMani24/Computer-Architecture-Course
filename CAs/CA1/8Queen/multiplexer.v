module multiplexer (
    select,
    inputs,
    out
);
    parameter WIDTH = 3, INPUT_SIZE = 8;
    input [WIDTH-1:0] select;
    input [INPUT_SIZE-1:0] inputs [0:(1<<WIDTH)-1];
    output [INPUT_SIZE-1:0] out;

    assign out = inputs[select];
endmodule