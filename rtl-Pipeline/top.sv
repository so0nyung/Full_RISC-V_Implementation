module top #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic trigger,
    //Debugging outputs
    output logic [DATA_WIDTH-1:0] t1,
    output logic [DATA_WIDTH-1:0] t2,
    output logic [DATA_WIDTH-1:0] t3,
    output logic [DATA_WIDTH-1:0] t4,
    output logic [DATA_WIDTH-1:0] s0,
    output logic [3:0] RanNum,
    //Test output
    output logic [DATA_WIDTH-1:0] a0
);

/*
ORDER:
IFtop
IFIDReg
IDtop
IDEXReg
Hazard Unit
EXTop
ExMemReg
MemTop
MemWrReg
WRTop - LOOP BACK
*/
// Internal wires for IF Inputs
logic [DATA_WIDTH-1:0] Int_PCTargetExF; // From Extop
logic Int_PCSrcExF; // From Extop
logic Int_StallHazF; // From Hazard Unit

// Internal Wires for IF -> IFIDReg
logic [DATA_WIDTH-1:0] Int_InstrFReg;
logic [DATA_WIDTH-1:0] Int_PCFReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4FReg;

// Internal Wires for IFIDReg inputs
logic Int_StallHazDReg;
logic Int_FlushHazDReg;

// Internal Wires for IFIDReg -> ID
logic [DATA_WIDTH-1:0] Int_InstrRegD; 
logic [DATA_WIDTH-1:0] Int_PCRegD;
logic [DATA_WIDTH-1:0] Int_PCPlus4RegD;


// Internal Wires for IDtop -> IDEXReg
logic Int_RegWriteDReg;
logic [1:0] Int_ResultSrcDReg;
logic Int_MemWriteDReg;
logic Int_JumpDReg;
logic Int_BranchDReg;
logic [3:0] Int_ALUControlDReg;
logic Int_ALUSrcDReg;
logic [4:0] Int_RdDReg;
logic [DATA_WIDTH-1:0] Int_RDReg1;
logic [DATA_WIDTH-1:0] Int_RDReg2;
logic [DATA_WIDTH-1:0] Int_ImmExtDReg;
logic Int_JALRDReg;
logic [2:0] Int_funct3DReg;
logic [4:0] Int_Rs1DReg;
logic [4:0] Int_Rs2DReg;
logic [DATA_WIDTH-1:0] Int_PCDReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4DReg;

// Internal Wires for IDEXReg inputs
logic Int_FlushHazReg; // From Hazard Unit

// Internal Wires for IDEXReg -> Extop
logic Int_RegWriteRegE;
logic [1:0] Int_ResultSrcRegE;
logic Int_MemWriteRegE;
logic Int_JumpRegE;
logic Int_BranchRegE;
logic [3:0] Int_ALUControlRegE;
logic Int_ALUSrcRegE;
logic [DATA_WIDTH-1:0] Int_RD1RegE;
logic [DATA_WIDTH-1:0] Int_RD2RegE;
logic [DATA_WIDTH-1:0] Int_PCRegE;
logic [4:0] Int_RdRegE;
logic [DATA_WIDTH-1:0] Int_ImmExtRegE;
logic [DATA_WIDTH-1:0] Int_PCPlus4RegE;
logic [2:0] Int_funct3RegE;
logic Int_JALRRegE;
logic [4:0] Int_Rs1RegE;
logic [4:0] Int_Rs2RegE;

// Internal Wires for Extop Input
logic [1:0] Int_ForwardAE; // From Hazard Unit
logic [1:0] Int_ForwardBE; // From Hazard Unit

// Internal Wires for Extop -> ExMemReg
logic Int_RegWriteEReg;
logic [1:0] Int_ResultSrcEReg;
logic [2:0] Int_funct3EReg;
logic Int_MemWriteEReg;
logic [DATA_WIDTH-1:0] Int_ALUResultEReg;
logic [4:0] Int_RdEReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4EReg;
logic [DATA_WIDTH-1:0] Int_WriteDataEReg;
// Internal Wires for Extop -> HAzard unit
logic Int_MemReadEHaz; // To Hazard Unit

