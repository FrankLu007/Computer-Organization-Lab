//Subject:     CO project 3 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0416024 ³¯¬ýÂ× 0516310 §f©Ó¿«
//----------------------------------------------
//Date:        2017/5/12 23:18
//----------------------------------------------
//Description:
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
  ALUSigned_o,
	RegDst_o,
	Branch_o,
  BranchType_o,
	Jump_o,
  MemToReg_o,
  MemRead_o,
  MemWrite_o
	);

//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output         ALUSigned_o;
output [1:0]   RegDst_o;
output         Branch_o;
output [1:0]   BranchType_o;
output         Jump_o;
output [1:0]   MemToReg_o;
output         MemRead_o;
output         MemWrite_o;

//Internal Signals
/*
reg    [3-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg            RegDst_o;
reg            Branch_o;
*/
//Parameter


//Main function
// 4: beq, 5: bne, 1: bltz, 6: ble
assign Branch_o = (instr_op_i == 4 || instr_op_i == 5 || instr_op_i == 1 || instr_op_i == 6);
// 3: jal, 2: jump
assign Jump_o = (instr_op_i == 3 || instr_op_i == 2);
// 6'b100011: lw
assign MemRead_o = (instr_op_i == 6'b100011);
// 6'b101011: sw
assign MemWrite_o = (instr_op_i == 6'b101011);
// not branch, not jump, and not sw
assign RegWrite_o = !Branch_o && (instr_op_i != 2) && instr_op_i != 6'b101011;
assign RegDst_o =
    (instr_op_i == 0) ? 2'b01 // R-type
  :((instr_op_i == 3) ? 2'b10 // jal
  : 2'b00) ; // I-type
// R-type or branch: ALUSrc is rt
// otherwise: ALUSrc is immediate
assign ALUSrc_o = (instr_op_i != 0 && !Branch_o);
assign ALU_op_o =
    (instr_op_i == 4 || instr_op_i == 5 || instr_op_i == 1) ? 3'b001 // beq, bne, bltz
  :((instr_op_i == 0 ) ? 3'b010 // R-type and nop
  :((instr_op_i == 13) ? 3'b011 // ori
  :((instr_op_i == 9 ) ? 3'b100 // sltiu
  :((instr_op_i == 6 ) ? 3'b101 // ble
  : 3'b000)))) ; // lw, sw, addi, li, and other instructions that don't use ALU

// immediate is unsigned extension
// 9: sltiu, 13: ori
assign ALUSigned_o = (instr_op_i == 9 || instr_op_i == 13);

assign BranchType_o =
    (instr_op_i == 4) ? 2'b00 // beq
  :((instr_op_i == 1) ? 2'b10 // ble
  : 2'b11); // bne, bnez, ble

assign MemToReg_o =
    (instr_op_i == 6'b100011) ? 2'b01 // lw
  :((instr_op_i == 3) ? 2'b11 // jal
  : 2'b00); // bne, bnez, ble

endmodule
