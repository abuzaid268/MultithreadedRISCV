module signed_sub #(parameter n = 32)
(output logic signed [n-1:0] signed_sub,
input logic signed [n-1:0] a, b);
assign signed_sub = a - b;
endmodule