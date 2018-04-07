`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:28:45 05/12/2017 
// Design Name: 
// Module Name:    Unsign_Extend 
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
module Unsign_Extend(
    input [15:0] data_i,
    output [31:0] data_o
    );

assign data_o[31 -: 16] = 0;
assign data_o[31:0] = data_i;

endmodule
