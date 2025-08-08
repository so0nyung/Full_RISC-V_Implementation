module PCPlus #(
    parameter DATA_WIDTH =32
)(
    input logic [DATA_WIDTH-1:0] PC,
    output logic [DATA_WIDTH-1:0] PCPlus4
);

assign PCPlus4 = PC + 4;

endmodule