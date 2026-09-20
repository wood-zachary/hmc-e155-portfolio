`timescale 1 ns/1 ns

module lab3_zw_tb();

    logic       rst_n;
    logic [3:0] kp_col_async;
    logic [6:0] seg;
    logic [1:0] an_en;
    logic [3:0] kp_row;

    lab3_zw dut (
        .rst_n(rst_n),
        .kp_col_async(kp_col_async),
        .seg(seg),
        .an_en(an_en),
        .kp_row(kp_row)
    );

    initial begin
        errors = 0;

    end

endmodule