// Internal Waires for ExMemReg -> Memtop
logic Int_RegWriteRegM;
logic [1:0] Int_ResultSrcRegM;
logic Int_MemWriteRegM;
logic [2:0] Int_funct3RegM;
logic [DATA_WIDTH-1:0] Int_ALUResultRegM;
logic [DATA_WIDTH-1:0] Int_WriteDataRegM;
logic [4:0] Int_RdRegM;
logic [DATA_WIDTH-1:0] Int_PCPlus4RegM;

// Internal Wires for Memtop -> MemWrReg
logic Int_RegWriteMReg;
logic [1:0] Int_ResultSrcMReg;
logic [DATA_WIDTH-1:0] Int_ReadDataMReg;
logic [4:0] Int_RdMReg;
logic [DATA_WIDTH-1:0] Int_PCPlus4MReg;
logic [DATA_WIDTH-1:0] Int_ALUResultMReg;

// Internal Wires for MemWrReg
logic Int_RegWriteRegW;
logic [1:0] Int_ResultSrcRegW;
logic [DATA_WIDTH-1:0] Int_ALUResultRegW;
logic [DATA_WIDTH-1:0] Int_ReadDataRegW;
logic [4:0] Int_RdRegW;
logic [DATA_WIDTH-1:0] Int_PCPlus4RegW;

// Internal logic for WRtop to IDtop
logic Int_RegWriteWD;
logic [4:0] Int_RdWD;
logic [DATA_WIDTH -1:0] Int_ResultWD;

lfsr RandomNum(
    .clk(clk),
    .data_out(RanNum)
);

IFtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Instruction_Fetch(
    //Input
    .clk(clk),
    .rst(rst),
    .PCTargetE(Int_PCTargetExF),
    .PCSrcE(Int_PCSrcExF),
    // Hazard Inputs
    .StallF(Int_StallHazF),
    //F1 inputs
    .trigger(trigger),
    //Output
    .Instr(Int_InstrFReg),
    .PCF(Int_PCFReg),
    .PCPlus4F(Int_PCPlus4FReg)
);

IFIDReg #(
    .DATA_WIDTH(DATA_WIDTH)
) IFIDReg(
    .clk(clk),
    .rst(rst),
    .instr(Int_InstrFReg),
    .PCF(Int_PCFReg),
    .PCPlus4F(Int_PCPlus4FReg),
    //Hazard Inputs
    .StallD(Int_StallHazDReg),
    .FlushD(Int_FlushHazDReg),

    //Outputs
    .instrD(Int_InstrRegD),
    .PCD(Int_PCRegD),
    .PCPlus4D(Int_PCPlus4RegD)
);

IDtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Decode(
    .clk(clk),
    .RegWriteW(Int_RegWriteWD), // From WRtop
    .RdW(Int_RdWD), // From WRtop
    .ResultW(Int_ResultWD), // From WRtop
    .InstrD(Int_InstrRegD),
    .PCD(Int_PCRegD),
    .PCPlus4D(Int_PCPlus4RegD),

    //Output
    .RegWriteD(Int_RegWriteDReg),
    .ResultSrcD(Int_ResultSrcDReg),
    .MemWriteD(Int_MemWriteDReg),
    .JumpD(Int_JumpDReg),
    .BranchD(Int_BranchDReg),
    .ALUControlD(Int_ALUControlDReg),
    .ALUSrcD(Int_ALUSrcDReg),
    .RdD(Int_RdDReg),
    .RD1(Int_RDReg1),
    .RD2(Int_RDReg2),
    .ImmExtD(Int_ImmExtDReg),
    .JALRD(Int_JALRDReg),
    .funct3D(Int_funct3DReg),
    .Rs1D(Int_Rs1DReg),
    .Rs2D(Int_Rs2DReg),
    .PCDout(Int_PCDReg),
    .PCPlus4Dout(Int_PCPlus4DReg),
    // Debugging register files
    .t1(t1),
    .t2(t2),
    .t3(t3),
    .t4(t4),
    .s0(s0),
    // Actual test output
    .a0(a0)
);

