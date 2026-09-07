module counter #(parameter int N = 32) (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [N-1:0] p,

    output logic [N-1:0] q
);

    always_ff @(posedge clk, posedge rst)
		if (rst) q <= 0;
		else if (en) q <= q + p;

endmodule
