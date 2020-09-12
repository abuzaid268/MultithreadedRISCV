`include "opcodes.sv"
module RISC_test #( parameter n = 32); // data bus width
 logic clk;
logic nReset;
logic [31:0] test,alu_out,a,b,SwitchCount/*,T1result,T2result,T3resut,T4result*/,tempaddress;
logic finisht1,finisht2,finisht3,finisht4,t1sw,t2sw,t3sw,t4sw,t1lw,t2lw,t3lw,t4lw,t1miss,t2miss,t3miss,t4miss,errorT1,errorT2,errorT3,errorT4;
logic /*stall,*/flush,branch,jump/*,stall_reg,stall_reg2*/,threadIDramflag;

enum logic [5:0] {addi ,addiu ,andi,ori,xori,lhi,llo,slti,
sltiu,beq ,blt,bgte,bne,Rtype,
lui,AUIPC,lw ,sb ,sh,sw,j ,jal,
add,addu,and_ins,div,divu,mul, mulh,mulhu,rem,remu,nor_ins,or_ins,Itype,
sll,slli,sllv,sra,srav,srl,srlv,sub,subu,xor_ins,slt,sltu,jalr,jr,mfhi,mflo,mthi,mtlo,NOP,bubble,error,Enquiry,CSRRS} fetching,decoding,executing,memory,writeback/*,temp1/*,temp2,Enq*/;
real  T1CPI,T2CPI,T3CPI,T4CPI,OverAllCPI;
real T1ClockCounter,T2ClockCounter,T3ClockCounter,T4ClockCounter,ProcessorClockCounter,T1InstCounter,T2InstCounter,T3InstCounter,T4InstCounter,ProcessorInstCounter;
logic [3:0] DataVector,InstVector;
logic [31:0] fetchingAddress,memoryaddress,Swcount,Lwcount,storeddata,loaddata,MissCount,branchCount,jumpCount,uncompletedSW,uncompletedLW/*,NOPCount*/,InstMissCount,HazardsCount;
logic DoneT1,DoneT2,DoneT3,DoneT4,EXT1,EXT2,EXT31,EXT32,EXT4,InstMiss,LED0,LED1,LED2,LED3,CacheMiss,SwitchAction;
logic [31:0] T0out,T1out,T2out,T3out;
logic [31:0] t0,t1,t2,t3;
assign test = RISC1.Wdata_WB;
always@(*)
begin
DataVector = RISC1.TM1.DataVector;
InstVector = RISC1.TM1.InstVector;
fetchingAddress = RISC1.IF1.FetchingAddress;
end

//logic test2;

always_comb
begin
if (RISC1.TM1.StoreHazard == 1 && RISC1.TM1.StoreHazardVector[RISC1.TM1.mhartID_Mem] == 0) 
begin
$error(" check this ");
$stop;
end 
//if (RISC1.Mem1.CM1.CC1.forwarded == 1 && RISC1.TM1.mhartID_Mem == 2'b01 ) begin $error("double check"); $stop; end
end




always_comb
begin
threadIDramflag = 0;
if (RISC1.TM1.CacheMiss == 1 && RISC1.Mem1.CM1.TagCompare == 1 && RISC1.Mem1.CM1.Valid == 1 ) threadIDramflag = 1;
end

always_comb
begin
DoneT1 = 0;
DoneT2 = 0;
DoneT3 = 0;
DoneT4 = 0;
if ( fetchingAddress == 96 && fetching == mul ) DoneT1 = 1;
if ( fetchingAddress == 196  ) DoneT2 = 1;
if ( fetchingAddress == 280 && fetching == mul) DoneT3 = 1;
if ( fetchingAddress == 356 ) DoneT4 = 1;
end
logic [31:0] t3addressregister;
logic [31:0] t2counter;
always @(posedge clk)
if (RISC1.TM1.mhartID_ID == 3) t3addressregister <= RISC1.ID1.currentPC_ID;
always_comb
begin
EXT1 = 0;
EXT2 = 0;
EXT31 = 0;
EXT32 = 0;
EXT4 = 0;

if (executing == add && RISC1.EX1.mhartID_EX == 0) EXT1 = 1;
if (executing == add && RISC1.EX1.mhartID_EX == 1) EXT2 = 1;
if ((executing == addi && RISC1.EX1.mhartID_EX == 2 && RISC1.EX1.currentPC_EX == 32'h02a4) ) EXT31 = 1;
if ( executing == add && RISC1.EX1.mhartID_EX == 2) EXT32 = 1;
EXT4 = (t3addressregister >= 32'h02a8) ? 1'b1 : 1'b0;
end

always_ff @(posedge clk, negedge nReset)
if (!nReset) t2counter <= 0;
else 
if ((executing == addi && RISC1.EX1.mhartID_EX == 2 && RISC1.EX1.currentPC_EX == 32'h02a4) ) t2counter <= t2counter + 1;


always_comb
begin
if (!nReset) 
begin
uncompletedLW = 0;
uncompletedSW = 0;
end
end

always_comb
begin
//errorT1 = 0;
//errorT2 = 0;
errorT3 = 0;
errorT4 = 0;

//if ((fetchingAddress > 112 ) && RISC1.TM1.mhartID == 0) errorT1 = 1;
//if ((memoryaddress <= 8192 ) && RISC1.EX1.mhartID_EX == 1 && RISC1.EX1.MemRead_EX) errorT2 = 1;
if ((fetchingAddress > 296 ) && RISC1.TM1.mhartID == 2) errorT3 = 1;
if (fetchingAddress == 376 || fetchingAddress == 380 ) errorT4 = 1;

end
always @(posedge clk)
begin
if ((RISC1.ID1.currentPC_ID == 32'h01dc && decoding == addi ) && RISC1.ID1.mhartID_ID == 1 ) errorT2 <= 1;
else errorT2 <= 0;
if (RISC1.EX1.currentPC_EX == 32'h01b8 && executing == sw) errorT1 <= 1;
else errorT1 <= 0;

end
always_comb
begin
if (!nReset)
begin
MissCount = 0;
branchCount = 0;
jumpCount = 0;
//NOPCount = 0;
InstMissCount = 0;
HazardsCount = 0;
end
else 
begin
if (RISC1.TM1.CacheMiss == 1) MissCount = MissCount + 1'b1;
if (RISC1.TM1.jump_ID == 1) jumpCount = jumpCount + 1'b1;
if (RISC1.TM1.branch_ID == 1) branchCount = branchCount + 1'b1;
//if (RISC1.TM1.flush) NOPCount = NOPCount + 1'b1;
if (RISC1.TM1.StoreHazard) HazardsCount = HazardsCount + 1'b1;
if (RISC1.TM1.InstMiss) InstMissCount = InstMissCount + 1'b1;
end
end





always_comb
begin
t1sw = 0;
t2sw = 0;
t3sw = 0;
t4sw = 0;

 if (memory == sw && RISC1.Mem1.mhartID_Mem == 0) t1sw = 1;
 if (memory == sw && RISC1.Mem1.mhartID_Mem == 1) t2sw = 1;
 if (memory == sw && RISC1.Mem1.mhartID_Mem == 2) t3sw = 1;
 if (memory == sw && RISC1.Mem1.mhartID_Mem == 3) t4sw = 1;
 if (!nReset) Swcount = 0;
 else if (memory == sw) Swcount = Swcount + 1;
end
always_comb
begin
t1lw = 0;
t2lw = 0;
t3lw = 0;
t4lw = 0;

 if (memory == lw && RISC1.Mem1.mhartID_Mem == 0) t1lw = 1;
 if (memory == lw && RISC1.Mem1.mhartID_Mem == 1) t2lw = 1;
 if (memory == lw && RISC1.Mem1.mhartID_Mem == 2) t3lw = 1;
 if (memory == lw && RISC1.Mem1.mhartID_Mem == 3) t4lw = 1;
 if (!nReset) Lwcount = 0;
 else if (memory == lw) Lwcount = Lwcount + 1;
end




always_comb
begin
t1miss = 0;
t2miss = 0;
t3miss = 0;
t4miss = 0;
if (RISC1.TM1.CacheMiss == 1 && RISC1.TM1.mhartID_Mem == 0) t1miss = 1;
if (RISC1.TM1.CacheMiss == 1 && RISC1.TM1.mhartID_Mem == 1) t2miss = 1;
if (RISC1.TM1.CacheMiss == 1 && RISC1.TM1.mhartID_Mem == 2) t3miss = 1;
if (RISC1.TM1.CacheMiss == 1 && RISC1.TM1.mhartID_Mem == 3) t4miss = 1;
end


always_comb
begin
memoryaddress = 0;
storeddata = 0;
if ((executing == sw || executing == lw ))
memoryaddress = RISC1.EX1.MemAddress;
if (executing == sw )
storeddata = RISC1.EX1.Rdata2_Mem;
if (memory == lw )
loaddata = RISC1.Mem1.ReadData;
else loaddata = 0;
end






always_ff @(posedge clk,negedge nReset)
begin
if (!nReset)
begin
ProcessorClockCounter <= 0;
T1ClockCounter <= 1;
T2ClockCounter <= 1;
T3ClockCounter <= 1;
T4ClockCounter <= 1;
end
else
begin
ProcessorClockCounter <= ProcessorClockCounter + 1'b1;
if (RISC1.TM1.mhartID == 0 && RISC1.TM1.initialisation != 0 && fetching != NOP) T1ClockCounter = T1ClockCounter + 1'b1;
if (RISC1.TM1.mhartID == 1 && RISC1.TM1.initialisation != 0  && fetching != NOP) T2ClockCounter = T2ClockCounter + 1'b1;
if (RISC1.TM1.mhartID == 2 && RISC1.TM1.initialisation != 0  && fetching != NOP) T3ClockCounter = T3ClockCounter + 1'b1;
if (RISC1.TM1.mhartID == 3 && RISC1.TM1.initialisation != 0  && fetching != NOP) T4ClockCounter = T4ClockCounter + 1'b1;
end
end
always_ff @(posedge clk,negedge nReset)
begin
if (!nReset)
begin
T1InstCounter <= 1;
T2InstCounter <= 1;
T3InstCounter <= 1;
T4InstCounter <= 1;
ProcessorInstCounter <= 1;
end
else
begin
if ((RISC1.TM1.mhartID == 0) && fetching != NOP)
begin
case (RISC1.IF1.IM1.I[6:0])
`JAL  :T1InstCounter <= T1InstCounter + 2;
`JALR :T1InstCounter <= T1InstCounter + 2;
`Btype :T1InstCounter <= T1InstCounter + 2;
`LW : T1InstCounter <= T1InstCounter + 5;
`SW : T1InstCounter <= T1InstCounter + 4;
`Itype : T1InstCounter <= T1InstCounter + 3;
`Rtype : T1InstCounter <= T1InstCounter + 3;
`CSRRS : T1InstCounter <= T1InstCounter + 3;
endcase
end
if ((RISC1.TM1.mhartID == 1) && fetching != NOP)
begin
case (RISC1.IF1.IM1.I[6:0])
`JAL  :T2InstCounter <= T2InstCounter + 2;
`JALR :T2InstCounter <= T2InstCounter + 2;
`Btype :T2InstCounter <= T2InstCounter + 2;
`LW : T2InstCounter <= T2InstCounter + 5;
`SW : T2InstCounter <= T2InstCounter + 4;
`Itype : T2InstCounter <= T2InstCounter + 3;
`Rtype : T2InstCounter <= T2InstCounter + 3;
`CSRRS : T2InstCounter <= T2InstCounter + 3;
endcase
end
if ((RISC1.TM1.mhartID == 2) && fetching != NOP)
begin
case (RISC1.IF1.IM1.I[6:0])
`JAL  :T3InstCounter <= T3InstCounter + 2;
`JALR :T3InstCounter <= T3InstCounter + 2;
`Btype :T3InstCounter <= T3InstCounter + 2;
`LW : T3InstCounter <= T3InstCounter + 5;
`SW : T3InstCounter <= T3InstCounter + 4;
`Itype : T3InstCounter <= T3InstCounter + 3;
`Rtype : T3InstCounter <= T3InstCounter + 3;
`CSRRS : T3InstCounter <= T3InstCounter + 3;
endcase
end
if ((RISC1.TM1.mhartID == 3) && fetching != NOP)
begin
case (RISC1.IF1.IM1.I[6:0])
`JAL  :T4InstCounter <= T4InstCounter + 2;
`JALR :T4InstCounter <= T4InstCounter + 2;
`Btype :T4InstCounter <= T4InstCounter + 2;
`LW : T4InstCounter <= T4InstCounter + 5;
`SW : T4InstCounter <= T4InstCounter + 4;
`Itype : T4InstCounter <= T4InstCounter + 3;
`Rtype : T4InstCounter <= T4InstCounter + 3;
`CSRRS : T4InstCounter <= T4InstCounter + 3;
endcase
end
case (RISC1.IF1.IM1.I[6:0])
`JAL  :ProcessorInstCounter <= ProcessorInstCounter + 2;
`JALR :ProcessorInstCounter <= ProcessorInstCounter + 2;
`Btype :ProcessorInstCounter <= ProcessorInstCounter + 2;
`LW : ProcessorInstCounter <= ProcessorInstCounter + 5;
`SW : ProcessorInstCounter <= ProcessorInstCounter + 4;
`Itype : ProcessorInstCounter <= ProcessorInstCounter + 3;
`Rtype : ProcessorInstCounter <= ProcessorInstCounter + 3;
`CSRRS : ProcessorInstCounter <= ProcessorInstCounter + 3;
endcase
end
end
always @(*)
begin
T1CPI = T1InstCounter / T1ClockCounter ;
T2CPI = T2InstCounter / T2ClockCounter;
T3CPI = T3InstCounter / T3ClockCounter ;
T4CPI = T4InstCounter / T4ClockCounter ;
OverAllCPI = ProcessorInstCounter/ ProcessorClockCounter;
end


enum logic [1:0]  {Thread0,Thread1,Thread2,Thread3} ThreadID;
 pipelined_RISC  RISC1 (.*);
//assign stall = RISC1.HD1.stall;
assign flush = RISC1.TM1.flush;
assign jump = RISC1.TM1.jump_ID;
assign branch = RISC1.TM1.branch_ID;
assign alu_out = RISC1.EX1.out;
assign a = RISC1.EX1.alu1.a;
assign b = RISC1.EX1.alu1.b;
always_comb
begin
 case (RISC1.TM1.mhartID)
 0: ThreadID = Thread0;
 1: ThreadID = Thread1;
 2: ThreadID = Thread2;
 3: ThreadID = Thread3;
 endcase
 end
initial
begin
  clk =  0;
    forever #5ns clk = ~clk;
end

/*always @(*)
begin
assert ((RISC1.TM1.T0 <= 80  ) || (RISC1.TM1.T0 >= 184 && RISC1.TM1.T0 <= 240) )
else
begin
 $error (" T0 is Wrong !!! shouldnt be %d ",RISC1.TM1.T0);
 $stop;
 end
end

always @(*)
begin
assert ((RISC1.TM1.T1 <= 36  ) || (RISC1.TM1.T1 >= 76 && RISC1.TM1.T1 <= 116) || (RISC1.TM1.T1 >= 236 && RISC1.TM1.T1 <= 320) )
else
begin
 $error (" T1 is Wrong !!! shouldnt be %d ",RISC1.TM1.T1 );
 $stop;
 end
end

always @(*)
begin
assert ((RISC1.TM1.T2 <= 36  ) || (RISC1.TM1.T2 >= 112 && RISC1.TM1.T2 <= 148) || (RISC1.TM1.T2 >= 320 && RISC1.TM1.T2 <= 372))
else
begin
 $error (" T2 is Wrong !!! shouldnt be %d ",RISC1.TM1.T2);
 $stop;
 end
end

always @(*)
begin
assert ((RISC1.TM1.T3 <= 36  ) || (RISC1.TM1.T3 >= 132 && RISC1.TM1.T3 <= 184) || (RISC1.TM1.T3 >= 372 && RISC1.TM1.T3 <= 424))
else
begin
 $error (" T3 is Wrong !!! shouldnt be %d",RISC1.TM1.T3);
 $stop;
 end
end*/
/*always@(*)
assert (alu_out != 8) else begin $error ("return address "); $stop; end*/

always@(*)
assert (RISC1.TM1.T1 != 1) else $stop;
initial
begin
nReset = 0;
#1ns
nReset=1;
#1ns 
nReset = 1;
 $monitor ($realtime, " Read Data = %h" ,RISC1.IF1.IM1.I);
end
/*always_ff @(posedge clk) stall_reg <= RISC1.IF1.stall;
always_ff @(posedge clk) stall_reg2 <= stall_reg;*/
always @(*)
begin
if (RISC1.IF1.flush || InstMiss) fetching = NOP;
else 
begin
case (RISC1.IF1.IM1.I[6:0])
`LW : fetching = lw;
`CSRRS: fetching = CSRRS;
`SW : fetching = sw;
`AUIPC : fetching = AUIPC;
`LUI : fetching = lui;
`JAL : fetching = jal;
`JALR : fetching = jalr;
`Btype : case (RISC1.IF1.IM1.I[14:12])
0: fetching = beq;
1: fetching = bne;
4: fetching = blt;
5: fetching = bgte;
default: fetching = error;
endcase// func3
`Rtype: begin
if (RISC1.IF1.IM1.I[25])
begin
case (RISC1.IF1.IM1.I[14:12])
			  0: fetching = mul;
			  1: fetching = mulh;
			  2: fetching = mulhu;
			  4: fetching = div;
			  5: fetching = divu;
			  6: fetching = rem;
			  7: fetching = remu;
			  endcase
