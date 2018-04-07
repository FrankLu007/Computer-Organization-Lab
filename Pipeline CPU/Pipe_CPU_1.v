//Subject:     CO project 4 - Pipe CPU with forwarding
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0416024 ³¯¬ýÂ× 0516310 §f©Ó¿«
//----------------------------------------------
//Date:        2017/6/4 PM 9:07
//----------------------------------------------
//Description:
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
        clk_i,
		rst_i
		);

/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
/**** IF stage ****/
wire [31:0] pcNext;
wire [31:0] pcNext_maybeStalled;
wire [31:0] pc;
wire [31:0] pcPlus4_IF;
wire [31:0] instruction_IF;
wire [63:0] IFCtrls;
wire [63:0] IFCtrls_maybeFlushed;

/**** ID stage ****/
wire [31:0] pcPlus4_ID;
wire [31:0] instruction_ID;

wire [5:0] instrOp;
wire [4:0] rs_ID;
wire [4:0] rt_ID;
wire [4:0] rd_ID;
wire [31:0] readData1_ID;
wire [31:0] readData2_ID;
wire [31:0] immediate_ID;

//control signal
wire RegWrite_ID;
wire MemToReg_ID;
wire Branch_ID;
wire BranchType_ID;
wire MemWrite_ID;
wire MemRead_ID;
wire [2:0] ALUOp_ID;
wire RegDst_ID;
wire ALUSrc_ID;
wire [10:0] IDCtrls;

//hazard control
wire PCWrite;
wire IFIDWrite;
wire IDFlush;
wire EXFlush;
wire MEMFlush;

/**** EX stage ****/
wire [31:0] pcPlus4_EX;
wire [31:0] readData1_EX;
wire [31:0] readData2_EX;
wire [31:0] immediate_EX;
wire [4:0] rs_EX;
wire [4:0] rt_EX;
wire [4:0] rd_EX;

wire [31:0] forwardData1;
wire [31:0] forwardData2;
wire [31:0] aluOperand1;
wire [31:0] aluOperand2;
wire [31:0] shiftLeftTwo;
wire [31:0] branchTarget_EX;
wire [31:0] aluResult_EX;
wire [4:0] writeReg_EX;

//control signal
wire RegWrite_EX;
wire MemToReg_EX;
wire Branch_EX;
wire BranchType_EX;
wire MemWrite_EX;
wire MemRead_EX;
wire [2:0] ALUOp_EX;
wire RegDst_EX;
wire ALUSrc_EX;

wire [1:0] EXCtrlsToWB;
wire [3:0] EXCtrlsToMEM;
wire [3:0] ALUCtrl;
wire ALUZero_EX;

// forwarding control
wire [1:0] Forward1;
wire [1:0] Forward2;

/**** MEM stage ****/
wire [31:0] branchTarget_MEM;
wire [31:0] aluResult_MEM;
wire [31:0] readData2_MEM;
wire [4:0] writeReg_MEM;

wire [31:0] memReadData_MEM;

//control signal
wire RegWrite_MEM;
wire MemToReg_MEM;
wire Branch_MEM;
wire BranchType_MEM;
wire MemWrite_MEM;
wire MemRead_MEM;
wire ALUZero_MEM;

wire PCSrc;

/**** WB stage ****/
wire [31:0] memReadData_WB;
wire [31:0] aluResult_WB;
wire [4:0] writeReg_WB;

wire [31:0] writeData;

//control signal
wire RegWrite_WB;
wire MemToReg_WB;

