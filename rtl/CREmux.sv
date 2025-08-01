module CREmux #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] ImmExt,
    input logic [DATA_WIDTH-1:0] RD2,
    input logic ALUsrc,
    output logic [DATA_WIDTH-1:0] SrcB
);

assign SrcB = (ALUsrc) ? RD2  : ImmExt;

endmodule