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
    input  logic [2:0]               funct3,        // load/store size
    input  logic [DATA_WIDTH-1:0]    mem_data,
    input  logic                     mem_ready,
    output logic                     hit,
    output logic                     miss,
    output logic                     mem_write,
    output logic                     mem_read,
    output logic                     busy,
    output logic [DATA_WIDTH-1:0]    data_out,
    output logic [DATA_WIDTH-1:0]    mem_addr,      // memory address
    output logic [DATA_WIDTH-1:0]    mem_write_data
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

    // Cache line: store full 32-bit words
    typedef struct packed {
        logic valid;
        logic dirty;
        logic [TAG_WIDTH-1:0] tag;
        logic [DATA_WIDTH-1:0] data;
    } line_t;

    // 2-way set-associative cache
    line_t cache[2**SET_WIDTH][2];
    logic [2**SET_WIDTH-1:0] lru; // 0: way0 LRU, 1: way1 LRU

    logic [TAG_WIDTH-1:0] tag;
    logic [SET_WIDTH-1:0] index;
    logic [DATA_WIDTH-1:0] word_addr;  // word-aligned address
    logic way;
    logic hit_way;
    
    // Extract fields from address
    assign word_addr = {address[DATA_WIDTH-1:2], 2'b00};
    assign tag       = word_addr[DATA_WIDTH-1:SET_WIDTH+2];
    assign index     = word_addr[SET_WIDTH+1:2];
    
    // Internal signal for UPDATE state (merged data on store miss)
    logic [DATA_WIDTH-1:0] merged_data;
    
    // Merge new store data with fetched memory line (for write-miss)
    always_comb begin
        merged_data = mem_data; // start with fetched word
        if (store) begin
            case(funct3)
                3'b000: begin // sb - store byte
                    case(address[1:0])
                        2'b00: merged_data[7:0]   = data_in[7:0];
                        2'b01: merged_data[15:8]  = data_in[7:0];
                        2'b10: merged_data[23:16] = data_in[7:0];
                        2'b11: merged_data[31:24] = data_in[7:0];
                    endcase
                end
                3'b001: begin // sh - store halfword
                    case(address[1])
                        1'b0: merged_data[15:0]  = data_in[15:0];
                        1'b1: merged_data[31:16] = data_in[15:0];
                    endcase
                end
                3'b010: merged_data = data_in; // sw - store word
                default: merged_data = data_in;
            endcase
        end
    end

    // Memory address: use cache line address for write-back, byte address otherwise
    assign mem_addr = (state == WRITE_BACK) ? 
                      {cache[index][way].tag, index, 2'b00} :
                      word_addr;

    // -------------------------
    // Data sizing logic
    // -------------------------
    logic [DATA_WIDTH-1:0] sized_write_data;
    logic [DATA_WIDTH-1:0] sized_read_data;
    
    // Handle store sizes (merge with cache line on hit)
    always_comb begin
        if (hit && store) begin
            sized_write_data = cache[index][hit_way].data;
            case(funct3)
                3'b000: case(address[1:0])
                    2'b00: sized_write_data[7:0]   = data_in[7:0];
                    2'b01: sized_write_data[15:8]  = data_in[7:0];
                    2'b10: sized_write_data[23:16] = data_in[7:0];
                    2'b11: sized_write_data[31:24] = data_in[7:0];
                endcase
                3'b001: case(address[1])
                    1'b0: sized_write_data[15:0]  = data_in[15:0];
                    1'b1: sized_write_data[31:16] = data_in[15:0];
                endcase
                3'b010: sized_write_data = data_in; // sw
                default: sized_write_data = data_in;
            endcase
        end else begin
            sized_write_data = data_in; // miss: will use merged_data later
        end
    end
    logic [DATA_WIDTH-1:0] source_data;

    // Handle load sizes (hit or miss)
    always_comb begin
        source_data = hit ? cache[index][hit_way].data : mem_data;
        case(funct3)
            3'b000: case(address[1:0]) // lb
                2'b00: sized_read_data = {{24{source_data[7]}},  source_data[7:0]};
                2'b01: sized_read_data = {{24{source_data[15]}}, source_data[15:8]};
                2'b10: sized_read_data = {{24{source_data[23]}}, source_data[23:16]};
                2'b11: sized_read_data = {{24{source_data[31]}}, source_data[31:24]};
            endcase
            3'b001: case(address[1])   // lh
                1'b0: sized_read_data = {{16{source_data[15]}}, source_data[15:0]};
                1'b1: sized_read_data = {{16{source_data[31]}}, source_data[31:16]};
            endcase
            3'b100: case(address[1:0]) // lbu
                2'b00: sized_read_data = {24'b0, source_data[7:0]};
                2'b01: sized_read_data = {24'b0, source_data[15:8]};
                2'b10: sized_read_data = {24'b0, source_data[23:16]};
                2'b11: sized_read_data = {24'b0, source_data[31:24]};
            endcase
            3'b101: case(address[1])   // lhu
                1'b0: sized_read_data = {16'b0, source_data[15:0]};
                1'b1: sized_read_data = {16'b0, source_data[31:16]};
            endcase
            3'b010: sized_read_data = source_data; // lw
            default: sized_read_data = source_data;
        endcase
    end

    // -------------------------
    // Hit/miss detection
    // -------------------------
    always_comb begin
        hit     = 0;
        hit_way = 0;

        // Check both ways for hit
        if (cache[index][0].valid && cache[index][0].tag == tag) begin
            hit = 1; hit_way = 0;
        end else if (cache[index][1].valid && cache[index][1].tag == tag) begin
            hit = 1; hit_way = 1;
        end

        // Pick replacement way: free way first, else LRU
        way = lru[index];
        if (!cache[index][0].valid) way = 0;
        else if (!cache[index][1].valid) way = 1;

        miss = !hit && (load || store);

        // Output sized data
        data_out = sized_read_data;

        // Memory write data: write-back old line or sized store data
        mem_write_data = (state == WRITE_BACK) ? cache[index][way].data : sized_write_data;
    end

    // -------------------------
    // Sequential FSM
    // -------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            busy <= 0;
            mem_read <= 0;
            mem_write <= 0;
            lru <= 0;
            for (int i = 0; i < 2**SET_WIDTH; i++) begin
                cache[i][0] <= '0;
                cache[i][1] <= '0;
            end
        end else begin
            unique case (state)
                IDLE: begin
                    busy <= miss;
                    mem_read  <= 0;
                    mem_write <= 0;

                    if (miss) begin
                        if (cache[index][way].valid && cache[index][way].dirty) begin
                            mem_write <= 1;
                            state <= WRITE_BACK;
                        end else if (load) begin
                            mem_read <= 1;
                            state <= READ_MISS;
                        end else begin
                            // store miss (write-allocate)
                            mem_read <= 1;
                            state <= WRITE_MISS;
                        end
                    end else if (hit) begin
                        if (store) begin
                            cache[index][hit_way].data  <= sized_write_data;
                            cache[index][hit_way].dirty <= 1;
                        end
                        // Update LRU
                        lru[index] <= hit_way ? 0 : 1;
                        busy <= 0;
                    end
                end

                WRITE_BACK: begin
                    if (mem_ready && mem_write) begin
                        mem_write <= 0;
                        if (load) begin
                            mem_read <= 1;
                            state <= READ_MISS;
                        end else if (store) begin
                            mem_read <= 1;
                            state <= WRITE_MISS;
                        end else begin
                            state <= IDLE;
                            busy <= 0;
                        end
                    end
                end

                READ_MISS: if (mem_ready) begin
                    mem_read <= 0;
                    state <= UPDATE;
                end

                WRITE_MISS: if (mem_ready) begin
                    mem_read <= 0;
                    state <= UPDATE;
                end

                UPDATE: begin
                    cache[index][way].valid <= 1;
                    cache[index][way].dirty <= store;
                    cache[index][way].tag   <= tag;
                    cache[index][way].data  <= store ? merged_data : mem_data;

                    // Update LRU
                    lru[index] <= way ? 0 : 1;

                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
