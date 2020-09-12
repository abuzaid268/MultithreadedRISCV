//
// File Name: pc.sv
// Function: Program Counter for the processor
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/099/19
//
module pc #(parameter n = 32) // up to 64 instructions
(input logic clk, nReset,EnablePC,
 input logic [n-1: 0] PCin,
 output logic [n-1 : 0]PCout
);

always_ff @ ( posedge clk , negedge nReset) // async reset
  if (!nReset) // sync reset
     PCout <= 0;
  else 
  if (EnablePC)
  PCout <= PCin;
endmodule // module pc