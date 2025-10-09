module lfsr(
    input   logic       clk,
    output  logic [3:0] data_out
);

/* verilator lint_off PROCASSINIT */
logic [4:1] sreg = 4'b0001;
/* verilator lint_on PROCASSINIT */

always_ff @(posedge clk) begin
    sreg <= {sreg[3:1], sreg[4] ^ sreg[3]};
end

assign data_out = sreg;

endmodule
