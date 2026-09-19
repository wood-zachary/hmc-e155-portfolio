module synchronizer #(
    parameter int WIDTH = 1,
    parameter int STAGES = 2,
    parameter logic [WIDTH-1:0] INIT_VAL = 0
) (
    input  logic clk,
    input  logic rst,
    input  logic [WIDTH-1:0] data_in,

    output logic [WIDTH-1:0] data_out
);

    logic [STAGES-1:0][WIDTH-1:0] sync_regs;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) sync_regs <= {STAGES{INIT_VAL}};
        else sync_regs <= {sync_regs[STAGES-2:0], data_in};
    end

    assign data_out = sync_regs[STAGES-1];

endmodule