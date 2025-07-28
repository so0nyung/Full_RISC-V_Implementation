module muxReg #(
    parameter DATA_WIDTH = 32
)(
    input logic PCsrc,
    input logic [DATA_WIDTH-1:0] branch_PC,
    input logic [DATA_WIDTH-1:0] inc_PC,
    output logic [DATA_WIDTH-1:0] next_PC
);

always_comb begin
    if(PCsrc) begin
        next_PC = branch_PC;
    end else begin
        next_PC = inc_PC;
    end
end

endmodule
