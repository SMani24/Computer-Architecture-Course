module onehot_to_position_decoder (
    onehot_row,
    column
);
    input [0:7] onehot_row;
    output reg [0:2] column;

    always @(onehot_row) begin
        casex (onehot_row)
            8'b1xxxxxxx: column = 0;
            8'b01xxxxxx: column = 1;
            8'b001xxxxx: column = 2;
            8'b0001xxxx: column = 3;
            8'b00001xxx: column = 4;
            8'b000001xx: column = 5;
            8'b0000001x: column = 6;
            8'b00000001: column = 7;
            default: column = {3{1'bx}};
        endcase
    end
    
endmodule