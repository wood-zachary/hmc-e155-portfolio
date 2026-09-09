module accumulator #(
    parameter int N = 32,
    parameter logic [N-1:0] MAX = '1
    ) (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [N-1:0] p,

    output logic [N-1:0] q
);

    always_ff @(posedge clk, posedge rst)
		if (rst) q <= 0;
		else if (en) begin
            if (q + p > MAX) q <= q + p - MAX - 1;
            else q <= q + p;
        end

endmodule
