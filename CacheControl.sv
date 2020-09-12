//
// File Name: CacheControl.sv
// Function: Data Cache Control
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module CacheControl(
input logic Match,clk,nReset,ReadEnable,
input logic [1:0] mhartID_Mem,mhartID_EX,
input logic [31:0] CacheData,WritetoData,Address_Mem,
input logic load,store,DoneWritingData,DoneReadingData,
input logic [31:0] RamData,
output logic [31:0] WriteBackData,WriteDataCache,RamReadAddress,RamWriteAddress,RamWriteData,
output logic [11:0] WriteAddressTag,
output logic [6:0] CacheIndexWrite,
output logic WriteValid,WriteTag,WriteCache,RamRead,RamWrite,StoreHazard,
output logic CacheHit,CacheMiss,
output logic [1:0] DoneForTID,DoneWritingFor
);
logic [7:0] PendingStoreRequest;
logic [1:0] WritingForTID,ReadingForTID;
logic [2:0] LastStoringTID;
logic [31:0] WriteAddress,ReadAddress,WritetoDataRegister;
logic [31:0] CacheWriteAddressStore,CacheWriteDataStore;
logic [31:0] PendingStoreAddress [7:0];
logic [31:0] PendingLoadAddress [3:0];
logic [31:0] PendingStoreData [7:0];
logic [3:0]PendingReadRequest;
logic CacheHazardFlag,Reading,Writing,StoreRequest;
// load logic
enum logic {Idle,Update} state,nextstate;

 always_ff @(posedge clk, negedge nReset)
 if (!nReset)
 begin
 ReadAddress <= 0;
 PendingReadRequest <= 4'b0000;
 ReadingForTID <= 0;
 Reading <= 0;
 RamRead <= 0;
 end
 else 
 begin
 // for reading cache, must happen every time load takes place
 if (ReadEnable)
 ReadAddress <= Address_Mem;
 // logic for Miss Queue
 if (CacheMiss && (Reading || (!Reading && PendingReadRequest != 0 )) && ReadingForTID != mhartID_Mem)
	 begin
	 PendingReadRequest [mhartID_Mem] <= 1;
	 PendingLoadAddress [mhartID_Mem] <= ReadAddress;
	 end
 if ((DoneReadingData || !Reading) && PendingReadRequest != 0)
	 begin
	 if (PendingReadRequest [ReadingForTID + 1'b1] == 1)
		 begin
		 PendingReadRequest [ReadingForTID + 1'b1] <= 0;
		 RamRead <= 1;
		 RamReadAddress <= PendingLoadAddress [ReadingForTID + 1'b1];
		 ReadingForTID <= ReadingForTID + 1'b1;
		 Reading <= 1;
		 end
	 else if (PendingReadRequest [ReadingForTID + 2'b10] == 1)
		 begin
		 PendingReadRequest [ReadingForTID + 2'b10] <= 0;
		 RamRead <= 1;
		 RamReadAddress <= PendingLoadAddress [ReadingForTID + 2'b10];
		 ReadingForTID <= ReadingForTID + 2'b10;
		 Reading <= 1;
		 end
	 else if (PendingReadRequest [ReadingForTID + 2'b11] == 1)
		 begin
		 PendingReadRequest [ReadingForTID + 2'b11] <= 0;
		 RamRead <= 1;
		 RamReadAddress <= PendingLoadAddress [ReadingForTID + 2'b11];
		 ReadingForTID <= ReadingForTID + 2'b11;
		 Reading <= 1;
		 end	
	end	 
else if (CacheMiss && !Reading)
	begin
	RamRead <= 1;
	RamReadAddress <= ReadAddress;
	ReadingForTID <= mhartID_Mem;
	Reading <= 1;
	end
else if (DoneReadingData)
	begin
	RamRead <= 0;
	RamReadAddress <= 1;
	 Reading <= 0;
	end
 end
 
 //logic forwarded;
// load control
always_comb
begin
CacheHit = 0;
CacheMiss = 0;
WriteBackData = 0;
//forwarded = 0;
	if (load)
	begin
	if (Match)
	begin
	CacheHit = 1;
	WriteBackData = CacheData;
	end
	else if (ReadAddress == PendingStoreAddress [mhartID_Mem]) begin WriteBackData = PendingStoreData [mhartID_Mem]; CacheHit = 1; /*forwarded = 1;*/end
	else if (ReadAddress == PendingStoreAddress [mhartID_Mem + 3'b100]) begin  WriteBackData = PendingStoreData [mhartID_Mem +  3'b100]; CacheHit = 1;/*forwarded = 1;*/ end
	else if (ReadAddress == RamWriteAddress) begin  WriteBackData = RamWriteData; CacheHit = 1; end
	else if (Reading && ReadingForTID == mhartID_Mem) CacheMiss = 0;
	else 
	CacheMiss = 1;
	end
	end	
always_ff @(posedge clk, negedge nReset)
if (!nReset)state <= Idle;
else state <= nextstate;

// store logic
always_comb
begin
RamWrite = 0;
Writing = 0;
RamWriteAddress = 0;
RamWriteData = 0;
nextstate = state;
case (state)
Idle : if (store || PendingStoreRequest != 0) nextstate = Update;
Update:
begin
RamWriteAddress = WriteAddress;
RamWriteData = WritetoDataRegister;
Writing = 1;
RamWrite = 1;
if (DoneWritingData)
begin
if (PendingStoreRequest == 0 && !StoreRequest)
nextstate = Idle;
end
end
endcase
end





// Write Ram Write Queue
always_ff @(posedge clk, negedge nReset)
begin
if (!nReset)
	begin
	 PendingStoreRequest <= 0;
	 WritetoDataRegister <= 0;
	 WriteAddress <= 0;
	 LastStoringTID <= 0;
	 WritingForTID <= 0;
	 StoreHazard <= 0;
	end
else
begin
 if (store && Writing)
 begin
 if (PendingStoreRequest [mhartID_EX] == 1 && PendingStoreRequest [mhartID_EX + 3'b100] == 1)
 begin
 PendingStoreRequest[mhartID_EX] <= 1;
 StoreHazard <= 1;
 end
 else
  begin
	 if (PendingStoreRequest [mhartID_EX] == 0)
	 begin
	 PendingStoreRequest [mhartID_EX] <= 1;
	 PendingStoreAddress [mhartID_EX]<= Address_Mem;
	 PendingStoreData [mhartID_EX]<= WritetoData;
	 end
	 else if (PendingStoreRequest [mhartID_EX + 3'b100 ] == 0)
	 begin
	 PendingStoreRequest [mhartID_EX + 3'b100 ] <= 1;
	 PendingStoreAddress [mhartID_EX + 3'b100 ]<= Address_Mem;
	 PendingStoreData [mhartID_EX + 3'b100 ]<= WritetoData;
	 end
	 StoreHazard <= 0;
	 end
 end
 else StoreHazard <= 0;
 if ((DoneWritingData || !Writing) && PendingStoreRequest != 0)
 begin
	  if (PendingStoreRequest [LastStoringTID + 1'b1])
		  begin
		  PendingStoreRequest [LastStoringTID + 1'b1] <= 0;
		  PendingStoreAddress [LastStoringTID + 1'b1] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID + 1'b1];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID + 1'b1];
		  LastStoringTID <= LastStoringTID + 1'b1;
		  WritingForTID <= LastStoringTID + 1'b1;
		  end
	  else if (PendingStoreRequest [LastStoringTID + 2'b10])
		  begin
		  PendingStoreRequest [LastStoringTID + 2'b10] <= 0;
		  PendingStoreAddress [LastStoringTID + 2'b10] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID + 2'b10];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID + 2'b10];
		  LastStoringTID <= LastStoringTID + 2'b10;
		  WritingForTID <= LastStoringTID + 2'b10;
		  end
	  else if (PendingStoreRequest [LastStoringTID + 2'b11])
	  begin
		  PendingStoreRequest [LastStoringTID + 2'b11] <= 0;
		  PendingStoreAddress [LastStoringTID + 2'b11] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID + 2'b11];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID + 2'b11];
		  LastStoringTID <= LastStoringTID + 2'b11;
		  WritingForTID <= LastStoringTID + 2'b11;
		  end// new queue
	  else if (PendingStoreRequest [LastStoringTID + 3'b100])
	  begin
		  PendingStoreRequest [LastStoringTID + 3'b100] <= 0;
		  PendingStoreAddress [LastStoringTID + 3'b100] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID + 3'b100];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID + 3'b100];
		  LastStoringTID <= LastStoringTID + 3'b100;
		  WritingForTID <= LastStoringTID + 3'b100;
		  end
	  else if (PendingStoreRequest [LastStoringTID + 3'b101])
	  begin
		  PendingStoreRequest [LastStoringTID + 3'b101] <= 0;
		  PendingStoreAddress [LastStoringTID + 3'b101] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID + 3'b101];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID + 3'b101];
		  LastStoringTID <= LastStoringTID + 3'b101;
		  WritingForTID <= LastStoringTID + 3'b101;
		  end
	  else if (PendingStoreRequest [LastStoringTID + 3'b110])
	  begin
		  PendingStoreRequest [LastStoringTID + 3'b110] <= 0;
		  PendingStoreAddress [LastStoringTID + 3'b110] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID + 3'b110];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID + 3'b110];
		  LastStoringTID <= LastStoringTID + 3'b110;
		  WritingForTID <= LastStoringTID + 3'b110;
		  end
	  else if (PendingStoreRequest [LastStoringTID + 3'b111])
	  begin
		  PendingStoreRequest [LastStoringTID + 3'b111] <= 0;
		  PendingStoreAddress [LastStoringTID + 3'b111] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID + 3'b111];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID + 3'b111];
		  LastStoringTID <= LastStoringTID + 3'b111;
		  WritingForTID <= LastStoringTID + 3'b111;
		  end
	  else if (PendingStoreRequest [LastStoringTID])
		  begin
		  PendingStoreRequest [LastStoringTID] <= 0;
		  PendingStoreAddress[LastStoringTID] <= 0;
		  WriteAddress <= PendingStoreAddress [LastStoringTID ];
		  WritetoDataRegister <= PendingStoreData [LastStoringTID];
		  LastStoringTID <= LastStoringTID;
		  WritingForTID <= LastStoringTID;
		  end
 end
 else if (store && !Writing)
	 begin
	 WriteAddress <= Address_Mem;
	 WritetoDataRegister <= WritetoData;
	 WritingForTID <= mhartID_EX;
	 LastStoringTID <= mhartID_EX;
	 end
	 if (store && !Writing )
	 StoreRequest <= 1;
	 else
	 StoreRequest <= 0;
end
end

// Write to cache Queue
always_ff @(posedge clk, negedge nReset)
if (!nReset)
	begin
	CacheWriteAddressStore <= 0;
	CacheWriteDataStore <= 0;
	CacheHazardFlag <= 0;
	end
else
begin
if (DoneReadingData && store)
	begin
	CacheHazardFlag <= 1;
	CacheWriteAddressStore <= Address_Mem;
	CacheWriteDataStore <= WritetoData;
	end
else CacheHazardFlag <= 0;
end


// write back cache logic
always_comb
begin
WriteTag = 0;
WriteValid = 0;
WriteCache = 0;
WriteAddressTag = 0;
WriteDataCache = 0;
CacheIndexWrite = 0;
DoneForTID = 0;
DoneWritingFor = 0;
if (DoneReadingData)
begin
	WriteTag = 1;
	WriteValid = 1;
	WriteCache = 1;
	DoneForTID = ReadingForTID;
	WriteAddressTag = RamReadAddress [20:9];
	WriteDataCache = RamData;
	CacheIndexWrite = RamReadAddress [8:2];
end
if (store && !DoneReadingData)
begin
	WriteTag = 1;
	WriteValid = 1;
	WriteCache = 1;
	WriteAddressTag = Address_Mem [20:9];
	WriteDataCache = WritetoData;
	CacheIndexWrite = Address_Mem [8:2];
end
if (CacheHazardFlag)
begin
	WriteTag = 1;
	WriteValid = 1;
	WriteCache = 1;
	WriteAddressTag = CacheWriteAddressStore [20:9];
	WriteDataCache = CacheWriteDataStore;
	CacheIndexWrite = CacheWriteAddressStore [8:2];
end
if (DoneWritingData) DoneWritingFor = WritingForTID;
end		 
endmodule
