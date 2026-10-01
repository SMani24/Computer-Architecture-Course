module stack_controller (
    clk,
    reset,

    user_push,
    user_pop,

    msb,
    zero,
    
    ready,
    push,
    pop,
    overflow,
    underflow
);
    localparam 
        IDLE = 3'd0,
        PUSH = 3'd1,
        POP = 3'd2,
        OVERFLOW = 3'd3,
        UNDERFLOW = 3'd4;

    reg [2:0] next_state, present_state;
    
    input clk, reset, msb, zero, user_push, user_pop;
    output reg ready, push, pop, overflow, underflow;


    always @(posedge clk) begin
        if (reset)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end

    always @(
        user_push 
        or user_pop or 
        zero 
        or msb or 
        present_state
    ) begin
        case (present_state)
            IDLE: next_state = 
                (user_pop && ~zero) ? POP :
                (user_pop && zero) ? UNDERFLOW :
                (user_push && ~msb) ? PUSH :
                (user_push && msb) ? OVERFLOW :
                IDLE;
            PUSH: next_state = IDLE;
            POP: next_state = IDLE;
            OVERFLOW: next_state = IDLE;
            UNDERFLOW: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(
        user_push 
        or user_pop or 
        zero 
        or msb or 
        present_state
    ) begin
        ready = 1'b0;
        push = 1'b0;
        pop = 1'b0;
        overflow = 1'b0;
        underflow = 1'b0;

        case (present_state)
            IDLE: ready = 1'b1;
            PUSH: push = 1'b1;
            POP: pop = 1'b1;
            OVERFLOW: overflow = 1'b1;
            UNDERFLOW: underflow = 1'b1;
        endcase
    end

endmodule