//Subject:     CO project 3 - ALU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0416024 ³¯¬ýÂ× 0516310 §f©Ó¿«
//----------------------------------------------
//Date:       2017/5/12 11:21
//----------------------------------------------
//Description:
//--------------------------------------------------------------------------------

module ALU(
    src1_i,
	src2_i,
	shamt,
	ctrl_i,
	result_o,
	zero_o
	);

//I/O ports
input  signed [32-1:0]  src1_i;
input  signed [32-1:0]	 src2_i;
input [4:0] shamt;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;


//Internal signals
reg    [32-1:0]  result_o;
wire             zero_o;
wire   [4:0]     shift;
//Parameter

//Main function
assign zero_o = result_o == 0;

always @(*) begin
  result_o = 0;
  case (ctrl_i)
    4'b0000: result_o = src1_i & src2_i;
    4'b0001: result_o = src1_i | src2_i;
    4'b0010: result_o = src1_i + src2_i;
    4'b0011: result_o = (src1_i <= src2_i) ? 1 : 0;
    4'b0110: result_o = src1_i - src2_i;
    4'b0111: result_o = (src1_i < src2_i) ? 1 : 0;
    4'b1000: result_o = src2_i >>> shamt;
    4'b1001: result_o = src2_i >>> src1_i[4:0];
    4'b1100: result_o = src1_i * src2_i;
  endcase
end
endmodule
