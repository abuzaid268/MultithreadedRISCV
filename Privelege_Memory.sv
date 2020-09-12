module Privelege_WBory(
input logic Enable,clk,
output logic [31:0] Instruction
);
logic [31:0] PrivMemo [1:0];
/*initial
  $readmemb("Priv.mem", PrivMemo);*/
assign Instruction = (Enable) ? PrivMemo[0] : 0;
endmodule

