module unsigned_divider(
input logic [31:0] a,b,
output logic [31:0] unsigned_quotient,unsigned_remainder
);
assign unsigned_quotient = a / b;
assign unsigned_remainder = (unsigned_quotient == 0 ) ? a-b : a - (unsigned_quotient * b);
endmodule
