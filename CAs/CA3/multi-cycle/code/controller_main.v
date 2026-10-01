module controller_main (
    clk,
    reset,
    
    // Datapath outputs
    opcode,
    f3,
    
    // Datapath inputs
    adr_src,
    mem_write,
    ir_write,
    old_pc_write,
    reg_write,
    imm_src,
    alu_src_a,
    alu_src_b,
    result_src,

    // Other contollers inputs
    alu_op,
    pc_write,
    beq,
    bne
);
    input clk, reset;

    input [6:0] opcode;
    input [2:0] f3;

    output reg adr_src;
    output reg [1:0] alu_src_a, alu_src_b, result_src;
    output reg [2:0] imm_src;
    output reg [1:0] alu_op;
    output reg mem_write, ir_write, pc_write, old_pc_write, reg_write;
    output reg beq, bne;

    // STATES
    localparam 
        IF = 4'd0,
        ID = 4'd1,
        MEM_REF = 4'd2,
        MEM_READ = 4'd3,
        LOAD_WORD = 4'd4,
        SAVE_WORD = 4'd5,
        R_TYPE = 4'd6,
        B_TYPE = 4'd7,
        I_TYPE = 4'd8,
        LUI = 4'd9,
        WRITE_BACK = 4'd10,
        JUMP = 4'd11,
        SAVE_RETURN_ADDRESS = 4'd12,
        JAL = 4'd13,
        JALR = 4'd14;


    // OPCODES
    localparam 
        OPCODE_JAL       = 7'b1101111,
        OPCODE_JALR      = 7'b1100111,
        OPCODE_B_TYPE    = 7'b1100011,
        OPCODE_R_TYPE    = 7'b0110011,
        OPCODE_I_TYPE    = 7'b0010011,
        OPCODE_SAVE_WORD = 7'b0100011,
        OPCODE_LOAD_WORD = 7'b0000011,
        OPCODE_LUI       = 7'b0110111;

    // F3s
    localparam
        F3_BEQ = 3'b000,
        F3_BNE = 3'b001;

    reg [3:0] present_state;
    reg [3:0] next_state;

    always @(posedge clk) begin
        if (reset)
            present_state <= IF;
        else
            present_state <= next_state;
    end

    always @(*) begin
        case (present_state)
            IF: next_state = ID;
            ID: next_state = 
                (opcode == OPCODE_I_TYPE) ? I_TYPE :
                (opcode == OPCODE_LOAD_WORD) ? MEM_REF :
                (opcode == OPCODE_SAVE_WORD) ? MEM_REF :
                (opcode == OPCODE_R_TYPE) ? R_TYPE :
                (opcode == OPCODE_B_TYPE) ? B_TYPE :
                (opcode == OPCODE_LUI) ? LUI :
                (opcode == OPCODE_JAL) ? JUMP :
                (opcode == OPCODE_JALR) ? JUMP :
                IF;
            MEM_REF: next_state =
                (opcode == OPCODE_LOAD_WORD) ? MEM_READ :
                (opcode == OPCODE_SAVE_WORD) ? SAVE_WORD :
                IF;
            MEM_READ: next_state = LOAD_WORD;
            LOAD_WORD: next_state = IF;
            SAVE_WORD: next_state = IF;
            R_TYPE: next_state = WRITE_BACK;
            B_TYPE: next_state = IF;
            I_TYPE: next_state = WRITE_BACK;
            LUI: next_state = IF;
            WRITE_BACK: next_state = IF;
            JUMP: next_state = SAVE_RETURN_ADDRESS;
            SAVE_RETURN_ADDRESS: next_state =
                (opcode == OPCODE_JAL) ? JAL:
                (opcode == OPCODE_JALR) ? JALR:
                IF;
            JAL: next_state = IF;
            JALR: next_state = IF;
            default: next_state = IF;
        endcase
    end

    always @(*) begin
        adr_src = 0;
        mem_write = 0;
        ir_write = 0;
        old_pc_write = 0;
        reg_write = 0;
        imm_src = 0;
        alu_src_a = 0;
        alu_src_b = 0;
        alu_op = 0;
        result_src = 0;
        pc_write = 0;
        beq = 0;
        bne = 0;
        case (present_state)
            IF: begin
                adr_src = 1'b0;
                ir_write = 1'b1;
                alu_src_a = 2'b00;
                alu_src_b = 2'b10;
                alu_op = 2'b00;
                result_src = 2'b10;
                pc_write = 1'b1;
                old_pc_write = 1'b1;
            end
            ID: begin
                alu_src_a = 2'b01;
                alu_src_b = 2'b01;
                alu_op = 2'b00;
                imm_src = 3'b010;
            end
            MEM_REF: begin
                alu_src_a = 2'b10;
                alu_src_b = 2'b01;
                imm_src = (opcode == OPCODE_SAVE_WORD) ? 3'b001 : 3'b000;
            end
            MEM_READ: begin
                result_src = 2'b00;
                adr_src = 1'b1;
            end
            LOAD_WORD: begin
                result_src = 2'b01;
                reg_write = 1'b1;
            end
            SAVE_WORD: begin
                result_src = 2'b00;
                adr_src = 1'b1;
                mem_write = 1'b1;
            end
            R_TYPE: begin 
                alu_src_a = 2'b10;
                alu_src_b = 2'b00;
                alu_op = 2'b10;
            end
            B_TYPE: begin
                alu_src_a = 2'b10;
                alu_src_b = 2'b00;
                alu_op = 2'b01;
                result_src = 2'b00;
                beq = (f3 == F3_BEQ);
                bne = (f3 == F3_BNE);
            end
            I_TYPE: begin
                alu_src_a = 2'b10;
                alu_src_b = 2'b01;
                imm_src = 3'b000;
                alu_op = 2'b11;
            end
            LUI: begin
                imm_src = 3'b100;
                reg_write = 1'b1;
                result_src = 2'b11;
            end
            WRITE_BACK: begin
                result_src = 2'b00;
                reg_write = 1'b1;
            end
            JUMP: begin
                alu_src_a = 2'b01;
                alu_src_b = 2'b10;
                alu_op = 2'b00;
            end
            SAVE_RETURN_ADDRESS: begin
                reg_write = 1'b1;
                result_src = 2'b00;
            end
            JAL: begin
                result_src = 2'b10;
                pc_write = 1'b1;
                alu_src_a = 2'b01;
                alu_src_b = 2'b01;
                imm_src = 3'b011;
                alu_op = 2'b00;
            end
            JALR: begin
                result_src = 2'b10;
                alu_op = 2'b00;
                alu_src_a = 2'b10;
                alu_src_b = 2'b01;
                pc_write = 1'b1;
                imm_src = 3'b000;
            end
        endcase
    end


endmodule
