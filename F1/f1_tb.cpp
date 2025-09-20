#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <iomanip>
#include <string>
#include <chrono>
#include <thread>
#include <sstream>

// Function for Aesthetic Purposes - To slowcase realistically the difference between the Q
void slowPrint(const std::string& text, int delay_ms = 100) {
    for (char c : text) {
        std::cout << c << std::flush;
        std::this_thread::sleep_for(std::chrono::milliseconds(delay_ms));
    }
    std::cout << std::endl;
}

// Function to get user input with quit option
bool getInput(const std::string& prompt, const std::string& expected) {
    std::string input;
    while (true) {
        slowPrint(prompt, 50);
        std::cin >> input;
        if (input == "Quit") return false; // Quit
        if (input == expected) return true;
        slowPrint("ERROR: Invalid input.", 50);
    }
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vtop* top = new Vtop;

    // Initialize trace
    VerilatedVcdC* tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("f1.vcd");

    // Initialize
    top->clk = 0;
    top->rst = 1;
    top->trigger = 0;

    int cycle = 0;
    int last_a0 = -1;

    std::cout << "=== F1 CPU Execution Trace ===" << std::endl;
    std::cout << "Cycle\ta0 (hex)\ta0 (dec)" << std::endl;
    std::cout << "-----\t--------\t--------" << std::endl;

    // Start prompt
    if (!getInput("Type 'Q' to start simulation or 'Quit' to quit:", "Q")) {
        slowPrint("Simulation aborted by user.", 50);
        return 0;
    }

    while (cycle < 100000) {
        // Clock low
        top->clk = 0;
        top->eval();
        tfp->dump(cycle * 2);

        // Clock high
        top->clk = 1;

        if (cycle > 10) {
            top->rst = 0;
            top->trigger = 1;
        }

        top->eval();
        tfp->dump(cycle * 2 + 1);

        // Detect changes in a0
        if (top->a0 != last_a0) {
            switch(top->a0) {
                case 1: slowPrint("X", 75); break;
                case 3: slowPrint("XX", 75); break;
                case 7: slowPrint("XXX", 75); break;
                case 15: slowPrint("XXXX", 75); break;
                case 31: slowPrint("XXXXX", 75); break;
                case 63: slowPrint("XXXXXX", 75); break;
                case 127: slowPrint("XXXXXXX", 75); break;
            }

            if (top->a0 == 0x7F) {
                int delay_val = ((int)top->RanNum & 0x0F) + 1;
                std::ostringstream oss;
                oss << "Loading... ," << delay_val << "s";
                slowPrint(oss.str(), 75);
                std::this_thread::sleep_for(std::chrono::seconds(delay_val));
            }

            if (top->a0 == 0xFF) {
                slowPrint("\nSTART! All lights on!\n", 50);

                // Manual reset or quit
                bool continueSim = getInput("Type 'R' to reset CPU or 'Quit' to quit:", "R");
                if (!continueSim) break;

                // Perform reset
                top->rst = 1;
                for (int i = 0; i < 2; ++i) {
                    top->clk = 0; top->eval(); tfp->dump(cycle * 2 + 2 + i*2);
                    top->clk = 1; top->eval(); tfp->dump(cycle * 2 + 3 + i*2);
                }
                top->rst = 0;
                slowPrint("CPU reset complete!\n", 50);
            }

            last_a0 = top->a0;
        }

        cycle++;
    }

    slowPrint("Simulation ended.", 50);
    tfp->close();
    delete top;
    delete tfp;
    return 0;
}
