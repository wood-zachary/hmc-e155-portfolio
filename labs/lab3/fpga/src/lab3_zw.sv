module lab3_zw(
	input  logic 	   rst_n,			// active-low push button (internal pull-up) for reset
	input  logic [3:0] kp_col_async,	// asynchronous keypad column inputs (pulled up)

	output logic [6:0] seg,				// shared segment lines, time multiplexed
	output logic [1:0] an_en,			// anode enable outputs for time multiplexing digits
	output logic [3:0] kp_row			// asserted row to scan keypad
);

	logic int_osc;
	logic sel;
	logic [15:0] mux_count;
	logic [3:0] digit_data;
	logic [3:0] kp_col_sync;

	// Internal high-speed oscillator generating a 48 MHz clock
	HSOSC hf_osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(int_osc)
	);

	// Synchronizer for kp_col inputs
	// kp_col is four separate inputs packed together, so an async FIFO shouldn't be necessary
	synchronizer #(.WIDTH(4), .STAGES(2)) sync (
		.clk(int_osc),
		.rst(~rst_n),
		.data_in(kp_col_async),
		.data_out(kp_col_sync)
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
