module PCTarget #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] PC,
    input logic [DATA_WIDTH-1:0] ImmExt,
    input logic [DATA_WIDTH-1:0] ALUResultE,
    input logic JALRE,
    output logic [DATA_WIDTH-1:0] PCTarget
);

    always_comb begin
        if (JALRE)
            PCTarget = ALUResultE & ~32'b1; // force LSB=0
        else
            PCTarget = PC + ImmExt;
    end
endmodule
