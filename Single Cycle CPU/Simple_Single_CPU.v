//Subject:     CO project 3 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:  0416024 ³¯¬ýÂ× 0516310 §f©Ó¿«
//----------------------------------------------
//Date:        2017/5/12 11:24
//----------------------------------------------
//Description:
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
		rst_i
		);

//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
// fetch
wire [31:0] instruction;
// decode & read reg
wire [1:0] RegDst;
wire RegWrite;
wire Branch;
wire ALUSrc;
wire ALUSigned;
wire MemRead;
wire MemWrite;
wire Jump;
wire [2:0] ALUOp;
wire [1:0] BranchType;
wire [1:0] MemToReg;
wire [3:0] ALUCtrl;
wire       Jr;
wire [4:0] rd;
wire [31:0] immediate;
wire [31:0] unsignedImmediate;
wire [31:0] chosenImmediate;
wire [27:0] jumpTarget;

wire [31:0] readReg1;
wire [31:0] readReg2;
wire [31:0] operand1;
wire [31:0] operand2;
// execute
wire [31:0] shiftedImmediate;
wire [31:0] branchTarget;
wire [31:0] ALUOut;
wire ALUZero;
wire toBranch;
// memory access
wire [31:0] memReadData;
wire [31:0] writeData;
// write reg
wire [31:0] PC_now;
wire [31:0] PCPlus4;
wire [31:0] PC_jr;
wire [31:0] PC_branch;
wire [31:0] PC_next;

//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),
	    .rst_i (rst_i),
	    .pc_in_i(PC_next) ,
	    .pc_out_o(PC_now)
	    );

Adder Adder1(
        .src1_i(PC_now),
	    .src2_i(32'd4),
	    .sum_o(PCPlus4)
	    );

Instr_Memory IM(
        .addr_i(PC_now),
	    .instr_o(instruction)
	    );

MUX_4to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instruction[20-:5]), // store to rt, used in I-type
        .data1_i(instruction[15-:5]), // store to rd, used in R-type
        .data2_i(5'd31), // store to register 31, only used in jal
        .data3_i(5'd31), // not used
        .select_i(RegDst),
        .data_o(rd)
        );

Reg_File RF(
        .clk_i(clk_i),
	    .rst_i(rst_i) ,
        .RSaddr_i(instruction[25-:5]) ,
        .RTaddr_i(instruction[20-:5]) ,
        .RDaddr_i(rd) ,
        .RDdata_i(writeData)  ,
        .RegWrite_i (RegWrite),
        .RSdata_o(readReg1) ,
        .RTdata_o(readReg2)
        );

Decoder Decoder(
  .instr_op_i(instruction[31-:6]),
  .RegWrite_o(RegWrite),
  .ALU_op_o(ALUOp),
  .ALUSrc_o(ALUSrc),
  .ALUSigned_o(ALUSigned),
  .RegDst_o(RegDst),
  .Branch_o(Branch),
  .BranchType_o(BranchType),
  .Jump_o(Jump),
  .MemToReg_o(MemToReg),
  .MemRead_o(MemRead),
  .MemWrite_o(MemWrite)
  );

ALU_Ctrl AC(
        .funct_i(instruction[5-:6]),
        .ALUOp_i(ALUOp),
        .ALUCtrl_o(ALUCtrl),
        .Jr_o(Jr)
        );

Sign_Extend SE(
        .data_i(instruction[15-:16]),
        .data_o(immediate)
        );

Unsign_Extend UE(
        .data_i(instruction[15-:16]),
        .data_o(unsignedImmediate)
        );

MUX_2to1 #(.size(32)) Mux_SignExtend(
        .data0_i(immediate), // signed extend
        .data1_i(unsignedImmediate), // unsigned extend
        .select_i(ALUSigned),
        .data_o(chosenImmediate)
        );

assign operand1 = readReg1;

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(readReg2), // R-type
        .data1_i(chosenImmediate), // I-type
        .select_i(ALUSrc),
        .data_o(operand2)
        );

ALU ALU(
        .src1_i(operand1),
	    .src2_i(operand2),
		 .shamt(instruction[10-:5]),
	    .ctrl_i(ALUCtrl),
	    .result_o(ALUOut),
		.zero_o(ALUZero)
	    );

Data_Memory Data_Memory(
  .clk_i(clk_i),
  .addr_i(ALUOut),
  .data_i(readReg2),
  .MemRead_i(MemRead),
  .MemWrite_i(MemWrite),
  .data_o(memReadData)
);

MUX_4to1 #(.size(32)) Mux_MemToReg(
  .data0_i(ALUOut), // from ALU
  .data1_i(memReadData), // from memory
  .data2_i(immediate), // from immediate
  .data3_i(PCPlus4), // store PC to register
  .select_i(MemToReg),
  .data_o(writeData)
  );

Adder Adder2(
        .src1_i(PCPlus4),
	    .src2_i(shiftedImmediate),
	    .sum_o(branchTarget)
	    );

Shift_Left_Two_32 Shifter(
        .data_i(immediate),
        .data_o(shiftedImmediate)
        );

MUX_4to1 #(.size(1)) Mux_BranchType(
  .data0_i(ALUZero), // beq
  .data1_i(!(ALUZero | ALUOut[31])), // not used
  .data2_i(ALUOut[31]), // bltz
  .data3_i(!ALUZero), // bne, bnez, ble
  .select_i(BranchType),
  .data_o(toBranch)
);

MUX_2to1 #(.size(32)) Mux_Jr_PC(
        .data0_i(PCPlus4), // not jr
        .data1_i(readReg1), // jr
        .select_i(Jr),
        .data_o(PC_jr)
  );

MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(PC_jr), // no branch or jr
        .data1_i(branchTarget), // branch
        .select_i(Branch & toBranch),
        .data_o(PC_branch)
        );

Shift_Left_Two_28 JumpTargetShifter(
    .data_i(instruction[25:0]),
    .data_o(jumpTarget)
  );

MUX_2to1 #(.size(32)) Mux_Jump_PC(
        .data0_i(PC_branch), // branch, jr or normal
        .data1_i({PCPlus4[31:28], jumpTarget}), // jump
        .select_i(Jump),
        .data_o(PC_next)
  );

endmodule
