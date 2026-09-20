`timescale 1 ns/1 ns

module keypad_scanner_tb();

    logic       clk;
    logic       rst;
    logic [3:0] kp_col;
    logic [3:0] kp_row;
    logic [3:0] digit0;
    logic [3:0] digit1;

    keypad_scanner dut (
        .clk(clk),
        .rst(rst),
        .kp_col(kp_col),
        .kp_row(kp_row),
        .digit0(digit0),
        .digit1(digit1)
    );

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        errors = 0;

    end

endmodule
