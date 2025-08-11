module ADPtop#(
    parameter DATA_WIDTH = 32
)(

    // Inputs
    input logic [3:0] ALUControl,
    input logic [DATA_WIDTH-1:0] SrcA,
    input logic [DATA_WIDTH-1:0] SrcB,
    input logic [DATA_WIDTH-1:0] PC,
    input logic [DATA_WIDTH-1:0] ImmExt,
    input logic MemWrite,
    input logic ResultSrc,
    input logic [DATA_WIDTH-1:0] WriteData,
    input logic [2:0] funct3,
    input logic clk,
    input logic Jump,
    input logic [DATA_WIDTH-1:0] PCPlus4,
    input logic [6:0] op,
    // Outputs
    output logic Zero,
    output logic [DATA_WIDTH-1:0] Result,
    output logic [DATA_WIDTH-1:0] PCTarget
);

logic [DATA_WIDTH -1:0] Int_ALUResult;
logic [DATA_WIDTH -1:0] Int_ReadData;
logic [DATA_WIDTH -1:0] Int_Result;
// logic [DATA_WIDTH -1:0]

ALU #(
    .DATA_WIDTH(DATA_WIDTH)
) alu(
    .ALUControl(ALUControl),
    .SrcA(SrcA),
    .SrcB(SrcB),
    .Zero(Zero),
    .ALUResult(Int_ALUResult)
);

ADPmux #(
    .DATA_WIDTH(DATA_WIDTH)
) Multiplexor(
    .ResultSrc(ResultSrc),
    .ReadData(Int_ReadData),
    .ALUResult(Int_ALUResult),
    .Result(Int_Result)
);

JumpMux #( // Selects PC+4 for JAL Instructions
    .DATA_WIDTH(DATA_WIDTH)
) jumpMux(
    .Jump(Jump),
    .Result(Int_Result),
    .PCPlus4(PCPlus4),
    .FinalResult(Result) 
);

DataMem #(
    .DATA_WIDTH(DATA_WIDTH)
) dataMem(
    .clk(clk), // Clock signal should be connected to a clock source
    .funct3(funct3),
    .MemWrite(MemWrite), // Write Enable should be controlled by the control unit
    .A(Int_ALUResult), // Address for memory access
    .WD(WriteData), // Write Data from ALU
    .RD(Int_ReadData) // Read Data output
);

PCTarget #(
    .DATA_WIDTH(DATA_WIDTH)
) pcTarget(
    .PC(PC),
    .ImmExt(ImmExt),
    .ALUResult(Int_ALUResult),
    .op(op),
    .PCTarget(PCTarget)
);


endmodule
