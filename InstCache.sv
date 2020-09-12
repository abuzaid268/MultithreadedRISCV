//
// File Name: InstCache.sv
// Function: holds instruction data
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module InstCache #(parameter SIZE = 128)
(
input logic  clk,WriteInst,Enable,nReset,
input logic  [6:0] CacheIndexRead,CacheIndexWrite,
input logic  [31:0] InstData,
output logic [31:0] Inst
);

logic [31:0] InstMem [0: SIZE - 1];
always_ff @(posedge clk)
begin
if(WriteInst) InstMem[CacheIndexWrite] <= InstData;

if (Enable) Inst <= InstMem[CacheIndexRead];
end
endmodule
