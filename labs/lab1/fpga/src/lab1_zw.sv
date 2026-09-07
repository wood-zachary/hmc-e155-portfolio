module lab1_zw(
	input logic	[3:0] s,  // the four DIP switches (on the board, SW6)

	output logic [2:0] led,  // three on-board LEDs
	output logic [6:0] seg  // the segments of a common-anode 7-segment display
);

	// Counter logic for led[2]'s 4.8 Hz clock
	logic [24:0] cnt_q;
	assign cnt_en = 1'b1;
	assign cnt_rst = 1'b0;

	// Internal high-speed oscillator logic
	logic int_osc;

	// Internal high-speed oscillator generating a 48 MHz clock
	HSOSC hf_osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(int_osc)
	);

	// Counter used to achieve 2.4 Hz clock
	counter #(.N(25), .MAX(25'd19_999_999)) cnt (
		.clk(int_osc),
		.rst(cnt_rst),
		.en(cnt_en),
		.q(cnt_q)
	);

	// Decoder for the seven segment display
	seven_seg_decoder sev_seg_dec (
		.s(s),
		.seg(seg)
	);

	// Switch-to-LED logic
	assign led[0] = s[0] ^ s[1];
	assign led[1] = s[2] & s[3];
	assign led[2] = (cnt_q < 24'd10_000_000);

endmodule
