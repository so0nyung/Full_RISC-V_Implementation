# Fully Implemented RISC-V CPU
This is a continuation of my Lab 4- Reduced RISC-V CPU, where I attempt to implement a full CPU instruction set. In brief, I have several main goals:
1. To implement a single-cycle RV32I instruction set in a microarchitecture
2.  implement the F1 starting light algorithm in RV32I assembly language. I can do this but it's not possible to physically test it, so I'll find another way to implement it.
3. Pipeline version - With hazard detection and mitigation
4. Add set-associative data cache to the pipelined RV32I
5. If Possbile, complete the RV32I processor



# Structure
There are several branches for the different versions of the CPU, listed in the table below:


| CPU| Branch |
| - | - |
| Single-Cycle| [Link](https://github.com/so0nyung/Full_RISC-V_Implementation/tree/Single_Cycle)|
| Pipelined | [Link](https://github.com/so0nyung/Full_RISC-V_Implementation/tree/Pipelined) |
| Cache | [Link](https://github.com/so0nyung/Full_RISC-V_Implementation/tree/Cache) |

Each branch will have a README.md file detailing the design choices I made. To lighten my load (I gave myself two (about) weeks to finish this) I have built the pipelined and cache README.md files off the single-cycle README.md (I.e. if you are not sure where to start, I'd recommend reading the Single-cycle, followed by pipelined and cache version).

The main brach contains, a folder of each of the different versions, as well as a test that runs for all of them to compare the speed differences. The main branch was the branch I tested the Single-Cycle version initially so there may be lingering files here and there, but for the most part that will be the ONLY test done.

The test would hopefully also produced the F1 and sine and cosine products. Because I do not have the ICL Vbuddy (Don't quote me on the name), I needed another way to visualise the results, so I made the scripts produce `.vcd` and graphable files, and subsequent scripts to plot them out.

# Testing
Testing used Google Gtest to test on .cpp files. For individual components, individual values were input. For whole-of-CPU testing, assembly language turned to hexadeximals was used.

# Final Products
In this branch, I have gathered all the RISC-V CPU versions I have made in this project:

| Type | Details |
| - | - |
| [Simplified](./rtl-Lab4/) | This was the beginning of my RISC-V CPU: A simplified version that only does several instructions |
| [Single-Cycle](./rtl)| This was the first complete RISC-V CPU I made|
| [Pipelined] | Second |
| [Cache] | Third |
# Results

## Timing of Testcases
Because my simplified CPU does not have sufficient instructions, I have removed it from this testing. 

### Executing
To run this test, clone this repository and head to the `tb` folder. Then, type in the terminal:
```
./doit.sh   
```

In my testing, I got the following results:

| Type | Timing (In ms) |
| - | - |
| Single-Cycle| 1662 ms |
| Pipelined | 4161 ms |
| Cache | 4943 ms |

# References
There are (most of) the 
1. (RISC-V Base Instructions - Reduced)(https://www.cse.cuhk.edu.hk/~byu/CENG3420/2024Spring/doc/RV32-reference-2.pdf) (I refernced this a LOT)
2. https://drive.google.com/file/d/1uviu1nH-tScFfgrovvFCrj7Omv8tFtkp/view


Confession: ChatGPT was used in this project, in the following capacities:
1. Inquiry of System Verilog and bash syntax
2. Analysis of errors encountered throughout testing
3. Analysis of convertion of testing outputs to graphs

For the record I did NOT just mod ChatGPT into a professor-esque personna and ask it to type out the code for me (Believe me I did that for another project it sucks at this). Majority of the code is written by me with a few sysntax errors amended by ChatGPT. Most errors would amended by me as best I can. Only at the initial testings was ChatGPT used to understand the file errors. My reliance on it got less and less throughout the construction.