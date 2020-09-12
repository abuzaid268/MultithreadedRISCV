//
// File Name: InstTag.sv
// Function: instruction tag memory
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module InstTag #(parameter SIZE = 128)
(
input logic WriteTag,clk,Enable,nReset,
input logic [6:0] WriteAddressTag,
input logic [6:0] CacheIndexWrite,CacheIndexRead,
output logic[6:0] TagCompare
);

logic [6:0] TagInst [0:SIZE - 1];
always_ff @(posedge clk)
begin
if (WriteTag)
TagInst[CacheIndexWrite] <= WriteAddressTag;

if (Enable) TagCompare <= TagInst[CacheIndexRead];
end
endmodule

