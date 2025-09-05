module ControlUnit(
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    // input logic Zero,
    
    output logic RegWriteD,
    output logic [1:0] ResultSrcD,
    output logic MemWriteD,
    output logic JumpD,
    output logic BranchD,
    output logic [3:0] ALUControlD,
    output logic ALUSrcD,
    output logic [2:0] ImmSrcD,
    output logic [2:0] funct3D,
    output logic JALRE
);

always_comb begin
    //Initialisation
    RegWriteD = 0;
    ResultSrcD = 2'b00;
    MemWriteD = 0;
    JumpD = 0;
    BranchD = 0;
    ALUControlD = 0;
    ALUSrcD = 0;
    ImmSrcD = 3'b000;
    JALRE = 0;
    case(op) 
        7'b0110011: begin // R-tpye instruction
            RegWriteD = 1'b1;
            ALUSrcD = 1'b0;
            case(funct3)
                3'b000: ALUControlD = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // sub/add
                3'b111: ALUControlD = 4'b0010; // and
                3'b110: ALUControlD = 4'b0011; // or
                3'b100: ALUControlD = 4'b0101; // xor
                3'b001: ALUControlD = 4'b1010; // sll
                3'b101: ALUControlD = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // sra/srl
                3'b010: ALUControlD = 4'b0110; // slt (Was 4'b1000)
                3'b011: ALUControlD = 4'b1001; // sltu
                default: ALUControlD = 4'b0000;
            endcase   
        end
        7'b0010011: begin// I-type arithmatic
            RegWriteD = 1; // Always write to register
            ALUSrcD = 1; // Use Immediate Value
            ImmSrcD = 3'b000; // I-type immediate
            case (funct3)
                    3'b000: ALUControlD = 4'b0000; // addi
                    3'b111: ALUControlD = 4'b0010; // andi
                    3'b110: ALUControlD = 4'b0011; // ori
                    3'b100: ALUControlD = 4'b0101; // xori
                    3'b001: ALUControlD = 4'b1010; // slli
                    3'b101: ALUControlD = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // srai/srli
                    3'b010: ALUControlD = 4'b0110; // slti (was 4'b1000)
                    3'b011: ALUControlD = 4'b1001; // sltiu
                    default: ALUControlD = 4'b0000;
            endcase
        end
        7'b0000011: begin // Load
                RegWriteD   = 1;
                ALUSrcD    = 1;
                ResultSrcD  = 2'b01;
                ImmSrcD     = 3'b000;
                ALUControlD = 4'b0000; // add
            end
        7'b0100011: begin // Store
                MemWriteD   = 1;
                ALUSrcD     = 1;
                ImmSrcD     = 3'b001;
                ALUControlD = 4'b0000; // add
            end
        7'b1101111: begin // J-type (jal)
                RegWriteD   = 1;
                ImmSrcD     = 3'b100;
                JumpD       = 1; // Signals a jump
                ResultSrcD = 2'b10; // Select PC+4 for write back 
            end

        7'b0110111: begin // U-type (lui)
            ALUSrcD     = 1;
            RegWriteD   = 1;
            ImmSrcD     = 3'b011;
            ALUControlD = 4'b0000;
        end


        7'b1100111: begin // JALR (for ret Instructions)
            RegWriteD   = 1;      // Write PC+4 to rd
            ALUSrcD     = 1;      // Use immediate
            ImmSrcD     = 3'b000; // I-type immediate  
            ALUControlD = 4'b0000; // ADD (rs1 + imm)
            JumpD       = 1;      // Signal jump for PC+4 storage
            JALRE     = 1'b1;
        end

        7'b1100011: begin // Branch instructions
            BranchD = 1'b1;       // Signal that it's a branch instruction
            ALUSrcD = 1'b0;       // Use rs2, not immediate, for comparison
            ImmSrcD = 3'b010;     // B-type immediate for target calculation
            ALUControlD = 4'b0001; // Subtract for all branch comparisons
        end


        7'b0010111: begin // AUIPC (Add Upper Immediate to PC)
            ALUSrcD    = 1'b1;
            RegWriteD  = 1'b1;
            ImmSrcD    = 3'b011;
            ALUControlD = 4'b0000; // ADD
            ResultSrcD = 2'b11; //
        end
        default: begin
            // Keep all default values (all zeros)
        end  
    endcase

    assign funct3D = funct3;
end
endmodule