end
else
begin
case (RISC1.IF1.IM1.I[14:12])
0: begin
   if (RISC1.IF1.IM1.I[31:25] == 0) fetching = add;
   else fetching = sub;
   end
1: fetching = sll;
2: fetching = slt;
3: fetching = sltu;
4: fetching = xor_ins;
5: begin
   if (RISC1.IF1.IM1.I[31:25] == 0) fetching = srl;
   else fetching = sra;
   end 
6: fetching = or_ins;
7: fetching = and_ins;   
endcase//func3
end
end
`Itype: case (RISC1.IF1.IM1.I[14:12])
0: fetching = addi;
1: fetching = slli;
2: fetching = slti;
3: fetching = sltiu;
4: fetching = xori;
6: fetching = ori;
7: fetching = andi;
default : fetching = error;
endcase // func3
endcase
end
end
always @(*)
begin
/*if (RISC1.ID1.I_ID == 32'h07f) decoding = Enquiry;
//else if (RISC1.ID1.I_ID == 0 && stall_reg) decoding = bubble;
else*/ 
if (RISC1.ID1.I_ID == 0 ) decoding = NOP;
else 
begin
case (RISC1.ID1.I_ID[6:0])
`LW : decoding = lw;
`CSRRS: decoding = CSRRS;
`SW : decoding = sw;
`AUIPC : decoding = AUIPC;
`LUI : decoding = lui;
`JAL : decoding = jal;
`JALR : decoding = jalr;
`Btype : case (RISC1.ID1.I_ID[14:12])
0: decoding = beq;
1: decoding = bne;
4: decoding = blt;
5: decoding = bgte;
default: decoding = error;
endcase// func3
`Rtype: begin
if (RISC1.ID1.I_ID[25])
begin
case (RISC1.ID1.I_ID[14:12])
			  0: decoding = mul;
			  1: decoding = mulh;
			  2: decoding = mulhu;
			  4: decoding = div;
			  5: decoding = divu;
			  6: decoding = rem;
			  7: decoding = remu;
			  endcase
