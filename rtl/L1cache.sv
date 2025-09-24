module L1cache #(
    parameter DATA_WIDTH = 32,
    parameter SET_WIDTH  = 9,
    parameter TAG_WIDTH  = DATA_WIDTH - SET_WIDTH - 2
)(
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     load,
    input  logic                     store,
    input  logic [DATA_WIDTH-1:0]    address,
    input  logic [DATA_WIDTH-1:0]    data_in,
    input  logic [2:0]               funct3,        
    input  logic [DATA_WIDTH-1:0]    mem_data,
    input  logic                     mem_ready,
    output logic                     hit,
    output logic                     miss,
    output logic                     mem_write,
    output logic                     mem_read,
    output logic                     busy,
    output logic [DATA_WIDTH-1:0]    data_out,
    output logic [DATA_WIDTH-1:0]    mem_addr,
    output logic [DATA_WIDTH-1:0]    mem_write_data
    // output logic [DATA_WIDTH-1:0] debug_cache_data,
    // output logic [TAG_WIDTH-1:0] debug_tag,
    // output logic [SET_WIDTH-1:0] debug_index,
    // output logic debug_hit_way,
    // output logic [DATA_WIDTH-1:0] debug_sized_write,
    // output logic [DATA_WIDTH-1:0] debug_actual_cache_line,
    // output logic [DATA_WIDTH-1:0] debug_sized_read

);

    // FSM states
    typedef enum logic [2:0] {
        IDLE,
        READ_MISS,
        WRITE_MISS,
        WRITE_BACK,
        UPDATE
    } state_t;

    state_t state;

    // Cache line - store full 32-bit words
    typedef struct packed {
        logic valid;
        logic dirty;
        logic [TAG_WIDTH-1:0] tag;
        logic [DATA_WIDTH-1:0] data;
    } line_t;

    // 2-way set-associative cache
    line_t cache[2**SET_WIDTH][2];
    logic [2**SET_WIDTH-1:0] LRU; // 0: way0 LRU, 1: way1 LRU

    logic [TAG_WIDTH-1:0] tag;
    logic [SET_WIDTH-1:0] index;
    /* verilator lint_off UNUSEDSIGNAL */
    logic [DATA_WIDTH-1:0] word_addr;  // Word-aligned address for cache lookup
    /* verilator lint_off UNUSEDSIGNAL */
    logic way;
    logic hit_way;
    
    // Extract word-aligned address for cache operations
    assign word_addr = {address[DATA_WIDTH-1:2], 2'b00};
    assign tag   = word_addr[DATA_WIDTH-1:SET_WIDTH+2];
    assign index = word_addr[SET_WIDTH+1:2];
    
// Direct byte address

    // -------------------------
    // Data sizing logic
    // -------------------------
    logic [DATA_WIDTH-1:0] sized_write_data;
    logic [DATA_WIDTH-1:0] sized_read_data;
    logic [DATA_WIDTH-1:0] base_data;

    // Handle different store sizes - merge with existing cache data
    always_comb begin
            if (hit) begin
                // Store hit - merge with existing cache data
                base_data = cache[index][hit_way].data;
            end else begin
                // Store miss - merge with memory data that we're reading
                base_data = mem_data;
            end
            
            sized_write_data = base_data;

        case(funct3)
            3'b000: begin // sb - store byte
                case(address[1:0])
                    2'b00: sized_write_data[7:0]   = data_in[7:0];
                    2'b01: sized_write_data[15:8]  = data_in[7:0];
                    2'b10: sized_write_data[23:16] = data_in[7:0];
                    2'b11: sized_write_data[31:24] = data_in[7:0];
                endcase
            end
            3'b001: begin // sh - store halfword
                case(address[1])
                    1'b0: sized_write_data[15:0]  = data_in[15:0];
                    1'b1: sized_write_data[31:16] = data_in[15:0];
                endcase
            end
            3'b010: begin // sw - store word
                sized_write_data = data_in;
            end
            default: sized_write_data = data_in;
        endcase
    end
            assign mem_addr = (state == WRITE_BACK) ? 
                      {cache[index][way].tag, index, 2'b00} : // Cache line address
                      address;                                 // Memory address - use word address for cache line operations, byte address for direct access

logic [DATA_WIDTH-1:0] latched_write_data;

    
    // Handle different load sizes - extract from cache data
    always_comb begin
        case(funct3)
            3'b000: begin // lb - load byte (sign-extended)
                case(address[1:0])
                    2'b00: sized_read_data = {{24{cache[index][hit_way].data[7]}},  cache[index][hit_way].data[7:0]};
                    2'b01: sized_read_data = {{24{cache[index][hit_way].data[15]}}, cache[index][hit_way].data[15:8]};
                    2'b10: sized_read_data = {{24{cache[index][hit_way].data[23]}}, cache[index][hit_way].data[23:16]};
                    2'b11: sized_read_data = {{24{cache[index][hit_way].data[31]}}, cache[index][hit_way].data[31:24]};
                endcase
            end
            3'b001: begin // lh - load halfword (sign-extended)
                case(address[1])
                    1'b0: sized_read_data = {{16{cache[index][hit_way].data[15]}}, cache[index][hit_way].data[15:0]};
                    1'b1: sized_read_data = {{16{cache[index][hit_way].data[31]}}, cache[index][hit_way].data[31:16]};
                endcase
            end
            3'b100: begin // lbu - load byte unsigned
                case(address[1:0])
                    2'b00: sized_read_data = {24'b0, cache[index][hit_way].data[7:0]};
                    2'b01: sized_read_data = {24'b0, cache[index][hit_way].data[15:8]};
                    2'b10: sized_read_data = {24'b0, cache[index][hit_way].data[23:16]};
                    2'b11: sized_read_data = {24'b0, cache[index][hit_way].data[31:24]};
                endcase
            end
            3'b101: begin // lhu - load halfword unsigned
                case(address[1])
                    1'b0: sized_read_data = {16'b0, cache[index][hit_way].data[15:0]};
                    1'b1: sized_read_data = {16'b0, cache[index][hit_way].data[31:16]};
                endcase
            end
            3'b010: begin // lw - load word
                sized_read_data = cache[index][hit_way].data;
            end
            default: sized_read_data = cache[index][hit_way].data;
        endcase
    end

    // -------------------------
    // Combinational logic
    // -------------------------
    always_comb begin
        hit = 0;
        hit_way = 0;

        // Check both ways for hit (using word-aligned address)
        if(cache[index][0].valid && cache[index][0].tag == tag) begin
            hit = 1; hit_way = 0;
        end else if(cache[index][1].valid && cache[index][1].tag == tag) begin
            hit = 1; hit_way = 1;
        end

        // Pick replacement way: free way first, else LRU
        way = LRU[index];
        if(!cache[index][0].valid) way = 0;
        else if(!cache[index][1].valid) way = 1;

        miss = !hit && (load || store);

        // Output properly sized data
        data_out = hit ? sized_read_data : mem_data;

        // Memory write data - for write-back operations
        mem_write_data = (state == WRITE_BACK) ? cache[index][way].data : latched_write_data;
    end

    // -------------------------
    // Sequential FSM
    // -------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
            busy <= 0;
            mem_read <= 0;
            mem_write <= 0;
            LRU <= 0;
            for(int i = 0; i < 2**SET_WIDTH; i++) begin
                cache[i][0] <= '0;
                cache[i][1] <= '0;
            end
        end else begin
            unique case(state)
                IDLE: begin
                    busy <= miss || (state != IDLE); // stall CPU on miss
                    mem_read <= 0;
                    mem_write <= 0;

                    if(miss) begin
                        // Check if replacement line is dirty
                        if(cache[index][way].valid && cache[index][way].dirty) begin
                            mem_write <= 1;
                            state <= WRITE_BACK;
                        end else if(load) begin
                            mem_read <= 1;
                            state <= READ_MISS;
                        end else begin
                            // Store miss (write-allocate)
                            mem_read <= 1;
                            state <= WRITE_MISS;
                        end
                    end else if(hit) begin
                        // Hit handling
                        if(store) begin
                            cache[index][hit_way].data <= sized_write_data;
                            cache[index][hit_way].dirty <= 1;
                            latched_write_data <= sized_write_data; // Add this line

                        end
                        // Update LRU on hit
                        LRU[index] <= hit_way ? 0 : 1;
                        busy <= 0;
                    end
                end

                WRITE_BACK: begin
                    busy <= 1;
                    if(mem_ready && mem_write) begin
                        mem_write <= 0;
                        if(load) begin
                            mem_read <= 1;
                            state <= READ_MISS;
                        end else if(store) begin
                            mem_read <= 1;
                            state <= WRITE_MISS;
                        end else begin
                            state <= IDLE;
                            busy <= 0;
                        end
                    end
                end

                READ_MISS: begin
                    busy <= 1;

                    if(mem_ready) begin
                        mem_read <= 0;
                        state <= UPDATE;
                    end
                end

                WRITE_MISS: begin
                    busy <= 1;
                    if(mem_ready) begin
                        mem_read <= 0;
                        // Latch the write data when memory is ready
                        latched_write_data <= sized_write_data;
                        state <= UPDATE;
                    end
                end


                UPDATE: begin
                    cache[index][way].valid <= 1;
                    cache[index][way].dirty <= store;
                    cache[index][way].tag   <= tag;
                    // Use latched data instead of combinational logic
                    cache[index][way].data  <= store ? latched_write_data : mem_data;
                    
                    // Update LRU
                    LRU[index] <= way ? 0 : 1;
                    
                    busy <= 0;
                    state <= IDLE;
                end

            endcase
        end
    end

// // Debugging assignments
// assign debug_cache_data = cache[index][hit_way].data;
// assign debug_tag = tag;
// assign debug_index = index;
// assign debug_hit_way = hit_way;
// assign debug_sized_write = sized_write_data;
// assign debug_sized_read = sized_read_data;
// assign debug_actual_cache_line = cache[index][way].data;
endmodule
