module JumpMux #(
    parameter DATA_WIDTH = 32
)(
    input logic Jump,
    input logic [DATA_WIDTH -1 :0] Result,
    input logic [DATA_WIDTH -1 :0] PCPlus4,
    output logic [DATA_WIDTH -1 :0] FinalResult
);

assign FinalResult = (Jump) ? PCPlus4: Result;

endmodule
