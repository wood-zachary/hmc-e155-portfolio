module lab1_zw(
	input logic	[3:0] s,  // the four DIP switches (on the board, SW6)

	output logic [2:0] led,  // three on-board LEDs
	output logic [6:0] seg  // the segments of a common-anode 7-segment display
);

	// Counter logic for led[2]'s 4.8 Hz clock
	logic [31:0] cnt_q;
	logic [31:0] cnt_max = 32'd9999999;  // overflow rate = 48e6/10e6 = 4.8 Hz
	logic cnt_en;

	// Internal high-speed oscillator logic
	logic int_osc;

	// Internal high-speed oscillator generating a 48 MHz clock
	HSOSC hf_osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(int_osc)
	);

	// Counter used to achieve 2.4 Hz clock
	counter cnt (
		.clk(int_osc),
		.rst(rst),
		.en(cnt_en),
		.q(cnt_q)
	);

	// Decoder for the seven segment display
	seven_seg_decoder sev_seg_dec (
		.whatever()
	);

	// switch logic


endmodule
