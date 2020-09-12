//
// File Name: asynchronous_ram.sv
// Function: module acts like sram
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/099/19
//
module asynchronous_ram #(parameter n = 16,datasize = 262144)
(input logic CS,WE,OE,LBS,HBS,
input logic [19:0] addr,
inout [15:0] data
);
logic [n-1:0] RAM [0:datasize-1];
logic [15:0] dataout;
always_latch
begin
if (!CS && !WE && !LBS) RAM[addr] <= data;
else if (!CS && !WE && !HBS) RAM[addr + 1'b1] <= data;
else if (!OE && !CS && !LBS) dataout <= RAM[addr];
else if (!OE && !CS && !HBS) dataout <= RAM[addr + 1'b1];



end
assign data = (!OE) ? dataout : 16'hzzzz;
endmodule