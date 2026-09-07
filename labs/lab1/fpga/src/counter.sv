module counter #(
    parameter int N = 32,
    parameter logic [N-1:0] MAX = '1
    ) (
    input logic clk,
    input logic rst,
    input logic en,

    output logic [N-1:0] q
);

    always_ff @(posedge clk, posedge rst)
        if (rst) q <= 0;
        else if (en) begin
            if (q >= MAX) q <= 0;
            else q <= q + 1;
        end

endmodule
