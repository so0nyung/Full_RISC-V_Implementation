module MEMWRReg #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic RegWriteM,
    input logic [1:0] ResultSrcM,
    input logic [DATA_WIDTH -1:0] ALUResultM,
    input logic [DATA_WIDTH-1:0] ReadDataM,
    input logic [4:0] RdM,
    input logic [DATA_WIDTH-1:0] PCPlus4M,
//Output
    output logic RegWriteW,
    output logic [1:0] ResultSrcW,
    output logic [DATA_WIDTH-1:0] ALUResultW,
    output logic [DATA_WIDTH-1:0] ReadDataW,
    output logic [4:0] RdW,
    output logic [DATA_WIDTH-1:0] PCPlus4W
);

    always_ff @(posedge clk) begin
        if(rst) begin
            RegWriteW <= 1'b0;
            ResultSrcW <= 2'b0;
            ALUResultW <= 32'b0;
            ReadDataW <= 32'b0;
            RdW <= 5'b0;
            PCPlus4W <= 32'b0;
        end
        else begin
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            ALUResultW <= ALUResultM;
            ReadDataW <= ReadDataM;
            RdW <= RdM;
            PCPlus4W <= PCPlus4M;
        end
    end

endmodule
