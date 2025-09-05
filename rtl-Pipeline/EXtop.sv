module EXtop #(
    parameter DATA_WIDTH = 32
)(
    input logic RegWriteE,
    input logic [1:0] ResultSrcE,
    input logic MemWriteE,
    input logic JumpE,
    input logic BranchE,
    input logic [3:0] ALUControlE,
    input logic ALUSrcE,
    input logic JALRE,
    input logic [2:0] funct3E,

    input logic [DATA_WIDTH-1:0] RD1E,
    input logic [DATA_WIDTH-1:0] RD2E,
    input logic [DATA_WIDTH-1:0] PCE,
    input logic [4:0] RdE,
    input logic [DATA_WIDTH-1:0] ImmExtE,
    input logic [DATA_WIDTH-1:0] PCPlus4E,

    //Outputs
    output logic RegWriteEout,
    output logic PCSrcE,
    output logic [1:0] ResultSrcEout,
    output logic [2:0] funct3Eout,
    output logic MemWriteEout,
    output logic [DATA_WIDTH-1:0] ALUResultE,
    output logic [DATA_WIDTH-1:0] WriteDataE,
    output logic [4:0] RdEout,
    output logic [DATA_WIDTH-1:0] PCPlus4Eout,
    output logic [DATA_WIDTH-1:0] PCTargetE

);
// Internal Wires
logic Int_ZeroE; // To indicate that we need it
logic [DATA_WIDTH-1:0] SrcBE;
logic [DATA_WIDTH-1:0] Int_ALUResultE;



ALU #(
    .DATA_WIDTH(DATA_WIDTH)
) Alu (
    .ALUControl(ALUControlE),
    .SrcA(RD1E),
    .SrcB(SrcBE),
    //Output
    .Zero(Int_ZeroE),
    .ALUResult(Int_ALUResultE)
);

ALUmux #(
    .DATA_WIDTH(DATA_WIDTH)
) ALUmultiplexor (
    .ImmExt(ImmExtE),
    .RD2(RD2E),
    .ALUsrc(ALUSrcE),
    .SrcB(SrcBE) //Output
);

PCTarget #(
    .DATA_WIDTH(DATA_WIDTH)
) TargetPC (
    .PC(PCE),
    .ImmExt(ImmExtE),
    .JALRE(JALRE),
    .ALUResultE(Int_ALUResultE),
    .PCTarget(PCTargetE)
);

// Logic for PCSrcE
logic branch_condition;
always_comb begin
    case(funct3E)
        3'b000: branch_condition = Int_ZeroE;        // BEQ: branch if equal (Zero=1)
        3'b001: branch_condition = ~Int_ZeroE;       // BNE: branch if not equal (Zero=0)
        3'b100: branch_condition = ALUResultE[0];    // BLT: branch if less than
        3'b101: branch_condition = ~ALUResultE[0];   // BGE: branch if greater/equal
        3'b110: branch_condition = ALUResultE[0];    // BLTU: branch if less than unsigned
        3'b111: branch_condition = ~ALUResultE[0];   // BGEU: branch if greater/equal unsigned
        default: branch_condition = 1'b0;
    endcase
    
    PCSrcE = JumpE | (BranchE & branch_condition);
end

// Assignment
assign PCPlus4Eout = PCPlus4E;
assign RdEout = RdE;
assign ALUResultE = Int_ALUResultE;
assign funct3Eout = funct3E;
assign RegWriteEout = RegWriteE;
assign ResultSrcEout = ResultSrcE;
assign MemWriteEout= MemWriteE;
assign WriteDataE = RD2E;
endmodule

