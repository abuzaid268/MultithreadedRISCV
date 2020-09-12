module sram_tb;

logic clk,nReset;
logic CS,WE,OE,LBS,HBS;
logic [19:0] addr;
wire [15:0] data;
logic RamReadEnable,RamWriteEnable;
logic [1:0] ByteEnable;
logic [31:0] RamByteAddress;
logic [15:0] RamByteData;
logic [31:0] RamReadAddress,RamWriteAddress,DataCumulativeRegister;
logic [31:0] RamWriteData;
logic [15:0] RamData;
logic RamWrite,RamRead,DoneReading,DoneWriting,DoneReadingData,DoneWritingData;

RamController RC1 (.*);
SRAMController SC1 (.*);
asynchronous_ram AR1 (.*);

initial
begin
  clk =  0;
    forever #5ns clk = ~clk;
end
initial
begin
nReset = 0;
#1ns
nReset=1;
#1ns 
nReset = 1;
end

initial
begin
RamReadAddress = 32'h00000000;
RamRead = 0;
RamWrite = 1;
RamWriteAddress = 32'h00000000;
RamWriteData = 32'h00ABCDEF;
#60ns RamRead = 1;
#20ns RamWrite = 0;
#50ns
RamRead = 1;
RamReadAddress = 32'h00BBBBBB;
end


endmodule