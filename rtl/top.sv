module top #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    
);
    // assign a0 = 32'd5;
// ==========Internal Signals==========
logic [DATA_WIDTH-1:0] Int_ImmOp;
logic [DATA_WIDTH-1:0] Int_rs1;
logic [DATA_WIDTH-1:0] Int_rs2;
logic [DATA_WIDTH-1:0] Int_rd;
logic [DATA_WIDTH-1:0] Int_PC;
logic int_PCsrc;
logic Int_RegWrite;
logic Int_ALUsrc;
logic Int_ALUctrl;
//logic Int_ResultSrc;
logic [DATA_WIDTH-1:0] Int_WD3;
logic [DATA_WIDTH-1:0] Int_ALUout;
logic Int_EQ;               

// This refers to the ALU, Register File, and Multiplexor Components
ARMtop #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ARM (
        .clk(clk),
        .rst(rst),
        .ImmOp(ImmOp),
        .rs1(Int_rs1),
        .rs2(Int_rs2),
        .rd(Int_rd),
        .RegWrite(Int_RegWrite),
        .ALUsrc(Int_ALUsrc),
        .ALUctrl(Int_ALUctrl),
        .WD3(Int_WD3),
        .ALUout(Int_ALUout),
        .EQ(Int_EQ), // Output
        .a0(a0)
        //.ResultSrc(Int_ResultSrc) // Input from CSMtop
    );

CSMtop #(
    .DATA_WIDTH(DATA_WIDTH)
) CSM(
    .clk(clk), // Input
    .rst(rst), // Input
    .addr(Int_PC), // Input from PCRegi -> PC
    .EQ(Int_EQ), // Input
    .PCSrc(int_PCsrc), // Output to PCRegi
    .ALUctrl(Int_ALUctrl), // Output to ARM
    .ALUsrc(Int_ALUsrc), // Output to ARM
    .RegWrite(Int_RegWrite), // Output to ARM
    // .Immsrc(Int_Imm), // Removed because it's supposed to be an internal signal
    .ImmOp(Int_ImmOp)// Output to PCRegi + ARM
    //.ResultSrc(Int_ResultSrc) // Output to ARM
);

PCRegi #(
    .DATA_WIDTH(DATA_WIDTH)
) PCReg (
    .clk(clk), 
    .rst(rst),
    .PCsrc(int_PCsrc), // Input from CSM
    .ImmOperator(Int_ImmOp), // Input from CSM
    .PC(Int_PC) // Output to CSM 
);

endmodule

