module stack (
    clk,
    reset,
    user_push,
    bus_in,
    user_pop,
    overflow,
    underflow,
    ready,
    bus_out
); 
    parameter DEPTH = 8, SIZE = 6;

    input clk, reset, user_push, user_pop;
    input [SIZE - 1:0] bus_in;
    
    output overflow, underflow, ready;
    output [SIZE - 1:0] bus_out;
    
    wire msb, zero;
    wire push, pop;
    
    stack_controller stack_controller_instance(
        .clk(clk),
        .reset(reset),
        .user_push(user_push),
        .user_pop(user_pop),
        .msb(msb),
        .zero(zero),
        .ready(ready),
        .push(push),
        .pop(pop),
        .overflow(overflow),
        .underflow(underflow)
    );

    stack_datapath stack_datapath_instance (
        .clk(clk),
        .reset(reset),
        .bus_in(bus_in),
        .bus_out(bus_out),
        .msb(msb),
        .zero(zero),
        .push(push),
        .pop(pop)
    );
endmodule