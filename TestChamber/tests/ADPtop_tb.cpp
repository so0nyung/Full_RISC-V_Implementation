#include <iostream>
#include "base_testbench.h"

Vdut* top;
VerilatedVcdC * tfp;
unsigned int ticks = 0; 

class ADPTestbench : public BaseTestbench{
protected:
    void initializeInputs() override {
        top->clk = 0;
        top->SrcA = 0;
        top->SrcB = 0;
        top->PC = 0;
        top->ImmExt = 0;
        top->MemWrite = 0;
        top->ResultSrc = 0;
        top->WriteData = 0;
        top->ALUControl = 0;
    }
    
    // Helper function to perform a clock cycle
    void clockCycle() {
        top->clk = 0;
        top->eval();
        top->clk = 1;
        top->eval();
    }
    
    // // Helper function to reset the system (Not needed)
    // void resetSystem() {
    //     top->rst = 1;
    //     clockCycle();
    //     top->rst = 0;
    //     clockCycle();
    // }
};


TEST_F(ADPTestbench, ALUADDTest){
    top->ALUControl = 0; // Set ALU to ADD operation
    top->SrcA = 5;       // First operand
    top->SrcB = 3;       // Second operand
    top->eval();         // Evaluate the design
    //std::cout << "ALU ADD result: " << (int)top->Result << std::endl;
    EXPECT_EQ(top->Result, 8); // Expect 5 + 3
}

TEST_F(ADPTestbench, ALUSUBTest){
    top->ALUControl = 1;
    top->SrcA = 10;
    top->SrcB = 7;
    top->eval();
    EXPECT_EQ(top->Result, 3);
    EXPECT_EQ(top->Zero, 0);
    // Test `Zero` Output
    top->SrcB = 10;
    top->eval();
    EXPECT_EQ(top->Zero, 1);
    EXPECT_EQ(top->Result, 0);
}
// This test checks what the set value is, each time we spin up an instance
TEST_F(ADPTestbench, RetainTest){
    EXPECT_EQ(top->Result, 0);
}

TEST_F(ADPTestbench, ALUANDTTest){
    // Test Double Non-Zero
    top->ALUControl = 2; // Set to 4'b0010
    top->SrcA = 15;
    top->SrcB = 7;
    top->eval();
    EXPECT_EQ(top->Result, 7); 
    //Test Single Non-Zero
    top->SrcA = 0xF0;
    top->SrcB = 0x00;
    top->eval();
    EXPECT_EQ(top->Result, 0);
}

TEST_F(ADPTestbench, ALUORTest){
    top->ALUControl = 3; // Set to 4'b0011
    top->SrcA = 0xF0;
    top->SrcB = 0x0F;
    top->eval();
    EXPECT_EQ(top->Result, 0xFF); // Expect 0xF0 

    top->SrcB = 0x00;
    top->eval();
    EXPECT_EQ(top->Result, 0xF0);
}

TEST_F(ADPTestbench, ALULUI){
    top->ALUControl = 4; // Load in 4'b0100
    top->SrcB = 0xFFFF;
    top->eval();
    EXPECT_EQ(top->Result, 0xFFFF);
}

TEST_F(ADPTestbench, ALUXORTest){
    top->ALUControl = 5; //Load in 4'b0101
    top->SrcA = 0x05; // 0101
    top->SrcB = 0x2; // 0010
    top->eval();
    EXPECT_EQ(top->Result, 0x7);

    top->SrcA = 0x2;
    top->eval();
    EXPECT_EQ(top->Result, 0x0);
}

TEST_F(ADPTestbench, ALUSLTTest){
    // Testing Positive Value, Less Than Scenario
    top->ALUControl = 6;
    top->SrcA = 0;
    top->SrcB = 10;
    top->eval();
    EXPECT_EQ(top->Result, 0x1);
    //Testing Positive Value, More Than Scenario
    top->SrcA = 20;
    top->eval();
    EXPECT_EQ(top->Result, 0x0);

    //Testing Negative Value, Less than Scenario
    top->SrcA = -3;
    top->SrcB = -2;
    top->eval();
    EXPECT_EQ(top->Result, 0x1);

    //Testing Negative Value, More than Scenario
    top->SrcA = -1;
    top->SrcB = -2;
    top->eval();
    EXPECT_EQ(top->Result, 0x0);
}

TEST_F(ADPTestbench, ALUSRLTest){
    top->ALUControl = 7;
    top->SrcA = 0x00FF; // 1111 1111
    top->SrcB = 0x2;
    top->eval(); //Becomes 0011 1111 (0x3F)
    //std::cout << (int)top->Result << std::endl;
    EXPECT_EQ(top->Result, 0x3F);
}

TEST_F(ADPTestbench, ALUSRATest){
    top->ALUControl = 8; // Instruction 4'b1000
    top->SrcA = 0xFFFF0000;
    top->SrcB = 4; //
    top->eval();
    EXPECT_EQ(top->Result, 0xFFFFF000);

}

TEST_F(ADPTestbench, ALUULTTest){
    top->ALUControl = 9;
    top->SrcA = 8;
    top->SrcB = 3;
    top->eval();
    EXPECT_EQ(top->Result, 0);

    top->SrcB = 10;
    top->eval();
    EXPECT_EQ(top->Result, 1);

    //Test negative numbers for fun lol. There are unpredictable
    // top->SrcA = -5;
    // top->SrcB = -1;
    // top->eval();
    // EXPECT_EQ(top->Result,1);
    // // A shld 

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