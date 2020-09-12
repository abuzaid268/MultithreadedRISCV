//
// File Name: alu.sv
// Function: ALU
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
`include "alucodes.sv"
module alu #(parameter n = 32)
(input logic [n-1:0] a,b,
input logic clk,
output logic [n-1:0] out,
input logic [4:0] ALUOp,
input logic [4:0] sa
);
logic [n-1:0] signed_add,signed_sub,unsigned_sub,unsigned_quotient,unsigned_remainder,signed_quotient,signed_remainder;
logic [63:0] signed_mul, unsigned_mul;

signed_add add1(.a(a),.b(b),.signed_add(signed_add));


signed_sub sub1(.a(a),.b(b),.signed_sub(signed_sub));

unsigned_sub sub2(.a(a),.b(b),.unsigned_sub(unsigned_sub));

signed_mult mul1(.a(a),.b(b),.signed_mul(signed_mul));

unsigned_mult mul2(.a(a),.b(b),.unsigned_mul(unsigned_mul));

signed_divider div1(.a(a),.b(b),.signed_quotient(signed_quotient),.signed_remainder(signed_remainder));

unsigned_divider div2(.a(a),.b(b),.unsigned_quotient(unsigned_quotient),.unsigned_remainder(unsigned_remainder));

always_comb
begin
out = 0;
case (ALUOp)
`alu_add: out = signed_add;
`alu_sub: out = signed_sub;
`alu_and: out = (a && b);
`alu_or:  out = (a || b);
`alu_xor: out = (a ^^ b);
`alu_nor: out = ~(a || b);
`alu_sll: out = a << b;
`alu_srl: out = a >> b;
`alu_sra: out = a >>> b;
`alu_slli: out = a << sa;
`alu_srli: out = a >> sa;
`alu_srai: out = a >>> sa;
`alu_slt:  out = (signed_sub[31] == 1) ? 1: 0;
`alu_sltu: out = (unsigned_sub[31] == 1) ? 1: 0;
`alu_div:  out = signed_quotient;
`alu_divu: out = unsigned_quotient;
`alu_mul:  out = signed_mul[31:0];
`alu_mulh: out = signed_mul[63:32];
`alu_mulhu: out = unsigned_mul[63:32];
`alu_rem : out = signed_remainder;
`alu_remu: out = unsigned_remainder;
default :  out = 0;
endcase// case ALUOp
end// always_comb
endmodule