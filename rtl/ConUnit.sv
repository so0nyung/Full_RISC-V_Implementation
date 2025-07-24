module ConUnit#(
    DATA_WIDTH = 32
)(
    input logic [6:0]   opcode,
    input logic [2:0]   funct3,    // Changed from [14:12] to [2:0] for clarity
    input logic         EQ,        // Zero flag from ALU comparison
    output logic        PCSrc,     // 1 = branch taken, 0 = PC+4
    //output logic        ResultSrc, // 1 = memory, 0 = ALU (not used for these instructions)
    // output logic        MemWrite,  // 1 = write to memory (not used for these instructions)
    output logic [1:0]  ALUctrl,   // Made 2-bit for better encoding
    output logic        ALUsrc,    // 1 = immediate, 0 = register
    output logic        RegWrite,  // 1 = write to register
    output logic [1:0]  Immsrc     // Made 2-bit: 00 = I-type, 01 = B-type
);

    // ALUctrl encoding: 00 = ADD, 01 = SUB, others as needed
    always_comb begin
        // Default values
        RegWrite  = 0;
        ALUsrc    = 0;
        Immsrc    = 2'b00;
        ALUctrl   = 2'b00;
        PCSrc     = 0;
       // ResultSrc = 0;    // Always ALU result for these instructions
        // MemWrite  = 0;    // No memory writes for these instructions

        case (opcode)
            7'b0010011: begin // I-type arithmetic (ADDI)
                if (funct3 == 3'b000) begin // ADDI
                    RegWrite = 1;
                    ALUsrc   = 1;     // Use immediate
                    Immsrc   = 2'b00; // I-type immediate
                    ALUctrl  = 2'b00; // ADD operation
                end
            end
            
            7'b1100011: begin // B-type (BNE)
                if (funct3 == 3'b001) begin // BNE
                    RegWrite = 0;     // No register write
                    ALUsrc   = 0;     // Use register (rs2)
                    Immsrc   = 2'b01; // B-type immediate
                    ALUctrl  = 2'b01; // SUB for comparison
                    PCSrc    = ~EQ;   // Branch if NOT equal (EQ = 0)
                end
            end

            default: begin
                // Safe defaults - NOP behavior
                RegWrite  = 0;
                ALUsrc    = 0;
                Immsrc    = 2'b00;
                ALUctrl   = 2'b00;
                PCSrc     = 0;
                //ResultSrc = 0;
                // MemWrite  = 0;
            end
        endcase
    end

endmodule