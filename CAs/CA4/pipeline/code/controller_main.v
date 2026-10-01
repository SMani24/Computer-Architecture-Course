module controller_main (
    opcode,
    f3,
    f7,

    // Datapath inputs
    reg_write,
    imm_src,
    alu_src,
    mem_write,
    result_src,

    // Other contollers 
    beq,
    bne,
    alu_op,
    jump,
    jalr
);
    input [6:0] opcode;
    input [14:12] f3;
    input [31:25] f7;

    output reg reg_write;
    output reg [2:0] imm_src;
    output reg alu_src;
    output reg mem_write;
    output reg [1:0] result_src;

    output reg beq, bne, jump, jalr;
    output reg [1:0] alu_op;

    always @(opcode) begin
        reg_write = 0;
        imm_src = 0;
        alu_src  = 0;
        mem_write = 0;
        result_src = 0;
        beq = 0;
        bne = 0;
        alu_op = 0;
        jump = 0;
        jalr = 0;
        
        case (opcode)
            // R-Type
            7'd51: begin
                reg_write = 1'b1;
                alu_src = 1'b0;
                mem_write = 1'b0;
                result_src = 2'b00;
                beq = 1'b0;
                bne = 1'b0;
                alu_op = 2'b10;
                jump = 1'b0;
                jalr = 1'b0;
            end
            // I-Type(lw)
            7'd3: begin
                reg_write = 1'b1;
                imm_src = 3'b000;
                alu_src = 1'b1;
                mem_write = 1'b0;
                result_src = 2'b01;
                beq = 1'b0;
                bne = 1'b0;
                alu_op = 2'b00;
                jump = 1'b0;
                jalr = 1'b0;
            end
            // I-Type
            7'd19: begin
                reg_write = 1'b1;
                imm_src = 3'b000;
                alu_src = 1'b1;
                mem_write = 1'b0;
                result_src = 2'b00;
                beq = 1'b0;
                bne = 1'b0;
                alu_op = 2'b11;
                jump = 1'b0;
                jalr = 1'b0;
            end
            // S-Type (sw)
            7'd35: begin
                reg_write = 1'b0;
                imm_src = 3'b001;
                alu_src = 1'b1;
                mem_write = 1'b1;
                beq = 1'b0;
                bne = 1'b0;
                alu_op = 2'b00;
                jump = 1'b0;
                jalr = 1'b0;
            end
            // J-Type
            7'd111: begin
                reg_write = 1'b1;
                imm_src = 3'b011;
                mem_write = 1'b0;
                result_src = 2'b10;
                beq = 1'b0;
                bne = 1'b0;
                jump = 1'b1;
                jalr = 1'b0;
            end
            // B-Type
            7'd99: begin
                reg_write = 1'b0;
                imm_src = 3'b010;
                alu_src = 1'b0;
                mem_write = 1'b0;

                beq = (f3 == 3'b000) ? 1'b1 : 1'b0;
                bne = (f3 == 3'b001) ? 1'b1 : 1'b0;

                alu_op = 2'b01;
                jump = 1'b0;
                jalr = 1'b0;
            end
            // U-Type
            7'd55: begin
                reg_write = 1'b1;
                imm_src = 3'b100;
                mem_write = 1'b0;
                result_src = 2'b11;
                beq = 1'b0;
                bne = 1'b0;
                jump = 1'b0;
                jalr = 1'b0;
            end
            // I-Type (jalr)
            7'd103: begin
                reg_write = 1'b1;
                imm_src = 3'b000;
                alu_src = 1'b1;
                mem_write = 1'b0;
                result_src = 2'b00;
                beq = 1'b0;
                bne = 1'b0;
                alu_op = 2'b11;
                jump = 1'b0;
                jalr = 1'b1;
            end
        endcase
    end
endmodule