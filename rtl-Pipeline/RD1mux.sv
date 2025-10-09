module RD1mux #(
    parameter DATA_WIDTH =32
)(
    input logic [1:0] ForwardAE,
    input logic [DATA_WIDTH-1:0] RD1E,
    input logic [DATA_WIDTH-1:0] ResultW,
    input logic [DATA_WIDTH-1:0] ALUResultM,

    output logic [DATA_WIDTH-1:0] SrcAE
);

    always_comb begin
        case(ForwardAE)
            2'b00: begin
                SrcAE = RD1E;
            end
            2'b01: begin
                SrcAE = ResultW;
            end
            2'b10: begin
                SrcAE = ALUResultM;
            end
            default: begin
            end
        endcase
    end

endmodule
