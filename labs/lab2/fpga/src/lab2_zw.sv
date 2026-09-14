module lab2_zw(
	input  logic 	   rst_n,	// active-low push button (internal pull-up) for reset
	input  logic [7:0] s,		// DIP switches: s[3:0] = digit 0 (on-board), s[7:4] = digit 1 (off-board)
	input  logic [3:0] kp_col,	// keypad column inputs (pulled up)

	output logic [3:0] led,		// on-board LEDs driven by scanned keypad columns
	output logic [6:0] seg,		// shared segment lines, time multiplexed
	output logic [1:0] an_en,	// anode enable outputs for time multiplexing digit
	output logic [3:0] kp_row	// asserted row to scan keypad
);

	// Internal high-speed oscillator logic
	logic int_osc;

	// Internal high-speed oscillator generating a 48 MHz clock
	HSOSC hf_osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(int_osc)
	);

	// Multiplexing counter selecting the active digit
	// TODO: choose new N and MAX for swapping without flickering/bleeding
	logic [24:0] mux_count;
	counter #(.N(25), .MAX(25'd19_999_999)) mux_cnt (
		.clk(int_osc),
		.rst(~rst_n),
		.en(1'b1),
		.count(mux_count)
	);

	// TODO: derive a digit-select bit from mux_count, mux s[3:0]/s[7:4]
	// into digit_data below, and drive an_en[1:0] from the same select bit
	logic [3:0] digit_data;

	// Decoder for the seven segment display shared by both digits
	seven_seg_decoder sev_seg_dec (
		.s(digit_data),
		.seg(seg)
	);

	// Keypad row scanning
	keypad_scanner scan (
		.clk(int_osc),
		.rst(~rst_n),
		.en(1'b1),
		.kp_row(kp_row)
	);

	// TODO: assign leds based on kp_col

endmodule
