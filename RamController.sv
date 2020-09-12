//
// File Name: pipelined_RISC.sv
// Function: top level module of the processor
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/099/19
//
module RamController(
 input logic [31:0] RamReadAddress,RamWriteAddress,
 input logic [31:0] RamWriteData,
 input logic [15:0] RamData,
 input logic RamWrite,RamRead,clk,nReset,DoneReading,DoneWriting,
 output logic [1:0] ByteEnable,
 output logic [15:0] RamByteData,
 output logic [31:0] RamByteAddress,DataCumulativeRegister,
 output logic DoneWritingData,DoneReadingData,
 output logic RamReadEnable,RamWriteEnable
);

logic ReadingData,WritingData,writingHBS,writingLBS,readingHBS,readingLBS;
// Byte Enable incremental
always_ff @(posedge clk, negedge nReset)
if (!nReset)
	begin
	ByteEnable <= 2'b00;
	DoneWritingData <= 0;
	ReadingData <= 0;
	end
else
	begin
	if (RamRead && !WritingData)
	begin
	if (!readingHBS && !readingLBS) ByteEnable <= 2'b01;
	if (DoneReading && readingLBS) ByteEnable <= 2'b10;
	if (DoneReading && readingHBS) ByteEnable <= 2'b00;
	end	
	if (RamWrite && !ReadingData)
	begin
	if (!writingHBS && !writingLBS) ByteEnable <= 2'b01;
	if (DoneWriting && writingLBS) ByteEnable <= 2'b10;
	if (DoneWriting && writingHBS)begin ByteEnable <= 2'b00; DoneWritingData <= 1; end
	else DoneWritingData <= 0;
	end
	if (RamRead && !WritingData) ReadingData <= 1;
	else ReadingData <= 0;
	if (DoneWriting && writingHBS) DoneWritingData <= 1; 
	else DoneWritingData <= 0;
	end

// Data Write & Read
always_comb
begin
RamByteData = 0;
RamByteAddress = 0;
WritingData = 0;
RamReadEnable = 0;
RamWriteEnable = 0;
writingLBS = 0;
writingHBS = 0;
readingHBS = 0;
readingLBS = 0;
if (RamWrite && !ReadingData)
	begin
		RamByteAddress = RamWriteAddress ;
		   WritingData = 1;
		   RamWriteEnable = 1;
		case(ByteEnable)
		2: begin
		   RamByteData = RamWriteData[31:16];
		   writingHBS = 1;
		   end
		1: begin
		   RamByteData = RamWriteData [15:0];
		   writingLBS = 1;
		   end 
	default: begin
		   RamByteAddress = 0;
		   RamByteData = 0;
		   WritingData = 0;
		   RamWriteEnable = 0;
		   end 
	   endcase
	end   	
     if (RamRead && !WritingData)
	begin 
		   RamByteAddress = RamReadAddress;
		   RamReadEnable = 1;
		case(ByteEnable)
		2: begin
		   readingHBS = 1;
		   end
		1: begin
		   readingLBS = 1;
		   end
	default:begin
		   RamByteAddress = 0;
		   RamReadEnable = 0;
		   end
		   endcase
	end	
end



// Data Read Cumulative Register
always_ff @(posedge clk, negedge nReset)
if (!nReset)
begin
DataCumulativeRegister <= 0;
DoneReadingData <= 0;
end
else
begin
if (DoneReading && readingLBS) DataCumulativeRegister[15:0] <= RamData; 
else if (DoneReading && readingHBS) begin DataCumulativeRegister[31:16] <= RamData; DoneReadingData <= 1; end
else DoneReadingData <= 0;
end

endmodule
/*// writing data Byte Enable
		if (RamWrite && !ReadingData && LBSDone)
		begin
		ByteEnable [0] <= 0;
		ByteEnable [1] <= 1;
		end
		else if (RamWrite && !ReadingData && HBSDone) ByteEnable <= 2'b00;
		else if (RamWrite && !ReadingData )
		begin
		ByteEnable[0] <= 1'b1;
		ByteEnable[1] <= 1'b0;
		end
		// Reading data Byte Enable
		if (DoneReadingData) ByteEnableDataRead <= 0;
		else if (RamRead && !WritingData && (LBSDone || HBSDone))
		begin
		ByteEnable <= ByteEnable + 1'b1 ;
		DataReadFlag <= 1;
		ReadingData <= 1;
		end
		else
		begin
		DataReadFlag <= 0;
		ByteEnable <= 0;
		end
		if (ReadingData)
		DataWriteEnableLatch <= ByteEnableDataRead;
		if (DataWriteEnableLatch == 3) ReadingData <= 0;*/