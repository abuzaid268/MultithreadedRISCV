//
// File Name: immediate_generator.sv
// Function: immediate generator
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module immediate_generator(
input logic [2:0] immSel,
input logic [31:0] IntmhartID,
input logic [24:0] I,
output logic [31:0] imm
);
always_comb
begin
imm = 0;
case (immSel)
0 : imm = {I[24:5],{12{1'b0}}};
1 : imm = {{12{I[24]}},I[12:5],I[13],I[23:14],1'b0};
2 : imm = {{20{I[24]}},I[24:13]};
3 : imm = {{20{I[24]}},I[0],I[23:18],I[4:1],1'b0};//branch
4 : imm = {{21{I[24]}}, I[23:18],I[4:0]};
5 : imm = IntmhartID;
default :;
endcase
end
endmodule
