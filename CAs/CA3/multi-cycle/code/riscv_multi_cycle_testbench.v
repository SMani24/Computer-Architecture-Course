module riscv_multi_cycle_testbench();
    reg clk,
        reset;
    riscv_multi_cycle rsc (
        clk,
        reset
    );

    // Clock signal with 10ns period.
    initial begin
        clk = 1;
        forever #(10 / 2) clk = ~clk;
    end

    initial begin
        reset = 0;
        # 50 reset = 1;
        # 50 reset = 0;
        # 50;
        #4500;
        $stop;
    end
endmodule