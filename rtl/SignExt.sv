    module SignExt #(
        parameter DATA_WIDTH = 32
    )(
        input [1:0] ImmSrc,
        input [DATA_WIDTH-1:7] ImmInput,
        output [DATA_WIDTH -1:0] ImmExt
    );

    always_comb begin
        case(ImmSrc)
                //I-type Immmediate
            3'b000: begin
                ImmExt = {{20{ImmInput[31]}}, ImmInput[31:20]};
            end
                //S-type Immediate
            3'b001:begin
                logic [11:0] immS;
                immS = {ImmInput[31:25],ImmInput[11:7]};
                ImmExt = {{20{immS[11]}}, immS};
            end
                // B-type Immediate: instr[31|7|30:25|11:8] + 1'b0 at LSB
            3'b010: begin
                logic[12:0] immB;
                immB = {ImmInput[31],ImmInput[7],ImmInput[30:25], ImmInput[11:8]};
                ImmExt = {{19{immB[12]}}, immB};
            end
                // U-type Immediate - Unextended (Upper 20 bits)
            3'b011: begin
                ImmExt = {ImmInput[31:12], 12'b0}; // no sign-extension
            end
            //J-type immediate: instr[31|19:12|20|30:21] + 0 at LSB
            3'b100: begin
                logic [20:0] immJ;
                immJ = {ImmInput[31],ImmInput[19:12],ImmInput[20],ImmInput[30:21], 1'b0}; // LSB is always 0
                ImmExt = {{11{immJ[20]}}, immJ};
            end

            default: ImmExt = 32'b0;
        endcase
    end

    endmodule