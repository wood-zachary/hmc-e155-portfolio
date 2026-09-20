`timescale 1 ns/1 ns

module debouncer_tb();

    logic clk;
    logic rst;
    logic btn_in;
    logic btn_out;

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

    end

endmodule
