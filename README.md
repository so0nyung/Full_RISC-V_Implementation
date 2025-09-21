# 5-Stage Pipeline CPU
This is the Pipelined version of the RISC-V CPU. 

If we want to read about how it works, please click [here](Pipeline.md)

## Testing
To test the main Pipelined CPU, make sure you've cloned the repo, go to the `tb` folder and type:
```
./doit.sh
```
You will get the following result.

[Expected Result](./images/FullPipelineResult.png)


### Simple Pipelined CPU
The Simple Pipelined CPU does not have any hazard detection or correction. However, you can still view and test the files in the `SimplePipeline` folder and test it as above. You will notice that the majority of the testcases will not pass, because there is no way for the CPU to correct jump, load and branch instructions. However, given enough NOPs, the CPU works (View the last [6 test cases](./SimplePipeline/tb/asm))