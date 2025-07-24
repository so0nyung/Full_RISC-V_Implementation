module PCReg #(
    offset = 4,
    DATA_WIDTH = 32
)(
    input logic     clk,
    input logic     rst,
    input logic     [DATA_WIDTH-1 :0] next_PC,
    output logic    [DATA_WIDTH-1 :0 ] PC,
    output logic [DATA_WIDTH-1:0] inc_PC
);

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        PC <= '0;
        inc_PC <= '0;
    end else begin
        PC <= next_PC;
        inc_PC <= PC + offset;
    end
end

endmodule