//
// File Name: pipelined_RISC.sv
// Function: top level module of the processor
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module pipelined_RISC(
// Sdram
input logic clk,nReset,
output logic LED0,LED1,LED2,LED3,
output logic [31:0] T0out,T1out,T2out,T3out
);

 logic [31:0] I_EX,currentPC_ID,currentPC_EX,currentPC_Mem;
 logic [31:0] Rdata1_EX,Rdata2_EX,imm_EX;
 logic RegWrite_EX,ALUSrc_EX,MemWrite_EX,MemRead_EX,MemtoReg_EX,/*branch_ID,jump_ID,*/store_address_EX,aui_EX;
 logic [4:0] ALUOpin_EX;
 logic [31:0] Wdata_Mem,Rdata2_Mem;
 logic RegWrite_Mem,MemWrite_Mem,MemRead_Mem,MemtoReg_Mem;
 logic [31:0] Ram_out_WB,Wdata_WB;
 logic RegWrite_WB,branch_ID,jump_ID,MemtoReg_WB;
 logic [31:0] I_ID,newpc_ID,newpc_EX,RBranch_EX,absolute_jump_ID,out,MemAddress;
 logic [4:0]  Waddr_Mem,Waddr_WB;
 logic InstMiss,CacheMiss,SwitchAction,flush,branch,CacheHit,MemRead;
 logic [1:0] ForwardA,ForwardB,ForwardRS1,ForwardRS2;
 logic [1:0] mhartID,mhartID_ID,mhartID_EX,mhartID_Mem,mhartID_WB,DoneForTID,RetrievingDoneFor,FetchingmhartID,nextthread,DoneWritingFor,ByteEnable;
 logic [31:0] RamReadAddress,RamWriteAddress,InstAddress;
 logic [31:0] RamWriteData,IntmhartID,RamByteAddress;
 logic [19:0] addr;
 wire [15:0] data;
 logic WE,CS,OE,LBS,HBS;
 logic [7:0] InstOut;
 logic [11:0] PendingStoreRequest;
 logic [15:0] RamData,RamByteData;
 logic DoneReading,DoneWriting;
 logic RamWrite,RamRead,InstRead,StoreHazard;
 //logic [7:0] RamByteData;
 logic [31:0] InstByteAddress,newPC,ThreadAddress,FetchingAddress,DataCumulativeRegister,InstCumulativeRegister;
 logic DoneWritingData,DoneReadingData,DoneReadingInst,MemWrite,InstHit,DoneRetrieving,ReadEnable;
 logic Ignore,ReadCacheStatus,RamReadEnable,RamWriteEnable;
 logic InstSource,IgnoreMiss,flushEX,flushID;
 // external memory ports
 logic [7:0] address;
 logic [31:0] datafromexternal;
 logic ReadAccess,ReadFromExternal;

 
 thread_management TM1 (
	 .clk,.nReset,.flushEX,.flushID,
	 .branch_ID,.jump_ID,.MemRead,.mhartID_Mem,.mhartID,.FetchingAddress,.DoneWritingData,
	 .RBranch_EX,.absolute_jump_ID,.currentPC_Mem,.currentPC_ID,.Ignore,.InstRead,.InstAddress,
	 .InstMiss,.InstHit,.CacheMiss,.MemWrite,.flush,/*.FetchingmhartID,*/.ReadCacheStatus,.InstReady(DoneReadingInst),
	 .RetrievingDoneFor,.DoneRetrieving,.DoneReadingData,.DoneForTID,.nextthread,.IgnoreMiss,.mhartID_EX,.DoneWritingFor,
	 .newPC,.ThreadAddress,.InstSource,.IntmhartID,.StoreHazard,.CacheHit,.SwitchAction,.mhartID_ID,.ReadFromExternal
 );
 
 externalmemory  EM1 (
	.clk,.ReadAccess,.ReadFromExternal,.address,.datafromexternal
 );
 
 
  ROMcontroller ROMC1(
 .InstAddress,
 .InstOut,
 .clk,.nReset,.InstRead,
 .InstByteAddress,.InstCumulativeRegister,
 .DoneReadingInst
);

