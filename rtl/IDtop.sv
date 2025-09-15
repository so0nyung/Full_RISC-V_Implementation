module IDtop #(
    parameter DATA_WIDTH = 32
)(
    //Inputs
    input logic clk,
    input logic RegWriteW,
    input logic [4:0] RdW,
    input logic [DATA_WIDTH-1:0] InstrD,
    input logic [DATA_WIDTH-1:0] PCD, 
    input logic [DATA_WIDTH-1:0] PCPlus4D,
    input logic [DATA_WIDTH-1:0] ResultW, // To write to address
    //Output logic - Altered
    output logic RegWriteD,
    output logic [1:0] ResultSrcD,
    output logic MemWriteD,
    output logic JumpD,
    output logic BranchD,
    output logic [3:0] ALUControlD,
    output logic ALUSrcD,
    output logic [4:0] RdD,
    output logic [DATA_WIDTH-1:0] RD1,
    output logic [DATA_WIDTH-1:0] RD2,
    output logic [DATA_WIDTH-1:0] ImmExtD,
    output logic JALRD,
    output logic [2:0] funct3D,
    //Hazard Outputs
    output logic [4:0] Rs1D,
    output logic [4:0] Rs2D,
    //Output logic - Unchanged from input
    output logic [DATA_WIDTH-1:0] PCDout,
    output logic [DATA_WIDTH-1:0] PCPlus4Dout,

    //Output logic - Testing
    output logic [DATA_WIDTH-1:0] a0
);

//Internal Logic Wires
logic [2:0] Int_ImmSrc;

assign PCDout = PCD;
assign PCPlus4Dout = PCPlus4D;
assign RdD = InstrD[11:7];
assign Rs1D = InstrD[19:15];
assign Rs2D = InstrD[24:20];


ControlUnit Control(
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7(InstrD[31:25]),
    .RegWriteD(RegWriteD),
    .ResultSrcD(ResultSrcD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUControlD(ALUControlD),
    .ALUSrcD(ALUSrcD),
    .ImmSrcD(Int_ImmSrc),
    .JALRE(JALRD),
    .funct3D(funct3D)
);

RegFile #(
    .DATA_WIDTH(DATA_WIDTH)
) Register(
    .clk(clk),
    .A1(InstrD[19:15]),
    .A2(InstrD[24:20]),
    .A3(RdW),
    .WD3(ResultW), // Data to Write
    .WE3(RegWriteW),
    .RD1(RD1), // Read Data 1
    .RD2(RD2), // Read Data 2
    .a0(a0) // a0 test output
);

SignExt #(
    .DATA_WIDTH(DATA_WIDTH)
) Extender(
    .ImmSrc(Int_ImmSrc),
    .ImmInput(InstrD[31:7]),
    .ImmExt(ImmExtD)
);
endmodule
