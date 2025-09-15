module IDEXReg #(
    parameter DATA_WIDTH =32
)(
    input logic clk,
    input logic rst,
    input logic RegWriteD,
    input logic [1:0] ResultSrcD,
    input logic MemWriteD,
    input logic JumpD,
    input logic BranchD,
    input logic [3:0] ALUControlD,
    input logic ALUSrcD,
    input logic [DATA_WIDTH-1:0] PCD,
    input logic [4:0] RdD,
    input logic [DATA_WIDTH-1:0] RD1,
    input logic [DATA_WIDTH-1:0] RD2,
    input logic [DATA_WIDTH-1:0] ImmExtD,
    input logic [DATA_WIDTH-1:0] PCPlus4D,
    input logic [2:0] funct3D,
    input logic JALRD,
    // Hazard inputs
    input logic [4:0] Rs1D,
    input logic [4:0] Rs2D,
    input logic FlushE,

    output logic RegWriteE,
    output logic [1:0] ResultSrcE,
    output logic MemWriteE,
    output logic JumpE,
    output logic BranchE,
    output logic [3:0] ALUControlE,
    output logic ALUSrcE,
    output logic [DATA_WIDTH-1:0] RD1E,
    output logic [DATA_WIDTH-1:0] RD2E,
    output logic [DATA_WIDTH-1:0] PCE,
    output logic [4:0] RdE,
    output logic [DATA_WIDTH-1:0] ImmExtE,
    output logic [DATA_WIDTH-1:0] PCPlus4E,
    output logic [2:0] funct3E,
    output logic JALRE,
    // Hazard Outputs
    output logic [4:0] Rs1Dout,
    output logic [4:0] Rs2Dout
);

    always_ff @(posedge clk) begin
        if(rst || FlushE) begin
            RegWriteE <= 1'b0;
            ResultSrcE <= 2'b0;
            MemWriteE <= 1'b0;
            JumpE <= 1'b0;
            BranchE <= 1'b0;
            ALUControlE <= 4'b0;
            ALUSrcE <= 1'b0;
            RD1E <= 32'b0;
            RD2E <= 32'b0;
            PCE <= 32'b0;
            RdE <= 5'b0;
            ImmExtE <= 32'b0;
            PCPlus4E <= 32'b0;
            JALRE <= 1'b0;
            Rs1Dout <= 5'b0;
            Rs2Dout <= 5'b0;
            // PCTargetE <= 32'b0;
        end
        else begin
            RegWriteE <= RegWriteD;
            ResultSrcE <= ResultSrcD;
            MemWriteE <= MemWriteD;
            JumpE <= JumpD;
            BranchE <= BranchD;
            ALUControlE <= ALUControlD;
            ALUSrcE <= ALUSrcD;
            RD1E <= RD1;
            RD2E <= RD2;
            PCE <= PCD;
            RdE <= RdD;
            ImmExtE <= ImmExtD;
            PCPlus4E <= PCPlus4D;
            funct3E <=funct3D;
            JALRE <= JALRD;
            Rs1Dout <= Rs1D;
            Rs2Dout <= Rs2D;
        end
    end

endmodule



