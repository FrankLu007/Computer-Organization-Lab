//Subject:     CO project 4 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0416024 ³¯¬ýÂ× 0516310 §f©Ó¿«
//----------------------------------------------
//Date:        2017/6/2 PM 8:04
//----------------------------------------------
//Description:
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
  //ALUSigned_o,
	RegDst_o,
	Branch_o,
  BranchType_o,
	//Jump_o,
  MemToReg_o,
  MemRead_o,
  MemWrite_o
	);

//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
//output         ALUSigned_o;
//output   [1:0] RegDst_o;
output         RegDst_o;
output         Branch_o;
//output [1:0]   BranchType_o;e
output         BranchType_o;
//output         Jump_o;
//output   [1:0] MemToReg_o;
output         MemToReg_o;
output         MemRead_o;
output         MemWrite_o;

//Internal Signals

//Parameter


//Main function
// 4: beq, 5: bne, 1: bltz, 6: ble
assign Branch_o = (instr_op_i == 4 || instr_op_i == 5);
// 3: jal, 2: jump, not used in this LAB
//assign Jump_o = (instr_op_i == 3 || instr_op_i == 2);
// 6'b100011: lw
assign MemRead_o = (instr_op_i == 6'b100011);
// 6'b101011: sw
assign MemWrite_o = (instr_op_i == 6'b101011);
// not branch, and not sw
assign RegWrite_o = !Branch_o && instr_op_i != 6'b101011;
assign RegDst_o =
    (instr_op_i == 0) ? 1 // R-type
  : 0 ; // I-type
// R-type or branch: ALUSrc is rt
// otherwise: ALUSrc is immediate
assign ALUSrc_o = (instr_op_i != 0 && !Branch_o);
assign ALU_op_o =
    (instr_op_i == 4 || instr_op_i == 5) ? 3'b001 // beq, bne
  : (instr_op_i == 0 ) ? 3'b010 // R-type and nop
  : 3'b000 ; // lw, sw, and addi

// immediate is unsigned extension
// 9: sltiu, 13: ori
//assign ALUSigned_o = (instr_op_i == 9 || instr_op_i == 13);

assign BranchType_o =
    (instr_op_i == 4) ? 0 // beq
  //: (instr_op_i == 1) ? 2'b10 // ble
  : 1; // bne

assign MemToReg_o =
    (instr_op_i == 6'b100011) ? 1 // lw
  : 0; // other instructions

endmodule
