module ARMtop #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] ImmOp,
    input logic [DATA_WIDTH-1:0] rs1,
    input logic [DATA_WIDTH-1:0] rs2,
    input logic [DATA_WIDTH-1:0] rd,
    input logic RegWrite,
    input logic ALUsrc,
    input logic ALUctrl,
    input logic [DATA_WIDTH-1:0] WD3,
    output logic [DATA_WIDTH-1:0] ALUout,
    output logic EQ,
    output logic [DATA_WIDTH-1:0] a0
);

logic [DATA_WIDTH-1:0] aluOP1;
logic [DATA_WIDTH-1:0] aluOP2;
logic [DATA_WIDTH-1:0] regOp2;
logic [DATA_WIDTH-1:0] aluOut;

RegARM #(
    .DATA_WIDTH(DATA_WIDTH)
) RegisterFile(
    .clk(clk),
    .rst(rst),
    .AD1(rs1),
    .AD2(rs2),
    .AD3(rd),
    .WD3(WD3),
    .WE3(RegWrite),
    // .ALUout(ALUout),
    .RD1(aluOP1),
    .RD2(regOp2),
    .a0(a0)
);

muxARM #(
    .DATA_WIDTH(DATA_WIDTH)
) mux(
    .regOp2(regOp2),
    .ImmOp(ImmOp),
    .ALUsrc(ALUsrc),
    .ALUop2(aluOP2)
);

ALU #(
    .DATA_WIDTH(DATA_WIDTH)
) MathUnit(
    .ALUctrl(ALUctrl),
    .ALUop1(aluOP1),
    .ALUop2(aluOP2),
    .ALUout(aluOut),
    .EQ(EQ)
);

assign ALUout = aluOut;

endmodule
