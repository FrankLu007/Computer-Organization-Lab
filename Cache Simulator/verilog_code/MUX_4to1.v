`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:06 05/12/2017 
// Design Name: 
// Module Name:    MUX_4to1 
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
module MUX_4to1(
    data_o,
    select_i,
	 data0_i,
    data1_i,
	 data2_i,
    data3_i
    );
parameter size = 0;

input [size-1:0] data0_i;
input [size-1:0] data1_i;
input [size-1:0] data2_i;
input [size-1:0] data3_i;
output [size-1:0] data_o;
input [1:0] select_i;

assign data_o = (select_i == 0) ? data0_i : ((select_i == 1) ? data1_i : ((select_i == 2) ? data2_i : data3_i) );

endmodule
