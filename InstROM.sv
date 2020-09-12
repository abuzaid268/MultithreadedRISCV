//
// File Name: InstROM.sv
// Function: ROM of instructions
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module InstROM(
 input logic [31:0] InstByteAddress,
 input logic InstRead,clk,
 output logic [7:0] InstOut

);

logic [7:0] InstRom [ 0:1023];
initial
$readmemh("D:/Desktop/fourthreadscompiler/simulation files/inst.sv",InstRom);
always_ff @(posedge clk)
if (InstRead) InstOut <= InstRom [InstByteAddress];


endmodule