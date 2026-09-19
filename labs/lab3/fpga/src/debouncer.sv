module debouncer #(
    parameter int WIDTH = 1
) (
    input  logic clk,
    input  logic rst,
    input  logic [WIDTH-1:0] btn_in,  // Should already be synchronized

    output logic [WIDTH-1:0] btn_out
);

    typedef enum logic [1:0] {IDLE, WAIT, PRESSED} statetype;
    statetype state, nextState;

    always_ff @(posedge clk, posedge rst)
        if (rst) state <= IDLE;
        else     state <= nextState;


    logic [19:0] counter;

    always_ff @(posedge clk)
        if (state == IDLE) counter <= 0;
        else               counter <= counter + 1;


    always_comb
        case (state)
            IDLE:                          nextState = btn ? WAIT : IDLE;
            WAIT:    if (!btn)             nextState = IDLE;  // A bounce
                     else if (counter[19]) nextState = PRESSED;
                     else                  nextState = WAIT;
            PRESSED:                       nextState = btn ? PRESSED: IDLE;
            default:                       nextState = IDLE;
        endcase

    assign btn_out = (state == PRESSED);

endmodule
