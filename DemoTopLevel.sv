module DemoTopLevel(
// sdram ports

output wire [19:0] addr,
inout  wire [15:0] data,
output wire WE,CS,OE,LBS,HBS,

input logic clk,nReset,
input logic /*slide1,*/slide2,slide3,slide4,FreezeOutput,
output logic Sega1,Sega2,Sega3,Sega4,Sega5,Sega6,Sega7,
output logic Segb1,Segb2,Segb3,Segb4,Segb5,Segb6,Segb7,
output logic Segc1,Segc2,Segc3,Segc4,Segc5,Segc6,Segc7,
output logic Segd1,Segd2,Segd3,Segd4,Segd5,Segd6,Segd7,
output logic Sege1,Sege2,Sege3,Sege4,Sege5,Sege6,Sege7,
output logic Segf1,Segf2,Segf3,Segf4,Segf5,Segf6,Segf7,
output logic Segg1,Segg2,Segg3,Segg4,Segg5,Segg6,Segg7,
output logic Segh1,Segh2,Segh3,Segh4,Segh5,Segh6,Segh7,
output logic LED0,LED1,LED2,LED3,LED4,LED5,LED6,LED7,LED8,LED9,LED10,LED13
);

logic InstMiss,CacheMiss,SwitchAction,branch_ID,jump_ID,waitrequest,readdatavalid,NotRead,NotWrite;
logic [31:0] T0out,T1out,T2out,T3out,T0in,T1in,T2in,T3in,SwitchCounter,InstMissCounter,CacheMissCounter;
logic [31:0] count,count2,DataRegister,RamByteAddress;
logic [23:0] display;
logic [3:0] decoder,seconds1,seconds2,minutes1,minutes2;
logic [1:0] mhartID_ID;
logic [7:0] RamByteData,RamData;
logic stopcounter;
logic [31:0] T0outdis,T1outdis,T2outdis,T3outdis,T0indis,T1indis,T2indis,T3indis;

pipelined_MIPS MIPS1 (.clk(clkin),.nReset,.T0out,.T1out,.T2out,.T3out,.InstMiss,.CacheMiss,
.SwitchAction,.LED0,.LED1,.LED2,.LED3,.mhartID_ID,.addr,.data,.WE,.CS,.OE,.LBS,.HBS,.T0in,.T1in,.T2in,.T3in);