end
else
begin
case (RISC1.ID1.I_ID[14:12])
0: begin
   if (RISC1.ID1.I_ID[31:25] == 0) decoding = add;
   else decoding = sub;
   end
1: decoding = sll;
2: decoding = slt;
3: decoding = sltu;
4: decoding = xor_ins;
5: begin
   if (RISC1.ID1.I_ID[31:25] == 0) decoding = srl;
   else decoding = sra;
   end 
6: decoding = or_ins;
7: decoding = and_ins;   
endcase//func3
end
end
`Itype: case (RISC1.ID1.I_ID[14:12])
0: decoding = addi;
1: decoding = slli;
2: decoding = slti;
3: decoding = sltiu;
4: decoding = xori;
6: decoding = ori;
7: decoding = andi;
default : decoding = error;
endcase // func3
endcase
end
end
always @(*)
begin
//if (RISC1.EX1.I_EX == 0 && stall_reg2) executing = bubble;
/*if (RISC1.ID1.I_EX == 32'h07f) executing = Enquiry;
else*/ 
if (RISC1.EX1.I_EX == 0) executing = NOP;
case (RISC1.EX1.I_EX[6:0])
`LW : executing = lw;
`CSRRS: executing = CSRRS;
`SW : executing = sw;
`AUIPC : executing = AUIPC;
`LUI : executing = lui;
`JAL : executing = jal;
`JALR : executing = jalr;
`Btype : case (RISC1.EX1.I_EX[14:12])
0: executing = beq;
1: executing = bne;
4: executing = blt;
5: executing = bgte;
default: executing = error;
endcase// func3
`Rtype: begin
if (RISC1.EX1.I_EX [25])
begin
case (RISC1.EX1.I_EX [14:12])
			  0: executing = mul;
			  1: executing = mulh;
			  2: executing = mulhu;
			  4: executing = div;
			  5: executing = divu;
			  6: executing = rem;
			  7: executing = remu;
			  endcase
