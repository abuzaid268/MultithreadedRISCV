//
// File Name: ID.sv
// Function: instruction decoder
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
module ID(
	input logic [31:0] I_ID,newpc_ID,Wdata_Mem,Wdata_WB,currentPC_ID,out,IntmhartID,
	input logic clk,RegWrite_WB,nReset,flush,
	input logic [1:0] ForwardRS1,ForwardRS2,mhartID_ID,mhartID_WB,
	input logic [4:0] Waddr_WB,
	output logic [31:0] Rdata1_EX,Rdata2_EX,currentPC_EX,
	output logic RegWrite_EX,ALUSrc_EX,MemWrite_EX,MemRead_EX,MemtoReg_EX,branch_ID,jump_ID,
	store_address_EX/*,flush*/,branch,aui_EX,MemRead,MemWrite,
	output logic [1:0] mhartID_EX,
	output logic [4:0] ALUOpin_EX,
	output logic [31:0] I_EX,
	output logic [31:0]newpc_EX,imm_EX,RBranch_EX,absolute_jump_ID
);
logic [31:0] Rdata1,Rdata2,imm,ForwardS1Mux,ForwardS2Mux;
logic [4:0] ALUOpin,addr1;
logic [2:0] immSel;
logic RegWrite,ALUSrc,MemtoReg,RegDst,store_address,jump_register,rd0,aui;
	
	regs gpr1(.clk,.RegWrite(RegWrite_WB),.Wdata(Wdata_WB),.Raddr1(addr1),.Raddr2(I_ID[24:20]),
	.Waddr(Waddr_WB),.Rdata1,.Rdata2,.mhartID_ID,.mhartID_WB);

	Control_pipeline control1(.opcode(I_ID[6:0]),.ALUOpin(ALUOpin),.RegWrite(RegWrite),.ALUSrc(ALUSrc),
     .MemWrite(MemWrite),.MemRead(MemRead),.MemtoReg(MemtoReg),.jump(jump_ID),
     .store_address(store_address),.immSel,.func3(I_ID[14:12]),.func7(I_ID[31:25]),.jump_register,.branch,.rd0,.aui);
	
	branch br1 (.rs1(ForwardS1Mux),.rs2(ForwardS2Mux),.opcode(I_ID[6:0]),.func3(I_ID[14:12]),.branch(branch_ID));
	
	immediate_generator Imm1 (.immSel,.I(I_ID[31:7]),.imm,.IntmhartID); 
	assign addr1 = (rd0) ? 5'b0:I_ID[19:15];
	//assign flush = (jump_ID || branch_ID || MemRead || MemWrite) ? 1'b1 : 1'b0;
     assign RBranch_EX = currentPC_ID + imm ;
	assign absolute_jump_ID = (jump_register) ? Rdata1 : imm + currentPC_ID;// for jalr, usually whats before is lui or auipc, which loads upper 20 bits
	// of target address in register and yu add lower 12, it is used becasuse you cannot store 32 bits of address in a signle operation
	
	always_comb
	begin
	ForwardS1Mux = 0;
	ForwardS2Mux = 0;
	case (ForwardRS1)
	0: ForwardS1Mux = Rdata1;
	2: ForwardS1Mux = Wdata_Mem;
	3: ForwardS1Mux = out;
	default: ForwardS1Mux = Rdata1;
	endcase
	case (ForwardRS2)
	0: ForwardS2Mux = Rdata2;
	2: ForwardS2Mux = Wdata_Mem;
	3: ForwardS2Mux = out;
	default: ForwardS2Mux = Rdata2;
	endcase
	end
	
	always_ff @(posedge clk, negedge nReset)
   if (!nReset)
   begin
	Rdata1_EX <= 0;
	Rdata2_EX <= 0;
	RegWrite_EX <= 0;
	ALUSrc_EX <= 0;
	MemWrite_EX <= 0;
	MemRead_EX <= 0;
	MemtoReg_EX <= 0;
	store_address_EX <= 0;
	I_EX <= 0;
   ALUOpin_EX <= 0;
	newpc_EX <= 0;
	imm_EX <= 0;
	currentPC_EX <= 0;
	aui_EX <= 0;
	mhartID_EX <= 0;
   end
    else if (flush)
   begin
	Rdata1_EX <= 0;
	Rdata2_EX <= 0;
	RegWrite_EX <= 0;
	ALUSrc_EX <= 0;
	MemWrite_EX <= 0;
	MemRead_EX <= 0;
	MemtoReg_EX <= 0;
	store_address_EX <= 0;
	I_EX <= 0;
   ALUOpin_EX <= 0;
	newpc_EX <= 0;
	imm_EX <= 0;
	aui_EX <= 0;
   end
   else
   begin
     currentPC_EX <= currentPC_ID;
	Rdata1_EX <= Rdata1;
	Rdata2_EX <= Rdata2;
	RegWrite_EX <= RegWrite;
	ALUSrc_EX <= ALUSrc;
	MemWrite_EX <= MemWrite;
	MemRead_EX <= MemRead;
	MemtoReg_EX <= MemtoReg;
	store_address_EX <= store_address;
	I_EX <= I_ID [31:0];
	ALUOpin_EX <= ALUOpin;
	newpc_EX <=  newpc_ID;
	imm_EX <= imm;
	aui_EX <= aui;
	mhartID_EX <= mhartID_ID;
   end
   endmodule
	