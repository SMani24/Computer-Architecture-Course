module controller (
    clk,
    start,
    user_reset,

    // Datapath outputs
    cout,
    down_counter_zero,
    last_queen_counter_zero,
    last_cell,
    safe,

    // Datapath inputs
    reset,
    enable_output,
    shift_right, 
    counter_reset, 
    count_up, 
    count_down,
    count,
    load_counter,
        
    // Outputs
    ready, 
    done,
);
    localparam 
        IDLE = 4'd0,
        RESET = 4'd1,
        CHECK_FINISH = 4'd2,
        COMPARE = 4'd3,
        CHECK_SAFETY = 4'd4,
        SHIFT = 4'd5,
        BACK_TRACK = 4'd6,
        WAIT = 4'd7,
        DONE = 4'd8,
        NEXT_ROW = 4'd9,
        TRANSMIT = 4'd10,
        DOUBLE_CHECK = 4'd11;
        
    reg [3:0] next_state, present_state;
    
    input clk,
        start,
        user_reset,
        cout,
        down_counter_zero,
        last_queen_counter_zero,
        last_cell,
        safe;

    output reg reset,
        enable_output,
        shift_right, 
        counter_reset, 
        count_up, 
        count_down,
        count,
        load_counter,
        ready, 
        done;
    
    always @(posedge clk) begin
        if (user_reset)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end


    always @( 
        present_state 
        or start or 
        last_queen_counter_zero 
        or cout or 
        safe
        or down_counter_zero or
        last_cell
        ) begin
        case (present_state)
            IDLE: next_state = start ? RESET : IDLE;
            RESET: next_state = CHECK_FINISH;
            CHECK_FINISH: next_state = 
                (~cout && ~last_queen_counter_zero) ? COMPARE :
                (~cout && last_queen_counter_zero) ? NEXT_ROW :
                DONE;
            COMPARE: next_state = 
                (safe && ~down_counter_zero) ? CHECK_SAFETY :
                (safe && down_counter_zero) ? NEXT_ROW : 
                (~last_cell) ? SHIFT :
                BACK_TRACK;
            CHECK_SAFETY: next_state = COMPARE;
            SHIFT: next_state = CHECK_FINISH;
            BACK_TRACK: next_state = DOUBLE_CHECK;
            WAIT: next_state = CHECK_FINISH;
            DONE: next_state = TRANSMIT;
            NEXT_ROW: next_state = CHECK_FINISH;
            TRANSMIT: next_state = (~cout) ? TRANSMIT : IDLE;
            DOUBLE_CHECK: next_state = (last_cell) ? BACK_TRACK : WAIT;
            default: next_state = IDLE;
        endcase
    end
    
    always @( 
        present_state 
        or start or 
        last_queen_counter_zero 
        or cout or 
        safe
        or down_counter_zero or
        last_cell
        ) begin

        reset = 1'b0;
        enable_output = 1'b0;
        shift_right = 1'b0;
        counter_reset = 1'b0;
        count_up = 1'b0;
        count_down = 1'b0;
        count = 1'b0;
        load_counter = 1'b0;
        ready = 1'b0;
        done = 1'b0;

        case (present_state)
            IDLE: ready = 1'b1;
            RESET: reset = 1'b1;
            CHECK_FINISH: load_counter = 1'b1;
            COMPARE: ;
            CHECK_SAFETY: count = 1'b1;
            SHIFT: shift_right = 1'b1;
            BACK_TRACK: {shift_right, count_down} = 2'b11;
            WAIT: shift_right = 1'b1;
            DONE: {done, counter_reset} = 2'b11;
            NEXT_ROW: count_up = 1'b1;
            TRANSMIT: {enable_output, count_up} = 2'b11;
        endcase
    end
endmodule