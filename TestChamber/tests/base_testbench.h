#pragma once

#include <memory>

#include "Vdut.h" //include Verilator-generated model
#include "verilated.h" //Verilator runtime
#include "verilated_vcd_c.h" //Verilator waveform tracing
#include "gtest/gtest.h" //Google Test framework

#define MAX_SIM_CYCLES 10000

extern unsigned int ticks;

class BaseTestbench : public ::testing::Test
{
public:
    void SetUp() override // Functon to setup testbench before each test
    {
        top = std::make_unique<Vdut>();
#ifndef __APPLE__ // If not on macOS, enable waveform tracing
        tfp = std::make_unique<VerilatedVcdC>();
        Verilated::traceEverOn(true);
        top->trace(tfp.get(), 99);
        tfp->open("waveform.vcd");
#endif
        initializeInputs();
    }

    void TearDown() override // Function to clean up after each test
    {
        top->final();
#ifndef __APPLE__ // If not on macOS, close waveform tracing file
        tfp->close();
#endif
    }

    virtual void initializeInputs() = 0;

protected:
    std::unique_ptr<Vdut> top;
#ifndef __APPLE__
    std::unique_ptr<VerilatedVcdC> tfp;
#endif
};