/****************************************
Instnatiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux1(
	.data0_i(pcPlus4_IF),
	.data1_i(branchTarget_MEM),
	.select_i(PCSrc),
	.data_o(pcNext)
		);

MUX_2to1 #(.size(32)) MuxPC(
	.data0_i(pc), // pc unchanged
	.data1_i(pcNext),
	.select_i(PCWrite),
	.data_o(pcNext_maybeStalled)
		);

ProgramCounter PC(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.pc_in_i(pcNext_maybeStalled),
	.pc_out_o(pc)
        );

Instr_Memory IM(
	.addr_i(pc),
	.instr_o(instruction_IF)
	    );

Adder Add_pc(
	.src1_i(pc),
	.src2_i(32'd4),
	.sum_o(pcPlus4_IF)
		);

MUX_2to1 #(.size(64)) IFIDWriteMUX(
  .data0_i({pcPlus4_ID, instruction_ID}), // pipe reg unchanged
  .data1_i({pcPlus4_IF, instruction_IF}),
  .select_i(IFIDWrite),
  .data_o(IFCtrls)
    );

MUX_2to1 #(.size(64)) IDFlushMUX(
  .data0_i(IFCtrls),
  .data1_i(64'b0),
  .select_i(IDFlush),
  .data_o(IFCtrls_maybeFlushed)
    );


Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i(IFCtrls_maybeFlushed), // 32+32bit
	.data_o({pcPlus4_ID, instruction_ID})
		);

//Instantiate the components in ID stage
assign instrOp = instruction_ID[31:26];
assign rs_ID = instruction_ID[25:21];
assign rt_ID = instruction_ID[20:16];
assign rd_ID = instruction_ID[15:11];

Reg_File RF(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.RSaddr_i(rs_ID),
	.RTaddr_i(rt_ID),
	.RDaddr_i(writeReg_WB),
	.RDdata_i(writeData),
	.RegWrite_i(RegWrite_WB),
	.RSdata_o(readData1_ID),
	.RTdata_o(readData2_ID)
		);

Decoder Control(
	.instr_op_i(instrOp),
	.RegWrite_o(RegWrite_ID),
	.ALU_op_o(ALUOp_ID),
	.ALUSrc_o(ALUSrc_ID),
	//.ALUSigned_o(),
	.RegDst_o(RegDst_ID),
	.Branch_o(Branch_ID),
	.BranchType_o(BranchType_ID),
	//.Jump_o(),
	.MemToReg_o(MemToReg_ID),
	.MemRead_o(MemRead_ID),
	.MemWrite_o(MemWrite_ID)
		);

HazardDetect Haz(
  .rs_ID_i(rs_ID),
  .rt_ID_i(rt_ID),
  .rt_EX_i(rt_EX),
  .MemRead_EX_i(MemRead_EX),
  .PCSrc_i(PCSrc),
  .PCWrite_o(PCWrite),
  .IFIDWrite_o(IFIDWrite),
  .IDFlush_o(IDFlush),
  .EXFlush_o(EXFlush),
  .MEMFlush_o(MEMFlush)
    );

Sign_Extend Sign_Extend(
	.data_i(instruction_ID[15:0]),
	.data_o(immediate_ID)
		);

MUX_2to1 #(.size(11)) EXFlushMUX(
  .data0_i({
    RegWrite_ID, MemToReg_ID, // 2bit
		Branch_ID, BranchType_ID, MemWrite_ID, MemRead_ID, // 4bit
		RegDst_ID, ALUOp_ID, ALUSrc_ID // 5bit
  }),
  .data1_i(11'b0),
  .select_i(EXFlush),
  .data_o(IDCtrls)
    );

Pipe_Reg #(.size(11+143)) ID_EX(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i({
		// control signals
		IDCtrls, // 11bit
		// data signals
		pcPlus4_ID, // 32bit
		readData1_ID, // 32bit
		readData2_ID, // 32bit
		immediate_ID, // 32bit
		rs_ID, // 5bit
		rt_ID, // 5bit
		rd_ID // 5bit
	}),
	.data_o({
		// control signals
		RegWrite_EX, MemToReg_EX,
		Branch_EX, BranchType_EX, MemWrite_EX, MemRead_EX,
		RegDst_EX, ALUOp_EX, ALUSrc_EX,
		// data signals
		pcPlus4_EX,
		readData1_EX,
		readData2_EX,
		immediate_EX,
		rs_EX,
		rt_EX,
		rd_EX
	})
		);

//Instantiate the components in EX stage

Shift_Left_Two_32 shifter(
	.data_i(immediate_EX),
	.data_o(shiftLeftTwo)
    );

Adder Add_branch_target(
	.src1_i(pcPlus4_EX),
	.src2_i(shiftLeftTwo),
	.sum_o(branchTarget_EX)
		);

ForwardUnit Fwd(
	.rs_EX_i(rs_EX),
	.rt_EX_i(rt_EX),
	.rd_MEM_i(writeReg_MEM),
	.RegWrite_MEM_i(RegWrite_MEM),
	.rd_WB_i(writeReg_WB),
	.RegWrite_WB_i(RegWrite_WB),
	.Forward1_o(Forward1),
	.Forward2_o(Forward2)
);

MUX_4to1 #(.size(32)) ForwardMux1(
	.data0_i(readData1_EX),
	.data1_i(writeData),
	.data2_i(aluResult_MEM),
	.data3_i(32'b0),
	.select_i(Forward1),
	.data_o(forwardData1)
        );

MUX_4to1 #(.size(32)) ForwardMux2(
	.data0_i(readData2_EX),
	.data1_i(writeData),
	.data2_i(aluResult_MEM),
	.data3_i(32'b0),
	.select_i(Forward2),
	.data_o(forwardData2)
        );

assign aluOperand1 = forwardData1;
MUX_2to1 #(.size(32)) Mux2(
	.data0_i(forwardData2),
	.data1_i(immediate_EX),
	.select_i(ALUSrc_EX),
	.data_o(aluOperand2)
        );

ALU ALU(
	.src1_i(aluOperand1),
	.src2_i(aluOperand2),
	//.shamt(),
	.ctrl_i(ALUCtrl),
	.result_o(aluResult_EX),
	.zero_o(ALUZero_EX)
		);

ALU_Ctrl ALU_Ctrl(
	.funct_i(immediate_EX[5:0]),
	.ALUOp_i(ALUOp_EX),
	.ALUCtrl_o(ALUCtrl)//,
	//.Jr_o()
		);

MUX_2to1 #(.size(5)) Mux3(
	.data0_i(rt_EX),
	.data1_i(rd_EX),
	.select_i(RegDst_EX),
	.data_o(writeReg_EX)
        );

MUX_2to1 #(.size(2)) MEMFlushMUX_WB(
  .data0_i({RegWrite_EX, MemToReg_EX}),
  .data1_i(2'b0),
  .select_i(MEMFlush),
  .data_o(EXCtrlsToWB)
    );

MUX_2to1 #(.size(4)) MEMFlushMUX_MEM(
  .data0_i({Branch_EX, BranchType_EX, MemWrite_EX, MemRead_EX}),
  .data1_i(4'b0),
  .select_i(MEMFlush),
  .data_o(EXCtrlsToMEM)
    );

Pipe_Reg #(.size(7+101)) EX_MEM(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i({
		// control signals
		EXCtrlsToWB, // 2bit
		EXCtrlsToMEM, // 4bit
		ALUZero_EX, // 1bit
		// data signals
		branchTarget_EX, // 32bit
		aluResult_EX, // 32bit
		readData2_EX, // 32bit
		writeReg_EX // 5bit
	}),
	.data_o({
		// control signals
		RegWrite_MEM, MemToReg_MEM,
		Branch_MEM, BranchType_MEM, MemWrite_MEM, MemRead_MEM,
		ALUZero_MEM,
		// data signals
		branchTarget_MEM,
		aluResult_MEM,
		readData2_MEM,
		writeReg_MEM
	})
		);

//Instantiate the components in MEM stage
// if BranchType is 1, then the instruction is bne
// when ALUZero == 1, rs is equal to rt
assign PCSrc = Branch_MEM & (BranchType_MEM == 1 ? !ALUZero_MEM : ALUZero_MEM);

Data_Memory DM(
	.clk_i(clk_i),
	.addr_i(aluResult_MEM),
	.data_i(readData2_MEM),
	.MemRead_i(MemRead_MEM),
	.MemWrite_i(MemWrite_MEM),
	.data_o(memReadData_MEM)
	    );

Pipe_Reg #(.size(2+69)) MEM_WB(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i({
		// control signals
		RegWrite_MEM, MemToReg_MEM, // 2bit
		// data signals
		memReadData_MEM, // 32bit
		aluResult_MEM, // 32bit
		writeReg_MEM // 5bit
	}),
	.data_o({
		// control signals
		RegWrite_WB, MemToReg_WB,
		// data signals
		memReadData_WB,
		aluResult_WB,
		writeReg_WB
	})
		);

//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux4(
	.data0_i(aluResult_WB),
	.data1_i(memReadData_WB),
	.select_i(MemToReg_WB),
	.data_o(writeData)
        );

/****************************************
signal assignment
****************************************/
endmodule
