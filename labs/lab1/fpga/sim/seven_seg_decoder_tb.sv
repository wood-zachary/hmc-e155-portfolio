`timescale 1 ns/1 ns

module seven_seg_decoder_tb ();

    logic [3:0] s;
    logic [6:0] seg;
    int         errors;

    seven_seg_decoder dut (
        .s(s),
        .seg(seg)
    );

    function automatic logic [6:0] expected_seg(input logic [3:0] val);
        unique case (val)
            4'h0: expected_seg = 7'b1000000;  // 0
            4'h1: expected_seg = 7'b1111001;  // 1
            4'h2: expected_seg = 7'b0100100;  // 2
            4'h3: expected_seg = 7'b0110000;  // 3
            4'h4: expected_seg = 7'b0011001;  // 4
            4'h5: expected_seg = 7'b0010010;  // 5
            4'h6: expected_seg = 7'b0000010;  // 6
            4'h7: expected_seg = 7'b1111000;  // 7
            4'h8: expected_seg = 7'b0000000;  // 8
            4'h9: expected_seg = 7'b0010000;  // 9
            4'hA: expected_seg = 7'b0001000;  // A
            4'hB: expected_seg = 7'b0000011;  // b
            4'hC: expected_seg = 7'b1000110;  // C
            4'hD: expected_seg = 7'b0100001;  // d
            4'hE: expected_seg = 7'b0000110;  // E
            4'hF: expected_seg = 7'b0001110;  // F
        endcase
    endfunction

    initial begin
        errors = 0;

        for (int i = 0; i < 16; i++) begin
            s = i;
            #10;

            assert (seg == expected_seg(s)) else begin
                errors++;
                $error("s=%h: expected seg=%b, got seg=%b", s, expected_seg(s), seg);
            end
        end

        if (errors == 0) $display("ALL 16 CASES PASSED");
        else             $display("%0d CASE(S) FAILED", errors);

        $stop;
    end

endmodule
