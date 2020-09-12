//
// File Name: InstCacheControl.sv
// Function: instruction cache control
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module InstCacheControl(
input logic InstReady,
input logic clk,
input logic Match,
input logic Ignore,
input logic nReset,
input logic flush,
input logic ReadCacheStatus,
input logic branch_ID,
input logic jump_ID,
input logic [1:0] mhartID_ID,
input logic initialising,
input logic [31:0] Inst,
input logic [31:0] InstfromRam,
input logic [31:0] Address,
output logic [31:0] I,
output logic IgnoreMiss,
output logic InstMiss,
output logic InstHit,
output logic WriteInst,
output logic WriteTag,
output logic WriteValid,
output logic DoneRetrieving,
output logic InstRead,//Ram
output logic [6:0] WriteAddressTag,
output logic [6:0] CacheIndexWrite,
output logic [31:0] InstAddress,//Ram
output logic [31:0] InstData,//Ram
output logic [1:0] RetrievingDoneFor
);
logic [1:0] RetrievingFor;
logic [3:0] PendingRequests;
logic [31:0] PendingRequestsAddress [3:0];
logic [31:0] LastRetrievedAddress;
logic [1:0] LastPendingThread;
logic RetrieveRequest;
logic JustFinishRetrieving;
logic nReady;
// for
// Checking for miss or hit
always_comb
begin
InstHit = 0;
InstMiss = 0;
RetrieveRequest = 0;
I = 0;
IgnoreMiss = 0;
if (InstReady && Address == InstAddress) I = InstfromRam;
if (ReadCacheStatus)
begin
if (Match)
begin
InstHit = 1;
I = Inst;
end
else if (!Ignore )
begin
if ((JustFinishRetrieving && Address == LastRetrievedAddress) || (InstReady && Address == InstAddress) ) I = InstfromRam;
else 
begin
InstMiss = 1;
if (Address == InstAddress && InstRead) IgnoreMiss = 1;
else
if (!nReady)  RetrieveRequest = 1;
			end
			end
		end	
end			
// Retrieve Request from Ram
always_ff @(posedge clk, negedge nReset)
if (!nReset)
	begin
	InstAddress <= 1;
	InstRead <= 0;
	nReady <= 0;
	PendingRequests <= 4'b0000;
	JustFinishRetrieving <= 0;
	LastRetrievedAddress <= 1;
	end
else
	begin
	if (InstRead == 0 && PendingRequests != 0)
	begin
				if (PendingRequests [LastPendingThread + 1'b1] == 1)
				begin
				InstRead <= 1;
				InstAddress <= PendingRequestsAddress [LastPendingThread + 1'b1];
				nReady <= 1;
				RetrievingFor <= LastPendingThread + 1'b1;
				end
				else if (PendingRequests [LastPendingThread + 2'b10] == 1)
				begin
				InstRead <= 1;
				InstAddress <= PendingRequestsAddress [LastPendingThread + 2'b10];
				nReady <= 1;
				RetrievingFor <= LastPendingThread + 2'b10;
				end
				else if (PendingRequests [LastPendingThread + 2'b11] == 1)
				begin
				InstRead <= 1; 
				InstAddress <= PendingRequestsAddress [LastPendingThread + 2'b11];
				nReady <= 1;
				RetrievingFor <= LastPendingThread + 2'b11;
				end
	end
	if (InstReady)
	begin
	PendingRequests [RetrievingFor] <= 0;
	JustFinishRetrieving <= 1;
	LastRetrievedAddress <= InstAddress;
	end
	else
	begin
	JustFinishRetrieving <= 0;
	LastRetrievedAddress <= 1;
	end
	if (InstMiss && nReady)
		begin
	     if (Address != InstAddress)
		 begin
		PendingRequests [mhartID_ID] <= 1;
		PendingRequestsAddress [mhartID_ID] <= Address;
		end
		end
		if (RetrieveRequest)
		begin
		InstAddress <= Address;
		InstRead <= 1;
		nReady <= 1;
		RetrievingFor <= mhartID_ID;
		end
		else if ((InstReady )&& (PendingRequests[LastPendingThread + 1'b1] != 0 || PendingRequests[LastPendingThread + 2'b10] != 0 || PendingRequests[LastPendingThread + 2'b11] != 0 ))
				begin
				if (PendingRequests [LastPendingThread + 1'b1] == 1)
				begin
				InstRead <= 1;
				InstAddress <= PendingRequestsAddress [LastPendingThread + 1'b1];
				nReady <= 1;
				RetrievingFor <= LastPendingThread + 1'b1;
				end
				else if (PendingRequests [LastPendingThread + 2'b10] == 1)
				begin
				InstRead <= 1;
				InstAddress <= PendingRequestsAddress [LastPendingThread + 2'b10];
				nReady <= 1;
				RetrievingFor <= LastPendingThread + 2'b10;
				end
				else if (PendingRequests [LastPendingThread + 2'b11] == 1)
				begin
				InstRead <= 1; 
				InstAddress <= PendingRequestsAddress [LastPendingThread + 2'b11];
				nReady <= 1;
				RetrievingFor <= LastPendingThread + 2'b11;
				end
			end
	else if (InstReady && RetrieveRequest)
		begin
		InstAddress <= Address;
		InstRead <= 1;
		nReady <= 1;
		RetrievingFor <= mhartID_ID;
		end
	else if (InstReady)
	begin
	nReady <= 0;
	InstRead <= 0;
	end
	end
// Writing Back to Cache
always_comb
begin
WriteTag = 0;
WriteInst = 0;
WriteValid = 0;
InstData = 0;
WriteAddressTag = 0;
CacheIndexWrite = 0;
DoneRetrieving = 0;
RetrievingDoneFor = 0;
LastPendingThread = RetrievingFor;
if (InstReady)
	begin
	WriteTag = 1;
	WriteInst = 1;
	WriteValid = 1;
	DoneRetrieving = 1;
	RetrievingDoneFor = RetrievingFor;
	InstData = InstfromRam;
	WriteAddressTag = InstAddress[15:9];
	CacheIndexWrite = InstAddress[8:2];
	end
end
endmodule