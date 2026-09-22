`timescale 1 ns/1 ns

module synchronizer_tb();

    logic clk;
    logic rst;
    logic data_in;
    logic data_out;
    int   errors;

    synchronizer dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out)
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
        data_in = 1;

        // Verify reset forces data_out to INIT_VAL (0)
        #12;
        assert (data_out == 1'b0)
            $display("PASSED! data_out holds INIT_VAL out of reset at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b out of reset at time: %0t.", data_out, $time);
        end
        rst = 0;
        data_in = 0;
        @(negedge clk);

        // Verify a rising data_in has not reached data_out after only 1 cycle
        data_in = 1;
        @(posedge clk);
        #1;
        assert (data_out == 1'b0)
            $display("PASSED! data_out still low 1 cycle after data_in rises at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b 1 cycle after data_in rises at time: %0t.", data_out, $time);
        end

        // Verify data_out rises after the 2nd stage, 2 cycles total
        @(posedge clk);
        #1;
        assert (data_out == 1'b1)
            $display("PASSED! data_out rises 2 cycles after data_in at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b 2 cycles after data_in rises at time: %0t.", data_out, $time);
        end

        // Verify a falling data_in also takes exactly 2 cycles to propagate
        @(negedge clk);
        data_in = 0;
        @(posedge clk);
        #1;
        assert (data_out == 1'b1)
            $display("PASSED! data_out still high 1 cycle after data_in falls at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b 1 cycle after data_in falls at time: %0t.", data_out, $time);
        end

        @(posedge clk);
        #1;
        assert (data_out == 1'b0)
            $display("PASSED! data_out falls 2 cycles after data_in at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b 2 cycles after data_in falls at time: %0t.", data_out, $time);
        end

        // Verify a change scheduled right on top of a clock edge
        // still resolves to a deterministic 2-cycle latency
        @(posedge clk);
        data_in <= 1'b1;
        @(posedge clk);
        #1;
        assert (data_out == 1'b0)
            $display("PASSED! data_out unaffected 1 cycle after an edge-aligned change at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b 1 cycle after an edge-aligned change at time: %0t.", data_out, $time);
        end

        @(posedge clk);
        #1;
        assert (data_out == 1'b1)
            $display("PASSED! data_out reflects an edge-aligned change after 2 cycles at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b 2 cycles after an edge-aligned change at time: %0t.", data_out, $time);
        end

        // Verify a change at an arbitrary, non-edge-aligned input still resolves the same way
        #3 data_in = 0;
        @(posedge clk);
        @(posedge clk);
        #1;
        assert (data_out == 1'b0)
            $display("PASSED! an asynchronous, non-edge-aligned change resolves correctly at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b after a non-edge-aligned change at time: %0t.", data_out, $time);
        end

        // Verify async reset overrides the synchronizer mid-shift
        data_in = 1;
        @(negedge clk);
        rst = 1;
        #1;
        assert (data_out == 1'b0)
            $display("PASSED! async reset immediately clears data_out at time: %0t.", $time);
        else begin
            errors++;
            $error("FAILED! data_out=%b immediately after async reset at time: %0t.", data_out, $time);
        end
        rst = 0;

        if (errors == 0) $display("ALL SYNCHRONIZER TESTS PASSED");
        else             $display("%0d SYNCHRONIZER TEST(S) FAILED", errors);

        $stop;
    end

endmodule
