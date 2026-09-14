module keypad_scanner(
	input logic clk,
	input logic rst,
	input logic en,

	output logic [3:0] kp_row
);

	// TODO: choose N and MAX so kp_row's four states rotate at 2 Hz per bit
	logic [24:0] scan_count;
	counter #(.N(25), .MAX(25'd19_999_999)) scan_cnt (
		.clk(clk),
		.rst(rst),
		.en(en),
		.count(scan_count)
	);

	// TODO: decode scan_count into 1000/0100/0010/0001

endmodule
