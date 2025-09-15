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
    // input logic BranchD,       // From IDtop (decode stage control signals)
    // input logic JumpD,         // From IDtop
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

    // Forwarding constants
    localparam [1:0] FORWARD_REG = 2'b00;  // Use register file (no forwarding)
    localparam [1:0] FORWARD_MEM = 2'b10;  // Forward from MEM stage (ALUResultM)
    localparam [1:0] FORWARD_WB  = 2'b01;  // Forward from WB stage (ResultW)
    
    // Internal signals for hazard detection
    logic LoadUseHazard;
    logic ControlHazard;

    // DATA FORWARDING LOGIC
    // Handles RAW (Read After Write) hazards by forwarding data from later stages
    always_comb begin
        // Default: no forwarding, use register file
        ForwardAE = FORWARD_REG;
        ForwardBE = FORWARD_REG;
        
        // Forwarding for Rs1E (operand A)
        // Priority: MEM stage > WB stage (MEM is more recent)
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E)) begin
            ForwardAE = FORWARD_MEM;
        end else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E) && 
                     !(RegWriteM && (RdM != 5'b0) && (RdM == Rs1E))) begin
            ForwardAE = FORWARD_WB;
        end
        
        // Forwarding for Rs2E (operand B)
        // Priority: MEM stage > WB stage (MEM is more recent)
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E)) begin
            ForwardBE = FORWARD_MEM;
        end else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E) && 
                     !(RegWriteM && (RdM != 5'b0) && (RdM == Rs2E))) begin
            ForwardBE = FORWARD_WB;
        end
    end

    // LOAD-USE HAZARD DETECTION
    // Detects when a load instruction in execute stage is immediately followed
    // by an instruction in decode stage that uses the loaded data
    always_comb begin
        LoadUseHazard = 1'b0;
        
        // Check if current execute instruction is a load (MemReadE = 1)
        // and the decode stage instruction uses the destination register
        if (MemReadE && (RdE != 5'b0)) begin
            if ((RdE == Rs1D) || (RdE == Rs2D)) begin
                LoadUseHazard = 1'b1;
            end
        end
    end

    // CONTROL HAZARD DETECTION
    // Detects control hazards from branches and jumps
    always_comb begin
        ControlHazard = 1'b0;
        
        // Method 1: Reactive - flush when branch/jump is actually taken
        // This occurs when PCSrcE=1, indicating the branch was taken or jump executed
        if (PCSrcE) begin
            ControlHazard = 1'b1;
        end
        
        // Method 2: Proactive - could flush immediately when branch/jump is detected
        // This would be more conservative but handles all branches/jumps
        // Uncomment below for more aggressive flushing (flushes ALL branches, not just taken ones):
        /*
        if (BranchD || JumpD) begin
            ControlHazard = 1'b1;
        end
        */
    end

    // PIPELINE STALL LOGIC
    // Stalls prevent new instructions from entering stalled stages
    always_comb begin
        StallF = 1'b0;
        StallD = 1'b0;
        
        // Stall for load-use hazard
        // Stall fetch and decode to give load time to complete
        if (LoadUseHazard) begin
            StallF = 1'b1;  // Prevent new instruction fetch
            StallD = 1'b1;  // Keep current decode instruction
        end
        
        // Note: We don't stall for control hazards - we flush instead
        // This is because stalling wouldn't help with mispredicted branches
    end

    // PIPELINE FLUSH LOGIC
    // Flushes convert instructions to NOPs by clearing control signals
    always_comb begin
        FlushD = 1'b0;
        FlushE = 1'b0;
        
        // Flush for control hazards (branch misprediction or jumps)
        // Clear incorrectly fetched/decoded instructions
        if (ControlHazard) begin
            FlushD = 1'b1;  // Clear decode stage (wrong instruction fetched)
            FlushE = 1'b1;  // Clear execute stage (wrong instruction decoded)
        end
        
        // Flush execute stage for load-use hazard
        // Insert bubble (NOP) in execute stage while stalling earlier stages
        if (LoadUseHazard) begin
            FlushE = 1'b1;  // Convert execute stage to NOP
        end
    end

endmodule
