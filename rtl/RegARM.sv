module RegARM #(
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS = 32
)(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] AD1,
    input logic [DATA_WIDTH-1:0] AD2,
    input logic [DATA_WIDTH-1:0] AD3,
    input logic WE3, // Write enable :)
    input logic [DATA_WIDTH-1:0] WD3,
    output logic [DATA_WIDTH-1:0] RD1,
    output logic [DATA_WIDTH-1:0] RD2,
    output logic [DATA_WIDTH-1:0] a0
);

logic [DATA_WIDTH-1:0] regs [NUM_REGS];

always_ff @(posedge clk or posedge rst)begin
    if(rst) begin // Reset all registers
        for(int i = 0; i < NUM_REGS; i++) begin
            regs[i] <= '0;
        end
    end else if(WE3) begin // Write to address if enabled
        regs[AD3] <= WD3;
    end
end

assign RD1 = regs[AD1];
assign RD2 = regs[AD2];
assign a0 = regs[10]; // Location 0x10 

endmodule

