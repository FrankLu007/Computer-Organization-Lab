`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Student #1:
//     ID: 0416024
//     name: ³¯¬ýÂ×
// Student #2:
//     ID: 0516310
//     name: §f©Ó¿«
//
// Create Date:    10:58:01 10/10/2011
// Design Name:
// Module Name:    alu_top
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

module alu_top(
               src1,       //1 bit source 1 (input)
               src2,       //1 bit source 2 (input)
               less,       //1 bit less     (input)
               A_invert,   //1 bit A_invert (input)
               B_invert,   //1 bit B_invert (input)
               cin,        //1 bit carry in (input)
               operation,  //operation      (input)
               result,     //1 bit result   (output)
               cout,       //1 bit carry out(output)
               equal_out,  //1 bit equal out(output)
               );

input         src1;
input         src2;
input         less;
input         A_invert;
input         B_invert;
input         cin;
input [2-1:0] operation;

output        result;
output        cout;
output        equal_out;

reg           result;

wire real_A, real_B;
assign real_A = src1 ^ A_invert; // it's A_invert ? ~src1 : src1
assign real_B = src2 ^ B_invert; // it's B_invert ? ~src2 : src2

always@( * )
begin
  case (operation)
    0: result = real_A & real_B;
    1: result = real_A | real_B;
    2: result = real_A ^ real_B ^ cin;
    3: result = less;
  endcase
end
assign cout = real_A & real_B | (real_A | real_B) & cin;
// src1 ^ src2 means src1 != src2
assign equal_out = ~(src1 ^ src2);

endmodule
