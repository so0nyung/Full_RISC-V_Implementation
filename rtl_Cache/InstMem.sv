module InstMem #(
    parameter DATA_WIDTH =32
)(
    input logic [11:0] A,
    output logic [DATA_WIDTH-1:0] Instr
);
    logic [7:0] rom [2**12-1:0]; // 0xBFC00000 - 0xBFC00FFF

    always_comb begin
        Instr = {rom[A[11:0] + 3], rom[A[11:0] + 2], rom[A[11:0] + 1], rom[A[11:0]]};
    end

    initial begin
        $readmemh("program.hex", rom);
    end
endmodule
