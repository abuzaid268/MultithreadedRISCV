module WB(
input logic [31:0] Ram_out_WB,Wdata_WB,
input logic [4:0] Waddr_WB,
input logic RegWrite_WB,MemtoReg_WB,
input logic [1:0] mhartID_WB,
output logic [31:0] Wdata_ee,
output logic [4:0] Waddr_ee,
output logic RegWrite_ee,
output logic [1:0] mhartID_ee
);
assign Wdata_ee = (MemtoReg_WB) ? Ram_out_WB : Wdata_WB ;
assign Waddr_ee = Waddr_WB;
assign RegWrite_ee = RegWrite_WB;
assign mhartID_ee  = mhartID_WB;
endmodule