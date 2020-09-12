module unsigned_sub #(parameter n = 32)
(output logic [n-1:0] unsigned_sub,
input logic [n-1:0] a, b);
assign unsigned_sub = a + b;
endmodule