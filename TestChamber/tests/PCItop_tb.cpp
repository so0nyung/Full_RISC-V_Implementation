#include <iostream>
#include "base_testbench.h"
Vdut* top;
VerilatedVcdC * tfp;
unsigned int ticks = 0; 

class PCITestbench : public BaseTestbench{
    protected:
        void initializeInputs() override {
            top->clk = 0;
            top->PCSrc = 0;
            top->PCTarget = 0;
        }

        void clockCycle() {
            top->clk = 0;
            top->eval();
            top->clk = 1;
            top->eval();
        }
};

TEST_F(PCITestbench, InitialTest){
    EXPECT_EQ(top->Instr, 0); // We expect the initial instruction to be 0
}

TEST_F(PCITestbench, PCSrcTest){
    top->PCSrc = 0; //Next Instruction to be PCPlus4
    top-> PCTarget = 0; // Test
    clockCycle();
    EXPECT_EQ(top->Instr, 0x00200113);

    top->PCSrc = 1;
    clockCycle();
    EXPECT_EQ(top->Instr, 0x00000093);
}



int main(int argc, char **argv){
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp,99);
    tfp->open("PCITestWaveform.vcd");
    testing::InitGoogleTest(&argc, argv);
    auto result = RUN_ALL_TESTS();
    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return result;
}