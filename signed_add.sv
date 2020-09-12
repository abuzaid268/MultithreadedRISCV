module signed_add #(parameter n = 32)
(output logic signed [n-1:0] signed_add,
input logic signed [n-1:0] a, b);
assign signed_add = a + b;
endmodule