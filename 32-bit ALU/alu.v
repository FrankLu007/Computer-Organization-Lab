`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Student #1:
//     ID: 0416024
//     name: ³¯¬ýÂ×
// Student #2:
//     ID: 0516310
//     name: §f©Ó¿«
//
// Create Date:    15:15:11 08/18/2010
// Design Name:
// Module Name:    alu
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.02 - BONUS Directive
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

/*
* A And B
* A Or B
* A Add B
* A Sub B = A Add -B = A Add (Not B) Add 1
* A Nor B = Not (A Or B)
* A Nand B = Not (A And B)
* A Slt B = (A Sub B < 0)
* ~B = -B - 1
* => -B = ~B + 1
*/

// implement alu_bottom
// case of slt:
// A = 0xxx, B = 0xxx
// Ax = xxx, Bx = xxx
// Ax+~Bx+1 = 2^31+Ax-Bx
// when Ax >= Bx, Ax-Bx >= 0, Ax+~Bx+1 will overflow
// when Ax < Bx, Ax-Bx < 0, Ax+~Bx+1 will not overflow
//
// A = 1xxx, B = 1xxx
// Ax = xxx, Bx = xxx
// Ax+~Bx+1 = 2^31+Ax-Bx
// when Ax >= Bx, Ax-Bx >= 0, Ax+~Bx+1 will overflow
// when Ax < Bx, Ax-Bx < 0, Ax+~Bx+1 will not overflow
//
// A = 1xxx, B = 0xxx => A < B
// A = 0xxx, B = 1xxx => A > B

// if you want to test BONUS, please uncomment `define BONUS
//`define BONUS "Yee!"

module alu(
           rst_n,         // negative reset            (input)
           src1,          // 32 bits source 1          (input)
           src2,          // 32 bits source 2          (input)
           ALU_control,   // 4 bits ALU control input  (input)
`ifdef BONUS
		 bonus_control, // 3 bits bonus control input(input)
`endif
           result,        // 32 bits result            (output)
           zero,          // 1 bit when the output is 0, zero must be set (output)
           cout,          // 1 bit carry out           (output)
           overflow       // 1 bit overflow            (output)
           );


input           rst_n;
input  [32-1:0] src1;
input  [32-1:0] src2;
input   [4-1:0] ALU_control;
`ifdef BONUS
input   [3-1:0] bonus_control;
`endif

output [32-1:0] result;
output          zero;
output          cout;
output          overflow;

reg    [32-1:0] result;
reg             zero;
reg             cout;
reg             overflow;

// function
reg A_invert, B_invert;
// operator for 1bit ALU
localparam OP_AND = 2'd0, OP_OR = 2'd1, OP_ADD = 2'd2, OP_LT = 2'd3;
reg [2-1:0] op;

wire [32-1:0] ret_from_1bit_alu;
wire [32-1:0] carry_chain;
wire [32-1:0] equals;
reg  equal;
wire less;

// now connect every 1bit ALUs
genvar i;
for (i = 0; i < 31; i = i+1) begin
    alu_top BB(
      .src1(src1[i]),
      .src2(src2[i]),
      .less(i == 0 ? less : 1'b0),
      .A_invert(A_invert),
      .B_invert(B_invert),
      .cin(carry_chain[i]),
      .operation(op),
      .result(ret_from_1bit_alu[i]),
      .cout(carry_chain[i + 1]),
      .equal_out(equals[i])
    );
end
// the highest bit ALU
wire cout_wire, overflow_wire;
alu_bottom BB(
  .src1(src1[31]),
  .src2(src2[31]),
  .equal(equal),
  .less(1'b0),
  .A_invert(A_invert),
  .B_invert(B_invert),
  .cin(carry_chain[31]),
  .operation(op),
`ifdef BONUS
  .comp(bonus_control),
`else
  .comp(3'b000), // there is only one compare function, set less than
`endif
  .result(ret_from_1bit_alu[31]),
  .cout(cout_wire),
  .overflow(overflow_wire),
  .cmp_result(less),
  .equal_out(equals[31])
);

always @(*) begin
    // It's a coincidence!
    op = ALU_control[1:0];
    A_invert = ALU_control[3];
    B_invert = ALU_control[2];
    result = ret_from_1bit_alu;
    zero = ~(
        (result[0] | result[1] | result[2] | result[3])
      | (result[4] | result[5] | result[6] | result[7])
      | (result[8] | result[9] | result[10] | result[11])
      | (result[12] | result[13] | result[14] | result[15])
      | (result[16] | result[17] | result[18] | result[19])
      | (result[20] | result[21] | result[22] | result[23])
      | (result[24] | result[25] | result[26] | result[27])
      | (result[28] | result[29] | result[30] | result[31])
    );
    // cout is only used in ADD and SUB
    cout = cout_wire & (op[1] & ~op[0]);
    overflow = overflow_wire;
    equal = (
        (equals[0] & equals[1] & equals[2] & equals[3])
      & (equals[4] & equals[5] & equals[6] & equals[7])
      & (equals[8] & equals[9] & equals[10] & equals[11])
      & (equals[12] & equals[13] & equals[14] & equals[15])
      & (equals[16] & equals[17] & equals[18] & equals[19])
      & (equals[20] & equals[21] & equals[22] & equals[23])
      & (equals[24] & equals[25] & equals[26] & equals[27])
      & (equals[28] & equals[29] & equals[30] & equals[31])
    );
end
assign carry_chain[0] = B_invert & ALU_control[1];

endmodule
