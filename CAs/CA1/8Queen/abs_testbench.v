module abs_testbench ();
    reg [2:0] number;
    wire [2:0] out;
    abs my_abs(out, number);
    initial begin
        number = 3'b001;
        #50;
        number = 3'b111;
        #50;
    end
endmodule