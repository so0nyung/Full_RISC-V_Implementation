module top#(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    output logic [DATA_WIDTH-1:0] a0
);

//FETCH
IFtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Fetch (
    //inputs
    .clk(clk),
    .rst(rst),
    .PCTargetE(Int_PCTargetEReg),
    .PCSrcE(Int_PCSrcEReg),
    //Outputs
    .Instr(Int_InstrFDReg),
    .PCF(Int_PCFDReg),
    .PCPlus4F(Int_PCPlus4FDReg)
);
// Internal Wries for IF ID
logic [DATA_WIDTH-1:0] Int_InstrFDReg;
logic [DATA_WIDTH-1:0] Int_PCFDReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4FDReg;

//Intermediate
IFIDReg #(
    .DATA_WIDTH(DATA_WIDTH)
) Fetch_To_Decode (
    //Inputs
    .clk(clk),
    .rst(rst),
    .instr(Int_InstrFDReg),
    .PCF(Int_PCFDReg),
    .PCPlus4F(Int_PCPlus4FDReg),

    //Outputs
    .instrD(Int_InstrFD),
    .PCD(Int_PCFD),
    .PCPlus4D(Int_PCPlus4FD)
);

// Internal Wries for IFIDReg to Decode
logic [DATA_WIDTH-1:0] Int_InstrFD;
logic [DATA_WIDTH-1:0] Int_PCFD;
logic [DATA_WIDTH-1:0] Int_PCPlus4FD;
// Inputs from the Write Reg Stage
logic Int_RegWriteMD; // From RegWrite MD
logic [4:0] Int_RdWD; // From Regwrite to Decode
logic [DATA_WIDTH-1:0] Int_ResultWD;

//Outputs from file - 
logic Int_RegWriteWReg;
logic [1:0] Int_ResultSrcDReg;
logic Int_MemWriteDReg;
logic Int_JumpD;
logic Int_BranchD;
logic [3:0] Int_ALUControlDReg;
logic Int_ALUSrcDReg;
logic Int_JALRDReg;
logic [DATA_WIDTH-1:0] Int_RD1Reg;
logic [DATA_WIDTH-1:0] Int_RD2Reg;
logic [4:0] Int_RdDReg;
logic [DATA_WIDTH-1:0] Int_ImmExtDReg;
logic [DATA_WIDTH-1:0] Int_PCDReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4DReg;

logic [2:0] funct3DReg;
// DECODE
IDtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Decode(
    .clk(clk),
    .RegWriteW(Int_RegWriteMD),
    .RdW(Int_RdWD),
    .InstrD(Int_InstrFD),
    .PCD(Int_PCFD),
    .PCPlus4D(Int_PCPlus4FD),
    .ResultW(Int_ResultWD),

    //Output
    .RegWriteD(Int_RegWriteWReg),
    .ResultSrcD(Int_ResultSrcDReg),
    .MemWriteD(Int_MemWriteDReg),
    .JumpD(Int_JumpD),
    .BranchD(Int_BranchD),
    .ALUControlD(Int_ALUControlDReg),
    .ALUSrcD(Int_ALUSrcDReg),
    .RdD(Int_RdDReg),
    .RD1(Int_RD1Reg),
    .RD2(Int_RD2Reg),
    .ImmExtD(Int_ImmExtDReg),
    .JALRE(Int_JALRDReg),
    .funct3D(funct3DReg),
    .PCDout(Int_PCDReg),
    .PCPlus4Dout(Int_PCPlus4DReg),
    .a0(a0) // Test Output
);

//Internal Wires
//Outputs
logic RegWriteRegEx;
logic [1:0] ResultSrcRegEx;
logic MemWriteRegEx;
logic JumpRegEx;
logic BranchRegEx;
logic [3:0] ALUControlRegEx;
logic ALUSrcRegEx;
logic [DATA_WIDTH-1:0] RD1RegEx;
logic [DATA_WIDTH-1:0] RD2RegEx;
logic [DATA_WIDTH-1:0] PCRegEx;
logic [4:0] RdRegEx;
logic [DATA_WIDTH-1:0] Int_ImmExtRegEx;
logic [DATA_WIDTH-1:0] Int_PCPlus4RegEx;
logic [2:0] Int_funct3RegEx;
// logic [DATA_WIDTH-1:0] Int_PCTargetE;
logic Int_JALRRegEx;

