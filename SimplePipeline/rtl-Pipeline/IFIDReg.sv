module IFIDReg #(
    parameter DATA_WIDTH = 32
)(
    input logic clk, 
    input logic rst,
    input logic [DATA_WIDTH-1:0] instr, // From Instruction Memory 
    input logic [DATA_WIDTH-1:0] PCF,  // From PC multiplexor
    input logic [DATA_WIDTH-1:0] PCPlus4F,
    //====Outputs==
    output logic [DATA_WIDTH-1:0] instrD, 
    output logic [DATA_WIDTH-1:0] PCD, 
    output logic [DATA_WIDTH-1:0] PCPlus4D
);
    always_ff @(posedge clk) begin
        if (rst) begin
            instrD <= 32'b0;
            PCD <= 32'b0;
            PCPlus4D <= 32'b0;
        end else begin
            instrD <= instr; // Current Instruction
            PCD <= PCF; //Current PC Counter
            PCPlus4D <= PCPlus4F; // Sequentially next PC Counter
        end
    end
endmodule
