module signed_divider(
input logic signed [31:0] a,b,
output logic signed [31:0] signed_quotient,signed_remainder
);
assign signed_quotient = a / b;
assign signed_remainder = (signed_quotient == 0 ) ? a-b : a - (signed_quotient * b);
endmodule
