//
// File Name: InstMem.sv
// Function: instruction cache top level
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module InstMem(
input logic nReset,clk,InstReady,Ignore,
input logic Enable,initialising,ReadCacheStatus,branch_ID,jump_ID,flush,
input logic [1:0] mhartID_ID,
input logic [31:0] Address,InstfromRam,
output logic InstMiss,InstHit,InstRead,DoneRetrieving,IgnoreMiss,
output logic [31:0] I,InstAddress,
output logic [31:0] FetchingAddress,
output logic [1:0]  FetchingmhartID,RetrievingDoneFor
);
logic WriteInst,WriteTag,WriteValid,Match,Valid;
logic [6:0] CacheIndexRead,CacheIndexWrite,TagCompare;
logic [31:0] InstData;
logic [31:0] Inst;
logic [6:0] TagAddress,WriteAddressTag;


 always_ff @(posedge clk)
 begin
 TagAddress <= Address [15:9];
 end
 always_comb
 CacheIndexRead = Address [8:2];
 
 always_ff @(posedge clk, negedge nReset)
 begin
 if (!nReset)
 begin
 FetchingAddress <= 0;
 FetchingmhartID <= 0;
 end
 else
 begin
 FetchingAddress <= Address;
 FetchingmhartID <= mhartID_ID;
 end
 end
 
assign Match = ((TagCompare == TagAddress)&& Valid);

InstCache IC1 (
.clk,.WriteInst,.Enable,.nReset,
.CacheIndexRead,.CacheIndexWrite,
.InstData,
.Inst
);
InstValid IV1
(
.clk,.WriteValid,.nReset,.Enable,//.nReset,
.CacheIndexWrite,.CacheIndexRead,
.Valid
);
InstTag IT1
(
.WriteTag,.clk,.Enable,.nReset,
.WriteAddressTag,
.CacheIndexWrite,.CacheIndexRead,
.TagCompare
);
InstCacheControl ICC1 (
.InstReady,
.clk,
.Match,
.Ignore,
.nReset,
.ReadCacheStatus,
.branch_ID,
.jump_ID,
.Inst,
.InstfromRam,
.Address(FetchingAddress),
.I,
.InstMiss,
.InstHit,
.WriteInst,
.WriteTag,
.WriteValid,
.InstRead,//Ram
.WriteAddressTag,
.CacheIndexWrite,
.InstAddress,//Ram
.InstData,
.flush,
.mhartID_ID(FetchingmhartID),
.RetrievingDoneFor,
.DoneRetrieving,.initialising,
.IgnoreMiss
);




endmodule