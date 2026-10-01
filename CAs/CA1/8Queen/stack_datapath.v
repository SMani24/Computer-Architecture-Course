module stack_datapath (
    clk,
    reset,
    bus_in,
    bus_out,

    // Controller-inputs
    msb,
    zero,

    // Controller-outputs
    push,
    pop
);
    parameter DEPTH = 8, SIZE = 6;
    input clk, reset, push, pop;
    input [SIZE-1:0] bus_in;

    output msb, zero;
    output reg [SIZE-1:0] bus_out;
    wire [SIZE-1:0] mux_output;

    wire [0:DEPTH-1] register_load;
    wire [SIZE-1:0] register_outputs [0:DEPTH-1];

    wire [$clog2(DEPTH) - 1:0] push_pointer;
    wire [$clog2(DEPTH) - 1:0] pop_pointer;
    
    assign pop_pointer = push_pointer - 1;

    counter #($clog2(DEPTH) + 1) stack_counter (
        .clk(clk),
        .reset(reset),
        .load(),
        .data(),
        .count_up(push),
        .count_down(pop),

        .zero(zero),
        .msb(msb),
        .value(push_pointer)
    );
    
    decoder #($clog2(DEPTH)) stack_decoder (
        .enable(push),
        .binary(push_pointer),
        .out(register_load)
    );

    genvar i;
    generate
        for (i = 0; i < DEPTH; i = i + 1) begin
            register r (
                .clk(clk),
                .reset(reset),
                .load(register_load[i]),
                .bus_in(bus_in),
                .bus_out(register_outputs[i])
            );
        end
    endgenerate

    // assign bus_out = pop ? mux_output : {SIZE{1'bz}};
    // Sorry, but to access the top of the stack without poping or giving TOP siganel.
    assign bus_out = mux_output;
    multiplexer #($clog2(DEPTH), SIZE) stack_multiplexer (
        .select(pop_pointer),
        .inputs(register_outputs),
        .out(mux_output)
    );
endmodule