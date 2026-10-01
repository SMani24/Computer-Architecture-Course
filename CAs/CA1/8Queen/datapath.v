module datapath (
    clk,
    reset,
    enable_output,
    
    // Decoder
    shift_right,
    
    // Counter
    counter_reset,
    count_up, 
    count_down,
    
    // Down counter
    count,
    load_counter,

    // Controller-inputs
    cout,
    down_counter_zero,
    last_queen_counter_zero,
    last_cell,
    safe,
    
    // Output
    out_bus
);
    input clk,
          reset,
          enable_output,
          shift_right, 
          counter_reset, 
          count_up, 
          count_down,
          count,
          load_counter;

    output cout,
           down_counter_zero,
           last_queen_counter_zero,
           last_cell,
           safe;

    output [7:0] out_bus;

    wire [0:7] right_register_shift;
    wire [7:0] register_outputs [0:7];
    
    wire [2:0] last_queen_row;
    wire [7:0] last_queen_row_data;
    wire [2:0] last_queen_column;
    
    wire [2:0] other_queen_row;
    wire [7:0] other_queen_row_data;
    wire [2:0] other_queen_column;

    wire [3:0] last_queen_counter_value;
    wire last_queen_counter_reset;

    wire [2:0] other_queen_counter_data;
    
    wire ZERO;
    assign ZERO = 1'b0;
    wire TRASH;

    decoder register_shift_decoder(
        .enable(shift_right),
        .binary(last_queen_row),
        .out(right_register_shift)
    );

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            shift_register sr (
                .clk(clk),
                .reset(reset),
                .shift_right(right_register_shift[i]),
                .out(register_outputs[i])
            );
        end
    endgenerate


    multiplexer last_queen_mux(
        .select(last_queen_row),
        .inputs(register_outputs),
        .out(last_queen_row_data)
    );

    multiplexer other_queen_mux(
        .select(other_queen_row),
        .inputs(register_outputs),
        .out(other_queen_row_data)
    );


    onehot_to_position_decoder last_queen_decoder(
        .onehot_row(last_queen_row_data),
        .column(last_queen_column)
    );

    onehot_to_position_decoder other_queen_decoder(
        .onehot_row(other_queen_row_data),
        .column(other_queen_column)
    );


    is_safe safety(
        .row1(last_queen_row),
        .column1(last_queen_column),
        .row2(other_queen_row),
        .column2(other_queen_column),
        .safe(safe)
    );
    

    assign last_queen_counter_reset = (reset || counter_reset);
    counter last_queen_row_counter(
        .clk(clk),
        .reset(last_queen_counter_reset),
        .load(ZERO),
        .data(ZERO),
        .count_up(count_up),
        .count_down(count_down),
        .zero(last_queen_counter_zero),
        .msb(cout),
        .value(last_queen_counter_value)
    );
    assign last_queen_row = last_queen_counter_value[2:0];

    assign other_queen_counter_data = last_queen_row - 3'b001;
    counter #(3) other_queen_row_counter(
        .clk(clk),
        .reset(reset),
        .load(load_counter),
        .data(other_queen_counter_data),
        .count_up(ZERO),
        .count_down(count),
        .zero(down_counter_zero),
        .msb(TRASH),
        .value(other_queen_row)
    );

    assign last_cell = last_queen_row_data[0];
    assign out_bus = enable_output ? last_queen_row_data : {8{1'bz}};


endmodule