module ControlUnit(
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic Zero,
    output logic PCSrc,
    output logic ResultSrc,
    output logic MemWrite,
    output logic [3:0] ALUControl,
    output logic ALUSrc,
    output logic [2:0] ImmSrc,
    output logic RegWrite,
    output logic Jump // Signal for JAL
);

always_comb begin
// Initialisation
    PCSrc      = 0;
    ResultSrc  = 0;
    MemWrite   = 0;
    ALUControl = 4'b0000;
    ALUSrc     = 0;
    ImmSrc     = 3'b000;
    RegWrite   = 0;
    Jump       = 0;

    case(op)
        7'b0110011: begin
            RegWrite = 1'b1;
            ALUSrc   = 1'b0;
            case(funct3)
                3'b000: ALUControl = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // sub/add
                3'b111: ALUControl = 4'b0010; // and
                3'b110: ALUControl = 4'b0011; // or
                3'b100: ALUControl = 4'b0101; // xor
                3'b001: ALUControl = 4'b1010; // sll
                3'b101: ALUControl = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // sra/srl
                3'b010: ALUControl = 4'b1000; // slt
                3'b011: ALUControl = 4'b1001; // sltu
                default: ALUControl = 4'b0000;
            endcase
        end

        7'b0010011: begin// I-type arithmatic
            RegWrite = 1; // Always write to register
            ALUSrc = 1; // Use Immediate Value
            ImmSrc = 3'b000; // I-type immediate
            case (funct3)
                    3'b000: ALUControl = 4'b0000; // addi
                    3'b111: ALUControl = 4'b0010; // andi
                    3'b110: ALUControl = 4'b0011; // ori
                    3'b100: ALUControl = 4'b0101; // xori
                    3'b001: ALUControl = 4'b1010; // slli
                    3'b101: ALUControl = (funct7 == 7'b0100000) ? 4'b0111 : 4'b0110; // srai/srli
                    3'b010: ALUControl = 4'b1000; // slti
                    3'b011: ALUControl = 4'b1001; // sltiu
                    default: ALUControl = 4'b0000;
            endcase
            end
        7'b0000011: begin // Load
                RegWrite   = 1;
                ALUSrc    = 1;
                ResultSrc  = 1;
                ImmSrc     = 3'b000;
                ALUControl = 4'b0000; // add
            end
            
            7'b0100011: begin // Store
                MemWrite   = 1;
                ALUSrc     = 1;
                ImmSrc     = 3'b001;
                ALUControl = 4'b0000; // add
            end

            7'b1100011: begin // Branch
                ALUSrc = 1'b0;
                ImmSrc = 3'b010;
                ALUControl = 4'b0001; // sub for comparison
                case(funct3)  // Case for branch only when conditions met
                    3'b000: PCSrc = Zero; // BEQ
                    3'b001: PCSrc = ~Zero;  // BNE
                    // Next time
                    default: PCSrc = 0;
                endcase
            end

            7'b1101111: begin // J-type (jal)
                PCSrc      = 1;
                RegWrite   = 1;
                ImmSrc     = 3'b100;
                Jump       = 1; // Signals a jump
            end

            7'b0110111: begin // U-type (lui)
                ALUSrc     = 1;
                RegWrite   = 1;
                ImmSrc     = 3'b011;
                ALUControl = 4'b0000;
            end

            default: begin
                // Do nothing, keep default '0's
            end
        
        7'b1100111: begin // JALR (for ret Instructions)
            PCSrc = 1;
            RegWrite   = 1;      // Write PC+4 to rd
            ALUSrc     = 1;      // Use immediate
            ImmSrc     = 3'b000; // I-type immediate  
            ALUControl = 4'b0000; // ADD (rs1 + imm)
            Jump       = 1;      // Signal jump for PC+4 storage
        end
    endcase
end
endmodule
