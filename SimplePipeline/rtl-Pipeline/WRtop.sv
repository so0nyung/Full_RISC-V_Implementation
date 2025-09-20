module WRtop #(
    parameter DATA_WIDTH =32
)(
    input logic RegWriteW,
    input logic [1:0] ResultSrcW,
    input logic [DATA_WIDTH-1:0] ALUResultW,
    input logic [DATA_WIDTH-1:0] ReadDataW,
    input logic [4:0] RdW,
    input logic [DATA_WIDTH-1:0] PCPlus4W,

    output logic RegWriteWout,
    output logic [DATA_WIDTH-1:0] ResultWout,
    output logic [4:0] RdWout
);

    always_comb begin

        case(ResultSrcW)
            2'b00: begin
                ResultWout = ALUResultW;
            end
            2'b01: begin
                ResultWout = ReadDataW;
            end
            2'b10: begin
                ResultWout = PCPlus4W;
            end
            default: begin
            end
        endcase
    end
    assign RdWout = RdW;
    assign RegWriteWout = RegWriteW;
endmodule
