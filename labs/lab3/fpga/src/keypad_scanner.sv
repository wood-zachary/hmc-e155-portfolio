module keypad_scanner(
	input  logic clk,
	input  logic rst,
	input  logic [3:0] kp_col,  // Should be synchronized and debounced

	output logic [3:0] kp_row,
	output logic [3:0] digit0,
	output logic [3:0] digit1
);

	logic [24:0] scan_count;
	logic [3:0] key;
	logic any_key, single_key;

	typedef enum logic [1:0] {SCAN, PRESS, HOLD_SINGLE, HOLD_MULTI} statetype;
	statetype state, nextState;

	assign any_key = ~&kp_col;
	assign single_key = (kp_col == 4'b0111) || (kp_col == 4'b1011) || (kp_col == 4'b1101) || (kp_col == 4'b1110);

	always_ff @(posedge clk, posedge rst)
		if (rst) state <= SCAN;
		else     state <= nextState;

	always_comb
		case (state)
			SCAN:        if (single_key)            nextState = PRESS;
			             else if (any_key)          nextState = HOLD_MULTI;
			             else                       nextState = SCAN;
			PRESS:                                  nextState = HOLD_SINGLE;
			HOLD_SINGLE: if (!any_key)              nextState = SCAN;
			             else if (!single_key)      nextState = HOLD_MULTI;
			             else                       nextState = HOLD_SINGLE;
			HOLD_MULTI:  if (!any_key)              nextState = SCAN;
			             else if (single_key)       nextState = PRESS;
			             else                       nextState = HOLD_MULTI;
			default:                                nextState = SCAN;
		endcase

	always_ff @(posedge clk, posedge rst)
		if (rst) begin
			digit0 <= 4'b0000;
			digit1 <= 4'b0000;
		end else begin
			if (state == PRESS) begin
				digit0 <= key;  // combinational decode of {rows, cols}
				digit1 <= digit0;
			end
		end

	// Cycle through all rows at 2 Hz
	// Rows are only scanned when in the SCAN state
	counter #(.WIDTH(25), .MAX(25'd23_999_999)) scan_cnt (
		.clk(clk),
		.rst(rst),
		.en(state == SCAN && !any_key),
		.count(scan_count)
	);

	assign kp_row = (scan_count < 25'd6_000_000)  ? 4'b1000 :
	                (scan_count < 25'd12_000_000) ? 4'b0100 :
	                (scan_count < 25'd18_000_000) ? 4'b0010 :
	                                                4'b0001;

	// Decode {rows, cols} to hexadecimal digit
	always_comb
		case ({kp_row, kp_col})
			8'b10001000: key = 4'b0001;  // 1
			8'b10000100: key = 4'b0010;  // 2
			8'b10000010: key = 4'b0011;  // 3
			8'b10000001: key = 4'b1010;  // A

			8'b01001000: key = 4'b0100;  // 4
			8'b01000100: key = 4'b0101;  // 5
			8'b01000010: key = 4'b0110;  // 6
			8'b01000001: key = 4'b1011;  // B

			8'b00101000: key = 4'b0111;  // 7
			8'b00100100: key = 4'b1000;  // 8
			8'b00100010: key = 4'b1001;  // 9
			8'b00100001: key = 4'b1100;  // C

			8'b00011000: key = 4'b1111;  // F
			8'b00010100: key = 4'b0000;  // 0
			8'b00010010: key = 4'b1110;  // E
			8'b00010001: key = 4'b1101;  // D

			default:     key = 4'b0000;  // 0
		endcase

endmodule
