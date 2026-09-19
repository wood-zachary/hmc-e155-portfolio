module debouncer (
    input  logic clk,
    input  logic rst,
    input  logic btn_in,  // Active low; should already be synchronized

    output logic btn_out  // Active low, mirrors btn_in once debounced
);

    typedef enum logic [1:0] {IDLE, WAIT, PRESSED} statetype;
    statetype state, nextState;

    always_ff @(posedge clk, posedge rst)
        if (rst) state <= IDLE;
        else     state <= nextState;


    logic [19:0] db_count;

    counter #(.WIDTH(20)) db_counter (
        .clk(clk),
        .rst(rst || (state == IDLE)),
        .en(1'b1),
        .count(db_count)
    );


    always_comb
        case (state)
            IDLE:                          nextState = !btn_in ? WAIT : IDLE;
            WAIT:    if (btn_in)           nextState = IDLE;  // A bounce
                     else if (db_count[19]) nextState = PRESSED;
                     else                  nextState = WAIT;
            PRESSED:                       nextState = !btn_in ? PRESSED : IDLE;
            default:                       nextState = IDLE;
        endcase

    assign btn_out = ~(state == PRESSED);

endmodule
