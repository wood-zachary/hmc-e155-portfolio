`timescale 1 ns/1 ns

module keypad_scanner_tb ();

    logic       clk;
    logic       rst;
    logic       en;
    logic [3:0] kp_row;
    int         errors;

    keypad_scanner dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .kp_row(kp_row)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        errors = 0;

        // Verify reset
        rst = 1;
        en  = 0;
        #22 rst = 0;
        #1;
        assert (kp_row == 4'b1000)
            $display("PASSED! kp_row holds row 0 out of reset at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b out of reset at time: %0t.", kp_row, $time);
        end

        // Verify enable holds the counter, and kp_row, still
        repeat (5) @(posedge clk);
        #1;
        assert (kp_row == 4'b1000)
            $display("PASSED! kp_row holds row 0 while disabled at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b while disabled at time: %0t.", kp_row, $time);
        end

        en = 1;

        // Verify all four row transitions at the counter's threshold
        force dut.scan_cnt.count = 25'd5_999_999;
        #1;
        assert (kp_row == 4'b1000)
            $display("PASSED! kp_row=1000 just below the row 1 boundary at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b just below the row 1 boundary at time: %0t.", kp_row, $time);
        end

        force dut.scan_cnt.count = 25'd6_000_000;
        #1;
        assert (kp_row == 4'b0100)
            $display("PASSED! kp_row=0100 at the row 1 boundary at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b at the row 1 boundary at time: %0t.", kp_row, $time);
        end

        force dut.scan_cnt.count = 25'd11_999_999;
        #1;
        assert (kp_row == 4'b0100)
            $display("PASSED! kp_row=0100 just below the row 2 boundary at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b just below the row 2 boundary at time: %0t.", kp_row, $time);
        end

        force dut.scan_cnt.count = 25'd12_000_000;
        #1;
        assert (kp_row == 4'b0010)
            $display("PASSED! kp_row=0010 at the row 2 boundary at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b at the row 2 boundary at time: %0t.", kp_row, $time);
        end

        force dut.scan_cnt.count = 25'd17_999_999;
        #1;
        assert (kp_row == 4'b0010)
            $display("PASSED! kp_row=0010 just below the row 3 boundary at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b just below the row 3 boundary at time: %0t.", kp_row, $time);
        end

        force dut.scan_cnt.count = 25'd18_000_000;
        #1;
        assert (kp_row == 4'b0001)
            $display("PASSED! kp_row=0001 at the row 3 boundary at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b at the row 3 boundary at time: %0t.", kp_row, $time);
        end

        force dut.scan_cnt.count = 25'd23_999_999;
        #1;
        assert (kp_row == 4'b0001)
            $display("PASSED! kp_row=0001 at the counter's MAX at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b at the counter's MAX at time: %0t.", kp_row, $time);
        end

        release dut.scan_cnt.count;

        // Verify the counter wraps back to row 0 on its own
        @(posedge clk);
        #1;
        assert (kp_row == 4'b1000)
            $display("PASSED! kp_row wraps back to row 0 at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b after wrapping at time: %0t.", kp_row, $time);
        end

        // Verify async reset while counting
        repeat (3) @(posedge clk);
        rst = 1;
        #1;
        assert (kp_row == 4'b1000)
            $display("PASSED! async reset forces kp_row back to row 0 at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b after async reset at time: %0t.", kp_row, $time);
        end
        rst = 0;

        if (errors == 0) $display("ALL KEYPAD_SCANNER TESTS PASSED");
        else             $display("%0d KEYPAD_SCANNER TEST(S) FAILED", errors);

        $stop;
    end

endmodule
