//
// File Name: regs.sv
// Function: register file
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module regs #(parameter n = 32) // n - data bus width
(input logic clk, RegWrite,
input logic [1:0] mhartID_WB,
 input logic [1:0] mhartID_ID, // clk and write control
 input logic [n-1:0] Wdata,
 input logic [4:0] Raddr1, Raddr2,Waddr,
 output logic [n-1:0] Rdata1, Rdata2);

 	// Declare 32 n-bit registers 
	logic [n-1:0] gpr1 [n-1:0];
	logic [n-1:0] gpr2 [n-1:0];
	logic [n-1:0] gpr3 [n-1:0];
	logic [n-1:0] gpr4 [n-1:0];

		
	// write process, dest reg is waddr
	always_ff @ (posedge clk)
	begin
		if (RegWrite)
		begin
		case (mhartID_WB)
          0: gpr1[Waddr] <= Wdata;
          1: gpr2[Waddr] <= Wdata;
		2: gpr3[Waddr] <= Wdata;
		3: gpr4[Waddr] <= Wdata;
		endcase
		end	
	 end
	
	always_comb
	begin
	   if (Raddr1==5'd0) Rdata1 =  {n{1'b0}};
	   else if (Raddr1 == Waddr && mhartID_ID == mhartID_WB && RegWrite) Rdata1 = Wdata;
        else
        begin
	   case(mhartID_ID)
	   0: Rdata1 = gpr1[Raddr1];
	   1: Rdata1 = gpr2[Raddr1];
	   2: Rdata1 = gpr3[Raddr1];
	   3: Rdata1 = gpr4[Raddr1];
	   endcase
	   end
        if (Raddr2==5'd0) Rdata2 =  {n{1'b0}};
	  else if (Raddr2 == Waddr && mhartID_ID == mhartID_WB && RegWrite) Rdata2 = Wdata;	
	  else
	  begin
	  case (mhartID_ID)
	   0: Rdata2 = gpr1[Raddr2];
	   1: Rdata2 = gpr2[Raddr2];
	   2: Rdata2 = gpr3[Raddr2];
	   3: Rdata2 = gpr4[Raddr2];
	  endcase
	  end
	end	
endmodule // module regs