module unsigned_mult (output logic [63:0] unsigned_mul, input logic [31:0] a, b);
assign unsigned_mul = a * b; 
endmodule