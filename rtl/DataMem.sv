module DataMem #(
    parameter DATA_WIDTH = 32
)(
    input logic clk, // Clock Signal
    input logic WE, // Write Enable
    input logic [7:0] A, // Address
    input logic [DATA_WIDTH -1 :0] WD, // Write Data
    output logic [DATA_WIDTH -1 :0] RD // Read Data
);

    logic [DATA_WIDTH -1 :0] memory [0:255]; // Memory array of 256 words

    always_ff @(posedge clk) begin
        if (WE) begin
            memory[A] <= WD; // Write data to memory at address A
        end
    end

    always_comb begin
        RD = memory[A]; // Read data from memory at address A
    end
endmodule