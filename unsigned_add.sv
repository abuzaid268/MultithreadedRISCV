module unsigned_add #(parameter n = 32)
(output logic [n-1:0] unsigned_add,
input logic [n-1:0] a, b);
assign unsigned_add = a + b;
endmodule