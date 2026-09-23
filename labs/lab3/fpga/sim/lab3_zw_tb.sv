`timescale 1 ns/1 ns

module lab3_zw_tb();

    logic       rst_n;
    logic [3:0] kp_col_async;
    logic [6:0] seg;
    logic [1:0] an_en;
    logic [3:0] kp_row;
    int         errors;

    lab3_zw dut (
        .rst_n(rst_n),
        .kp_col_async(kp_col_async),
        .seg(seg),
        .an_en(an_en),
        .kp_row(kp_row)
    );

    initial begin
        errors = 0;
        rst_n = 0;
        kp_col_async = 4'hF;

        // Verify reset defaults
        #100;
        assert (kp_row == 4'b1000 && an_en == 2'b01 && seg == 7'b1000000 &&
                dut.digit0 == 4'h0 && dut.digit1 == 4'h0)
            $display("PASSED! system holds reset defaults at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b, an_en=%b, seg=%b out of reset at time: %0t.",
                   kp_row, an_en, seg, $time);
        end
        rst_n = 1;

        // Verify the display mux swaps to digit 0's phase after 24,000 int_osc cycles, same as lab2
        force dut.mux_counter.count = 16'd24_000;
        #1;
        assert (an_en == 2'b10 && seg == 7'b1000000)
            $display("PASSED! mux swaps to digit 0's phase at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! an_en=%b, seg=%b after the mux swap at time: %0t.", an_en, seg, $time);
        end
        release dut.mux_counter.count;

        // Verify a realistic key press with switch bounce and arrival
        // at asynchronous positions relative to int_osc, including on a clock edge,
        // all correctly synchronized, debounced, and decoded (using key "1")
        kp_col_async[3] = 1'b0;  // first contact bounce
        #3  kp_col_async[3] = 1'b1;
        #2  kp_col_async[3] = 1'b0;
        #4  kp_col_async[3] = 1'b1;
        @(posedge dut.int_osc);
        kp_col_async[3] <= 1'b0;  // settles low right on top of a clock edge

        // Force the debounce timer for column 3 near its threshold so the
        // waveform doesn't have to show the full ~11 ms confirmation window.
        // Wait for the debouncer to confirm PRESSED to cover the sync+debounce lateny
        // and then wait the 2 edges keypad_scanner needs to capture a confirmed
        // press (SCAN -> PRESS, then PRESS -> SINGLE_HOLD with digit0 <= key).
        force dut.debounce3.db_counter.count = 20'd524_288;
        wait (dut.debounce3.state == dut.debounce3.PRESSED);
        release dut.debounce3.db_counter.count;
        repeat (2) @(posedge dut.int_osc);
        #1;
        assert (dut.digit0 == 4'h1 && dut.digit1 == 4'h0)
            $display("PASSED! a bounced, asynchronous press of key 1 decodes correctly at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit0=%h, digit1=%h after pressing key 1 at time: %0t.",
                   dut.digit0, dut.digit1, $time);
        end

        // Verify the decoded value reaches seg during digit 0's mux phase so that the full pipeline is wired together
        wait (an_en == 2'b10);
        #1;
        assert (seg == 7'b1111001)  // seven_seg_decoder(4'h1)
            $display("PASSED! seg reflects key 1 during digit 0's phase at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! seg=%b during digit 0's phase after pressing key 1 at time: %0t.",
                   seg, $time);
        end

        // Release key 1, then press key 2 (same row) to verify digit0/digit1 shift through the top level
        kp_col_async[3] = 1'b1;
        repeat (4) @(posedge dut.int_osc);

        kp_col_async[2] = 1'b0;
        force dut.debounce2.db_counter.count = 20'd524_288;
        wait (dut.debounce2.state == dut.debounce2.PRESSED);
        release dut.debounce2.db_counter.count;
        repeat (2) @(posedge dut.int_osc);
        #1;
        assert (dut.digit0 == 4'h2 && dut.digit1 == 4'h1)
            $display("PASSED! a second press shifts digit0=2, digit1=1 at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit0=%h, digit1=%h after a second press at time: %0t.",
                   dut.digit0, dut.digit1, $time);
        end

        // Verify async reset affects the whole system immediately with a key still held down
        rst_n = 0;
        #1;
        assert (kp_row == 4'b1000 && dut.digit0 == 4'h0 && dut.digit1 == 4'h0 &&
                an_en == 2'b01)
            $display("PASSED! async reset recovers the whole system at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b, digit0=%h, digit1=%h after async reset at time: %0t.",
                   kp_row, dut.digit0, dut.digit1, $time);
        end
        rst_n = 1;
        kp_col_async = 4'hF;

        if (errors == 0) $display("ALL LAB3_ZW TESTS PASSED");
        else             $display("%0d LAB3_ZW TEST(S) FAILED", errors);

        $stop;
    end

endmodule
