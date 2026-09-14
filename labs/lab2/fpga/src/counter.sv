module counter #(
    parameter int N = 32,
    parameter logic [N-1:0] MAX = '1
    ) (
    input logic clk,
    input logic rst,
    input logic en,

    output logic [N-1:0] count
);

    always_ff @(posedge clk, posedge rst)
        if (rst) count <= 0;
        else if (en) begin
            if (count >= MAX) count <= 0;
            else count <= count + 1;
        end

endmodule
