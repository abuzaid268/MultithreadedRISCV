//
// File Name: ValidRam.sv
// Function: Data cache valid
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module ValidRam #(parameter SIZE = 128)
(
input logic clk,WriteValid,nReset,ReadEnable,
input logic [6:0] CacheIndexWrite,CacheIndexRead,
output logic Valid
);
logic  ValidData [0: SIZE - 1];
always_ff @(posedge clk, negedge nReset)
begin
if (!nReset)
begin
for (int i = 0; i < SIZE ; i++)
ValidData[i]<=0;
end
else
begin
if (WriteValid)
ValidData [CacheIndexWrite] <= 1'b1;
if (ReadEnable)
Valid <= ValidData[CacheIndexRead]; 
end
end
endmodule
