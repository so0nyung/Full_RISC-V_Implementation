module DataMem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 17
)(
    input logic clk, // Clock Signal
    input logic [2:0] funct3, // SizeCtr
    input logic MemWrite, // Write Enable (WE)
    input logic [DATA_WIDTH-1:0] A, // Address / ALUResult
    input logic [DATA_WIDTH -1 :0] WD, // Write Data
    output logic [DATA_WIDTH-1 :0] RD // Read Data
);

//initialise memory
logic [7:0] memory [2**ADDR_WIDTH-1:0];
initial begin
    $readmemh("data.hex", memory, 17'h10000);
end

// To write to memory
always_ff @(posedge clk) begin
    if(MemWrite) begin
        case(funct3)
        3'b010: begin // Load word instructions
            memory[A] <= WD[7:0];
            memory[A+1]   <= WD[15:8];
            memory[A+2]   <= WD[23:16];
            memory[A+3]   <= WD[31:24];           
        end
        3'b001: begin // Load half
            memory[A]     <= WD[7:0];
            memory[A+1]   <= WD[15:8];
        end
        3'b000: begin // Load byte
            memory[A]   <= WD[7:0];
        end
        default ;
        endcase
    end
end


// Reading Data
    always_comb begin
        case (funct3)
            3'b010: begin
                RD = {memory[A+3], memory[A+2], memory[A+1], memory[A]};
            end
            3'b001: begin
                RD = {{16{memory[A+1][7]}}, memory[A+1], memory[A]};
            end
            3'b000: begin
                RD = {{24{memory[A][7]}}, memory[A]};
            end
            3'b100: begin
                RD = {24'b0, memory[A]};
            end
            3'b101: begin
                RD = {16'b0, memory[A+1], memory[A]};
            end
            default: RD = 32'b0;
        endcase
    end
endmodule
