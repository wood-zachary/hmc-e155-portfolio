module lab3_zw(
	input  logic 	   rst_n,			// active-low reset, internal pull-up
	input  logic [3:0] kp_col_async,	// async keypad columns (pulled up)

	output logic [6:0] seg,				// shared segment lines, multiplexed
	output logic [1:0] an_en,			// anode enables for digit multiplexing
	output logic [3:0] kp_row			// asserted row to scan keypad
);

	logic int_osc;
	logic sel;
	logic [15:0] mux_count;
	logic [3:0] digit0, digit1, digit_out;
	logic [3:0] kp_col_sync, kp_col_db;

	// Internal high-speed oscillator generating a 48 MHz clock
	HSOSC hf_osc (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(int_osc)
	);

	// Synchronizers for kp_col_async inputs, one per column
	// kp_col packs 4 independent inputs, so no async FIFO is needed
	synchronizer sync0 (
		.clk(int_osc),
		.rst(~rst_n),
		.data_in(kp_col_async[0]),
		.data_out(kp_col_sync[0])
	);

	synchronizer sync1 (
		.clk(int_osc),
		.rst(~rst_n),
		.data_in(kp_col_async[1]),
		.data_out(kp_col_sync[1])
	);

	synchronizer sync2 (
		.clk(int_osc),
		.rst(~rst_n),
		.data_in(kp_col_async[2]),
		.data_out(kp_col_sync[2])
	);

	synchronizer sync3 (
		.clk(int_osc),
		.rst(~rst_n),
		.data_in(kp_col_async[3]),
		.data_out(kp_col_sync[3])
	);

	// Debouncers for synchronized kp_col_sync inputs, one per column
	debouncer debounce0 (
		.clk(int_osc),
		.rst(~rst_n),
		.btn_in(kp_col_sync[0]),
		.btn_out(kp_col_db[0])
	);

	debouncer debounce1 (
		.clk(int_osc),
		.rst(~rst_n),
		.btn_in(kp_col_sync[1]),
		.btn_out(kp_col_db[1])
	);

	debouncer debounce2 (
		.clk(int_osc),
		.rst(~rst_n),
		.btn_in(kp_col_sync[2]),
		.btn_out(kp_col_db[2])
	);

	debouncer debounce3 (
		.clk(int_osc),
		.rst(~rst_n),
		.btn_in(kp_col_sync[3]),
		.btn_out(kp_col_db[3])
	);

	// Multiplexing counter for toggling the active digit at 1 kHz
	counter #(.WIDTH(16), .MAX(16'd47_999)) mux_counter (
		.clk(int_osc),
		.rst(~rst_n),
		.en(1'b1),
		.count(mux_count)
	);

	// Decoder for the seven segment display shared by both digits
	seven_seg_decoder sev_seg_dec (
		.hex(digit_out),
		.seg(seg)
	);

	// Keypad row scanning
	keypad_scanner kp_scanner (
		.clk(int_osc),
		.rst(~rst_n),
		.kp_col(kp_col_db),
		.kp_row(kp_row),
		.digit0(digit0),
		.digit1(digit1)
	);

	assign digit_out = (mux_count < 16'd24_000) ? digit1 : digit0;
	assign an_en = (mux_count < 16'd24_000) ? 2'b01 : 2'b10;

endmodule
