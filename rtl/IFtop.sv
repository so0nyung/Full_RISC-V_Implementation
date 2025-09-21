module IFtop#(
    parameter DATA_WIDTH = 32
)(
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] PCTargetE, // From Execute
    input logic PCSrcE, // From Execute Stage
    input logic StallF, // From Hazard Unit
    input logic trigger, // For F1
    //OUTPUT
    output logic [DATA_WIDTH-1:0] Instr,
    output logic [DATA_WIDTH-1:0] PCF,
    output logic [DATA_WIDTH-1:0] PCPlus4F
);

//Internal Wires
logic [DATA_WIDTH-1:0] Int_PCF;
logic [DATA_WIDTH-1:0] Int_PCPlus4F;
logic [DATA_WIDTH-1:0] Int_PCFmux;

PCImux #(
    .DATA_WIDTH(DATA_WIDTH)
) mux(
    .PCSrc(PCSrcE),
    .PCPlus4(Int_PCPlus4F),
    .PCTarget(PCTargetE),
    .PCNext(Int_PCFmux)
);

PCPlus #( // +4 Module
    .DATA_WIDTH(DATA_WIDTH)
) Plus4(
    .PC(Int_PCF),
    .PCPlus4(Int_PCPlus4F)
);

//Instruction Memory
InstMem #(
    .DATA_WIDTH(DATA_WIDTH)
) Instr_Memory(
    .A(Int_PCF[11:0]),
    .Instr(Instr)
);

always_ff @(posedge clk) begin
    if (rst) begin
        // Reset PC to start address
        Int_PCF <= 32'h00000000;  
    end 
    else if (PCSrcE) begin  
        // Branch or jump has highest priority
        Int_PCF <= PCTargetE;
    end 
    else if (!StallF & trigger) begin  
        // Normal sequential update (stall freezes PC)
        Int_PCF <= Int_PCFmux;
    end 
    // else: StallF=1, hold current Int_PCF (do nothing)
end


//Assigning internal wires
assign PCF = Int_PCF;
assign PCPlus4F = Int_PCPlus4F;

endmodule
