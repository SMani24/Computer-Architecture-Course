module controller_alu (
    f3,
    f7,
    alu_op,
    alu_function
);
    input [2:0] f3;
    input [6:0] f7;
    input [1:0] alu_op;
    output reg [2:0] alu_function;

    always @(f3 or f7 or alu_op) begin
        alu_function = 3'b000;
        case (alu_op)
            2'b00: alu_function = 3'b000;
            2'b01: alu_function = 3'b001;
            2'b10: case ({f3, f7})
                // ADD
                {3'b000, 7'b0000000}: alu_function = 3'b000;
                // SUB
                {3'b000, 7'b0100000}: alu_function = 3'b001;
                // AND
                {3'b111, 7'b0000000}: alu_function = 3'b010;
                // OR
                {3'b110, 7'b0000000}: alu_function = 3'b011;
                // SLT
                {3'b010, 7'b0000000}: alu_function = 3'b100;
            endcase
            2'b11: case (f3)
                // ADDI or JALR
                3'b000: alu_function = 3'b000;
                // ANDI
                3'b111: alu_function = 3'b010;
                // ORI
                3'b110: alu_function = 3'b011;
                // SLTI
                3'b010: alu_function = 3'b100;
                // XORI
                3'b100: alu_function = 3'b101;
            endcase
        endcase
    end
endmodule
