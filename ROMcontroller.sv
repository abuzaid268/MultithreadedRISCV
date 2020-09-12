//
// File Name: pipelined_RISC.sv
// Function: top level module of the processor
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/099/19
//
module ROMcontroller (
 input logic [31:0] InstAddress,
 input logic [7:0] InstOut,
 input logic clk,nReset,InstRead,
 output logic [31:0] InstByteAddress,InstCumulativeRegister,
 output logic DoneReadingInst
);
logic [1:0] ByteEnableInstRead,InstByteEnableRegister;
logic ReadingInst,InstReadFlag;
// Byte Enable incremental
always_ff @(posedge clk, negedge nReset)
if (!nReset)
	begin
	ByteEnableInstRead <= 0;
	InstByteEnableRegister <= 0;
	end
else
	begin
		// reading inst Byte Enable
		if (DoneReadingInst)
		ByteEnableInstRead <= 0;
		else if (InstRead)
		begin
		InstReadFlag <= 1;
		ByteEnableInstRead <= ByteEnableInstRead + 1'b1;
		end
		else
		begin
		InstReadFlag <= 0;
		ByteEnableInstRead <= 0;
		end
		if (ReadingInst)
		InstByteEnableRegister <= ByteEnableInstRead;
	end
// Read Inst logic
always_comb
begin
ReadingInst = 0;
InstByteAddress = 0;
	if (InstRead)
	begin
		case (InstByteEnableRegister)
		3:  begin
			InstByteAddress = InstAddress + ByteEnableInstRead;
			ReadingInst = 1;
			end
		2:  begin
			InstByteAddress = InstAddress + ByteEnableInstRead;
			ReadingInst = 1;
			end
		1:  begin
			InstByteAddress = InstAddress + ByteEnableInstRead;
			ReadingInst = 1;
			end
		0:  begin
			InstByteAddress = InstAddress + ByteEnableInstRead;
			ReadingInst = 1;
			end	
		endcase
	end	
end
// InstCumulativeRegister
always_ff @(posedge clk, negedge nReset)
if (!nReset)
begin
InstCumulativeRegister <= 0;
DoneReadingInst <= 0;
end
else
begin
	if (InstReadFlag)
	begin
		case (InstByteEnableRegister)
		0: InstCumulativeRegister[7:0] <= InstOut;
		1: InstCumulativeRegister[15:8] <= InstOut;
		2: InstCumulativeRegister[23:16]<= InstOut;
		3: InstCumulativeRegister[31:24]<= InstOut;
		endcase
	end
	if (InstByteEnableRegister == 3) DoneReadingInst <= 1;
	else DoneReadingInst <= 0;
end

endmodule
