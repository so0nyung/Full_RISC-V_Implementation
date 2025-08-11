# A Guide to Reading the testbenches

All the testbenches here used google testing suite, which makes for uniform testing. Each testbench is (generally) seperated into three sections:
```
class ModuleTestbench: public BaseTestbench{ // Initialising a class for this specific testbench
// Functions within it
}

//========== TESTS ===============
TEST_F(ModuleTestbench, NameOfTest){
    top->input = 0; //change value of
    EXPECT_EQ(top->output,"Expected Value");
}

// =============== MAIN FUNCTION==============

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
```

## Given Test - `Verify.cpp`
The main given test was to verify that the CPU works, and is under the `tb` section.


## Final Test in `main` branch