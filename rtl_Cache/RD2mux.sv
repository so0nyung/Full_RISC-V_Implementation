module RD2mux #(
    parameter DATA_WIDTH =32
)(
    input logic [1:0] ForwardBE,
    input logic [DATA_WIDTH-1:0] RD2E,
    input logic [DATA_WIDTH-1:0] ResultW,
    input logic [DATA_WIDTH-1:0] ALUResultM,

    output logic [DATA_WIDTH-1:0] RD2Eout
);
    always_comb begin
        case(ForwardBE)
            2'b00: begin
                RD2Eout = RD2E;
            end
            2'b01: begin
                RD2Eout = ResultW;
            end
            2'b10: begin
                RD2Eout = ALUResultM;
            end
            default: begin
                RD2Eout = 32'b0;
            end
        endcase
    end
endmodule