assign decoder = {slide4,slide3,slide2/*,slide1*/};

	 always_ff @(posedge clkin,negedge nReset)
	 if (!nReset)
	 stopcounter <= 0;
	 else
	 if (T0in ==135 && T1in == 16 && T2in == 135 && T3in == 127)
	 stopcounter <= 1;
	 
	 
	 always_ff @(posedge clk)
		 begin
		 count <= count + 1'b1;
		 if (count == 500) clkin <= '1;
		 if (count == 1000)
		 begin
		 count <= '0; 
		 clkin <= '0; 
		 end
		 end
		 
		always_ff @(posedge clkin, negedge nReset)
		if (!nReset)
		begin
		seconds1 <= 0;
		seconds2 <= 0;
		minutes1 <= 0;
		minutes2 <= 0;
		count2 <= 0;
		end
		else
		begin
		count2 <= count2 + 1'b1;
		if (count2 == 50000 && stopcounter == 0)
		begin
		seconds1 <= seconds1 + 1'b1;
		count2 <= 0;
		if (seconds1 == 9)
		begin
		seconds1 <= 0;
		seconds2 <= seconds2 + 1'b1;
		end
		if (seconds2 == 5 && seconds1 == 9)
		begin
		seconds2 <= 0;
		minutes1 <= minutes1 + 1'b1;
		end
		if (minutes1 == 9)
		begin
		minutes1 <= 0;
		minutes2 <= minutes2 + 1'b1;
		end
		end 
		end 
		
		always_ff @(posedge clkin, negedge nReset)
		begin
		if (!nReset)
		begin
		SwitchCounter <= 0;
		InstMissCounter <= 0;
		CacheMissCounter <= 0;
		LED4 <= 0;
		LED5 <= 0;
		LED6 <= 0;
		LED7 <= 0;
		LED8 <= 0;
		LED9 <= 0;
		LED10 <= 0;
		end
		else
		begin
		if (InstMiss && !stopcounter && !FreezeOutput) InstMissCounter <= InstMissCounter + 1'b1;
		if (CacheMiss && !stopcounter && !FreezeOutput) CacheMissCounter <= CacheMissCounter + 1'b1;
		if (SwitchAction && !stopcounter && !FreezeOutput) SwitchCounter <= SwitchCounter + 1'b1;
		if (stopcounter) LED4 <= 1;
		else LED4 <= 0;
		if (SwitchAction) LED5 <= 1;
		else LED5 <= 0;
		if (CacheMiss) LED6 <= 1;
		else LED6<=0;
		if (mhartID_ID == 0) LED7 <= 1;
		else LED7 <= 0;
		if (mhartID_ID == 1) LED8 <= 1;
		else LED8 <= 0;
		if (mhartID_ID == 2) LED9 <= 1;
		else LED9 <= 0;
		if (mhartID_ID == 3) LED10 <= 1;
		else LED10 <= 0;
		if (!FreezeOutput)
		begin
		T0indis <= T0in;
		T1indis <= T1in;
		T2indis <= T2in;
		T3indis <= T3in;
		T0outdis <= T0out;
		T1outdis <= T1out;
		T2outdis <= T2out;
		T3outdis <= T3out;
		end
		end
		end
	
	always_comb
	begin
	LED13 = 0;
	case (decoder)
	0: begin
		display = {T0indis[7:0],T0outdis[15:0]};
		LED13 = ( T0indis[11:8] == 1) ? 1'b1 : 1'b0;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;
		
		Segh1 = 1'b1;
		Segh2 = 1'b1;
		Segh3 = 1'b1;
		Segh4 = 1'b0;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
	1: begin
		display = {T1indis[7:0],T1outdis[15:0]};
		LED13 = ( T1indis[11:8] == 1) ? 1'b1 : 1'b0;
		Segg1 = 1'b1;
		Segg2 = 1'b1;
		Segg3 = 1'b1;
		Segg4 = 1'b1;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;
		
		Segh1 = 1'b1;
		Segh2 = 1'b1;
		Segh3 = 1'b1;
		Segh4 = 1'b0;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
	2: begin
		display = {T2indis[7:0],T2outdis[15:0]};
		LED13 = ( T2indis[11:8] == 1) ? 1'b1 : 1'b0;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b1;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b1;
		Segg7 = 1'b0;

		Segh1 = 1'b1;
		Segh2 = 1'b1;
		Segh3 = 1'b1;
		Segh4 = 1'b0;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
	3: begin
		display = {T3indis[7:0],T3outdis[15:0]};
		LED13 = ( T3indis[11:8] == 1) ? 1'b1 : 1'b0;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b1;
		Segg6 = 1'b1;
		Segg7 = 1'b0;

		Segh1 = 1'b1;
		Segh2 = 1'b1;
		Segh3 = 1'b1;
		Segh4 = 1'b0;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
	4: begin
		display = InstMissCounter;
		Segg1 = 1'b0;
		Segg2 = 1'b1;
		Segg3 = 1'b1;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;

		Segh1 = 1'b1;
		Segh2 = 1'b1;
		Segh3 = 1'b1;
		Segh4 = 1'b1;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b1;
		end
	5: begin
		display = CacheMissCounter;
		Segg1 = 1'b0;
		Segg2 = 1'b1;
		Segg3 = 1'b1;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;

		Segh1 = 1'b1;
		Segh2 = 1'b0;
		Segh3 = 1'b0;
		Segh4 = 1'b0;
		Segh5 = 1'b0;
		Segh6 = 1'b1;
		Segh7 = 1'b0;
		end
	6: begin
		display = SwitchCounter;
		Segg1 = 1'b0;
		Segg2 = 1'b1;
		Segg3 = 1'b1;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;

		Segh1 = 1'b0;
		Segh2 = 1'b1;
		Segh3 = 1'b0;
		Segh4 = 1'b0;
		Segh5 = 1'b1;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
	7: begin
		display = {8'b0,minutes2,minutes1,seconds2,seconds1};
		Segg1 = 1'b1;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b0;

		Segh1 = 1'b1;
		Segh2 = 1'b0;
		Segh3 = 1'b0;
		Segh4 = 1'b0;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
	
		end
	/*8: begin
		display = DataRegister;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;
		
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b1;
		Segh4 = 1'b1;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end*/
	/*9: begin
		display = tp1;
		Segg1 = 1'b1;
		Segg2 = 1'b1;
		Segg3 = 1'b1;
		Segg4 = 1'b1;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;
	
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b1;
		Segh4 = 1'b1;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
	
		end
	10: begin
		display = tp2;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b1;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b1;
		Segg7 = 1'b0;
	
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b1;
		Segh4 = 1'b1;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
	
		end
  11: begin
		display = tp3;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b1;
		Segg6 = 1'b1;
		Segg7 = 1'b0;
  
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b1;
		Segh4 = 1'b1;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
  12: begin
		display = T0;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;
		
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b0;
		Segh4 = 1'b1;
		Segh5 = 1'b1;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
  13: begin
		display = T1;
		Segg1 = 1'b1;
		Segg2 = 1'b1;
		Segg3 = 1'b1;
		Segg4 = 1'b1;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;
		
		
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b0;
		Segh4 = 1'b1;
		Segh5 = 1'b1;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
  14: begin
		display = T2;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b1;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b1;
		Segg7 = 1'b0;
		
		
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b0;
		Segh4 = 1'b1;
		Segh5 = 1'b1;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
  15: begin
		display = T3;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b1;
		Segg6 = 1'b1;
		Segg7 = 1'b0;

		
		Segh1 = 1'b0;
		Segh2 = 1'b0;
		Segh3 = 1'b0;
		Segh4 = 1'b1;
		Segh5 = 1'b1;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end*/
default: begin
		display = T0out;
		Segg1 = 1'b0;
		Segg2 = 1'b0;
		Segg3 = 1'b0;
		Segg4 = 1'b0;
		Segg5 = 1'b0;
		Segg6 = 1'b0;
		Segg7 = 1'b1;
		
		Segh1 = 1'b1;
		Segh2 = 1'b1;
		Segh3 = 1'b1;
		Segh4 = 1'b0;
		Segh5 = 1'b0;
		Segh6 = 1'b0;
		Segh7 = 1'b0;
		end
	endcase
	end
	
	always_comb
	begin
	case (display[3:0])
	
	 0:begin Sega1=1'b0;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b1;       end
	 1:begin Sega1=1'b1;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b1;       Sega5=1'b1;       Sega6=1'b1;       Sega7=1'b1;       end
	 2:begin Sega1=1'b0;       Sega2=1'b0;       Sega3=1'b1;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b1;       Sega7=1'b0;       end
	 3:begin Sega1=1'b0;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b1;       Sega6=1'b1;       Sega7=1'b0;       end
	 4:begin Sega1=1'b1;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b1;       Sega5=1'b1;       Sega6=1'b0;       Sega7=1'b0;       end
	 5:begin Sega1=1'b0;       Sega2=1'b1;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b1;       Sega6=1'b0;       Sega7=1'b0;       end
	 6:begin Sega1=1'b0;       Sega2=1'b1;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b0;       end
	 7:begin Sega1=1'b0;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b1;       Sega5=1'b1;       Sega6=1'b1;       Sega7=1'b1;       end
	 8:begin Sega1=1'b0;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b0;       end
	 9:begin Sega1=1'b0;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b1;       Sega6=1'b0;       Sega7=1'b0;       end
	 
	10:begin Sega1=1'b0;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b1;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b0;       end//a
	11:begin Sega1=1'b1;       Sega2=1'b1;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b0;       end//b
	12:begin Sega1=1'b0;       Sega2=1'b1;       Sega3=1'b1;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b1;       end//c
	13:begin Sega1=1'b1;       Sega2=1'b0;       Sega3=1'b0;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b1;       Sega7=1'b0;       end//d
	14:begin Sega1=1'b0;       Sega2=1'b1;       Sega3=1'b1;       Sega4=1'b0;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b0;       end//e
	15:begin Sega1=1'b0;       Sega2=1'b1;       Sega3=1'b1;       Sega4=1'b1;       Sega5=1'b0;       Sega6=1'b0;       Sega7=1'b0;       end//f
	endcase
	
	 case (display[7:4])
	 0:begin Segb1=1'b0;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b1;       end
	 1:begin Segb1=1'b1;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b1;       Segb5=1'b1;       Segb6=1'b1;       Segb7=1'b1;       end
	 2:begin Segb1=1'b0;       Segb2=1'b0;       Segb3=1'b1;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b1;       Segb7=1'b0;       end
	 3:begin Segb1=1'b0;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b1;       Segb6=1'b1;       Segb7=1'b0;       end
	 4:begin Segb1=1'b1;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b1;       Segb5=1'b1;       Segb6=1'b0;       Segb7=1'b0;       end
	 5:begin Segb1=1'b0;       Segb2=1'b1;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b1;       Segb6=1'b0;       Segb7=1'b0;       end
	 6:begin Segb1=1'b0;       Segb2=1'b1;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b0;       end
	 7:begin Segb1=1'b0;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b1;       Segb5=1'b1;       Segb6=1'b1;       Segb7=1'b1;       end
	 8:begin Segb1=1'b0;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b0;       end
	 9:begin Segb1=1'b0;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b1;       Segb6=1'b0;       Segb7=1'b0;       end
	 
	10:begin Segb1=1'b0;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b1;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b0;       end//a
	11:begin Segb1=1'b1;       Segb2=1'b1;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b0;       end//b
	12:begin Segb1=1'b0;       Segb2=1'b1;       Segb3=1'b1;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b1;       end//c
	13:begin Segb1=1'b1;       Segb2=1'b0;       Segb3=1'b0;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b1;       Segb7=1'b0;       end//d
	14:begin Segb1=1'b0;       Segb2=1'b1;       Segb3=1'b1;       Segb4=1'b0;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b0;       end//e
	15:begin Segb1=1'b0;       Segb2=1'b1;       Segb3=1'b1;       Segb4=1'b1;       Segb5=1'b0;       Segb6=1'b0;       Segb7=1'b0;       end//f 
	 endcase
	 
	 case (display[11:8])
	 0:begin Segc1=1'b0;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b1;       end
	 1:begin Segc1=1'b1;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b1;       Segc5=1'b1;       Segc6=1'b1;       Segc7=1'b1;       end
	 2:begin Segc1=1'b0;       Segc2=1'b0;       Segc3=1'b1;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b1;       Segc7=1'b0;       end
	 3:begin Segc1=1'b0;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b1;       Segc6=1'b1;       Segc7=1'b0;       end
	 4:begin Segc1=1'b1;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b1;       Segc5=1'b1;       Segc6=1'b0;       Segc7=1'b0;       end
	 5:begin Segc1=1'b0;       Segc2=1'b1;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b1;       Segc6=1'b0;       Segc7=1'b0;       end
	 6:begin Segc1=1'b0;       Segc2=1'b1;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b0;       end
	 7:begin Segc1=1'b0;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b1;       Segc5=1'b1;       Segc6=1'b1;       Segc7=1'b1;       end
	 8:begin Segc1=1'b0;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b0;       end
	 9:begin Segc1=1'b0;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b1;       Segc6=1'b0;       Segc7=1'b0;       end
	 
	10:begin Segc1=1'b0;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b1;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b0;       end//a
	11:begin Segc1=1'b1;       Segc2=1'b1;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b0;       end//b
	12:begin Segc1=1'b0;       Segc2=1'b1;       Segc3=1'b1;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b1;       end//c
	13:begin Segc1=1'b1;       Segc2=1'b0;       Segc3=1'b0;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b1;       Segc7=1'b0;       end//d
	14:begin Segc1=1'b0;       Segc2=1'b1;       Segc3=1'b1;       Segc4=1'b0;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b0;       end//e
	15:begin Segc1=1'b0;       Segc2=1'b1;       Segc3=1'b1;       Segc4=1'b1;       Segc5=1'b0;       Segc6=1'b0;       Segc7=1'b0;       end//f
	 endcase
	 
	 case (display[15:12])
	 0:begin Segd1=1'b0;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b1;       end
	 1:begin Segd1=1'b1;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b1;       Segd5=1'b1;       Segd6=1'b1;       Segd7=1'b1;       end
	 2:begin Segd1=1'b0;       Segd2=1'b0;       Segd3=1'b1;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b1;       Segd7=1'b0;       end
	 3:begin Segd1=1'b0;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b1;       Segd6=1'b1;       Segd7=1'b0;       end
	 4:begin Segd1=1'b1;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b1;       Segd5=1'b1;       Segd6=1'b0;       Segd7=1'b0;       end
	 5:begin Segd1=1'b0;       Segd2=1'b1;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b1;       Segd6=1'b0;       Segd7=1'b0;       end
	 6:begin Segd1=1'b0;       Segd2=1'b1;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b0;       end
	 7:begin Segd1=1'b0;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b1;       Segd5=1'b1;       Segd6=1'b1;       Segd7=1'b1;       end
	 8:begin Segd1=1'b0;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b0;       end
	 9:begin Segd1=1'b0;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b1;       Segd6=1'b0;       Segd7=1'b0;       end
	 
	10:begin Segd1=1'b0;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b1;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b0;       end//a
	11:begin Segd1=1'b1;       Segd2=1'b1;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b0;       end//b
	12:begin Segd1=1'b0;       Segd2=1'b1;       Segd3=1'b1;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b1;       end//c
	13:begin Segd1=1'b1;       Segd2=1'b0;       Segd3=1'b0;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b1;       Segd7=1'b0;       end//d
	14:begin Segd1=1'b0;       Segd2=1'b1;       Segd3=1'b1;       Segd4=1'b0;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b0;       end//e
	15:begin Segd1=1'b0;       Segd2=1'b1;       Segd3=1'b1;       Segd4=1'b1;       Segd5=1'b0;       Segd6=1'b0;       Segd7=1'b0;       end//f
	 endcase
	 
	 case (display [19:16])
	 0:begin Sege1=1'b0;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b1;       end
	 1:begin Sege1=1'b1;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b1;       Sege5=1'b1;       Sege6=1'b1;       Sege7=1'b1;       end
	 2:begin Sege1=1'b0;       Sege2=1'b0;       Sege3=1'b1;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b1;       Sege7=1'b0;       end
	 3:begin Sege1=1'b0;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b1;       Sege6=1'b1;       Sege7=1'b0;       end
	 4:begin Sege1=1'b1;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b1;       Sege5=1'b1;       Sege6=1'b0;       Sege7=1'b0;       end
	 5:begin Sege1=1'b0;       Sege2=1'b1;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b1;       Sege6=1'b0;       Sege7=1'b0;       end
	 6:begin Sege1=1'b0;       Sege2=1'b1;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b0;       end
	 7:begin Sege1=1'b0;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b1;       Sege5=1'b1;       Sege6=1'b1;       Sege7=1'b1;       end
	 8:begin Sege1=1'b0;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b0;       end
	 9:begin Sege1=1'b0;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b1;       Sege6=1'b0;       Sege7=1'b0;       end
	 
	10:begin Sege1=1'b0;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b1;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b0;       end//a
	11:begin Sege1=1'b1;       Sege2=1'b1;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b0;       end//b
	12:begin Sege1=1'b0;       Sege2=1'b1;       Sege3=1'b1;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b1;       end//c
	13:begin Sege1=1'b1;       Sege2=1'b0;       Sege3=1'b0;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b1;       Sege7=1'b0;       end//d
	14:begin Sege1=1'b0;       Sege2=1'b1;       Sege3=1'b1;       Sege4=1'b0;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b0;       end//e
	15:begin Sege1=1'b0;       Sege2=1'b1;       Sege3=1'b1;       Sege4=1'b1;       Sege5=1'b0;       Sege6=1'b0;       Sege7=1'b0;       end//f
	 endcase
	 
	 case (display[23:20])
	 0:begin Segf1=1'b0;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b1;       end
	 1:begin Segf1=1'b1;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b1;       Segf5=1'b1;       Segf6=1'b1;       Segf7=1'b1;       end
	 2:begin Segf1=1'b0;       Segf2=1'b0;       Segf3=1'b1;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b1;       Segf7=1'b0;       end
	 3:begin Segf1=1'b0;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b1;       Segf6=1'b1;       Segf7=1'b0;       end
	 4:begin Segf1=1'b1;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b1;       Segf5=1'b1;       Segf6=1'b0;       Segf7=1'b0;       end
	 5:begin Segf1=1'b0;       Segf2=1'b1;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b1;       Segf6=1'b0;       Segf7=1'b0;       end
	 6:begin Segf1=1'b0;       Segf2=1'b1;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b0;       end
	 7:begin Segf1=1'b0;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b1;       Segf5=1'b1;       Segf6=1'b1;       Segf7=1'b1;       end
	 8:begin Segf1=1'b0;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b0;       end
	 9:begin Segf1=1'b0;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b1;       Segf6=1'b0;       Segf7=1'b0;       end
	 
	10:begin Segf1=1'b0;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b1;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b0;       end//a
	11:begin Segf1=1'b1;       Segf2=1'b1;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b0;       end//b
	12:begin Segf1=1'b0;       Segf2=1'b1;       Segf3=1'b1;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b1;       end//c
	13:begin Segf1=1'b1;       Segf2=1'b0;       Segf3=1'b0;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b1;       Segf7=1'b0;       end//d
	14:begin Segf1=1'b0;       Segf2=1'b1;       Segf3=1'b1;       Segf4=1'b0;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b0;       end//e
	15:begin Segf1=1'b0;       Segf2=1'b1;       Segf3=1'b1;       Segf4=1'b1;       Segf5=1'b0;       Segf6=1'b0;       Segf7=1'b0;       end//f
	 endcase
		end
	
	
	
	
	endmodule
	 



	 
	 
	 
	 
	 
	 