module stacked_eight_queen_testbench ();
    reg clk,
        start, 
        user_reset;
    wire [7:0] out_bus;
    
    wire
        ready,
        done,
        no_answer;

    stacked_eight_queen eq (
        .clk(clk),
        .start(start),
        .user_reset(user_reset),
        .ready(ready),
        .done(done),
        .no_answer(no_answer),
        .out_bus(out_bus)
    );

    // Clock signal with 10ns period.
    initial begin
        clk = 1;
        forever #(10 / 2) clk = ~clk;
    end

    initial begin
        user_reset = 0;
        # 50 user_reset = 1;
        # 50 user_reset = 0;
        # 50;
        start = 1;
        #200 start = 0;
        
        #100000 start = 1;
        #50 start = 0;
    end

    always @(posedge clk) begin
        if (done == 1) begin
            #200;
            $stop; 
        end
    end
endmodule