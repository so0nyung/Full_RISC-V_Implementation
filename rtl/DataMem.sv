module DataMem #(
    parameter DATA_WIDTH = 32
)(
    input logic clk, // Clock Signal
    input logic WE, // Write Enable
    input logic [DATA_WIDTH-1:0] A, // Address
    input logic [DATA_WIDTH -1 :0] WD, // Write Data
    output logic [DATA_WIDTH -1 :0] RD // Read Data
);
    localparam BASE_ADDR = 32'h00002000;
    logic [9:0] word_addr;
    assign word_addr = (A - BASE_ADDR) >> 2;


    logic [DATA_WIDTH -1 :0] memory [0:1023]; // Memory array of 256 words

    always_ff @(posedge clk) begin
        if (WE) begin
            memory[word_addr] <= WD; // Write data to memory at address A
        end
    end

    always_comb begin
        RD = memory[word_addr]; // Read data from memory at address A
    end
endmodule