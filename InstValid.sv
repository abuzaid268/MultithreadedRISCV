//
// File Name: InstValid.sv
// Function: instruction valid memory
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module InstValid #(parameter SIZE = 128)
(
input logic clk,WriteValid,nReset,Enable,
input logic [6:0] CacheIndexWrite,CacheIndexRead,
output logic Valid
);

logic  Validmemory [0: SIZE - 1];

always_ff @(posedge clk, negedge nReset)
begin
if (!nReset)
begin
for (int i = 0; i <SIZE; i++)
Validmemory[i] <= 0;
end
else
begin
if (WriteValid)
Validmemory [CacheIndexWrite] <= 1'b1;
//if (Enable)
Valid <= Validmemory[CacheIndexRead]; 
//end
end
end
endmodule
