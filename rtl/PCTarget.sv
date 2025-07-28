module PCTarget #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH -1 :0] PC,
    input logic [DATA_WIDTH -1 :0] ImmExt,
    output logic [DATA_WIDTH -1 :0] PCTarget
);
assign PCTarget = PC + ImmExt;

endmodule