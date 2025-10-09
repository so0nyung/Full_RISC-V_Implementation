module CSMtop #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] addr,
    input logic EQ,
    output logic PCSrc,
    //output logic ResultSrc,
   // output logic MemWrite,
    output logic [1:0] ALUctrl,
    output logic ALUsrc,
    output logic RegWrite,
    // output logic Immsrc,
    output logic [DATA_WIDTH-1:0] ImmOp
);


    // Instruction memory output
    logic [DATA_WIDTH-1:0] instr;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25]; // If needed later
    
ConUnit Control 
// #(
//     .DATA_WIDTH(DATA_WIDTH)
// )
(
    .opcode(opcode),
    .funct3(funct3), // Assuming funct3 is in bits 14:12
    .EQ(EQ),              // EQ signal from ALU comparison
    .PCSrc(PCSrc),
    //.ResultSrc(ResultSrc),
    // .MemWrite(MemWrite),
    .ALUctrl(ALUctrl),
    .ALUsrc(ALUsrc),
    .RegWrite(RegWrite),
    .Immsrc(Immsrc)
);

InsMem Instruction_Memory 
// #(
//     .DATA_WIDTH(DATA_WIDTH)
// )
(
    .addr(addr),
    .instr(instr) // Assuming 'instr' is the output instruction
);

SignEx Sign_Extension 
// #(
//     .DATA_WIDTH(DATA_WIDTH)
// )
(
    .instr(instr), // Assuming 'instr' is the instruction fetched from memory
    .Immsrc(Immsrc), 
    .ImmOp(ImmOp)
);

endmodule