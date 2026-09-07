`timescale 1 ns/1 ns

module lab1_zw_tb ();

    logic [3:0] s;
    logic [2:0] led;
    logic [6:0] seg;
    int         errors;

    lab1_zw dut (
        .s(s),
        .led(led),
        .seg(seg)
    );

    function automatic logic expected_led0(input logic [1:0] val);
        unique case (val)
            2'b00: expected_led0 = 0;
            2'b01: expected_led0 = 1;
            2'b10: expected_led0 = 1;
            2'b11: expected_led0 = 0;
        endcase
    endfunction

    function automatic logic expected_led1(input logic [1:0] val);
        unique case (val)
            2'b00: expected_led1 = 0;
            2'b01: expected_led1 = 0;
            2'b10: expected_led1 = 0;
            2'b11: expected_led1 = 1;
        endcase
    endfunction

    initial begin
        errors = 0;

        for (int i = 0; i < 16; i++) begin
            s = i;
            #10;

            assert (led[0] == expected_led0(s[1:0])) else begin
                errors++;
                $error("s=%h: expected led0=%b, got led0=%b", s, expected_led0(s[1:0]), led[0]);
            end

            assert (led[1] == expected_led1(s[3:2])) else begin
                errors++;
                $error("s=%h: expected led1=%b, got led1=%b", s, expected_led1(s[3:2]), led[1]);
            end

            assert (led[2] == (dut.cnt_q < 24'd10_000_000)) else begin
                errors++;
                $error("s=%h: expected led2=%b, got led2=%b", s, (dut.cnt_q < 24'd10_000_000), led[2]);
            end
        end

        s = 4'h0;
        #10;
        assert (seg == 7'b1000000) else begin
            errors++;
            $error("s=%h: expected seg=%b, got seg=%b", s, 7'b1000000, seg);
        end

        s = 4'hA;
        #10;
        assert (seg == 7'b0001000) else begin
            errors++;
            $error("s=%h: expected seg=%b, got seg=%b", s, 7'b0001000, seg);
        end

        s = 4'hF;
        #10;
        assert (seg == 7'b0001110) else begin
            errors++;
            $error("s=%h: expected seg=%b, got seg=%b", s, 7'b0001110, seg);
        end

        fork
            begin
                @(posedge dut.int_osc);
                $display("PASSED! HSOSC produced a rising edge at time: %0t.", $time);
            end
            begin
                #1000;
                errors++;
                $error("FAILED! HSOSC never toggled within 1000 ns.");
            end
        join_any
        disable fork;

        if (errors == 0) $display("ALL TOP-LEVEL CASES PASSED");
        else             $display("%0d TOP-LEVEL CASE(S) FAILED", errors);

        $stop;
    end

endmodule
