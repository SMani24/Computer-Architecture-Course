module stacked_eight_queen (
    clk,
    start,
    user_reset,

    ready,
    done,
    no_answer,
    out_bus
);
    input clk, start, user_reset;
    output done, no_answer, ready;
    output [7:0] out_bus;

    wire 
        enable_output,
        register_load,
        count,
        load_counter,
        push,
        pop,
        increament_row,
        increament_column,
        cout,
        down_counter_zero,
        row_zero,
        last_column,
        safe,
        stack_ready,
        underflow,
        load_updated_position,
        reset_column,
        reset_to_seven;

    stacked_datapath datapath (
        .clk(clk),
        .reset(reset),
        .enable_output(enable_output),
        .register_load(register_load),
        .count(count),
        .load_counter(load_counter),
        .push(push),
        .pop(pop),
        .increament_row(increament_row),
        .increament_column(increament_column),
        .cout(cout),
        .down_counter_zero(down_counter_zero),
        .row_zero(row_zero),    
        .last_column(last_column),
        .safe(safe),
        .stack_ready(stack_ready),
        .underflow(underflow),
        .ready(ready), 
        .done(done),
        .out_bus(out_bus),
        .load_updated_position(load_updated_position),
        .reset_column(reset_column),
        .reset_to_seven(reset_to_seven)
    );

    stacked_controller controller (
        .clk(clk),
        .start(start),
        .user_reset(user_reset),
        .cout(cout),
        .down_counter_zero(down_counter_zero),
        .last_column(last_column),
        .row_zero(row_zero),
        .safe(safe),
        .stack_ready(stack_ready),
        .underflow(underflow),
        .reset(reset),
        .enable_output(enable_output),
        .register_load(register_load),
        .count(count),
        .load_counter(load_counter),
        .push(push),
        .pop(pop),
        .increament_row(increament_row),
        .increament_column(increament_column),
        .ready(ready),
        .no_answer(no_answer),
        .done(done),
        .load_updated_position(load_updated_position),
        .reset_column(reset_column),
        .reset_to_seven(reset_to_seven)
    );
endmodule