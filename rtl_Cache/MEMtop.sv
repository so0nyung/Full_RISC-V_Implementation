module MEMtop #(
    parameter DATA_WIDTH = 32
)(
    input  logic clk,
    input  logic rst,
    input  logic RegWriteM,
    input  logic [1:0] ResultSrcM,
    input  logic MemWriteM,
    input  logic [DATA_WIDTH-1:0] ALUResultM,   // store/load address
    input  logic [DATA_WIDTH-1:0] WriteDataM,   // store data
    input  logic [4:0] RdM,
    input  logic [DATA_WIDTH-1:0] PCPlus4M,
    input  logic [2:0] funct3M,                 // load/store size
    output logic RegWriteMout,
    output logic [1:0] ResultSrcMout,
    output logic [DATA_WIDTH-1:0] ReadDataM,    // memory output to CPU
    output logic [4:0] RdMout,
    output logic [DATA_WIDTH-1:0] PCPlus4Mout,
    output logic [DATA_WIDTH-1:0] ALUResultMout,
    output logic cache_busy                     // for HazardUnit stall
);

    // Cache-Memory interface signals
    logic CacheMem_Read;
    logic CacheMem_Write; 
    logic CacheMem_Ready;
    logic [DATA_WIDTH-1:0] CacheMem_Data;
    logic [DATA_WIDTH-1:0] CacheMem_Addr;
    logic [DATA_WIDTH-1:0] CacheMem_WriteData;

    // Cache control signals  
    logic Int_CacheBusy;
    logic CPULoad;
    logic CPUStore;

    // Generate load/store signals based on CPU operations
    assign CPULoad  = (ResultSrcM == 2'b01);  // Load instruction detected
    assign CPUStore = MemWriteM;              // Store instruction detected

    // Debug signals (optional)
    /* verilator lint_off UNUSEDSIGNAL */
    logic CacheHit;
    logic CacheMiss;
    /* verilator lint_on UNUSEDSIGNAL */

    // L1 Cache instance
    L1cache #(
        .DATA_WIDTH(DATA_WIDTH),
        .SET_WIDTH(9),                         // 512 sets (2^9)
        .TAG_WIDTH(DATA_WIDTH - 9 - 2)        // 21 bits for tag (32-9-2)
    ) Cache (
        .clk(clk),
        .rst_n(~rst),                          // Cache uses active-low reset
        .load(CPULoad),
        .store(CPUStore),
        .address(ALUResultM),                  // Byte-addressed memory access
        .data_in(WriteDataM),
        .funct3(funct3M),
        .mem_data(CacheMem_Data), // From Data Memory
        .mem_ready(CacheMem_Ready),
        .hit(CacheHit),
        .miss(CacheMiss),
        .mem_write(CacheMem_Write), // To Memory
        .mem_read(CacheMem_Read),
        .busy(Int_CacheBusy),
        .data_out(ReadDataM), // Output
        .mem_addr(CacheMem_Addr),
        .mem_write_data(CacheMem_WriteData) // To Memory 
    );

    // Data Memory accessed only through cache
    DataMem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(17)
    ) Data_Memory (
        .clk(clk),
        .funct3(funct3M),
        .MemWrite(CacheMem_Write),            // Cache controls memory writes
        .A(CacheMem_Addr),                    // Cache provides memory address
        .WD(CacheMem_WriteData),             // Cache provides write data
        .RD(CacheMem_Data)                    // Memory provides read data to cache
    );

    // Memory ready and stall logic
    assign CacheMem_Ready = CacheMem_Read || CacheMem_Write;
    assign cache_busy = Int_CacheBusy;

    // Pipeline register passthrough
    assign RegWriteMout  = RegWriteM;
    assign ResultSrcMout = ResultSrcM;
    assign RdMout        = RdM;
    assign PCPlus4Mout   = PCPlus4M;
    assign ALUResultMout = ALUResultM;

endmodule
