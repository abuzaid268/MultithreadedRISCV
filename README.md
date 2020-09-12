# MultithreadedRISCV
Design of Coarse Grained Multithreaded RISCV Processor

# Specifications 

This repo contains a design of 5-stage pipelined multithreaded RISC-V Processor which runs RISC-V instruction set. The design is based on the classical 5 stage pipelined processor with some modifications were made in order to meet the design requirements. These changes were made in order to get a maximum of one cycle being wasted at each switch made between the threads. Memory hierarchy presented in this design consists of level 1 instruction and data cache memory and main memory where all the data and instructions are located. This design with this level of hierarchy allowed the design to have long memory latency which is intended to be hidden by the processor as a result of adding coarse-grained multithreading technique.
The final processor supports 32-bit instructions, a variety of instructions from the RV32I and RV32M instructions were implemented, the instructions that were not implemented during the design are FENCE, ECALL, EBREAK and bit manipulation instructions. Additionally, privileged instruction had to be added to the processor, which is CSRRS instruction. This instruction has a higher privilege than the other instructions because it can read control and status registers while the other instructions could only read registers within the general-purpose registers file. The intended register to be read by the program was mhartID control register which holds the hardware thread ID of each thread.
Finally, as mentioned above the processor modification were successfully implemented and the coarse-grained multithreaded architecture was achieved.

For more information please refer to the design report in the repo