IDEXReg #(
    .DATA_WIDTH(DATA_WIDTH)
) IDEXReg(
    .clk(clk),
    .rst(rst),
    .RegWriteD(Int_RegWriteDReg),
    .ResultSrcD(Int_ResultSrcDReg),
    .MemWriteD(Int_MemWriteDReg),
    .JumpD(Int_JumpDReg),
    .BranchD(Int_BranchDReg),
    .ALUControlD(Int_ALUControlDReg),
    .ALUSrcD(Int_ALUSrcDReg),
    .PCD(Int_PCDReg),
    .RdD(Int_RdDReg),
    .RD1(Int_RDReg1),
    .RD2(Int_RDReg2),
    .ImmExtD(Int_ImmExtDReg),
    .PCPlus4D(Int_PCPlus4DReg),
    .funct3D(Int_funct3DReg),
    .JALRD(Int_JALRDReg),
    .Rs1D(Int_Rs1DReg),
    .Rs2D(Int_Rs2DReg),
    //Hazard Inputs
    .FlushE(Int_FlushHazReg),
    //Output
    .RegWriteE(Int_RegWriteRegE),
    .ResultSrcE(Int_ResultSrcRegE),
    .MemWriteE(Int_MemWriteRegE),
    .JumpE(Int_JumpRegE),
    .BranchE(Int_BranchRegE),
    .ALUControlE(Int_ALUControlRegE),
    .ALUSrcE(Int_ALUSrcRegE),
    .RD1E(Int_RD1RegE),
    .RD2E(Int_RD2RegE),
    .PCE(Int_PCRegE),
    .RdE(Int_RdRegE),
    .ImmExtE(Int_ImmExtRegE),
    .PCPlus4E(Int_PCPlus4RegE),
    .funct3E(Int_funct3RegE),
    .JALRE(Int_JALRRegE),
    //Hazard Output
    .Rs1E(Int_Rs1RegE),
    .Rs2E(Int_Rs2RegE)
);
 
HazardUnit Hazard(
    .Rs1E(Int_Rs1RegE), // From Execute
    .Rs2E(Int_Rs2RegE), // From Execute
    .RdE(Int_RdRegE),
    .RdM(Int_RdRegM),
    .RegWriteM(Int_RegWriteRegM),
    .RdW(Int_RdRegW),
    .RegWriteW(Int_RegWriteRegW),
    .MemReadE(Int_MemReadEHaz),
    .PCSrcE(Int_PCSrcExF),
    .Rs1D(Int_Rs1DReg),
    .Rs2D(Int_Rs2DReg),
    //Output
    .StallF(Int_StallHazF), // Connect to IFtop 
    .StallD(Int_StallHazDReg), // Connect to IFIDReg
    .FlushD(Int_FlushHazDReg), // Connect to IFIDReg
    .FlushE(Int_FlushHazReg), // Connect to IDEXReg
    .ForwardAE(Int_ForwardAE), // RS1E - To Extop
    .ForwardBE(Int_ForwardBE) // RD2E - To Extop
);

EXtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Execute(
    .RegWriteE(Int_RegWriteRegE),
    .ResultSrcE(Int_ResultSrcRegE),
    .MemWriteE(Int_MemWriteRegE),
    .JumpE(Int_JumpRegE),
    .BranchE(Int_BranchRegE),
    .ALUControlE(Int_ALUControlRegE),
    .ALUSrcE(Int_ALUSrcRegE),
    .JALRE(Int_JALRRegE),
    .funct3E(Int_funct3RegE),
    .RD1E(Int_RD1RegE),
    .RD2E(Int_RD2RegE),
    .PCE(Int_PCRegE),
    .RdE(Int_RdRegE),
    .ImmExtE(Int_ImmExtRegE),
    .PCPlus4E(Int_PCPlus4RegE),
    //Additional Hazard Inputs
    .ForwardAE(Int_ForwardAE), // From Hazard Unit
    .ForwardBE(Int_ForwardBE), // From Hazard Unit
    .ALUResultM(Int_ALUResultMReg), // To haz Mux
    .ResultW(Int_ResultWD), // To Haz Mux
    //Outputs
    .RegWriteEout(Int_RegWriteEReg),
    .PCSrcE(Int_PCSrcExF),
    .ResultSrcEout(Int_ResultSrcEReg),
    .funct3Eout(Int_funct3EReg),
    .MemWriteEout(Int_MemWriteEReg),
    .ALUResultE(Int_ALUResultEReg),
    .WriteDataE(Int_WriteDataEReg),
    .RdEout(Int_RdEReg),
    .PCPlus4Eout(Int_PCPlus4EReg),
    .PCTargetE(Int_PCTargetExF),
    .MemReadE(Int_MemReadEHaz) // To Hazard Unit
);

ExMemReg #(
    .DATA_WIDTH(DATA_WIDTH)
) ExMemReg(
    .clk(clk),
    .rst(rst),
    .RegWriteE(Int_RegWriteEReg),
    .ResultSrcE(Int_ResultSrcEReg),
    .MemWriteE(Int_MemWriteEReg),
    .ALUResultE(Int_ALUResultEReg),
    .WriteDataE(Int_WriteDataEReg),
    .RdE(Int_RdEReg),
    .PCPlus4E(Int_PCPlus4EReg),
    .funct3M(Int_funct3EReg),
    //Output
    .RegWriteM(Int_RegWriteRegM),
    .ResultSrcM(Int_ResultSrcRegM),
    .MemWriteM(Int_MemWriteRegM),
    .funct3Mout(Int_funct3RegM),
    .ALUResultM(Int_ALUResultRegM),
    .WriteDataM(Int_WriteDataRegM),
    .RdM(Int_RdRegM),
    .PCPlus4M(Int_PCPlus4RegM)
);

MEMtop #(
    .DATA_WIDTH(DATA_WIDTH)
) Memory(
    .clk(clk),
    .ResultSrcM(Int_ResultSrcRegM),
    .MemWriteM(Int_MemWriteRegM),
    .ALUResultM(Int_ALUResultRegM),
    .WriteDataM(Int_WriteDataRegM),
    .RdM(Int_RdRegM),
    .PCPlus4M(Int_PCPlus4RegM),
    .funct3M(Int_funct3RegM),
    .RegWriteM(Int_RegWriteRegM),

    //Output
    .RegWriteMout(Int_RegWriteMReg), // Hazard Unit output also
    .ResultSrcMout(Int_ResultSrcMReg),
    .ReadDataM(Int_ReadDataMReg),
    .PCPlus4Mout(Int_PCPlus4MReg),
    .ALUResultMout(Int_ALUResultMReg), // Hazard Unit output also
    .RdMout(Int_RdMReg) // Hazard Unit output also
);

MEMWRReg #(
    .DATA_WIDTH(DATA_WIDTH)
) MemWrReg(
    .clk(clk),
    .rst(rst),
    .RegWriteM(Int_RegWriteMReg),
    .ResultSrcM(Int_ResultSrcMReg),
    .ALUResultM(Int_ALUResultMReg),
    .RdM(Int_RdMReg),
    .PCPlus4M(Int_PCPlus4MReg),
    .ReadDataM(Int_ReadDataMReg),
    
    //Output
    .RegWriteW(Int_RegWriteRegW),
    .ResultSrcW(Int_ResultSrcRegW),
    .ALUResultW(Int_ALUResultRegW),
    .ReadDataW(Int_ReadDataRegW),
    .RdW(Int_RdRegW),
    .PCPlus4W(Int_PCPlus4RegW)
);


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
    .RegWriteWout(Int_RegWriteWD),
    .ResultWout(Int_ResultWD),
    .RdWout(Int_RdWD)
);
endmodule
