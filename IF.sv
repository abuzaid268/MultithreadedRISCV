//
// File Name: IF.sv
// Function: instruction fetch module
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module IF(
input logic clk,nReset,flush,Ignore,
input logic [1:0] nextthread,mhartID,
output logic [31:0] I_ID,newpc_ID,currentPC_ID,
input logic InstSource,branch_ID,jump_ID,
//Ram
input logic [31:0]newPC,
input logic [31:0] ThreadAddress,
input logic InstReady,ReadCacheStatus,
input logic [31:0] InstOut,
output logic [31:0] InstAddress,FetchingAddress,
output logic InstRead,DoneRetrieving,
output logic InstMiss,InstHit,IgnoreMiss,
output logic [1:0] RetrievingDoneFor,FetchingmhartID,mhartID_ID
);
logic [31:0] I,Instruction,newPCtemp;
logic initialising;
InstMem IM1 (
.nReset,.clk,.InstReady,.Enable(InstSource),.ReadCacheStatus,.branch_ID,
.Address(ThreadAddress),.InstfromRam(InstOut),.FetchingAddress,.jump_ID,.flush,
.InstMiss,.InstHit,.InstRead,.initialising,.Ignore,.FetchingmhartID,.IgnoreMiss,
.I,.InstAddress,.mhartID_ID(nextthread),.RetrievingDoneFor,.DoneRetrieving
);
assign I_ID = (InstMiss) ? 0 : I;
assign mhartID_ID = FetchingmhartID;
always_ff @(posedge clk, negedge nReset)
begin
   if (!nReset)
   begin
   newpc_ID <= 0;
   newPCtemp <= 0;
   currentPC_ID <= 0;
   initialising <= 0;
   end
	else
	begin
     newpc_ID <=  newPC;
     currentPC_ID <= ThreadAddress;
	initialising <= 1;
  end
end
endmodule