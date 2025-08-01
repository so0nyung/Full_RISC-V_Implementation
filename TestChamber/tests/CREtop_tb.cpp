#include <iostream>
#include "base_testbench.h"
Vdut* top;
VerilatedVcdC * tfp;
unsigned int ticks = 0; 

class CRETestbench : public BaseTestbench{
    protected:
        void initializeInputs() override {
            top->clk = 0;
            top->instr = 0;
            top->zero = 0;
            top->WD3 = 0;
        }

        void clockCycle() {
            top->clk = 0;
            top->eval();
            top->clk = 1;
            top->eval();
        }
};

TEST_F(CRETestbench, InitialisationTest){
    clockCycle();
    EXPECT_EQ(top->PCSrc, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->MemWrite,0);
    EXPECT_EQ(top->ALUControl, 0);
    EXPECT_EQ(top->ALUSrc, 0);
    EXPECT_EQ(top->ImmSrc,0);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->SrcA,0);
    EXPECT_EQ(top->SrcBOut,0);
}

TEST_F(CRETestbench, XYZ){
    
}

int main(int argc, char **argv){
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp,99);
    tfp->open("waveform.vcd");
    testing::InitGoogleTest(&argc, argv);
    auto result = RUN_ALL_TESTS();
    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return result;
}