RamController RC1(
 .RamReadAddress,.RamWriteAddress,
 .RamWriteData,
 .RamData,
 .RamWrite,.RamRead,.clk,.nReset,.DoneReading,.DoneWriting,
 .ByteEnable,
 .RamByteData,
 .RamByteAddress,.DataCumulativeRegister,
 .DoneWritingData,.DoneReadingData,
 .RamReadEnable,.RamWriteEnable
);
 
 SRAMController SRC1 (
// SRAM INTERFACS
.addr,
.data,
.WE,.CS,.OE,.LBS,.HBS,.DoneReading,.DoneWriting,
// PROCSSSOR Inputs and Outputs
.RamReadEnable,.RamWriteEnable,.clk,.nReset,
.ByteEnable,
.RamByteAddress,
.RamByteData,
.RamData
);	

asynchronous_ram AR1
(
.CS,.WE,.OE,.LBS,.HBS,
.addr,
.data
);

 
   InstROM  IR1(
 .InstByteAddress,
 .InstRead,.clk,
 .InstOut
);
 
 IF IF1(
	.clk,.nReset,.flush,
	.I_ID,.newpc_ID,.currentPC_ID,.nextthread,
	.newPC,.FetchingAddress,.branch_ID,.jump_ID,
	.ThreadAddress,.Ignore,.FetchingmhartID,
	.InstReady(DoneReadingInst),
	.InstOut(InstCumulativeRegister),
	.InstAddress,.IgnoreMiss,
	.InstHit,.InstMiss,.mhartID,.mhartID_ID,
	.InstRead,.ReadCacheStatus,
	.RetrievingDoneFor,.DoneRetrieving,.InstSource
	);
 
 ID ID1(
	.I_ID,.newpc_ID,.Wdata_Mem,.Wdata_WB,.currentPC_ID,.out,
	.clk,.RegWrite_WB,.nReset,.mhartID_ID,.mhartID_WB,.flush(flushID),
	.ForwardRS1,.ForwardRS2,.Waddr_WB,.Rdata1_EX,.Rdata2_EX,.currentPC_EX,
	.RegWrite_EX,.ALUSrc_EX,.MemWrite_EX,.MemRead_EX,.MemtoReg_EX,.branch_ID,.jump_ID,
	.store_address_EX,.branch,.aui_EX,.mhartID_EX,.MemRead,.MemWrite,.IntmhartID,
	.ALUOpin_EX,.I_EX,.newpc_EX,.imm_EX,.RBranch_EX,.absolute_jump_ID
	);
	
 EX EX1(
	.Rdata1_EX,.Rdata2_EX,.RegWrite_EX,.ALUSrc_EX,.flush(flushEX),
	.MemWrite_EX,.MemRead_EX,.MemtoReg_EX,.ReadAccess,.address,.LED0,.LED1,.LED2,.LED3,
     .store_address_EX,.clk,.ALUOpin_EX,.I_EX,.Waddr_Mem,.ReadEnable,
     .Wdata_Mem,.Rdata2_Mem,.RegWrite_Mem,.MemWrite_Mem,.MemRead_Mem,.MemtoReg_Mem,
	.nReset,.Wdata_WB,.ForwardA,.ForwardB,.newpc_EX,.imm_EX,.currentPC_Mem,
	.currentPC_EX,.aui_EX,.out,.mhartID_EX,.mhartID_Mem,.MemAddress,.T0out,.T1out,.T2out,.T3out);
	
 Mem Mem1( 
	.Wdata_Mem,.Rdata2_Mem,.MemAddress,
	.Waddr_Mem,.RegWrite_Mem,.MemWrite_Mem,.MemRead_Mem,
	.MemtoReg_Mem,.clk,.nReset,.mhartID_Mem,.DoneWritingFor,
	.DoneReadingData,.DoneWritingData,.ReadEnable,
	.Wdata_WB,.Waddr_WB,.mhartID_EX,.ReadFromExternal,.datafromexternal,
	.RegWrite_WB,.CacheHit,.StoreHazard,
	.CacheMiss,.mhartID_WB,.RamData(DataCumulativeRegister),
	.RamReadAddress,.RamWriteAddress,.RamWriteData,.RamRead,.RamWrite,.DoneForTID);
	
 forwarding FW1(
	.RegWrite_WB,.RegWrite_EX,.RegisterRS1_ID(I_ID[19:15]),
	.RegisterRS1_EX(I_EX[19:15]),.RegisterRS2_ID(I_ID[24:20]),
	.RegisterRS2_EX(I_EX[24:20]),.Waddr_WB,.Waddr_Mem,.ForwardA,
	.ForwardB,.ForwardRS1,.ForwardRS2,.RegWrite_Mem,.Waddr_EX(I_EX[11:7]),
	.mhartID_Mem,.mhartID_WB,
	.mhartID_ID,.mhartID_EX
	);
endmodule
