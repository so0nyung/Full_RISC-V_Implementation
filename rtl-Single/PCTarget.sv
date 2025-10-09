module PCTarget #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH -1 :0] PC,
    input logic [DATA_WIDTH -1 :0] ImmExt,
    input logic [DATA_WIDTH -1 :0] ALUResult,
    input logic [6:0] op, // To detect JALR
    output logic [DATA_WIDTH -1 :0] PCTarget
);

// New JALR added conditions
always_comb begin
    if (op == 7'b1100111) begin // JALR
        PCTarget = ALUResult & ~32'b1; // follows this instruction-> (rs1 + imm) & ~1
    end else begin // JAL and branches
        PCTarget = PC + ImmExt;
    end
end

endmodule
