module MEMtop #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic RegWriteM,
    input logic [1:0] ResultSrcM,
    input logic MemWriteM,

    input logic [DATA_WIDTH-1:0] ALUResultM,
    input logic [DATA_WIDTH-1:0] WriteDataM,
    input logic [4:0] RdM,
    input logic [DATA_WIDTH-1:0] PCPlus4M,
    input logic [2:0] funct3M,

    output logic RegWriteMout,
    output logic [1:0] ResultSrcMout,
    output logic [DATA_WIDTH-1:0] ReadDataM,
    output logic [4:0] RdMout,
    output logic [DATA_WIDTH-1:0] PCPlus4Mout,
    output logic [DATA_WIDTH-1:0] ALUResultMout
);

    DataMem#(   
        .DATA_WIDTH(DATA_WIDTH)
    ) Data_Memory(
        .clk(clk),
        .funct3(funct3M),
        .MemWrite(MemWriteM),
        .A(ALUResultM),
        .WD(WriteDataM),
        .RD(ReadDataM)
    );


    assign RegWriteMout = RegWriteM;
    assign ResultSrcMout = ResultSrcM;
    assign RdMout = RdM;
    assign PCPlus4Mout = PCPlus4M;
    assign ALUResultMout = ALUResultM;
endmodule
