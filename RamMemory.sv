module RamMemory (
 input logic [31:0] RamByteAddress,
 input logic [7:0] RamByteData,
 input logic RamWriteEnable, clk,RamReadEnable,
 output logic [7:0] RamData
 );
 
 logic [7:0] mem [0:131072];
 
 always_ff @(posedge clk)
 begin
 if (RamWriteEnable) mem[RamByteAddress] <= RamByteData;

 if (RamReadEnable)   RamData <= mem[RamByteAddress];
 end
 
endmodule
