module SRAMController (
// SRAM INTERFACS
output logic [19:0] addr,
inout  wire [15:0] data,
output logic WE,CS,OE,LBS,HBS,DoneReading,DoneWriting,
// PROCSSSOR Inputs and Outputs
input logic RamReadEnable,RamWriteEnable,clk,nReset,
input logic [1:0] ByteEnable,
input logic [31:0] RamByteAddress,
input logic [15:0] RamByteData,
output logic [15:0] RamData
);
logic hold,setup;
always_ff @(posedge clk, negedge nReset)
if (!nReset)
begin
CS <= 1;
WE <= 1;
OE <= 1;
LBS <= 1;
HBS <= 1;
DoneReading <= 0;
DoneWriting <= 0;
setup <= 0;
hold <= 0;
end
else
begin
addr <= RamByteAddress;
RamData <= data;
LBS <= ~(ByteEnable[0] & (RamReadEnable || RamWriteEnable));
HBS <= ~(ByteEnable[1] & (RamReadEnable || RamWriteEnable));
if ((RamReadEnable || RamWriteEnable) && !(setup || hold)) setup <= 1;
// read logic
if (setup && RamReadEnable)
begin
OE <= 0;
CS <= 0;
hold <= 1;
setup <= 0;
end
if (hold && RamReadEnable)
begin
OE <= 1;
CS <= 1;
hold <= 0;
DoneReading <= 1;
end
else DoneReading <= 0;
// write logic
if (setup && RamWriteEnable)
begin
CS <= 0;
WE <= 0;
hold <= 1;
setup <= 0;
end
if (hold && RamWriteEnable)
begin
CS <= 1;
WE <= 1;
hold <= 0;
DoneWriting <= 1;
end
else DoneWriting <= 0;
end
assign data	= (RamWriteEnable) ? RamByteData : 16'hzzzz;
endmodule