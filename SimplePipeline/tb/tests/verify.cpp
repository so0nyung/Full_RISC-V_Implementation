#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, TestAddiBne)
{
    setupTest("1_addi_bne");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 254);
}

TEST_F(CpuTestbench, TestLiAdd)
{
    setupTest("2_li_add");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1000);
}

TEST_F(CpuTestbench, TestLbuSb)
{
    setupTest("3_lbu_sb");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, TestJalRet)
{
    setupTest("4_jal_ret");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 53);
}

TEST_F(CpuTestbench, TestPdf)
{
    setupTest("5_pdf");
    setData("reference/gaussian.mem");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 15363);
}



TEST_F(CpuTestbench, TestPipelineSimp){
    //Simple Pipeline Test
    setupTest("6_pipeBasic");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 42);

    //Addition
    setupTest("7_pipeAdd");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 100);
    
    setupTest("8_pipeLog");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 15);

    setupTest("9_PipeMem");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 777);
    
    setupTest("10_PipeBranch");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 555);  

    setupTest("11_pipeStress");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 42);
        
    setupTest("12_pipeLoop");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 55);
        
 
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;

}
