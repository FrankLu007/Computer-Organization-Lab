`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Student #1:
//     ID: 0416024
//     name: ³¯¬ýÂ×
// Student #2:
//     ID: 0516310
//     name: §f©Ó¿«
//
// Create Date:    21:30:22 03/23/2017
// Design Name:
// Module Name:    alu_bottom
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module alu_bottom(
               src1,       //1 bit source 1 (input)
               src2,       //1 bit source 2 (input)
               less,       //1 bit less     (input)
               equal,      //1 bit equal    (input)
               A_invert,   //1 bit A_invert (input)
               B_invert,   //1 bit B_invert (input)
               cin,        //1 bit carry in (input)
               operation,  //operation      (input)
               comp,       //comparison     (input)
               result,     //1 bit result   (output)
               cout,       //1 bit carry out(output)
               overflow,   //1 bit overflow (output)
               cmp_result, //1 bit compare result(output)
               equal_out,  //1 bit equal out(output)
               );

input         src1;
input         src2;
input         less;
input         equal;
input         A_invert;
input         B_invert;
input         cin;
input [2-1:0] operation;
input [3-1:0] comp;

output        result;
output        overflow;
output        cout;
output        cmp_result;
output        equal_out;

reg           result;
reg           cout, overflow;
wire real_A, real_B;
assign real_A = src1 ^ A_invert; // it's A_invert ? ~src1 : src1
assign real_B = src2 ^ B_invert; // it's B_invert ? ~src2 : src2

reg less_reg;

// calculate the compare function
compare COMP(
  .less(less_reg),
  .equal(equal),
  .comp(comp),
  .cmp_result(cmp_result)
);

always@( * )
begin
  case (operation)
    0: result = real_A & real_B;
    1: result = real_A | real_B;
    2: result = real_A ^ real_B ^ cin;
    3: result = less;
  endcase
  cout = real_A & real_B | (real_A | real_B) & cin;
  less_reg = ~(src1 ^ src2) & ~cin | (src1 & ~src2);
  // overflow only happens in add and sub operation
  // if add:
  //   real_A has the same sign bit of A.
  //   real_B has the same sign bit of B.
  //   when A and B have different sign bits, no overflow will happen.
  //   when both A and B are nonnegative, overflow will happen if the result sign bit is 1
  //   when both A and B are negative, overflow will happen if the result sign bit is 0
  // if sub:
  //   real_A has the same sign bit of A.
  //   the sign bit of real_B is different to that of B.
  //   when A and B have the same sign bit, no overflow will happen.
  //   when A is nonnegative and B is negative, overflow will happen if the result sign bit is 1
  //   becomes real_A positive and real_B positive
  //   when A is negative and B is nonnegative, overflow will happen if the result sign bit is 0
  //   becomes real_A negative and real_B negative
  // So we check the operation
  // then we check if real_A sign == real_B sign
  // then we check if the result sign bit != real_A sign bit
  overflow = ~(real_A ^ real_B) & (real_A ^ result) & (operation[1] & ~operation[0]);
end

assign equal_out = ~(src1 ^ src2); // it means src1 == src2

endmodule
