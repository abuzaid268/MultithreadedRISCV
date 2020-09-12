//
// File Name: EX.sv
// Function: execute stage
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module EX(
input logic [31:0] Rdata1_EX,Rdata2_EX,Wdata_WB,imm_EX,currentPC_EX,
input logic RegWrite_EX,ALUSrc_EX,MemWrite_EX,MemRead_EX,MemtoReg_EX,store_address_EX,clk,nReset,aui_EX,flush,
input logic [1:0] mhartID_EX,
input logic [4:0] ALUOpin_EX,
input logic [31:0] newpc_EX,
input logic [31:0] I_EX,
output logic [31:0] Wdata_Mem,Rdata2_Mem,out,MemAddress,currentPC_Mem,T0out,T1out,T2out,T3out,T0in,T1in,T2in,T3in,
output logic [4:0] Waddr_Mem,
output logic RegWrite_Mem,MemWrite_Mem,MemRead_Mem,MemtoReg_Mem,ReadEnable,
output logic [1:0] mhartID_Mem,
input logic [1:0] ForwardA,ForwardB,
// external data memory
output logic ReadAccess,LED0,LED1,LED2,LED3,
output logic [7:0] address
);
  logic [31:0] ALUBMUX,ALUAMUX,storeregister;//,store_register,absolute_jump_Mem1;
  logic [4:0] DstMux,ALUOp;
  logic [31:0] ForwardAMux,ForwardBMux;
  
  alu alu1(.a(ALUAMUX),.b(ALUBMUX),.out,.ALUOp(ALUOpin_EX),.clk,.sa(I_EX[24:20]));
 
  assign ALUAMUX    = (aui_EX)       ? currentPC_EX : ForwardAMux;
  assign ALUBMUX    = (ALUSrc_EX)   ?  imm_EX: ForwardBMux;
  
  assign memorymux = out[20];
  assign storeregister = (store_address_EX) ? newpc_EX : out;
  assign ReadEnable = (MemRead_EX & !memorymux ) ? 1'b1 : 1'b0;
  assign MemAddress = storeregister;
  assign MemWrite_Mem = MemWrite_EX;
  assign ReadAccess = (MemRead_EX & memorymux) ? 1'b1 : 1'b0;
  assign address = {storeregister[9:2]};
  always_ff @(posedge clk, negedge nReset)
  if (!nReset)
  begin
  RegWrite_Mem <= 0;
  MemtoReg_Mem <= 0;
  Waddr_Mem <= 0;
  Wdata_Mem <= 0;
  MemRead_Mem <= 0;
 /* LED0 <= 0;
  LED1 <= 0;
  LED2 <= 0;
  LED3 <= 0;
  T0out <= 0;
  T1out <= 0;
  T2out <= 0;
  T3out <= 0;
  T0in <= 0;
  T1in <= 0;
  T2in <= 0;
  T3in <= 0;*/
  mhartID_Mem <= 0;
  currentPC_Mem <= 0;
  end
  else if (flush)
  begin
  RegWrite_Mem <= 0;
  MemtoReg_Mem <= 0;
  Waddr_Mem <= 0;
  Wdata_Mem <= 0;
  MemRead_Mem <= 0;
 // MemWrite_Mem = 0;
  //Rdata2_Mem <= 0;
  end
  else
  begin
  RegWrite_Mem <= RegWrite_EX;
  MemtoReg_Mem <= MemtoReg_EX;
  Waddr_Mem <= I_EX[11:7];
  Wdata_Mem <= storeregister;
  mhartID_Mem <= mhartID_EX;
  currentPC_Mem <= currentPC_EX;
  MemRead_Mem <= MemRead_EX;
  if (MemWrite_EX && out == 32'h00) begin T0out <= Rdata2_Mem; LED0 <= 1; end else LED0 <= 0;
  if (MemWrite_EX && out == 32'h02) T0in <= Rdata2_Mem;
  if (MemWrite_EX && out == 32'h04) begin T1out <= Rdata2_Mem; LED1 <= 1; end else LED1 <= 0;
  if (MemWrite_EX && out == 32'h06) T1in <= Rdata2_Mem;
  if (MemWrite_EX && out == 32'h08) begin T2out <= Rdata2_Mem; LED2 <= 1; end else LED2 <= 0;
  if (MemWrite_EX && out == 32'h0A) T2in <= Rdata2_Mem;
  if (MemWrite_EX && out == 32'h0C) begin T3out <= Rdata2_Mem; LED3 <= 1; end else LED3 <= 0;
  if (MemWrite_EX && out == 32'h0E) T3in <= Rdata2_Mem;
  end
  // forwarding mux
 always_comb
 begin
 case (ForwardA)
 0: ForwardAMux = Rdata1_EX;
 1: ForwardAMux =  Wdata_WB;
 2: ForwardAMux = Wdata_Mem;
 default: ForwardAMux = Rdata1_EX;
 endcase 
 case (ForwardB)
 0: ForwardBMux = Rdata2_EX;
 1: ForwardBMux =  Wdata_WB;
 2: ForwardBMux = Wdata_Mem;
 default: ForwardBMux = Rdata2_EX;
 endcase 
 case (ForwardB)
 0: Rdata2_Mem = Rdata2_EX;
 1: Rdata2_Mem =  Wdata_WB;
 2: Rdata2_Mem = Wdata_Mem;
 default: Rdata2_Mem = Rdata2_EX;
 endcase 
 end
// branch execution 
endmodule
