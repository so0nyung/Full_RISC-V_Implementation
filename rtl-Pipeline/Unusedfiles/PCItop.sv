// REDUNDANT - TO REMOVE
module PCItop#(
    parameter DATA_WIDTH =32
)(
    input logic clk,
    input logic PCSrc,
    input logic [DATA_WIDTH-1:0] PCTarget,
    output logic [DATA_WIDTH-1:0] Instr,
    output logic [DATA_WIDTH-1:0] PC,
    output logic [DATA_WIDTH-1:0] PCPlus4
);


// Internal Wires
logic [DATA_WIDTH-1:0] Int_PCPlus4;
logic [DATA_WIDTH-1:0] Int_PC;
// ============ FLAGGED OUT WARNING MAY NEED TO REINSTITUTE
logic [DATA_WIDTH-1:0] Reg_PC; // Internal Register, initialised at 0

PCImux #(
    .DATA_WIDTH(DATA_WIDTH)
) mux(
    .PCSrc(PCSrc),
    .PCPlus4(Int_PCPlus4),
    .PCTarget(PCTarget),
    .PCNext(Int_PC)
);

PCPlus #(
    .DATA_WIDTH(DATA_WIDTH)
) adder(
    .PC(Reg_PC),
    .PCPlus4(Int_PCPlus4)
);

InstMem #(
    .DATA_WIDTH(DATA_WIDTH)
) instruction(
    .A(Reg_PC[11:0]),
    .Instr(Instr)
);

always_ff @(posedge clk) begin
    Reg_PC <= Int_PC;
end

// Testing purposes
assign PC = Reg_PC; // Next PC
assign PCPlus4 = Int_PCPlus4;

endmodule
