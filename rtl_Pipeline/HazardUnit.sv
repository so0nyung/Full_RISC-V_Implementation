module HazardUnit (
    // Forwarding stage inputs
    input logic [4:0] Rs1E, // From IDEXReg
    input logic [4:0] Rs2E, // From IDEXReg
    input logic [4:0] RdE,  // From IDEXReg
    
    // Memory stage
    input logic [4:0] RdM,     // From ExMemReg -> Memory -> MemWRReg
    input logic RegWriteM,     // From ExMemReg -> Memory -> MemWRReg

    // Writeback stage
    input logic [4:0] RdW,     // From MemWRReg
    input logic RegWriteW,     // From MemWRReg

    // Load-Use Hazard Detection
    input logic MemReadE,      // From Execute stage (indicates load instruction)
    input logic [4:0] Rs1D,    // From IDtop (decode stage source registers)
    input logic [4:0] Rs2D,    // From IDtop
    
    // Control Hazard Detection
    input logic PCSrcE,        // From Execute stage (indicates taken branch/jump)

    // Pipeline control outputs
    output logic StallF,       // To IFtop - stall fetch stage
    output logic StallD,       // To IFIDReg - stall decode stage
    output logic FlushD,       // To IFIDReg - flush decode stage
    output logic FlushE,       // To IDEXReg - flush execute stage

    // Data Forwarding outputs  
    output logic [1:0] ForwardAE, // For Rs1E
    output logic [1:0] ForwardBE  // For Rs2E
);    
    // DATA FORWARDING LOGIC
    always_comb begin
        // Default: Use register file (no forwarding)
        ForwardAE = 2'b00;  
        ForwardBE = 2'b00;
        
        // Forwarding for Rs1E MEM stage priority over WB stage (MEM is more recent)
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E)) begin
            ForwardAE = 2'b10;  // Forward from MEM stage (ALUResultM)
        end else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E) && 
                     !(RegWriteM && (RdM != 5'b0) && (RdM == Rs1E))) begin
            ForwardAE = 2'b01;  // Forward from WB stage (ResultW)
        end
        
        // Forwarding for Rs2E 
        // Priority: MEM stage > WB stage (MEM is more recent)
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E)) begin
            ForwardBE = 2'b10;  // Forward from MEM stage (ALUResultM)
        end else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E) && 
                     !(RegWriteM && (RdM != 5'b0) && (RdM == Rs2E))) begin
            ForwardBE = 2'b01;  // Forward from WB stage (ResultW)
        end
    end
    // Internal signals for hazard detection
    logic LoadUseHazard;
    logic ControlHazard;


    // Hazard Detection
    always_comb begin
        LoadUseHazard = 1'b0;
        ControlHazard = 1'b0;

        //Load Hazard Detection
        if (MemReadE && (RdE != 5'b0)) begin
            // Check if the instruction in decode stage needs the load result
            if (((RdE == Rs1D) && (Rs1D != 5'b0)) || 
                ((RdE == Rs2D) && (Rs2D != 5'b0))) begin
                LoadUseHazard = 1'b1;
            end
        end
        // Detects if there's a Jump / Branch
        if (PCSrcE) begin
            ControlHazard = 1'b1;
        end


    end

    // Stall + Flush Flag logic
    always_comb begin
        StallF = 1'b0;
        StallD = 1'b0;
        FlushD = 1'b0;
        FlushE = 1'b0;

        //Load-use hazard detected
        if (LoadUseHazard) begin
            StallF = 1'b1;  // Prevent new instruction fetch
            StallD = 1'b1;  // Keep current decode instruction frozen
            FlushE = 1'b1;  // Convert execute stage to NOP
        end
        // Control hazards
        if (ControlHazard) begin 
            FlushD = 1'b1;  
            FlushE = 1'b1;  
        end
    end

endmodule
