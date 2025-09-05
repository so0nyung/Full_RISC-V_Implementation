module RegFile #(
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS = 32
)(
    input logic clk,
    input logic [$clog2(NUM_REGS)-1 :0] A1,
    input logic [$clog2(NUM_REGS)-1 :0] A2,
    input logic [$clog2(NUM_REGS)-1 :0] A3,
    input logic [DATA_WIDTH -1 :0] WD3, // Data to Write
    input logic WE3,
    output logic [DATA_WIDTH -1 :0] RD1, // Read Data 1
    output logic [DATA_WIDTH -1 :0] RD2, // Read Data 2
    output logic [DATA_WIDTH -1 :0] a0 // a0 test output
);
logic [DATA_WIDTH -1:0] regs [NUM_REGS];

initial begin
    for (int i = 0; i < NUM_REGS; i++) begin
        regs[i] = 32'b0;
    end
end

always_ff @(posedge clk) begin
    if(WE3 && A3 != 0) begin  // Do not write to x0
        regs[A3] <= WD3; // Write
    end
end

    assign RD1 = (A1== 0) ? 32'b0 :regs[A1];
    assign RD2 = (A2== 0) ? 32'b0 : regs[A2];
    assign a0 = regs[10]; //0x10
endmodule
