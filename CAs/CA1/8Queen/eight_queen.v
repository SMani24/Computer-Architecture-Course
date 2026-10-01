module eight_queen (
    clk,
    start, 
    user_reset,
    ready,
    done,
    out_bus
);
    input clk, start, user_reset;
    output ready, done;
    output [7:0] out_bus;
    
    wire
        reset,
        enable_output,
        shift_right,
        counter_reset,
        count_up, 
        count_down,
        count,
        load_counter,
        cout,
        down_counter_zero,
        last_queen_counter_zero,
        last_cell,
        safe;

    wire [7:0] out_bus;

    controller eight_queen_controller(
        .clk(clk),
        .start(start),
        .user_reset(user_reset),
        // Datapath outputs
        .cout(cout),
        .down_counter_zero(down_counter_zero),
        .last_queen_counter_zero(last_queen_counter_zero),
        .last_cell(last_cell),
        .safe(safe),

        // Datapath inputs
        .reset(reset),
        .enable_output(enable_output),
        .shift_right(shift_right), 
        .counter_reset(counter_reset), 
        .count_up(count_up), 
        .count_down(count_down),
        .count(count),
        .load_counter(load_counter),
            
        // Outputs
        .ready(ready), 
        .done(done)
    );

    datapath eight_queen_datapath (
        .clk(clk),
        .reset(reset),
        .enable_output(enable_output),
        
        // Decoder
        .shift_right(shift_right),
        
        // Counter
        .counter_reset(counter_reset),
        .count_up(count_up), 
        .count_down(count_down),
        
        // Down counter
        .count(count),
        .load_counter(load_counter),

        // Controller-inputs
        .cout(cout),
        .down_counter_zero(down_counter_zero),
        .last_queen_counter_zero(last_queen_counter_zero),
        .last_cell(last_cell),
        .safe(safe),
        
        // Output
        .out_bus(out_bus)
    );

endmodule