//
// File Name: branch.sv
// Function: branch comparator
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
`include "opcodes.sv"
module branch(
input logic [6:0] opcode,
input logic [2:0] func3,
input logic signed [31:0] rs1,rs2,
output logic branch
);
always_comb 
begin
branch = 0;
if (opcode == `Btype)
begin
case (func3)
0 : if (rs1 == rs2)   branch = 1;
1 : if (rs1 != rs2)   branch = 1;
4 : if (rs1 < rs2)    branch = 1;
5 : if ( rs1 >= rs2)  branch = 1;
default : ;
endcase
end // if
end // always_comb
endmodule
