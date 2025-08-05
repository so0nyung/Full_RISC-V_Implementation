module CREtop #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] instr,
    input logic clk,
    input logic zero,
    input logic [DATA_WIDTH-1:0] WD3,
    output logic PCSrc, // Use for branching 
    output logic ResultSrc, // To determine if we read additional value or not
    output logic MemWrite, // To write to memory
    output logic [3:0] ALUControl, // What math instruction
    output logic ALUSrc, // To use immediate or register value
    output logic [2:0] ImmSrc, // What immediate operation to do
    output logic RegWrite, // To write to register or not
    output logic [DATA_WIDTH-1:0] SrcA, // Value of SrcA
    output logic [DATA_WIDTH-1:0] SrcBOut // Value of SrcB
);

// Internal Wires
logic Int_ALUSrc;
logic [DATA_WIDTH-1:0] Int_Immediate;
logic [2:0] Int_ImmSrc;
logic Int_RegWrite;
logic [DATA_WIDTH-1:0] Int_SrcB;

ControlUnit #(
    .DATA_WIDTH(DATA_WIDTH)
) ConUnit(
    //Inputs
    .op(instr[6:0]),
    .funct3(instr[14:12]),
    .funct7(instr[31:25]),
    .Zero(zero),
    //Outputs
    .PCSrc(PCSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUControl(ALUControl),
    .ALUSrc(Int_ALUSrc),
    .ImmSrc(Int_ImmSrc),
    .RegWrite(Int_RegWrite)
);

SignExt #(
    .DATA_WIDTH(DATA_WIDTH)
) SignEx(
    .ImmSrc(Int_ImmSrc), // Input Instruction
    .ImmInput(instr[31:7]), // Input Value
    .ImmExt(Int_Immediate) // Output to Multiplexor
);

CREmux #(
    .DATA_WIDTH(DATA_WIDTH)
) mux(
    //Inputs 
    .ImmExt(Int_Immediate), // Immediate
    .RD2(Int_SrcB), // Register Value
    .ALUsrc(Int_ALUSrc), // Bit to Select
    //Output 
    .SrcB(SrcBOut)
);

RegFile #(
    .DATA_WIDTH(DATA_WIDTH)
) Register(
    //Input
    .clk(clk),
    .A1(instr[19:15]), // Read Register Address 1 
    .A2(instr[24:20]), // Read Register Address 2
    .A3(instr[11:7]), // Write Register Address
    .WD3(WD3), // Write Data
    .WE3(Int_RegWrite), // Enable to Write
    //Output
    .RD1(SrcA), // 
    .RD2(Int_SrcB)
);

//Assigning values for testing
assign ALUSrc = Int_ALUSrc;
assign ImmSrc = Int_ImmSrc;
assign RegWrite = Int_RegWrite;

endmodule