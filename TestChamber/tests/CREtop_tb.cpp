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
//=============================== REGISTER OR IMMEDIATE OPERATION TESTS =========================


TEST_F(CRETestbench, ADDImmTEST){
    //Initialise for Addition instruction
    top->instr =  0x00A00093; // addi x1, x0, 10

    clockCycle();
    //Results
    EXPECT_EQ(top->ALUSrc, 1); // Test that we add the immediate value
    EXPECT_EQ(top->ALUControl, 0); // Test it's addition
    EXPECT_EQ(top->ImmSrc, 0); // I-type Immediate
    EXPECT_EQ(top->RegWrite, 1); // Expect Writing to Register
}

TEST_F(CRETestbench, ADDRegTest){
    top->instr = 0x002082B3; // add x5, x1, x2
    clockCycle();

    //Results
    EXPECT_EQ(top->ALUSrc, 0); // Use Register Value
    EXPECT_EQ(top->ALUControl, 0); // Addition instruction
    EXPECT_EQ(top->ImmSrc, 0); // Don't use ImmSrc
    EXPECT_EQ(top->RegWrite, 1); // Test Writing to Register
}
// ========= TESTING ALUCtrl OUTPUT ===========

TEST_F(CRETestbench, ALUCtrlTest){ // To test ALUControl outputs
    top->instr = 0x402081b3;
    clockCycle();
    EXPECT_EQ(top->ALUControl, 1); // Subtraction instruction
    
    top->instr = 0x0020f2b3;  // AND Operation - and  x5, x1, x2
    clockCycle();
    std::cout << (int)top->ALUControl << std::endl;
    EXPECT_EQ(top->ALUControl, 2); // AND code

    top->instr = 0x0020e333;  // OR Operation - or x6, x1, x2
    clockCycle();
    EXPECT_EQ(top->ALUControl, 3); // OR Code

    top->instr = 0x00012283; // Load Instruction - lw x5, 0(x1)
    clockCycle();
    EXPECT_EQ(top->ALUControl, 0); // Load Code
    // EXPECT_EQ()

    top-> instr = 0x0020c333; // XOR Instruction - xor x6, x1, x2
    clockCycle();
    EXPECT_EQ(top->ALUControl, 4);

    top-> instr = 0x00112233; // SLT Instruction - slt x4, x1, x2
    clockCycle();
    EXPECT_EQ(top->ALUControl, 8);

    top->instr = 0x0020d433; // SRL Instruction - srl x8, x1, x2
    clockCycle();
    EXPECT_EQ(top->ALUControl, 6);

    top->instr = 0x4020d4b3; //SRA Instruction - sra x9, x1, x2
    clockCycle();
    EXPECT_EQ(top->ALUControl, 7);

    top->instr = 0x0020b533; // ULT - SLTU (Set Less Than Unsigned) - sltu x10, x1, x2
    clockCycle();
    EXPECT_EQ(top->ALUControl, 9);
}
// ========= TESTING ImmSrc OUTPUT ===========
/*
What instruction does what:
opcode- ImmSrc
1. 7'b0110011 (0x33) - ImmSrc = 3'b000; general
2. 7'b0010011 (0x13) - ImmSrc = 3'b000; I-type
3. 7'b0000011 (0x02) - ImmSrc - 3'b000: load
4. 7'b0100011 (0x23) - ImmSrc - 3'b001; S-type
5. 7'b1100011 (0x63) - ImmSrc - 3'b010; B-type
6. 7'b1101111 (0x6F) - ImmSrc - 3'b100; J-type
7. 7'b0110111 (0x37)- ImmSrc - 3'b011; U-type
*/
TEST_F(CRETestbench, ImmSrcTestbench){
    // I-type Immediate
    top->instr = 0x13;
    clockCycle();
    EXPECT_EQ(top->ImmSrc, 0);
    // S-type Immediate
    top->instr = 0x23;
    clockCycle();
    EXPECT_EQ(top->ImmSrc, 1);
    // B-type Immediate
    top->instr = 0x63;
    clockCycle();
    EXPECT_EQ(top->ImmSrc, 2);    
    // J-type Immediate
    top->instr = 0x6F;
    clockCycle();
    EXPECT_EQ(top->ImmSrc, 4);
    //U-type Immediate
    top->instr = 0x37;
    clockCycle();
    EXPECT_EQ(top->ImmSrc, 3);
}



//==================TESTING REGWRITE INPUT================

TEST_F(CRETestbench, RandomTest){
    //I-type
    top->instr= 0x13;
    clockCycle();
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->MemWrite, 0);
    //Load
    top->instr= 0x3;
    clockCycle();
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->MemWrite, 0);

    //Store
    top->instr= 0x23;
    clockCycle();
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->MemWrite, 1);

    //Branch
    top->instr= 0x63;
    clockCycle();
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->MemWrite, 0);

    //J-type
    top->instr= 0x6F;
    clockCycle();
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->MemWrite, 0);

    //U-type
    top->instr= 0x37;
    clockCycle();
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->MemWrite, 0);
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