//ID/EX Register
IDEXReg #(
    .DATA_WIDTH(DATA_WIDTH)
) Decode_To_Execute(
    .clk(clk),
    .rst(rst),
    .RegWriteD(Int_RegWriteWReg),
    .ResultSrcD(Int_ResultSrcDReg),
    .MemWriteD(Int_MemWriteDReg),
    .JumpD(Int_JumpD),
    .BranchD(Int_BranchD),
    .ALUControlD(Int_ALUControlDReg),
    .ALUSrcD(Int_ALUSrcDReg),
    .PCD(Int_PCDReg),
    .RdD(Int_RdDReg),
    .RD1(Int_RD1Reg),
    .RD2(Int_RD2Reg),
    .ImmExtD(Int_ImmExtDReg),
    .PCPlus4D(Int_PCPlus4DReg),
    .funct3D(funct3DReg),
    .JALRD(Int_JALRDReg),

    //Output
    .RegWriteE(RegWriteRegEx),
    .ResultSrcE(ResultSrcRegEx),
    .MemWriteE(MemWriteRegEx),
    .JumpE(JumpRegEx),
    .BranchE(BranchRegEx),
    .ALUControlE(ALUControlRegEx),
    .ALUSrcE(ALUSrcRegEx),
    .RD1E(RD1RegEx),
    .RD2E(RD2RegEx),
    .PCE(PCRegEx),
    .RdE(RdRegEx),
    .ImmExtE(Int_ImmExtRegEx),
    .PCPlus4E(Int_PCPlus4RegEx),
    .funct3E(Int_funct3RegEx),
    .JALRE(Int_JALRRegEx)
);


// Internal Wires - Output from Execute Phase
logic Int_RegWriteEReg;
logic Int_PCSrcEReg;
logic [1:0] Int_ResultSrcEReg;
logic [2:0] Int_funct3EReg;
logic Int_MemWriteEReg;
logic [DATA_WIDTH-1:0] Int_ALUResultEReg;
logic [DATA_WIDTH-1:0] Int_WriteDataEReg;
logic [4:0] Int_RdEReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4EReg;
logic [DATA_WIDTH-1:0] Int_PCTargetEReg;
//Execute Code
EXtop #(
    .DATA_WIDTH(DATA_WIDTH)
)Execute(
    .RegWriteE(RegWriteRegEx),
    .ResultSrcE(ResultSrcRegEx),
    .MemWriteE(MemWriteRegEx),
    .JumpE(JumpRegEx),
    .BranchE(BranchRegEx),
    .ALUControlE(ALUControlRegEx),
    .ALUSrcE(ALUSrcRegEx),
    .JALRE(Int_JALRRegEx),
    .funct3E(Int_funct3RegEx),
    .RD1E(RD1RegEx),
    .RD2E(RD2RegEx),
    .PCE(PCRegEx),
    .RdE(RdRegEx),
    .ImmExtE(Int_ImmExtRegEx),
    .PCPlus4E(Int_PCPlus4RegEx),
    //Outputs
    .RegWriteEout(Int_RegWriteEReg),
    .PCSrcE(Int_PCSrcEReg),
    .ResultSrcEout(Int_ResultSrcEReg),
    .funct3Eout(Int_funct3EReg),
    .MemWriteEout(Int_MemWriteEReg),
    .ALUResultE(Int_ALUResultEReg),
    .WriteDataE(Int_WriteDataEReg),
    .RdEout(Int_RdEReg),
    .PCPlus4Eout(Int_PCPlus4EReg),
    .PCTargetE(Int_PCTargetEReg)
);

//Internal Wires
logic Int_RegwriteRegM;

