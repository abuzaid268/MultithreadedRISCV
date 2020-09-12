module hazard_detector(
input logic MemRead_Mem,CacheMiss,clk,Ready,nReset,
input logic [4:0] RegisterRD_Mem,RegisterRS2_EX,RegisterRS1_EX,
output logic stall,EnablePC,stall_all
);
logic CacheMiss_flag;
assign stall = ((MemRead_Mem && 0) && ( (RegisterRD_Mem == RegisterRS1_EX )  || (RegisterRD_Mem == RegisterRS2_EX ))) ? 1'b1 : 1'b0;
assign EnablePC = (stall || stall_all)  ? 1'b0 : 1'b1;
//assign stall_all = (CacheMiss || !Ready) ? 1'b1: 1'b0;
always_ff @(posedge clk, negedge nReset)
begin
if(!nReset) 
begin
CacheMiss_flag <= 0;
stall_all <= 0;
end
else
begin
if (CacheMiss)
begin
CacheMiss_flag <= 1;
stall_all <= 1;
end
else if (CacheMiss_flag)
begin
if (Ready)
stall_all <= 0;
end//CacheMiss_flag
end//else
end//always_ff
endmodule
