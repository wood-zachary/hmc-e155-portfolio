module lab1_zw(
	input logic	[3:0] s,  // the four DIP switches (on the board, SW6)

	output logic [2:0] led,  // three on-board LEDs
	output logic [6:0] seg  // the segments of a common-anode 7-segment display
);

	// Counter logic
	// f_out = f_in * p / 2^n
	// result: 2.402812 Hz (error: +0.00281 Hz, +0.117%)
	logic [31:0] cnt_p = 32'd215;
	logic [31:0] cnt_q;
	logic cnt_en;

	// Internal high-speed oscillator logic
	logic int_osc;

	// Internal high-speed oscillator generating a 48 MHz clock
	HSOSC hf_osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(int_osc)
	);

	// Counter used to achieve a 2.4 Hz clock
	counter cnt (
		.clk(int_osc),
		.rst(rst),
		.en(en),
		.p(p),
		.q(q)
	);

	// Decoder for the seven segment display
	seven_seg_decoder sev_seg_dec (
		.whatever()
	);

	// switch logic


endmodule
