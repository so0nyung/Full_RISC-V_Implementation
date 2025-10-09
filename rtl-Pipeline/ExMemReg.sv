module ExMemReg #(
    parameter DATA_WIDTH =32
)(
    input clk,
    input rst,
    input logic RegWriteE,
    input logic [1:0] ResultSrcE,
    input logic MemWriteE,
    input logic [DATA_WIDTH-1:0] ALUResultE,
    input logic [DATA_WIDTH-1:0] WriteDataE,
    input logic [4:0] RdE,
    input logic [DATA_WIDTH-1:0] PCPlus4E,
    input logic [2:0] funct3M,
    // OUTPUT
    output logic RegWriteM,
    output logic [1:0] ResultSrcM,
    output logic MemWriteM,
    output logic [2:0] funct3Mout,
    output logic [DATA_WIDTH-1:0] ALUResultM,
    output logic [DATA_WIDTH-1:0] WriteDataM,
    output logic [4:0] RdM,
    output logic [DATA_WIDTH-1:0] PCPlus4M
);

    always_ff@(posedge clk) begin
        if(rst) begin
            RegWriteM <= 1'b0;
            ResultSrcM <= 2'b0;
            MemWriteM <= 1'b0;
            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            RdM <= 5'b0;
            PCPlus4M <= 32'b0;
            funct3Mout <= 3'b000;
        end
        else begin
            RegWriteM <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM <= MemWriteE;
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            RdM <= RdE;
            PCPlus4M <= PCPlus4E;
            funct3Mout <= funct3M;
        end
    end
endmodule