logic [1:0] Int_ResultSrcRegM;
logic Int_MemWriteRegM;
logic [2:0] Int_funct3RegM;
logic [DATA_WIDTH-1:0] Int_ALUResultRegM;
logic [DATA_WIDTH-1:0] Int_WriteDataRegM;
logic [4:0] Int_RdRegM;
logic [DATA_WIDTH-1:0] Int_PCPlus4RegM;
// EX/MEM Register
ExMemReg #(
    .DATA_WIDTH(DATA_WIDTH)
) Execute_To_Memory(
    .clk(clk),
    .rst(rst),
    .RegWriteE(Int_RegWriteEReg),
    .ResultSrcE(Int_ResultSrcEReg),
    .ALUResultE(Int_ALUResultEReg),
    .WriteDataE(Int_WriteDataEReg),
    .RdE(Int_RdEReg),
    .PCPlus4E(Int_PCPlus4EReg),
    .funct3M(Int_funct3EReg),
    .MemWriteE(Int_MemWriteEReg),
    //Output
    .RegwriteM(Int_RegwriteRegM),
    .ResultSrcM(Int_ResultSrcRegM),
    .MemWriteM(Int_MemWriteRegM),
    .funct3Mout(Int_funct3RegM),
    .ALUResultM(Int_ALUResultRegM),
    .WriteDataM(Int_WriteDataRegM),
    .RdM(Int_RdRegM),
    .PCPlus4M(Int_PCPlus4RegM)
);

//Internal Wires - Outputs from Memory 
logic Int_RegWriteMReg;
logic [1:0] Int_ResultSrcMReg;
logic [DATA_WIDTH-1:0] Int_ReadDataMReg;
logic [4:0] Int_RdMReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4MReg;
logic [DATA_WIDTH-1:0] Int_ALUResultMReg;
//Memory
MEMtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Mem(
    .clk(clk),
    .RegWriteM(Int_RegwriteRegM),
    .ResultSrcM(Int_ResultSrcRegM),
    .MemWriteM(Int_MemWriteRegM),
    .ALUResultM(Int_ALUResultRegM),
    .WriteDataM(Int_WriteDataRegM),
    .RdM(Int_RdRegM),
    .PCPlus4M(Int_PCPlus4RegM),
    .funct3M(Int_funct3RegM),
    
    //Output
    .RegWriteMout(Int_RegWriteMReg),
    .ResultSrcMout(Int_ResultSrcMReg),
    .ReadDataW(Int_ReadDataMReg),
    .RdMout(Int_RdMReg),
    .PCPlus4Mout(Int_PCPlus4MReg),
    .ALUResultMout(Int_ALUResultMReg)
);

//Internal Wires
logic Int_RegWriteRegW;
logic [1:0] Int_ResultSrcRegW;
logic [DATA_WIDTH-1:0] Int_ALUResultRegW;
logic [DATA_WIDTH-1:0] Int_ReadDataRegW;
logic [4:0] Int_RdRegW;
logic [DATA_WIDTH-1:0] Int_PCPlus4RegW;
// Mem-to-Write Register
MEMWRReg #(
    .DATA_WIDTH(DATA_WIDTH)
) Memory_To_Write(
    .clk(clk),
    .rst(rst),
    .RegWriteM(Int_RegWriteMReg),
    .ResultSrcM(Int_ResultSrcMReg),
    .ALUResultM(Int_ALUResultMReg),
    .ReadDataM(Int_ReadDataMReg),
    .RdM(Int_RdMReg),
    .PCPlus4M(Int_PCPlus4MReg),
    
    //Output
    .RegWriteW(Int_RegWriteRegW),
    .ResultSrcW(Int_ResultSrcRegW),
    .ALUResultW(Int_ALUResultRegW),
    .ReadDataW(Int_ReadDataRegW),
    .RdW(Int_RdRegW),
    .PCPlus4W(Int_PCPlus4RegW)
);



//Write Register
WRtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Write_DAta (
    .RegWriteW(Int_RegWriteRegW),
    .ResultSrcW(Int_ResultSrcRegW),
    .ALUResultW(Int_ALUResultRegW),
    .ReadDataW(Int_ReadDataRegW),
    .RdW(Int_RdRegW),
    .PCPlus4W(Int_PCPlus4RegW),
    //Output
    .RegWriteWout(Int_RegWriteMD),
    .ResultWout(Int_ResultWD),
    .RdWout(Int_RdWD)
);

endmodule
