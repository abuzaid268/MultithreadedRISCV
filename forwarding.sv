module forwarding(
input logic RegWrite_Mem,RegWrite_WB,RegWrite_EX,
input logic [4:0] RegisterRS1_EX,RegisterRS2_EX,RegisterRS1_ID,RegisterRS2_ID,Waddr_Mem,Waddr_WB,Waddr_EX,
output logic [1:0] ForwardA,ForwardB,ForwardRS1,ForwardRS2 ,
// MT
input logic [1:0] mhartID_EX,mhartID_Mem,mhartID_WB,mhartID_ID
);
always_comb
begin
ForwardA = 2'b00;
ForwardB = 2'b00;
ForwardRS1 = 2'b00;
ForwardRS2 = 2'b00;
if (RegWrite_Mem && Waddr_Mem != 0 &&  Waddr_Mem == RegisterRS1_EX && mhartID_EX == mhartID_Mem) ForwardA = 2'b10;    
if (RegWrite_Mem && Waddr_Mem != 0 &&  Waddr_Mem == RegisterRS2_EX && mhartID_EX == mhartID_Mem) ForwardB = 2'b10;    

if (RegWrite_WB && Waddr_WB != 0 && !(Waddr_Mem == RegisterRS1_EX && mhartID_EX == mhartID_Mem) &&  Waddr_WB == RegisterRS1_EX && mhartID_WB == mhartID_EX) ForwardA = 2'b01;    
if (RegWrite_WB && Waddr_WB != 0 && !(Waddr_Mem == RegisterRS2_EX && mhartID_EX == mhartID_Mem) &&  Waddr_WB == RegisterRS2_EX && mhartID_WB == mhartID_EX) ForwardB = 2'b01;    
// for branch

if (RegWrite_EX && Waddr_EX != 0 &&  Waddr_EX == RegisterRS1_ID && mhartID_EX == mhartID_ID) ForwardRS1 = 2'b11;    
if (RegWrite_EX && Waddr_EX != 0 &&  Waddr_EX == RegisterRS2_ID && mhartID_EX == mhartID_ID) ForwardRS2 = 2'b11; 

if (RegWrite_Mem && Waddr_Mem != 0 && Waddr_EX != RegisterRS1_ID && Waddr_Mem == RegisterRS1_ID && mhartID_Mem == mhartID_ID) ForwardRS1 = 2'b10;    
if (RegWrite_Mem && Waddr_Mem != 0 && Waddr_EX != RegisterRS1_ID && Waddr_Mem == RegisterRS2_ID && mhartID_Mem == mhartID_ID) ForwardRS2 = 2'b10;    
   
end // always_comb
endmodule

