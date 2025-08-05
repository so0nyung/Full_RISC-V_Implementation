#include <iostream>
#include "base_testbench.h"
Vdut* top;
VerilatedVcdC * tfp;
unsigned int ticks = 0; 

class SignExtTestbench : public BaseTestbench{
    protected:
        void initializeInputs() override {
            top->ImmSrc = 0;
            top->ImmInput = 0;
            top->ImmExt = 0;
        }

        void clockCycle() {
            top->clk = 0;
            top->eval();
            top->clk = 1;
            top->eval();
        }
};

TEST_F(SignExtTestbench, ItypeTest){
    top->ImmSrc = 0xFFF0000; // 1111 1111 1111 0000 0000 0000 0000 0000 
    top->ImmInput = 0; // I-type Immediate
    EXPECT_EQ(top->ImmExt, 0xFFFF);
}

TEST_F(SignExtTestbench, StypeTest){
    top->ImmSrc = 0xFE000F80; // 1111 1110 0000 0000 0000 1111 1000 0000
    top->ImmInput = 1; //S-type Immediate
    EXPECT_EQ(top->ImmExt, 0xFFFFFFFF);
}

TEST_F(SignExtTestbench, BtypeTest){
    top->ImmSrc = 0xC2000F00; // 1100 0010 0000 0000 0000 1111 0000 0000
    top->ImmInput = 2; // B-type
    EXPECT_EQ(top->ImmExt, 0x7FFFFC1F); // 1111 1111 1111 1111 1111 1000 001 1111
}

TEST_F(SignExtTestbench, UtypeTest){
    top->ImmSrc = ; // 1111 1111 1111 1111 1111 1111 1111 1111
    top->ImmInput = 3;  //U-type
    EXPECT_EQ(top->ImmExt, 0xFFFFF000);
}

TEST_F(SignExtTestbench, JtypeTest){
    top->ImmSrc = 0x80100000; //1000 0000 0001 0000 0000 0000 0000 0000
    top->ImmInput = 4; // J-type
    EXPECT_EQ(top->ImmExt, 0xFFF00800); //1111 1111 1111 0000 0000 1000 0000 0000
}

int main(int argc, char **argv){
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp,99);
    tfp->open("CRETestWaveform.vcd");
    testing::InitGoogleTest(&argc, argv);
    auto result = RUN_ALL_TESTS();
    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return result;
}