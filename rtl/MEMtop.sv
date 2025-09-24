module MEMtop #(
    parameter DATA_WIDTH = 32,
    parameter ENABLE_CACHE = 1  // Enable/disable cache (For testing)
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
    logic cache_mem_read;
    logic cache_mem_write; 
    logic cache_mem_ready;
    logic [DATA_WIDTH-1:0] cache_mem_data;
    logic [DATA_WIDTH-1:0] cache_mem_addr;
    logic [DATA_WIDTH-1:0] cache_mem_write_data;
    logic [DATA_WIDTH-1:0] direct_mem_data;
    
    // Cache control signals  
    logic cache_busy_internal;
    logic cpu_load;
    logic cpu_store;
    
    // Generate load/store signals based on CPU operations
    assign cpu_load = (ResultSrcM == 2'b01);  // Load instruction detected
    assign cpu_store = MemWriteM;              // Store instruction detected

    // Debug signals (can be removed in production)
    /* verilator lint_off UNUSEDSIGNAL */
    logic cache_hit, cache_miss;
    /* verilator lint_on UNUSEDSIGNAL */

    generate
        if (ENABLE_CACHE) begin : gen_cache
            // L1 Cache instance
            L1cache #(
                .DATA_WIDTH(DATA_WIDTH),
                .SET_WIDTH(9),                         // 512 sets (2^9)
                .TAG_WIDTH(DATA_WIDTH - 9 - 2)        // 21 bits for tag (32-9-2)
            ) l1_cache_inst (
                .clk(clk),
                .rst_n(~rst),                          // Cache uses active-low reset
                .load(cpu_load),
                .store(cpu_store),
                .address(ALUResultM),                  // Byte-addressed memory access
                .data_in(WriteDataM),
                .funct3(funct3M),
                .mem_data(cache_mem_data),
                .mem_ready(cache_mem_ready),
                .hit(cache_hit),
                .miss(cache_miss),
                .mem_write(cache_mem_write),
                .mem_read(cache_mem_read),
                .busy(cache_busy_internal),
                .data_out(ReadDataM),
                .mem_addr(cache_mem_addr),
                .mem_write_data(cache_mem_write_data)
            );

            // Data Memory instance - accessed only through cache
            DataMem #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(17)                        // Ensure sufficient address width
            ) Data_Memory (
                .clk(clk),
                .funct3(funct3M),                      // Pass through for memory sizing
                .MemWrite(cache_mem_write),            // Cache controls memory writes
                .A(cache_mem_addr),                    // Cache provides memory address
                .WD(cache_mem_write_data),             // Cache provides write data
                .RD(cache_mem_data)                    // Memory provides read data to cache
            );

            // Simple memory ready logic - DataMem responds immediately
            assign cache_mem_ready = cache_mem_read || cache_mem_write;
            assign cache_busy = cache_busy_internal;
            
        end else begin : gen_direct
            // Direct memory access path (bypass cache entirely)
            DataMem #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(17)
            ) Data_Memory (
                .clk(clk),
                .funct3(funct3M),
                .MemWrite(MemWriteM),      // CPU directly controls memory writes
                .A(ALUResultM),            // CPU directly provides memory address
                .WD(WriteDataM),           // CPU directly provides write data
                .RD(direct_mem_data)       // Memory directly provides read data
            );
            
            // Direct assignment for non-cached mode
            assign ReadDataM = direct_mem_data;
            assign cache_busy = 1'b0;      // Never stall pipeline when no cache
            
            // Tie off unused cache interface signals
            assign cache_mem_read = 1'b0;
            assign cache_mem_write = 1'b0;
            assign cache_mem_ready = 1'b0;
            assign cache_mem_data = 32'b0;
            assign cache_mem_addr = 32'b0;
            assign cache_mem_write_data = 32'b0;
            assign cache_hit = 1'b0;
            assign cache_miss = 1'b0;
            assign cache_busy_internal = 1'b0;
        end
    endgenerate

    // Pipeline register passthrough
    assign RegWriteMout  = RegWriteM;
    assign ResultSrcMout = ResultSrcM;
    assign RdMout        = RdM;
    assign PCPlus4Mout   = PCPlus4M;
    assign ALUResultMout = ALUResultM;

endmodule
