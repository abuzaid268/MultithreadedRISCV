module signed_mult (output logic signed [63:0] signed_mul,
input logic signed [31:0] a, b);
assign signed_mul = a * b; 
endmodule