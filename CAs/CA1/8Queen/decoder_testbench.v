module decoder_testbench ();
    localparam WIDTH = 3;
    reg enable;
    reg [WIDTH-1:0] binary;
    wire [(1<<WIDTH)-1:0] out;
    decoder  uut (
        enable,
        binary,
        out
    );

    initial begin
        enable = 0;
        #50 enable = 1;
        #50 binary = 3'd0;
        #50 binary = 3'd1;
        #50 binary = 3'd2;
        #50 binary = 3'd3;
        #50 binary = 3'd4;
        #50 binary = 3'd5;
        #50 binary = 3'd6;
        #50 binary = 3'd7;
        #50;
    end
endmodule