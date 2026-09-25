`timescale 1 ns/1 ns

module debouncer_tb();

    logic clk;
    logic rst;
    logic btn_in;
    logic btn_out;
    int   errors;

    debouncer dut (
        .clk(clk),
        .rst(rst),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        errors = 0;
        rst = 1;
        btn_in = 1;

        // Verify reset forces the idle (not pressed, active low) state
        #12;
        assert (btn_out == 1'b1 && dut.state == dut.IDLE)
            $display("PASSED! btn_out idles high out of reset at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! btn_out=%b, state=%s out of reset at time: %0t.",
                   btn_out, dut.state.name(), $time);
        end
        rst = 0;

        // Verify a press (btn_in low) moves IDLE -> WAIT
        @(negedge clk);
        btn_in = 0;
        @(posedge clk);
        #1;
        assert (dut.state == dut.WAIT && btn_out == 1'b1)
            $display("PASSED! btn_in low moves IDLE -> WAIT, not yet PASSED at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, btn_out=%b after btn_in fell at time: %0t.",
                   dut.state.name(), btn_out, $time);
        end

        // Verify a bounce (btn_in returns high before confirmation) aborts
        // back to IDLE, discarding whatever progress had accumulated
        force dut.db_counter.count = 20'd524_287;  // 2^19 - 1
        @(negedge clk);
        btn_in = 1;
        @(posedge clk);
        #1;
        assert (dut.state == dut.IDLE && btn_out == 1'b1)
            $display("PASSED! a bounce before confirmation returns to IDLE at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, btn_out=%b after a bounce at time: %0t.",
                   dut.state.name(), btn_out, $time);
        end
        release dut.db_counter.count;

        // Verify the debounce counter reset to 0.
        // force/release only overrides the register's value, so we must wait a cycle for the cont to reset from it.
        @(posedge clk);
        #1;
        assert (dut.db_count == 20'd0)
            $display("PASSED! debounce counter resets to 0 back in IDLE at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! db_count=%0d back in IDLE at time: %0t.", dut.db_count, $time);
        end

        // Verify a press held just below the debounce threshold is still in WAIT
        @(negedge clk);
        btn_in = 0;
        @(posedge clk);
        force dut.db_counter.count = 20'd524_287;  // 2^19 - 1
        #1;
        assert (dut.state == dut.WAIT && btn_out == 1'b1)
            $display("PASSED! still in WAIT just below the debounce threshold at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, btn_out=%b just below threshold at time: %0t.",
                   dut.state.name(), btn_out, $time);
        end

        // Verify the press confirms right at the debounce threshold
        force dut.db_counter.count = 20'd524_288;  // 2^19
        @(posedge clk);
        #1;
        assert (dut.state == dut.PRESSED && btn_out == 1'b0)
            $display("PASSED! confirmed PRESSED at the debounce threshold at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, btn_out=%b at the debounce threshold at time: %0t.",
                   dut.state.name(), btn_out, $time);
        end
        release dut.db_counter.count;

        // Verify holding the button keeps it PRESSED
        repeat (3) @(posedge clk);
        #1;
        assert (dut.state == dut.PRESSED && btn_out == 1'b0)
            $display("PASSED! stays PRESSED while btn_in is held low at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, btn_out=%b while held at time: %0t.",
                   dut.state.name(), btn_out, $time);
        end

        // Verify release is immediate
        @(negedge clk);
        btn_in = 1;
        @(posedge clk);
        #1;
        assert (dut.state == dut.IDLE && btn_out == 1'b1)
            $display("PASSED! release returns to IDLE immediately at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, btn_out=%b immediately after release at time: %0t.",
                   dut.state.name(), btn_out, $time);
        end

        // Verify the default case recovers from an unreachable state encoding back to IDLE (no implied latch!)
        force dut.state = 2'b11;
        #1;
        assert (dut.nextState == dut.IDLE)
            $display("PASSED! the default case recovers from an unreachable encoding at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! nextState=%s for an unreachable state encoding at time: %0t.",
                   dut.nextState.name(), $time);
        end
        release dut.state;
        @(negedge clk);
        btn_in = 1;

        // Verify async reset recovers works while in PRESSED
        @(negedge clk);
        btn_in = 0;
        force dut.db_counter.count = 20'd524_288;
        @(posedge clk);
        #1;
        rst = 1;
        #1;
        assert (dut.state == dut.IDLE && btn_out == 1'b1)
            $display("PASSED! async reset forces IDLE while PRESSED at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! state=%s, btn_out=%b after async reset while PRESSED at time: %0t.",
                   dut.state.name(), btn_out, $time);
        end
        rst = 0;
        release dut.db_counter.count;

        if (errors == 0) $display("ALL DEBOUNCER TESTS PASSED");
        else             $display("%0d DEBOUNCER TEST(S) FAILED", errors);

        $stop;
    end

endmodule
