`timescale 1 ns/1 ns

module counter_tb ();

    logic       clk;
    logic       rst;
    logic       en;
    logic [2:0] q;
    int         errors;

    counter #(.N(3), .MAX(3'b100)) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        errors = 0;

        rst = 1;
        #22 rst = 0;

        // Verify enable
        en = 0;
        @(posedge clk);
        #1;
        assert (q == 3'b000)
            $display("PASSED! The counter behaves as desired at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! The counter behaves incorrectly at time: %0t.", $time);
        end

        en = 1;
        @(posedge clk);
        #1;
        assert (q == 3'b001)
            $display("PASSED! The counter behaves as desired at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! The counter behaves incorrectly at time: %0t.", $time);
        end

        // Verify async reset
        rst = 1;
        #1;
        assert (q == 3'b000)
            $display("PASSED! The counter behaves as desired at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! The counter behaves incorrectly at time: %0t.", $time);
        end

        @(posedge clk);
        #1;
        assert (q == 3'b000)
            $display("PASSED! The counter behaves as desired at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! The counter behaves incorrectly at time: %0t.", $time);
        end

        rst = 0;

        // Verify max count
        repeat (dut.MAX) @(posedge clk);
        #1;
        assert (q == dut.MAX)
            $display("PASSED! The counter behaves as desired at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! The counter behaves incorrectly at time: %0t.", $time);
        end

        @(posedge clk);  // one more edge should wrap back to 0
        #1;
        assert (q == 3'b000)
            $display("PASSED! The counter behaves as desired at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! The counter behaves incorrectly at time: %0t.", $time);
        end

        if (errors == 0) $display("ALL COUNTER TESTS PASSED");
        else             $display("%0d COUNTER TEST(S) FAILED", errors);

        $stop;

    end

endmodule
