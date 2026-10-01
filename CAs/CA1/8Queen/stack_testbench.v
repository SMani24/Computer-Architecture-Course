module stack_testbench();
    reg clk, reset, user_push, user_pop;
    reg [5:0] bus_in;
    
    wire [5:0] bus_out;
    wire overflow, underflow, ready;

    stack #(8, 6) my_stack(
        .clk(clk),
        .reset(reset),
        .user_push(user_push),
        .bus_in(bus_in),
        .user_pop(user_pop),
        .overflow(overflow),
        .underflow(underflow),
        .ready(ready),
        .bus_out(bus_out)
    );

    initial begin
        clk = 1;
        forever #(10 / 2) clk = ~clk;
    end

    initial begin
        user_pop = 0;
        user_push = 0;
        reset = 1;
        #15 reset = 0;
        

        // CASE 1: Full, then empty.
        bus_in = 6'b0;
        repeat (16) begin
            #10 user_push = ~user_push;
            #10 user_push = ~user_push;
            bus_in = bus_in + 1;
        end
        repeat (16) begin
            #10 user_pop = ~user_pop;
            #10 user_pop = ~user_pop;
        end

        // CASE2: Half-Full, then Full-Empty
        reset = 1;
        #15 reset = 0;
        bus_in = 6'b0;
        repeat (4) begin
            #10 user_push = ~user_push;
            #10 user_push = ~user_push;
            bus_in = bus_in + 1;
        end
        repeat (8) begin
            #10 user_pop = ~user_pop;
            #10 user_pop = ~user_pop;
        end


        // Case 3: Half-Full, then Half-Empty 
        reset = 1;
        #15 reset = 0;
        bus_in = 6'b0;
        repeat (4) begin
            #10 user_push = ~user_push;
            #10 user_push = ~user_push;
            bus_in = bus_in + 1;
        end
        repeat (2) begin
            #10 user_pop = ~user_pop;
            #10 user_pop = ~user_pop;
        end
        
        // Case 4: 6 PUSH, 2 POP, 4 PUSH, 4 POP
        reset = 1;
        #15 reset = 0;
        #3 bus_in = 6'b0;
        repeat (6) begin
            #10 user_push = ~user_push;
            #10 user_push = ~user_push;
            bus_in = bus_in + 1;
        end
        repeat (2) begin
            #10 user_pop = ~user_pop;
            #10 user_pop = ~user_pop;
        end
        repeat (4) begin
            #10 user_push = ~user_push;
            #10 user_push = ~user_push;
            bus_in = bus_in + 1;
        end
        repeat (4) begin
            #10 user_pop = ~user_pop;
            #10 user_pop = ~user_pop;
        end
        #20 $stop;

        
    end
endmodule