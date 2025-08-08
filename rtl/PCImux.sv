module PCImux#(
    parameter DATA_WIDTH = 32
)(
    input logic PCSrc,
    input logic [DATA_WIDTH-1:0] PCPlus4, // 0
    input logic [DATA_WIDTH-1:0] PCTarget, // 1
    output logic [DATA_WIDTH-1:0] PCNext
);

always_comb begin
    PCNext = (PCSrc) ? PCTarget : PCPlus4;
end

endmodule