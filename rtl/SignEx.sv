module SignEx#(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH -1 :0] instr,
    input logic Immsrc,
    output logic [DATA_WIDTH -1 :0] ImmOp
);

    always_comb begin
        case (Immsrc)
            1'b0: begin // I-type
                ImmOp = {{20{instr[31]}}, instr[31:20]};
            end
            1'b1: begin // S-type
                ImmOp = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            default: ImmOp = 32'b0;
        endcase
    end
endmodule