module stacked_controller (
    clk,
    start,
    user_reset,

    // Datapath-outputs
    cout,
    down_counter_zero,
    last_column,
    row_zero,
    safe,
    stack_ready,
    underflow,
    
    // Datapath-inputs
    reset,
    enable_output,
    register_load,
    count,
    load_counter,
    push,
    pop,
    increament_row,
    increament_column,
    load_updated_position,
    reset_column,
    reset_to_seven,

    // Outputs
    ready,
    no_answer,
    done
);
    localparam
        IDLE = 5'd0,
        RESET = 5'd1,
        CHECK_FINISH = 5'd2,
        SAFETY_CHECK = 5'd3,
        PREVIOUS_QUEEN = 5'd4,
        NO_ANSWER = 5'd5,
        WAIT_FOR_PUSH = 5'd6,
        NEXT_ROW = 5'd7,
        DONE = 5'd8,
        BACK_TRACK = 5'd9,
        COLUMN_INCREASE = 5'd10,
        TRANSMIT = 5'd11,
        POP = 5'd12,
        WAIT_FOR_POP = 5'd13,
        PUSH = 5'd14,
        LOAD_TO_REGISTER = 5'd15,
        WAIT_FOR_POP_BACK_TRACK = 5'd16;


    input 
        clk,
        start,
        user_reset,
        cout,
        down_counter_zero,
        last_column,
        row_zero,
        safe,
        stack_ready,
        underflow;
    
    output reg
        reset,
        enable_output,
        register_load,
        count,
        load_counter,
        push,
        pop,
        increament_row,
        increament_column,
        load_updated_position,
        reset_to_seven,

        // Outputs
        ready,
        no_answer,
        done,
        reset_column;


    reg [4:0] present_state;
    reg [4:0] next_state;

    always @(posedge clk) begin
        if (user_reset)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end

    always @(
        start
        or row_zero or
        cout
        or safe or
        down_counter_zero
        or last_column or
        stack_ready 
        or underflow or
        present_state
    ) begin
        case (present_state)
            IDLE: next_state = start ? RESET : IDLE;
            RESET: next_state = CHECK_FINISH;
            CHECK_FINISH: next_state = 
                (~row_zero && ~cout) ? SAFETY_CHECK : 
                (row_zero && ~cout)  ? LOAD_TO_REGISTER :
                (~row_zero && cout)  ? DONE :
                NO_ANSWER;
            SAFETY_CHECK: next_state =
                (safe && ~down_counter_zero) ? PREVIOUS_QUEEN :
                (safe && down_counter_zero) ? LOAD_TO_REGISTER :
                (~safe && last_column) ? BACK_TRACK :
                COLUMN_INCREASE;
            PREVIOUS_QUEEN: next_state = SAFETY_CHECK;
            NO_ANSWER: next_state = IDLE;
            WAIT_FOR_PUSH: next_state = stack_ready ? CHECK_FINISH : WAIT_FOR_PUSH;
            NEXT_ROW: next_state = cout ? DONE : WAIT_FOR_PUSH;
            DONE: next_state = TRANSMIT;
            BACK_TRACK: next_state = last_column ? POP : COLUMN_INCREASE;
            COLUMN_INCREASE: next_state = WAIT_FOR_POP;
            // TRANSMIT: next_state = underflow ? IDLE : TRANSMIT;
            TRANSMIT: next_state = down_counter_zero ? IDLE : TRANSMIT;
            POP: next_state = WAIT_FOR_POP_BACK_TRACK;
            WAIT_FOR_POP_BACK_TRACK: next_state = stack_ready ? BACK_TRACK : WAIT_FOR_POP_BACK_TRACK;
            WAIT_FOR_POP: next_state = stack_ready ? PUSH : WAIT_FOR_POP;
            PUSH: next_state = WAIT_FOR_PUSH;
            LOAD_TO_REGISTER: next_state = NEXT_ROW;
            default: next_state = IDLE;
        endcase
    end

    always @(
        start
        or row_zero or
        cout
        or safe or
        down_counter_zero
        or last_column or
        stack_ready 
        or underflow or
        present_state
    ) begin
        reset = 1'b0;
        enable_output = 1'b0;
        register_load = 1'b0;
        count = 1'b0;
        load_counter = 1'b0;
        push = 1'b0;
        pop = 1'b0;
        increament_row = 1'b0;
        increament_column = 1'b0;
        load_updated_position = 1'b0;
        reset_column = 1'b0;
        ready = 1'b0;
        done = 1'b0;
        no_answer = 1'b0;
        reset_to_seven = 1'b0;

        case (present_state)
            IDLE: ready = 1'b1;
            RESET: reset = 1'b1;
            CHECK_FINISH: load_counter = 1'b1;
            SAFETY_CHECK: ;
            PREVIOUS_QUEEN: count = 1'b1;
            NO_ANSWER: no_answer = 1'b1;
            WAIT_FOR_PUSH: ;
            NEXT_ROW: {reset_column, increament_row, push, load_updated_position} = 4'b1111; // TODO: Sus
            DONE: {done, load_counter, reset_to_seven} = 3'b111;
            BACK_TRACK: ;
            COLUMN_INCREASE: {increament_column, pop, load_updated_position} = 3'b111;
            TRANSMIT: {enable_output, count} = 2'b11;
            POP: pop = 1'b1;
            WAIT_FOR_POP_BACK_TRACK: ;
            LOAD_TO_REGISTER: {register_load} = 1'b1;
            WAIT_FOR_POP: ;
            PUSH: push = 1'b1;
        endcase
    end
endmodule