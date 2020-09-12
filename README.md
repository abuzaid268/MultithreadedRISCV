# MultithreadedRISCV
Design of Coarse Grained Multithreaded RISCV Processor

# Specifications 

This repo contains a design of 5 stages pipelined multithreaded RISC-V Processor which runs RISC-V instruction set architecture. The design is based on the classical 5 stage pipeline processor with some modifications were made in order to meet the design requirements,  these changes were made in order to get a maximum of one cycle being wasted at each switch made between the threads, memory hierarchy presented in this design consists of level 1 instruction and data cache memory, and main memory where all the data and instructions are located, this design with this level of hierarchy allowed the design to have long memory latency which is intended to be hidden by the processor as a result of adding coarse grained multithreading technique. 

 

The final processor supports 32 bit instructions, a variety of instructions from the RV32I and RV32M ISA were implemented, the instructions that were not implemented during the design are FENCE, ECALL and EBREAK. Additionally, a privileged instruction had to be added to the processor, which is CSRRS instruction, this instruction has a higher privilege than the other instructions because it is able to read control and status registers while the other instructions could only read registers within the general purpose registers, the intended register to be read by the program was mhartID control register which holds the hardware thread ID of each thread. 

Finally, as mentioned above the processor modification were successfully implemented and the coarse grained multithreaded architecture was achieved, Figure 3.1 below illustrates the final design and the 5 stage pipelined processor, noting that thread management unit and IF stage are parallel to each other, and updating the program counter is not considered to be one of the pipeline stages. 


