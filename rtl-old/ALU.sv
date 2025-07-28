module ALU #(
    DATA_WIDTH = 32
)(
    input logic ALUctrl,
    input logic [DATA_WIDTH-1:0] ALUop1,
    input logic [DATA_WIDTH-1:0] ALUop2,
    output logic [DATA_WIDTH-1:0] ALUout,
    output logic EQ
);

assign ALUout = ALUctrl ? (ALUop1 + ALUop2) : (ALUop1 - ALUop2);

always_comb begin
    EQ = (ALUop1 == ALUop2);
end

endmodule