end
else
begin
case (RISC1.EX1.I_EX [14:12])
0: begin
   if (RISC1.EX1.I_EX [31:25] == 0) executing = add;
   else executing = sub;
   end
1: executing = sll;
2: executing = slt;
3: executing = sltu;
4: executing = xor_ins;
5: begin
   if (RISC1.EX1.I_EX [31:25] == 0) executing = srl;
   else executing = sra;
   end 
6: executing = or_ins;
7: executing = and_ins;   
endcase//func3
end
end
`Itype: case (RISC1.EX1.I_EX[14:12])
0: executing = addi;
1: executing = slli;
2: executing = slti;
3: executing = sltiu;
4: executing = xori;
6: executing = ori;
7: executing = andi;
default : executing = error;
endcase // func3
endcase
end
logic [31:0] temp2address;
always_ff @(posedge clk, negedge nReset)
if (!nReset) tempaddress <= 0;
else
begin
if (fetching == addi) tempaddress <= fetchingAddress;
temp2address <= tempaddress;
end
/*initial
begin
#64000000ns
forever #10ns
if (memoryaddress == 32'h1ffd8 || memoryaddress == 32'h1ffd6 ) begin $error(" wrong execution"); $stop;end
end*/
/*initial
begin
forever #10ns
if ((/*EXT1 || EXT2 == 1 )&& !(alu_out == 1 || alu_out == 2 || alu_out == 3 || alu_out == 5 || alu_out == 8 ||alu_out == 13 ||alu_out == 21 ||alu_out == 34 ||alu_out == 55 ||alu_out == 89 ||alu_out == 144 ||alu_out == 233
 ||alu_out == 377 ||alu_out == 610 ||alu_out == 987 || alu_out == 1597 || alu_out == 2584 ||alu_out == 4181 ||alu_out == 6765 ||alu_out == 10946 || alu_out == 17711)) begin $error (" wrong answer"); $stop; end
end*/
/*always_comb
begin
if (RISC1.Mem1.CM1.CC1.RamReadAddress == RISC1.Mem1.CM1.CC1.RamWriteAddress)
begin
$error ("finally");
$stop;
end
end*/
/*initial
begin
#450000ns
forever #10ns
if (memoryaddress == 32'h01fef4) $stop;
end*/
logic [15:0] copy [0:262143];
logic [31:0] stored;
always_ff @(posedge clk)
begin
if (RISC1.Mem1.MemWrite_Mem)
begin
copy [RISC1.Mem1.MemAddress] <= RISC1.Mem1.Rdata2_Mem [15:0];
copy [RISC1.Mem1.MemAddress + 1'b1] <= RISC1.Mem1.Rdata2_Mem [31:16];
end
end
always_comb
begin
stored = 0;
if (RISC1.Mem1.MemWrite_Mem) stored = RISC1.Mem1.Rdata2_Mem;

end
logic [31:0] tempdata;
logic dagdog;
always_ff @(posedge clk)
begin
if (RISC1.EX1.ReadEnable) tempdata <= {copy[memoryaddress + 1'b1], copy[memoryaddress]};
if ((RISC1.TM1.CacheMiss || RISC1.TM1.StoreHazard) && (RISC1.TM1.mhartID_Mem == RISC1.TM1.mhartID) && RISC1.IF1.I_ID != 0) dagdog <= 1;
else dagdog <= 0;
end
initial
begin
forever #10ns
if (RISC1.Mem1.CacheHit == 1 && (RISC1.Mem1.ReadData != tempdata) && (RISC1.Mem1.ReadFromExternal == 0) ) 
begin
$error ("bahbahani");
$stop;
end

end
logic debug;
always_comb
begin
debug = 0;
if (fetchingAddress == 32'h0b4) debug = 1;
end





logic [31:0] t0in,t1in,t2in,t3in;
always @(posedge clk, negedge nReset)
begin
if (!nReset)
begin
t0 <= 0;t1<= 0;t2 <= 0 ;t3 <= 0;
t0in <= 0;t1in <= 0;t2in <= 0 ;t3in <= 0;
end
else
begin
t0 <= {RISC1.AR1.RAM[1],RISC1.AR1.RAM[0]};
t0in <= {RISC1.AR1.RAM[3],RISC1.AR1.RAM[2]};
t1 <= {RISC1.AR1.RAM[5],RISC1.AR1.RAM[4]};
t1in <= {RISC1.AR1.RAM[7],RISC1.AR1.RAM[6]};
t2 <= {RISC1.AR1.RAM[9],RISC1.AR1.RAM[8]};
t2in <= {RISC1.AR1.RAM[11],RISC1.AR1.RAM[10]};
t3 <= {RISC1.AR1.RAM[13],RISC1.AR1.RAM[12]};
t3in <= {RISC1.AR1.RAM[15],RISC1.AR1.RAM[14]};
end
end
always_ff @(posedge clk,negedge nReset)
begin
if (!nReset)
begin
finisht1 <=0;
finisht2 <=0;
finisht3 <=0;
finisht4 <=0;
SwitchCount <= 0;
end
else
begin
if (t0in == 1000) finisht1 <= 1;
if (t1in == 1000) finisht2 <= 1;
if (t2in == 1000) finisht3 <= 1;
if (t3in == 1000) finisht4 <= 1;
if (RISC1.TM1.SwitchAction) SwitchCount <= SwitchCount + 1'b1;
end
end
logic [31:0] waste;
logic [31:0] DataMisstimes;
logic [31:0] InstMisstimes,Storehazardtimes;
real efficency;
always_ff @(posedge clk, negedge nReset)
if (!nReset)
begin
waste <= 0;
DataMisstimes <= 0;
InstMisstimes <= 0;
Storehazardtimes <= 0;
end
else
begin
waste <= (executing == NOP) ? waste + 1'b1 : waste;
DataMisstimes <= (RISC1.TM1.CacheMiss) ? DataMisstimes + 1'b1 : DataMisstimes;
InstMisstimes <= (RISC1.TM1.InstMiss) ? InstMisstimes + 1'b1 : InstMisstimes;
Storehazardtimes <= (RISC1.TM1.StoreHazard) ? Storehazardtimes + 1'b1 : Storehazardtimes;
end
always_comb
begin
if (finisht1 && finisht2 && finisht3 && finisht4)begin
 $display("report for 4 threaded processor");
 $display("total cycles are : %d",ProcessorClockCounter);
 $display("total waste cycles are : %d",waste);
 $display("total data miss are : %d",DataMisstimes);
 $display("total inst miss are : %d",InstMisstimes);
 $display("total store hazards are : %d",Storehazardtimes);
 $display(" system switch between threads : %d", SwitchCount);
 $display("instruction per clock : %0.2f ", ((ProcessorClockCounter - waste)/ProcessorClockCounter));
 $stop;
 end
end






always_ff @(posedge clk) memory <= executing;
always_ff @(posedge clk) writeback <= memory;
endmodule

