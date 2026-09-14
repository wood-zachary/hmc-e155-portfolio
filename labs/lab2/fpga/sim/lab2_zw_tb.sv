`timescale 1 ns/1 ns

module lab2_zw_tb ();

    logic       rst_n;
    logic [7:0] s;
    logic [3:0] kp_col;
    logic [3:0] led;
    logic [6:0] seg;
    logic [1:0] an_en;
    logic [3:0] kp_row;
    int         errors;

    lab2_zw dut (
        .rst_n(rst_n),
        .s(s),
        .kp_col(kp_col),
        .led(led),
        .seg(seg),
        .an_en(an_en),
        .kp_row(kp_row)
    );

    initial begin
        errors = 0;

        rst_n  = 0;
        s      = 8'h00;
        kp_col = 4'hF;
        #10;
        rst_n = 1;

        // Verify digit 1 (s[7:4]) is active immediately out of reset
        s = 8'hA5;  // digit 0 = 5, digit 1 = A
        #1;
        assert (dut.digit_data == s[7:4])
            $display("PASSED! Digit 1 selected out of reset at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit_data=%h out of reset at time: %0t.", dut.digit_data, $time);
        end

        assert (dut.an_en == 2'b01)
            $display("PASSED! Digit 1's anode enabled out of reset at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! an_en=%b out of reset at time: %0t.", dut.an_en, $time);
        end

        assert (seg == 7'b0001000)  // seven_seg_decoder(4'hA)
            $display("PASSED! seg reflects digit 1's value at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! seg=%b, expected digit 1's value at time: %0t.", seg, $time);
        end

        // Verify the multiplexing counter swaps to digit 0 (s[3:0])
        repeat (24_000) @(posedge dut.int_osc);
        #1;
        assert (dut.digit_data == s[3:0])
            $display("PASSED! Digit 0 selected after the mux swap at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit_data=%h after the mux swap at time: %0t.", dut.digit_data, $time);
        end

        assert (dut.an_en == 2'b10)
            $display("PASSED! Digit 0's anode enabled after the mux swap at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! an_en=%b after the mux swap at time: %0t.", dut.an_en, $time);
        end

        assert (seg == 7'b0010010)  // seven_seg_decoder(4'h5)
            $display("PASSED! seg reflects digit 0's value at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! seg=%b, expected digit 0's value at time: %0t.", seg, $time);
        end

        // Verify the mux counter wraps and returns to digit 1
        repeat (24_000) @(posedge dut.int_osc);
        #1;
        assert (dut.digit_data == s[7:4])
            $display("PASSED! Digit 1 selected again after the mux wraps at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit_data=%h after the mux wraps at time: %0t.", dut.digit_data, $time);
        end

        // Verify LED driving: idle, single presses, and multiple simultaneous presses
        kp_col = 4'b1111;  // nothing pressed
        #1;
        assert (led == 4'b0000)
            $display("PASSED! led idle with kp_col=%b at time: %0t.", kp_col, $time);
        else begin
            errors++;
            $error("FAILED! led=%b with kp_col=%b at time: %0t.", led, kp_col, $time);
        end

        for (int i = 0; i < 4; i++) begin
            kp_col = ~(4'b0001 << i);  // single key pressed in column i
            #1;
            assert (led == (4'b0001 << i))
                $display("PASSED! led=%b with kp_col=%b at time: %0t.", led, kp_col, $time);
            else begin
                errors++;
                $error("FAILED! led=%b with kp_col=%b at time: %0t.", led, kp_col, $time);
            end
        end

        kp_col = 4'b0101;  // two simultaneous presses, columns 1 and 3
        #1;
        assert (led == 4'b1010)
            $display("PASSED! led tolerates two simultaneous presses, kp_col=%b at time: %0t.", kp_col, $time);
        else begin
            errors++;
            $error("FAILED! led=%b with kp_col=%b at time: %0t.", led, kp_col, $time);
        end

        if (errors == 0) $display("ALL LAB2_ZW TESTS PASSED");
        else             $display("%0d LAB2_ZW TEST(S) FAILED", errors);

        $stop;
    end

endmodule
