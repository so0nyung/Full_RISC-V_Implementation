module PCAdd #(
    DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] PC,
    input logic [DATA_WIDTH-1:0] ImmOp,
    output logic [DATA_WIDTH-1:0] branch_PC
);

always_comb begin
    branch_PC = PC + ImmOp; 
end

endmodule