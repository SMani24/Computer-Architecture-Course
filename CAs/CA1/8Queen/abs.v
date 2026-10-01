module abs (
    value,
    number
);
    parameter N = 8; //TODO: This can be lower (and also where it is used)
    input signed [N-1:0] number;
    output [N-1:0] value;
    wire positivity;
    assign positivity = (number >= 0);
    assign value = positivity ? number : -number;
endmodule