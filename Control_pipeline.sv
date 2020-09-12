//
// File Name: Control_pipeline.sv
// Function: control unit
// Author: Mohammad Abu Alhalawe
// Last rev.: 05/09/19
//
`include "opcodes.sv"
`include "alucodes.sv"
module Control_pipeline(
input logic [6:0] opcode,
input logic [2:0] func3,
input logic [6:0] func7,
output logic [4:0] ALUOpin,
output logic [2:0] immSel,
output logic RegWrite,
output logic ALUSrc,
output logic MemWrite,
output logic jump,
output logic MemRead,
output logic MemtoReg,
output logic store_address,
output logic jump_register,branch,rd0,aui
);
 always_comb
 begin

 ALUSrc = 1;
 RegWrite = 0;
 MemWrite = 0;
 MemRead = 0;
 MemtoReg = 0;
 store_address = 0;
 jump = 0;
 ALUOpin = `alu_add;
 immSel = 0;
 jump_register = 0;
 branch = 0;
 rd0 = 0;
 aui = 0;
  case  (opcode)
   `CSRRS :begin
		   immSel = 3'b101;
		  RegWrite = 1;
		  end
   `LUI : begin
          RegWrite = 1;
		    ALUOpin = `alu_add;
		    immSel = 0; // case imm {{13{I[31]}}, I[30:12]} case 1
			rd0 = 1;
		    end
			 
  `AUIPC: begin
                ALUOpin = `alu_add;
			 immSel = 0; // case imm {{13{I[31]}}, I[30:12]} case 1
			 RegWrite = 1;
			 aui = 1;
			 end
			 
  `JAL  : begin
          jump = 1;
			 store_address = 1;
			 RegWrite = 1;
			 immSel = 3'b001; // case imm {{12{I[31]}},I[19:12],I[20],I[30:21],1'b0} case 2
			 end
			 
  `JALR : begin
          jump = 1;
			 store_address = 1;
			 RegWrite = 1;
			 immSel = 3'b010;// case  imm {20{I[11]},I[11:0]} case 3
			 jump_register = 1;
			 end
			 
    `SW : begin
			 MemWrite = 1;
			 ALUOpin = `alu_add;
			 immSel = 3'b100;// case  imm {{21{I[31]}}, I[30:25],I[11:7]} case 5
			 end
			 
 `Btype : begin
			 immSel = 3'b011;// case  imm {20{I[12]},I[30:25],I[11:7],1'b0} case 4
			 branch = 1;
			 end
 `LW    : begin
          ALUOpin = `alu_add;
			 RegWrite = 1;
			 MemRead = 1;
			 MemtoReg = 1;
			 immSel = 3'b010;// case  imm {20{I[11]},I[11:0]}
			 end
			 
 `Rtype : begin
			 ALUSrc = 0;
                RegWrite = 1;
		      if (func7[0])
			  begin
			  case (func3)
			  0: ALUOpin = `alu_mul;
			  1: ALUOpin = `alu_mulh;
			  2: ALUOpin = `alu_mulhu;
			  4: ALUOpin = `alu_div;
			  5: ALUOpin = `alu_divu;
			  6: ALUOpin = `alu_rem;
			  7: ALUOpin = `alu_remu;
			  default: ;
			  endcase
			  end
			  else
			  begin
			 case (func3)
			 0 : begin
			     if (func7 == 0) ALUOpin = `alu_add;
			     else ALUOpin = `alu_sub;
				  end
			 1 : ALUOpin = `alu_sll;
			 2 : ALUOpin = `alu_slt;
			 3 : ALUOpin = `alu_sltu;
			 4 : ALUOpin = `alu_xor;
			 5 : begin
			     if (func7 == 0) ALUOpin = `alu_srl;
			     else ALUOpin = `alu_sra;
				  end 
			 6 : ALUOpin = `alu_or;
			 7 : ALUOpin = `alu_and;
			 endcase // func 3
			 end
			 end
 `Itype : begin
			 RegWrite = 1;
			 immSel = 3'b010;// case  imm {20{I[11]},I[11:0]}
			 case (func3)
			 0: ALUOpin = `alu_add;
			 1: ALUOpin = `alu_slli;
			 2 : ALUOpin = `alu_slt;
			 3 : ALUOpin = `alu_sltu;
			 4 : ALUOpin = `alu_xor;
			 5:  ALUOpin = `alu_srai;
			 6 : ALUOpin = `alu_or;
			 7 : ALUOpin = `alu_and;
			 default : ;
			 endcase
			 end
default : ;
endcase
end//always_comb
 endmodule