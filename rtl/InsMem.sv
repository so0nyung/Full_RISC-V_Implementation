module InsMem#(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] instr
);


    // Memory array: 256 words (can expand if needed)
    logic [31:0] mem [0:255];

    // Read from instruction memory
    assign instr = mem[addr[9:2]];  // word-aligned access (ignore bottom 2 bits)

 
    // Optional: load from hex or bin file for simulation
    initial begin
        $readmemh("program.hex", mem);  // or $readmemb
    end
endmodule