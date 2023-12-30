# RSSB-CPU-Implementation
A Systemverilog implementation of the One Instruction ISA using Reverse Subtract Swap if Borrow



Note: Work in progress. Currently works with simulation (using VCS and custom memory.hex file).
      Will be updated to work with synthesis and have an attached module for lcd display output


Command used for simulation is vcs -sverilog library.sv memory.sv U_RISC.sv


Format assembly file as such:
    
    .ORG f    ; .ORG sets current address to value(not an actual operation)
hi  RSSB 5    ; Label
    RSSB 6    ;
    RSSB hi   ; Label again


Note, this code doesn't really do anything
