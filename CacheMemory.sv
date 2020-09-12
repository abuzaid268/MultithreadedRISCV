//
// File Name: CacheMemory.sv
// Function: data cache top level
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module CacheMemory (
 input logic clk,nReset,load,store,DoneReadingData,DoneWritingData,ReadEnable,
 input logic [1:0] mhartID_Mem,mhartID_EX,
 input logic [31:0] WritetoData,Address_Mem,
 output logic CacheHit,CacheMiss,StoreHazard,
 output logic [31:0] WriteBackData,
 //Ram
 input logic [31:0] RamData,
 output logic [31:0] RamReadAddress,RamWriteData,RamWriteAddress,
 output logic RamRead,RamWrite,
 output logic [1:0] DoneForTID,DoneWritingFor
);
 // Data Memory
 logic WriteCache,Writethread;
 logic [6:0] CacheIndexWrite,CacheIndexRead;
 logic [31:0] WriteDataCache;
 logic [31:0] CacheData;
 // TagMemory
 logic WriteTag;
 logic [11:0] TagAddress,WriteAddressTag;
 logic [11:0] TagCompare;
 // ValidRam
 logic WriteValid;
 logic Valid;
 //Cache Control
 logic Match;
 always_ff @(posedge clk)
 TagAddress <= Address_Mem [20:9];

 
 assign Match = ((TagCompare == TagAddress )&& Valid );
 assign CacheIndexRead = Address_Mem [8:2];
 
 DataMemory   DM1 (.clk,.WriteCache,.CacheIndexWrite,.ReadEnable,
 .WriteDataCache,.CacheData,.CacheIndexRead,.nReset);
 
 TagRAM       TR1 (.clk,.CacheIndexWrite,.WriteTag,.ReadEnable,
 .TagAddress,.WriteAddressTag,.TagCompare,.CacheIndexRead,.nReset);
 
 ValidRam     VR1 (.clk,.CacheIndexWrite,.WriteValid,.ReadEnable,
 .Valid,.nReset,.CacheIndexRead);
 
 CacheControl CC1 (.Match,.clk,.nReset,.mhartID_Mem,
 .CacheData,.WritetoData,.Address_Mem,.ReadEnable,.mhartID_EX,
 .load,.store,.DoneWritingData,.DoneReadingData,.RamData,
 .WriteBackData,.WriteDataCache,.RamReadAddress,.RamWriteAddress,
 .RamWriteData,.WriteAddressTag,.CacheIndexWrite,.StoreHazard,
 .WriteValid,.WriteTag,.WriteCache,.RamRead,.RamWrite,.DoneWritingFor,
 .CacheHit,.CacheMiss,.DoneForTID);
 

 
 endmodule
 
