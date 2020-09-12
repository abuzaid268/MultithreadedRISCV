//
// File Name: Datamemory.sv
// Function: data memory
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module DataMemory #(parameter SIZE = 128)
(
input logic clk,WriteCache,ReadEnable,nReset,
input logic [6:0] CacheIndexWrite,CacheIndexRead,
input logic [31:0] WriteDataCache,
output logic [31:0] CacheData
);
logic [31:0] CacheMem [0: SIZE - 1];
always_ff @(posedge clk)
begin
if (WriteCache)
CacheMem [CacheIndexWrite] <= WriteDataCache;

if (ReadEnable)
CacheData <= CacheMem [CacheIndexRead];
end
endmodule
