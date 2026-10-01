module eight_queen_testbench ();
    reg clk,
        start, 
        user_reset;
    wire [7:0] out_bus;
    
    wire
        ready,
        done;

    eight_queen eq (
        .clk(clk),
        .start(start),
        .user_reset(user_reset),
        .ready(ready),
        .done(done),
        .out_bus(out_bus)
    );

    // Clock signal with 10ns period.
    initial begin
        clk = 1;
        forever #(10 / 2) clk = ~clk;
    end

    initial begin
        user_reset = 0;
        # 50;
        user_reset = 1;
        # 50;
        user_reset = 0;
        # 50;

        start = 1;
    end

    always @(posedge clk) begin
        if (done == 1) begin
            #100;
            $display("Simulation stopped at time %0t because DONE signal is high.", $time);
            $stop; // or use $finish if you want to end the simulation
        end
    end
endmodule