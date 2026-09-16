module keypad_scanner(
	input logic clk,
	input logic rst,
	input logic en,

	output logic [3:0] kp_row
);

	logic [24:0] scan_count;

	// Cycle through all rows at 2 Hz
	counter #(.WIDTH(25), .MAX(25'd23_999_999)) scan_cnt (
		.clk(clk),
		.rst(rst),
		.en(en),
		.count(scan_count)
	);

	assign kp_row = (scan_count < 25'd6_000_000)  ? 4'b1000 :
	                (scan_count < 25'd12_000_000) ? 4'b0100 :
	                (scan_count < 25'd18_000_000) ? 4'b0010 :
	                                                 4'b0001;

endmodule
