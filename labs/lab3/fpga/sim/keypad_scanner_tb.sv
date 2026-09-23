`timescale 1 ns/1 ns

module keypad_scanner_tb();

    logic       clk;
    logic       rst;
    logic [3:0] kp_col;
    logic [3:0] kp_row;
    logic [3:0] digit0;
    logic [3:0] digit1;
    int         errors;

    localparam logic [24:0] ROW_CNT [4] =
        '{25'd0, 25'd6_000_000, 25'd12_000_000, 25'd18_000_000};
    localparam logic [3:0] EXPECTED_KEY [4][4] = '{
        '{4'h1, 4'h2, 4'h3, 4'hA},
        '{4'h4, 4'h5, 4'h6, 4'hB},
        '{4'h7, 4'h8, 4'h9, 4'hC},
        '{4'hF, 4'h0, 4'hE, 4'hD}
    };

    keypad_scanner dut (
        .clk(clk),
        .rst(rst),
        .kp_col(kp_col),
        .kp_row(kp_row),
        .digit0(digit0),
        .digit1(digit1)
    );

    // Model of the physical keypad. kp_col is not driven directly since in the
    // real hardware a column only reads active while its row is being
    // scanned, so kp_col has to be derived from kp_row (a DUT output)
    // and which keys a finger is actually holding.
    // key_down[row][col] uses the same left-to-right indexing as EXPECTED_KEY above.
    logic key_down [4][4];
    logic [24:0] row_cnt_val;

    assign kp_col[3] = ~((kp_row[0] & key_down[0][0]) | (kp_row[1] & key_down[1][0]) |
                          (kp_row[2] & key_down[2][0]) | (kp_row[3] & key_down[3][0]));
    assign kp_col[2] = ~((kp_row[0] & key_down[0][1]) | (kp_row[1] & key_down[1][1]) |
                          (kp_row[2] & key_down[2][1]) | (kp_row[3] & key_down[3][1]));
    assign kp_col[1] = ~((kp_row[0] & key_down[0][2]) | (kp_row[1] & key_down[1][2]) |
                          (kp_row[2] & key_down[2][2]) | (kp_row[3] & key_down[3][2]));
    assign kp_col[0] = ~((kp_row[0] & key_down[0][3]) | (kp_row[1] & key_down[1][3]) |
                          (kp_row[2] & key_down[2][3]) | (kp_row[3] & key_down[3][3]));

    // SytemVerilog has two callable subroutines: function and task.
    // function must return a value and cannot contain any timing control like # or @
    // task can contain timing control and doesn't have to return a value
    // While these don't have delays, the action should technically take time, so I used task.
    task automatic press(input int r, input int c);
        key_down[r][c] = 1'b1;
    endtask

    task automatic lift(input int r, input int c);
        key_down[r][c] = 1'b0;
    endtask

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        errors = 0;
        rst = 1;
        for (int r = 0; r < 4; r++) begin
            for (int c = 0; c < 4; c++) begin
                key_down[r][c] = 1'b0;
            end
        end

        // Verify reset defaults
        #12;
        assert (kp_row == 4'b1000 && digit0 == 4'h0 && digit1 == 4'h0 &&
                dut.state == dut.SCAN)
            $display("PASSED! kp_row/digit0/digit1 hold reset defaults at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b, digit0=%h, digit1=%h out of reset at time: %0t.",
                   kp_row, digit0, digit1, $time);
        end
        rst = 0;

        // Verify all four row-scan boundaries, same as lab2
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
        @(posedge clk);
        #1;
        assert (kp_row == 4'b1000)
            $display("PASSED! kp_row wraps back to row 0 on its own at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b after wrapping at time: %0t.", kp_row, $time);
        end

        for (int r = 0; r < 4; r++) begin
            row_cnt_val = ROW_CNT[r];
            force dut.scan_cnt.count = row_cnt_val;
            // Verify the full {row, col} -> hex decode table combinationally.
            // The row is forced exactly one physical key is held at a time, so
            // kp_col is always a value the real keypad could actually produce.
            for (int c = 0; c < 4; c++) begin
                press(r, c);
                #1;
                assert (dut.key == EXPECTED_KEY[r][c])
                    $display("PASSED! decode row=%0d col=%0d -> key=%h at time: %0t.",
                             r, c, dut.key, $time);
                else begin
                    errors++;
                    $error("FAILED! decode row=%0d col=%0d gave key=%h, expected %h at time: %0t.",
                           r, c, dut.key, EXPECTED_KEY[r][c], $time);
                end
                lift(r, c);
            end

            // Verify an idle read and an ambiguous multi-press both result in the default decode
            #1;
            assert (dut.key == 4'h0)
                $display("PASSED! idle kp_col defaults to key=0 at time: %0t.", $time);
            else begin
                errors++;
                $error("FAILED! idle kp_col decoded key=%h at time: %0t.", dut.key, $time);
            end

            press(r, 0);
            press(r, 1);
            #1;
            assert (dut.key == 4'h0)
                $display("PASSED! an ambiguous 2-key read defaults to key=0 at time: %0t.", $time);
            else begin
                errors++;
                $error("FAILED! ambiguous kp_col decoded key=%h at time: %0t.", dut.key, $time);
            end
            lift(r, 0);
            lift(r, 1);
        end
        release dut.scan_cnt.count;

        // Reset before verifying the actual FSM
        rst = 1;
        #12;
        rst = 0;

        // Verify a clean single press captures digit0 and leaves digit1 untouched
        // 2 cycles after the key resolves (SCAN -> PRESS -> HOLD).
        @(negedge clk);
        press(0, 0);  // key "1"
        @(posedge clk);
        @(posedge clk);
        #1;
        assert (dut.state == dut.HOLD && digit0 == 4'h1 && digit1 == 4'h0)
            $display("PASSED! a single clean press captures digit0=1, digit1=0 at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, digit0=%h, digit1=%h after pressing 1 at time: %0t.",
                   dut.state.name(), digit0, digit1, $time);
        end

        // Verify a long hold registers exactly once: kp_row/scan_count
        // stay frozen and digit0 never changes again across hundreds of cycles
        repeat (200) @(posedge clk);
        #1;
        assert (kp_row == 4'b1000 && dut.scan_count == 25'd0 &&
                digit0 == 4'h1 && digit1 == 4'h0)
            $display("PASSED! a 200-cycle hold still registers key 1 exactly once at time: %0t.",
                      $time);
        else begin
            errors++;
            $error("FAILED! kp_row=%b, scan_count=%0d, digit0=%h drifted while held at time: %0t.",
                   kp_row, dut.scan_count, digit0, $time);
        end

        // Release, then press a second key: verify digit0/digit1 shift
        @(negedge clk);
        lift(0, 0);
        @(posedge clk);
        #1;
        assert (dut.state == dut.SCAN)
            $display("PASSED! releasing returns to SCAN at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s after releasing at time: %0t.", dut.state.name(), $time);
        end

        @(negedge clk);
        press(0, 1);  // key "2"
        @(posedge clk);
        @(posedge clk);
        #1;
        assert (digit0 == 4'h2 && digit1 == 4'h1)
            $display("PASSED! a second press shifts digit0=2, digit1=1 at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit0=%h, digit1=%h after a second press at time: %0t.",
                   digit0, digit1, $time);
        end

        // Verify two keys pressed simultaneously in the same row freeze in
        // SCAN (any_key true, ambiguous, nothing committed yet) with no capture
        @(negedge clk);
        lift(0, 1);
        @(posedge clk);
        @(negedge clk);
        press(0, 0);  // keys "1" and "2" together
        press(0, 1);
        @(posedge clk);
        #1;
        assert (dut.state == dut.SCAN && dut.any_key && digit0 == 4'h2 && digit1 == 4'h1)
            $display("PASSED! simultaneous presses freeze in SCAN with no capture at time: %0t.",
                      $time);
        else begin
            errors++;
            $error("FAILED! state=%s, any_key=%b, digit0=%h after simultaneous presses at time: %0t.",
                   dut.state.name(), dut.any_key, digit0, $time);
        end

        // Verify releasing all but one registers the last held key
        @(negedge clk);
        lift(0, 0);  // release "1", keep "2" held
        @(posedge clk);
        @(posedge clk);
        #1;
        assert (dut.state == dut.HOLD && digit0 == 4'h2 && digit1 == 4'h2)
            $display("PASSED! releasing to one held key registers it, digit0=2 at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, digit0=%h, digit1=%h after resolving to one key at time: %0t.",
                   dut.state.name(), digit0, digit1, $time);
        end

        // Verify adding a second key while one is already held is ignored
        @(negedge clk);
        lift(0, 1);
        @(posedge clk);
        @(negedge clk);
        press(0, 2);  // key "3"
        @(posedge clk);
        @(posedge clk);
        #1;
        assert (digit0 == 4'h3 && dut.state == dut.HOLD)
            $display("PASSED! key 3 captured cleanly before the add-on test at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit0=%h, state=%s before the add-on test at time: %0t.",
                   digit0, dut.state.name(), $time);
        end

        @(negedge clk);
        press(0, 3);  // add key "A" while "3" is held
        @(posedge clk);
        #1;
        assert (dut.state == dut.HOLD && digit0 == 4'h3)
            $display("PASSED! adding a second key while holding one is ignored at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, digit0=%h after adding a second key at time: %0t.",
                   dut.state.name(), digit0, $time);
        end

        // Verify releasing the newly added key, leaving the original still held, doesn't re-capture it.
        // "the only way to register the same button twice is to lift off and press it again"
        @(negedge clk);
        lift(0, 3);  // release "A", keep "3" held
        @(posedge clk);
        #1;
        assert (dut.state == dut.HOLD && digit0 == 4'h3 && digit1 == 4'h2)
            $display("PASSED! releasing the added key does not re-capture the original at time: %0t.",
                      $time);
        else begin
            errors++;
            $error("FAILED! state=%s, digit0=%h, digit1=%h after releasing the added key at time: %0t.",
                   dut.state.name(), digit0, digit1, $time);
        end

        // Re-add "A" the same way, then verify releasing the original key
        // this time, leaving the newly added one, registers it
        @(negedge clk);
        press(0, 3);  // add key "A" again while "3" is held
        @(posedge clk);
        #1;
        assert (dut.state == dut.HOLD && digit0 == 4'h3)
            $display("PASSED! re-added key A ahead of the original-release test at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, digit0=%h ahead of the original-release test at time: %0t.",
                   dut.state.name(), digit0, $time);
        end

        @(negedge clk);
        lift(0, 2);  // release "3", keep "A" held
        @(posedge clk);
        @(posedge clk);
        #1;
        assert (dut.state == dut.HOLD && digit0 == 4'hA && digit1 == 4'h3)
            $display("PASSED! releasing the original key registers the added one at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, digit0=%h, digit1=%h after the sequential-add release at time: %0t.",
                   dut.state.name(), digit0, digit1, $time);
        end

        // Verify releasing every key at once from a multi-press, without
        // ever resolving to a single key, captures nothing
        @(negedge clk);
        lift(0, 3);
        @(posedge clk);
        @(negedge clk);
        press(0, 0);  // keys "1" and "A" together
        press(0, 3);
        @(posedge clk);
        #1;
        assert (dut.state == dut.SCAN && dut.any_key)
            $display("PASSED! frozen in SCAN, ambiguous, ahead of the drop-both test at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, any_key=%b ahead of the drop-both test at time: %0t.",
                   dut.state.name(), dut.any_key, $time);
        end

        @(negedge clk);
        lift(0, 0);  // release both at once
        lift(0, 3);
        @(posedge clk);
        #1;
        assert (dut.state == dut.SCAN && digit0 == 4'hA && digit1 == 4'h3)
            $display("PASSED! dropping both at once returns to SCAN with no misfire at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, digit0=%h after dropping both at time: %0t.",
                   dut.state.name(), digit0, $time);
        end

        // Verify normal operation resumes correctly afterward
        @(negedge clk);
        press(0, 0);  // key "1"
        @(posedge clk);
        @(posedge clk);
        #1;
        assert (digit0 == 4'h1 && digit1 == 4'hA)
            $display("PASSED! normal single-key capture resumes cleanly at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! digit0=%h, digit1=%h resuming after a multi-press episode at time: %0t.",
                   digit0, digit1, $time);
        end

        // Verify async reset works while a key is currently pressed
        rst = 1;
        #1;
        assert (dut.state == dut.SCAN && kp_row == 4'b1000 &&
                digit0 == 4'h0 && digit1 == 4'h0)
            $display("PASSED! async reset forces SCAN and clears digits at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, kp_row=%b, digit0=%h, digit1=%h after async reset at time: %0t.",
                   dut.state.name(), kp_row, digit0, digit1, $time);
        end
        rst = 0;
        lift(0, 0);

        if (errors == 0) $display("ALL KEYPAD_SCANNER TESTS PASSED");
        else             $display("%0d KEYPAD_SCANNER TEST(S) FAILED", errors);

        $stop;
    end

endmodule
