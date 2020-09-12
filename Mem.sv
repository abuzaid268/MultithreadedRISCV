//
// File Name: Mem.sv
// Function: memory stage
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module Mem(
input logic [31:0] Wdata_Mem,Rdata2_Mem,MemAddress,datafromexternal,
input logic [4:0] Waddr_Mem,
input logic RegWrite_Mem,MemWrite_Mem,MemRead_Mem,MemtoReg_Mem,clk,nReset,DoneReadingData,DoneWritingData,ReadEnable,ReadFromExternal,
input logic [1:0] mhartID_Mem,mhartID_EX,
output logic [31:0] Wdata_WB,
output logic [4:0] Waddr_WB,
output logic RegWrite_WB,CacheHit,CacheMiss,StoreHazard,
input logic [31:0] RamData,
output logic [31:0] RamReadAddress,RamWriteAddress,
output logic [31:0] RamWriteData,
output logic RamRead,
output logic RamWrite,
output logic [1:0] mhartID_WB,DoneForTID,DoneWritingFor
);
logic [31:0] ReadData,WriteBackData;

CacheMemory CM1 (
.clk,.nReset,.load(MemRead_Mem),.store(MemWrite_Mem),
.WritetoData(Rdata2_Mem),.Address_Mem(MemAddress),
.CacheHit,.CacheMiss,.ReadEnable,
.WriteBackData,.DoneWritingFor,
.RamData,.mhartID_EX,.StoreHazard,
.RamReadAddress,.RamWriteData,.RamWriteAddress,
.RamRead,.RamWrite,
.DoneReadingData,.DoneWritingData,.mhartID_Mem,.DoneForTID
);

assign ReadData = (ReadFromExternal) ? datafromexternal : WriteBackData;
always_ff @(posedge clk, negedge nReset)
if (!nReset)
begin
RegWrite_WB <= 0;
Wdata_WB <= 0;
Waddr_WB <= 0;
mhartID_WB <= 0;
end
else if (CacheMiss)
begin
RegWrite_WB <= 0;
Wdata_WB <= 0;
Waddr_WB <= 0;
mhartID_WB <= mhartID_Mem;
end
else
begin
RegWrite_WB <= RegWrite_Mem;
Wdata_WB <= (MemtoReg_Mem) ? ReadData: Wdata_Mem;
Waddr_WB <= Waddr_Mem;
mhartID_WB <= mhartID_Mem;
end
endmodule
