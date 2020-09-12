//
// File Name: pipelined_RISC.sv
// Function: top level module of the processor
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module thread_management(
input logic clk,nReset,
input logic branch_ID,jump_ID,MemRead,ReadFromExternal,
input logic [1:0] mhartID_Mem,mhartID_ID,mhartID_EX,DoneWritingFor,/*mhartID_ID,*/
input logic [31:0] RBranch_EX,absolute_jump_ID,currentPC_Mem,currentPC_ID,FetchingAddress,InstAddress,
input logic InstMiss,InstHit,CacheMiss,MemWrite,InstRead,CacheHit,
input logic DoneRetrieving,DoneReadingData,IgnoreMiss,InstReady,StoreHazard,DoneWritingData,
input logic [1:0] RetrievingDoneFor,DoneForTID,
output logic  flush,Ignore,InstSource,ReadCacheStatus,SwitchAction,flushID,flushEX,
output logic [1:0] mhartID,nextthread,
output logic [31:0] ThreadAddress,newPC,IntmhartID
);
     logic [31:0] T0Mux1,T0Mux2,T0Mux3,T1Mux1,T1Mux2,T1Mux3,T2Mux1,T2Mux2,T2Mux3,T3Mux1,T3Mux2,T3Mux3;
	logic [3:0] DataVector,InstVector,PendingSameAddress,StoreHazardVector;
	logic [31:0] PCBRANCHT0,PCBRANCHT1,finalpcT0,finalpcT1,newPCT0,newPCT1;
	logic [31:0] PCBRANCHT2,PCBRANCHT3,finalpcT2,finalpcT3,newPCT2,newPCT3,T0,T1,T2,T3;
	logic [3:0] EnablePCThread;
	logic [31:0] JustFinishedForAddress;
	logic MemAccessRegister;
	assign IntmhartID = {30'b0,mhartID};
	assign ReadSuccessful = (CacheHit || ReadFromExternal);
	//logic nextthread;
	logic initialisation,DontFetch,DontFetchRegister;//,NoAvailableInstruction;
	assign flushEX = ((StoreHazard || CacheMiss) && mhartID_EX == mhartID_Mem) ? 1'b1:1'b0;
	assign flushID = ((StoreHazard || CacheMiss) && mhartID_ID == mhartID_Mem) ? 1'b1:1'b0;
	
	pc pc1 (.PCin(T0Mux3),.PCout(T0),.clk,.nReset,
	.EnablePC(EnablePCThread[0]));
	
	pc pc2 (.PCin(T1Mux3),.PCout(T1),.clk,.nReset,
	.EnablePC(EnablePCThread[1]));
	
	pc pc3 (.PCin(T2Mux3),.PCout(T2),.clk,.nReset,
	.EnablePC(EnablePCThread[2]));
	
	pc pc4 (.PCin(T3Mux3),.PCout(T3),.clk,.nReset,
	.EnablePC(EnablePCThread[3]));
	
      // PC and store Address logic
	  assign SwitchThread = (SwitchAction || (DontFetchRegister && !MemWrite));
	  assign SwitchAction = (branch_ID || jump_ID || MemRead || InstMiss || MemAccessRegister );
	  assign InstSource = 1'b1;
	  assign Ignore = (!initialisation) ? 1'b1 : 1'b0;
	  assign flush = (InstMiss || MemWrite) ? 1'b1 : 1'b0;
	  always_comb
	  begin
	  PendingSameAddress = 4'b0000;
	  if ((InstMiss && FetchingAddress == T0 && JustFinishedForAddress != T0) || (InstRead && InstAddress == T0)) PendingSameAddress [0] = 1;
	  if ((InstMiss && FetchingAddress == T1 && JustFinishedForAddress != T1) || (InstRead && InstAddress == T1)) PendingSameAddress [1] = 1;
	  if ((InstMiss && FetchingAddress == T2 && JustFinishedForAddress != T2) || (InstRead && InstAddress == T2)) PendingSameAddress [2] = 1;
	  if ((InstMiss && FetchingAddress == T3 && JustFinishedForAddress != T3) || (InstRead && InstAddress == T3)) PendingSameAddress [3] = 1;

	  newPCT0 = T0 + 3'b100;
       newPCT1 = T1 + 3'b100;
	  newPCT2 = T2 + 3'b100;
	  newPCT3 = T3 + 3'b100;
       ///newPC = (nextthread) ? newPCT1 : newPCT0;
	   case (nextthread)
	   0: newPC = newPCT0;
	   1: newPC = newPCT1;
	   2: newPC = newPCT2;
	   3: newPC = newPCT3;
	   endcase
	   // next PC logic 
       PCBRANCHT0 = (branch_ID && mhartID == 0) ? RBranch_EX : newPCT0;
	  finalpcT0 = (jump_ID && mhartID == 0) ? absolute_jump_ID : PCBRANCHT0;
	  PCBRANCHT1 = (branch_ID && mhartID == 1) ? RBranch_EX : newPCT1;
	  finalpcT1 = (jump_ID && mhartID == 1) ? absolute_jump_ID : PCBRANCHT1;
	  PCBRANCHT2 = (branch_ID && mhartID == 2) ? RBranch_EX : newPCT2;
	  finalpcT2 = (jump_ID && mhartID == 2) ? absolute_jump_ID : PCBRANCHT2;
	  PCBRANCHT3 = (branch_ID && mhartID == 3) ? RBranch_EX : newPCT3;
	  finalpcT3 = (jump_ID && mhartID == 3) ? absolute_jump_ID : PCBRANCHT3;
	  // ThreadAddress for cache access
	  case (nextthread)
	   0: ThreadAddress = ((branch_ID || jump_ID) && mhartID_ID == 0 ) ? finalpcT0 :  T0;
	   1: ThreadAddress = ((branch_ID || jump_ID) && mhartID_ID == 1 ) ? finalpcT1 :  T1;
	   2: ThreadAddress = ((branch_ID || jump_ID) && mhartID_ID == 2 ) ? finalpcT2 :  T2;
	   3: ThreadAddress = ((branch_ID || jump_ID) && mhartID_ID == 3 ) ? finalpcT3 :  T3;
	   endcase
	  // final value stored in the program counter is based on priorities, priorities are from low to high from Mux1 to Mux4, where priority is based on the olddest address in a thread
	  // Thread one store address cases
	  newPCT0 = T0 + 3'b100;
	  PCBRANCHT0 = (branch_ID && mhartID == 0) ? RBranch_EX : newPCT0;
	  finalpcT0 = (jump_ID && mhartID == 0) ? absolute_jump_ID : PCBRANCHT0;
	  T0Mux1 = (InstMiss && mhartID_ID == 0 ) ? FetchingAddress : finalpcT0;
	  T0Mux2 = ((MemRead  || MemWrite)&& mhartID == 0 )  ? T0 : T0Mux1;
	  T0Mux3 = ((CacheMiss || StoreHazard) && mhartID_Mem == 0) ? currentPC_Mem : T0Mux2;
	  //Thread two store address cases
	  T1Mux1 = (InstMiss && mhartID_ID == 1 ) ? FetchingAddress : finalpcT1;
	  T1Mux2 = ((MemRead  || MemWrite)&& mhartID == 1 )  ? T1 : T1Mux1;
	  T1Mux3 = ((CacheMiss || StoreHazard) && mhartID_Mem == 1) ? currentPC_Mem : T1Mux2;
	  // Thread3 store address cases
	  T2Mux1 = (InstMiss && mhartID_ID == 2 ) ? FetchingAddress : finalpcT2;
	  T2Mux2 = ((MemRead || MemWrite) && mhartID == 2 )  ? T2 : T2Mux1;
	  T2Mux3 = ((CacheMiss || StoreHazard) && mhartID_Mem == 2) ? currentPC_Mem : T2Mux2;
	  // Thread 4 store address cases
	  T3Mux1 = (InstMiss && mhartID_ID == 3 ) ? FetchingAddress : finalpcT3;
	  T3Mux2 = ((MemRead  || MemWrite)&& mhartID == 3 )  ? T3 : T3Mux1;
	  T3Mux3 = ((CacheMiss || StoreHazard) && mhartID_Mem == 3) ? currentPC_Mem : T3Mux2;
	  
	  end
	  // initialisation of the processor
	  always_ff @(posedge clk, negedge nReset)
	  if (!nReset)
	  begin
	  initialisation <= 0;
	  ReadCacheStatus <= 0;
	  JustFinishedForAddress <= 1;
	  DontFetchRegister <= 0;
	  MemAccessRegister <= 0;
	  end
	  else
	 begin
	 initialisation <= 1;
	 ReadCacheStatus <= (DontFetch || PendingSameAddress == 4'hF || MemWrite) ? 1'b0 : 1'b1;
	 JustFinishedForAddress <= (InstReady) ? InstAddress : 1;
	 DontFetchRegister <= (DontFetch) ? 1'b1 : 1'b0;
	 MemAccessRegister <= (MemWrite) ? 1'b1 : 1'b0;
	 end
	 //Invalid cases for Instructions and Data
	 always_ff @(posedge clk,negedge nReset)
	 begin
	 if (!nReset)
	 begin
	 DataVector <= 4'b1111;
	 InstVector <= 4'b1111;
	 StoreHazardVector <= 4'b1111;
	 end
	 else
	 begin
	 if (InstMiss && !IgnoreMiss) InstVector[mhartID_ID] <= 0;
	 if (DoneRetrieving) InstVector [RetrievingDoneFor] <= 1;
	 if (StoreHazard) StoreHazardVector [mhartID_Mem] <= 0;
	 if (DoneWritingData) StoreHazardVector [DoneWritingFor] <= 1;
	 if (MemRead) DataVector [mhartID] <= 0;
	 if (ReadSuccessful)DataVector[mhartID_Mem]<= 1;
	 if (CacheMiss) DataVector[mhartID_Mem] <= 0;
	 if (DoneReadingData) DataVector [DoneForTID] <= 1;
	 
	 end
	 end
	// this combinational block decides what the next thread is, out of order thread selection is enabled to avoid any thread from starting while it cannot be executed
	always_comb
	begin
	nextthread = mhartID;
	DontFetch = 0;
	if (SwitchThread)
	begin
	if (DataVector [mhartID + 1'b1] == 1 && InstVector [mhartID + 1'b1] == 1 && PendingSameAddress[mhartID + 1'b1] == 0 && StoreHazardVector [mhartID + 1'b1] == 1 && !(StoreHazard && mhartID_Mem == mhartID + 1'b1))
	nextthread = mhartID + 1'b1;
	else if (DataVector [mhartID + 2'b10] == 1 && InstVector [mhartID + 2'b10] == 1 && PendingSameAddress[mhartID + 2'b10] == 0 && StoreHazardVector [mhartID + 2'b10] == 1 && !(StoreHazard && mhartID_Mem == mhartID + 2'b10)) 
	nextthread = mhartID + 2'b10;
	else if (DataVector [mhartID + 2'b11] == 1 && InstVector [mhartID + 2'b11] == 1 && PendingSameAddress[mhartID + 2'b11] == 0 && StoreHazardVector [mhartID + 2'b11] == 1 && !(StoreHazard && mhartID_Mem == mhartID + 2'b11)) 
	nextthread = mhartID + 2'b11;
	else if (PendingSameAddress != 4'b1111)  DontFetch = 1;
	end
	end
	
	
	
	always_ff @(posedge clk, negedge nReset)
	begin
	if (!nReset) 
	mhartID <= 0;
	else
	mhartID <= nextthread;
	end
	// For Current Thread Enable
	// conditions here may overlap, but the priority system presented in the multiplixers before resolves the overlapping
	always_comb
	begin
	EnablePCThread = 4'b0000;
	if (InstMiss || InstHit || jump_ID || branch_ID) EnablePCThread [mhartID_ID] = 1;
	if (SwitchThread && !DontFetch && PendingSameAddress != 4'hF ) EnablePCThread [nextthread] = 1;
	if (InstReady && (RetrievingDoneFor == nextthread ) ) EnablePCThread [nextthread] = 1;
	if (InstReady && (RetrievingDoneFor == mhartID)) EnablePCThread [mhartID] = 1;
	if (CacheMiss ) EnablePCThread [mhartID_Mem] = 1;
	if (StoreHazard && StoreHazardVector[mhartID_Mem] == 1) EnablePCThread [mhartID_Mem] = 1;
	end
endmodule