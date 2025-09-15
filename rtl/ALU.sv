module ALU#(
    parameter DATA_WIDTH = 32
)(
    input logic [3:0] ALUControl,
    input logic [DATA_WIDTH-1:0] SrcA,
    input logic [DATA_WIDTH-1:0] SrcB,
    output logic Zero,
    output logic [DATA_WIDTH-1:0] ALUResult
);

    logic signed [DATA_WIDTH-1:0] signedA;
    logic [4:0] shiftAmt;
always_comb begin
    signedA = SrcA;
    shiftAmt = SrcB[4:0]; // Assuming SrcB contains the shift amount
    case(ALUControl)
        4'b0000: ALUResult = SrcA + SrcB;    //ADD
        4'b0001: ALUResult = SrcA - SrcB;    //SUB
        4'b0010: ALUResult = SrcA & SrcB;    //AND
        4'b0011: ALUResult = SrcA | SrcB;    //OR
        4'b0100: ALUResult = SrcB;    //LOAD IMMEDIATE
        4'b0101: ALUResult = SrcA ^ SrcB;    // XOR
        4'b0110: ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'b1 : 32'b0;  // Signed Less Than (SLT)
        4'b0111: ALUResult = SrcA >> shiftAmt; // Shift Right Logical (SRL)
        4'b1000: ALUResult = signedA >>> shiftAmt; // Shift Right Arithmetic (SRA)
        4'b1001: ALUResult = (SrcA < SrcB) ? 32'b1 : 32'b0; //Unsigned Less Than (ULT)
        4'b1010: ALUResult = SrcA << shiftAmt;    // SLL (Shift Left Logical)

        // ========== Blank Registers ========== //
        // 4'b1011: 
        // 4'b1100:
        // 4'b1101:
        // 4'b1110:
        // 4'b1111:
        default: ALUResult = SrcA + SrcB; // Default case
    endcase
    Zero = (ALUResult == 0);
end

endmodule
