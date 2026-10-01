module immediate_extender (
    immediate_source,
    instruction,
    out
);
    input [2:0] immediate_source;
    input [31:7] instruction;
    output reg [31:0] out;

    always @(immediate_source or instruction) begin
        case (immediate_source)
            // I-Type
            3'b000: out = {{20{instruction[31]}}, instruction[31:20]};
            // S-Type
            3'b001: out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            // B-Type
            3'b010: out = {
                {19{instruction[31]}}, 
                instruction[31], 
                instruction[7],
                instruction[30:25],
                instruction[11:8],
                1'b0
            };
            // J-Type
            3'b011: out = {
                {12{instruction[31]}},
                instruction[19:12],
                instruction[20],
                instruction[30:21],
                1'b0
            };
            // U-Type
            3'b100: out = {
                instruction[31:12],
                {12{1'b0}}
            };
            default: out = {32{1'b0}};
        endcase
    end
endmodule