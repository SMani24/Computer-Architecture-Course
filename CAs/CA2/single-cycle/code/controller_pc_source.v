module controller_pc_source (
    branch,
    jump,
    jalr,
    zero,
    f3,
    pc_src
);
    input branch, jump, jalr, zero;
    input [2:0] f3;
    output reg [1:0] pc_src;
    
    always @(*) begin
        pc_src = 2'b00;
        if (jump) pc_src = 2'b01;
        else if (branch) begin
            if (f3 == 3'b000 & zero) pc_src = 2'b01;
            else if (f3 == 3'b001 & ~zero) pc_src = 2'b01;
        end 
        else if (jalr) pc_src = 2'b10;
    end
endmodule