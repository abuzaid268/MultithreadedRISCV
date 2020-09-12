//
// File Name: TagRAM.sv
// Function: data memory tag
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module TagRAM #(parameter SIZE = 128)
(
input logic clk,WriteTag,ReadEnable,nReset,
input logic [11:0] TagAddress,WriteAddressTag,
input logic [6:0] CacheIndexWrite,CacheIndexRead,
output logic [11:0] TagCompare
);
logic [11:0] TagData [0:SIZE - 1];
always_ff @(posedge clk)
begin
if (WriteTag)
TagData[CacheIndexWrite] <= WriteAddressTag;

if (ReadEnable)
TagCompare <= TagData[CacheIndexRead]; 
end
endmodule
