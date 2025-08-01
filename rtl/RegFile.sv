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
    output logic [DATA_WIDTH -1 :0] RD2 // Read Data 2
);
logic [DATA_WIDTH -1:0] regs [NUM_REGS];

always_ff @(posedge clk) begin
    if(WE3) begin 
        regs[A3] <= WD3; // Write
    end
end

    assign RD1 = regs[A1];
    assign RD2 = regs[A2];
endmodule