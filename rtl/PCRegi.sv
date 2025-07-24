module PCRegi #(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    //input logic [DATA_WIDTH-1:0] next_PC,
    input logic PCsrc,
    input logic [DATA_WIDTH-1:0] ImmOperator,
    output logic [DATA_WIDTH-1:0] PC
    // output logic [DATA_WIDTH-1:0] inc_PC
);

// Internal signals to manage between module operations
logic [ DATA_WIDTH -1 :0] current_PC;
logic [DATA_WIDTH-1:0] branch_PC_loc;
logic [DATA_WIDTH-1:0] next_PC_loc;

muxReg #(
    .DATA_WIDTH(DATA_WIDTH)
) mux(
    .PCsrc(PCsrc), 
    .branch_PC(branch_PC_loc),
    .inc_PC(inc_PC),
    .next_PC(next_PC_loc)
);

PCReg #(
    .offset(4),
    .DATA_WIDTH(DATA_WIDTH)
) pc_reg(
    .clk(clk),
    .rst(rst),
    .next_PC(next_PC_loc),
    .PC(current_PC),
    .inc_PC(inc_PC)
);

PCAdd #(
    .DATA_WIDTH(DATA_WIDTH)  
) adder(
    .PC(current_PC),
    .ImmOp(ImmOperator), 
    .branch_PC(branch_PC_loc) 
);   

assign PC = current_PC;

endmodule