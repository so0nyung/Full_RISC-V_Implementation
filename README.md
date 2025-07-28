# Fully Implemented RISC-V CPU
This is a continuation of my Lab 4- Reduced RISC-V CPU, where I attempt to implement a full CPU instruction set. In brief, I have several main goals:
1. To implement a single-cycle RV32I instruction set in a microarchitecture
2.  implement the F1 starting light algorithm in RV32I assembly language. I can do this but it's not possible to physically test it, so I'll find another way to implement it.
3. Pipeline version - With hazard detection and mitigation
4. Add set-associative data cache to the pipelined RV32I
5. If Possbile, complete the RV32I processor



# Structure
There are (will be*) several branches for the different versions of the CPU, listed in the table below:


| CPU| Branch |
| - | - |
| Single-Cycle| [Link]|
| Pipelined | [Link] |
| Cache | [Link] |

Each branch will have a README.md file detailing the design choices I made. To lighten my load (I gave myself two (about) weeks to finish this) I have built the pipelined and cache README.md files off the single-cycle README.md (I.e. if you are not sure where to start, I'd recommend reading the Single-cycle, followed by pipelined and cache version).

The main brach contains (hopefully), a folder of each of the different versions, as well as (again, hopefully) a test that runs for all of them to compare the speed differences (This is ambitious I can't even lie). The main branch was the branch I tested the Single-Cycle version initially so there may be lingering files here and there, but for the most part that will be the ONLY test done.

The test would hopefully also produced the F1 and sine and cosine products. Because I do not have the ICL Vbuddy (Don't quote me on the name), I needed another way to visualise the results, so I made the scripts produce `.vcd` and graphable files, and subsequent scripts to plot them out.

# Testing
Testing used Google XXXX Scope to test on .cpp files. For individual components, individual values were input. For whole-of-CPU testing, assembly language turned to hexadeximals was used.

# References
There are (most of) the 
1. (RISC-V Base Instructions - Reduced)(https://www.cse.cuhk.edu.hk/~byu/CENG3420/2024Spring/doc/RV32-reference-2.pdf) (I refernced this a LOT)
2. https://drive.google.com/file/d/1uviu1nH-tScFfgrovvFCrj7Omv8tFtkp/view


Confession: ChatGPT was used in this project, in the following capacities:
1. Inquiry of System Verilog and bash syntax
2. Analysis of errors encountered throughout testing
3. Analysis of convertion of testing outputs to graphs

For the record I did NOT just mod ChatGPT into a professor-esque personna and ask it to type out the code for me (Believe me I did that for another project it sucks at this). Majority of the code is written by me with a few sysntax errors amended by ChatGPT. Most errors would amended by me as best I can. Only at the initial testings was ChatGPT used to understand the file errors. My reliance on it got less and less throughout the construction.