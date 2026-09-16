module lab2_zw(
	input  logic 	   rst_n,	// active-low push button (internal pull-up) for reset
	input  logic [7:0] s,		// DIP switches: s[3:0] = digit 0 (on-board), s[7:4] = digit 1 (off-board)
	input  logic [3:0] kp_col,	// keypad column inputs (pulled up)

	output logic [3:0] led,		// on-board LEDs driven by scanned keypad columns
	output logic [6:0] seg,		// shared segment lines, time multiplexed
	output logic [1:0] an_en,	// anode enable outputs for time multiplexing digit
	output logic [3:0] kp_row	// asserted row to scan keypad
);

	logic int_osc;
	logic sel;
	logic [15:0] mux_count;
	logic [3:0] digit_data;

	// Internal high-speed oscillator generating a 48 MHz clock
	HSOSC hf_osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(int_osc)
	);

	// Multiplexing counter for toggling the active digit at 1 kHz
	counter #(.WIDTH(16), .MAX(16'd47_999)) mux_cnt (
		.clk(int_osc),
		.rst(~rst_n),
		.en(1'b1),
		.count(mux_count)
	);

	// Decoder for the seven segment display shared by both digits
	seven_seg_decoder sev_seg_dec (
		.s(digit_data),
		.seg(seg)
	);

	// Keypad row scanning
	keypad_scanner kp_scanner (
		.clk(int_osc),
		.rst(~rst_n),
		.en(1'b1),
		.kp_row(kp_row)
	);

	assign digit_data = (mux_count < 16'd24_000) ? s[7:4] : s[3:0];
	assign an_en = (mux_count < 16'd24_000) ? 2'b01 : 2'b10;
	assign led = ~kp_col;

endmodule
