`timescale 1 ns/1 ns

module synchronizer_tb();

    logic clk;
    logic rst;
    logic data_in;
    logic data_out;

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

    end

endmodule
