module prog #(parameter Psize = 512,  n = 32) 
(input logic [ n-1:0] address,
output logic [ n-1:0] I); 
logic [7:0] progMem[ Psize - 1 :0];
initial
  $readmemb("D:/Desktop/Education/Msc/Thesis/design/MT/files/prog.mem", progMem);
always_comb
  begin
  I[31:24] = progMem[address];
  I[23:16] = progMem[address+1'b1];
  I[15:8] = progMem[address+2'b10];
  I[7:0] = progMem[address + 2'b11];
  end
endmodule
