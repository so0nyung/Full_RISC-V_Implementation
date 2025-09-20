module top#(
    parameter DATA_WIDTH =32
)(
    input logic clk,
    output [DATA_WIDTH-1 :0] a0
);


// Internal Wires
logic [DATA_WIDTH-1:0] Int_PCTarget;
logic [DATA_WIDTH-1:0] Int_Instr;
logic [DATA_WIDTH-1:0] Int_SrcA;
logic [DATA_WIDTH-1:0] Int_SrcB;
logic [DATA_WIDTH-1:0] Int_PC;
logic [DATA_WIDTH-1:0] Int_WD3; // Result for ADPtop
logic [DATA_WIDTH-1:0] Int_ImmExt;
logic [DATA_WIDTH-1:0] Int_RD2out;
logic [DATA_WIDTH-1:0] Int_PCPlus4;

logic [3:0] Int_ALUControl;

logic Int_ResultSrc;
logic Int_MemWrite;
logic Int_PCSrc;
//logic Int_ALUSrc;
//logic [2:0] Int_ImmSrc;
//logic Int_RegWrite;
logic Int_zero;
logic Int_Jump;

PCItop #(
    .DATA_WIDTH(DATA_WIDTH)
) PCI(
    //Input
    .clk(clk),
    .PCSrc(Int_PCSrc), // Decides what output to put
    .PCTarget(Int_PCTarget),
    //Output
    .Instr(Int_Instr), // To send to CREtop
    .PC(Int_PC), // To send to ADPtop
    .PCPlus4(Int_PCPlus4)
);

CREtop #(
    .DATA_WIDTH(DATA_WIDTH)
) CRE(
    .instr(Int_Instr), // From PCItop
    .clk(clk),
    .zero(Int_zero), // From ADPtop
    .WD3(Int_WD3), // From ADPtop
    .PCPlus4(Int_PCPlus4),
    //Outputs - Majority to send to ADPtop
    .PCSrc(Int_PCSrc), // 1-bit -> Send to PCItop
    .ResultSrc(Int_ResultSrc), // 1-bit
    .MemWrite(Int_MemWrite), // 1-bit
    .ALUControl(Int_ALUControl), // 4-bit
    //.ALUSrc(Int_ALUSrc), // 1-bit
    //.ImmSrc(Int_ImmSrc), // 3-bit
    //.RegWrite(Int_RegWrite), // 1-bit
    .Jump(Int_Jump),
    .SrcA(Int_SrcA), // 32-bit
    .SrcBOut(Int_SrcB), // 32-bit
    .ImmExt(Int_ImmExt), // 32-bit -> to ADPtop
    .RD2out(Int_RD2out),
    .a0(a0) // Test result
);


ADPtop #(
    .DATA_WIDTH(DATA_WIDTH)
) ADP(
    //Inputs
    .clk(clk),
    .funct3(Int_Instr[14:12]),
    .ALUControl(Int_ALUControl),
    .SrcA(Int_SrcA),
    .SrcB(Int_SrcB),
    .PC(Int_PC), // From PCItop
    .ImmExt(Int_ImmExt), // From CREtop
    .MemWrite(Int_MemWrite),
    .ResultSrc(Int_ResultSrc),
    .WriteData(Int_RD2out), // From CREtop
    .Jump(Int_Jump),
    .PCPlus4(Int_PCPlus4),
    .op(Int_Instr[6:0]),
    //Output
    .Zero(Int_zero), // To ADPtop
    .Result(Int_WD3), // To send to CREtop
    .PCTarget(Int_PCTarget) // To send to PCItop
);

endmodule
