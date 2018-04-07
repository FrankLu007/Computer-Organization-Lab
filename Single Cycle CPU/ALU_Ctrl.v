//Subject:     CO project 3 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      0416024 ³¯¬ýÂ× 0516310 §f©Ó¿«
//----------------------------------------------
//Date:        2017/5/12 11:23
//----------------------------------------------
//Description:
//--------------------------------------------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o,
          Jr_o
          );

//I/O ports
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;
output             Jr_o;

//Internal Signals
reg        [4-1:0] ALUCtrl_o;
reg                Jr_o;

//Parameter


//Select exact operation

always @(*) begin
  ALUCtrl_o = 4'b0000; // default to AND if opcode is undefined
  Jr_o = 0;
  case (ALUOp_i)
    3'b000: ALUCtrl_o = 4'b0010; // lw, sw, addi, li: please add
    3'b001: ALUCtrl_o = 4'b0110; // beq, bne, bltz: please subtract
    3'b010: case (funct_i) // Rtype
      6'd32: ALUCtrl_o = 4'b0010; // add
      6'd34: ALUCtrl_o = 4'b0110; // subtract
      6'd36: ALUCtrl_o = 4'b0000; // AND
      6'd37: ALUCtrl_o = 4'b0001; // OR
      6'd42: ALUCtrl_o = 4'b0111; // set less than
      6'd3:  ALUCtrl_o = 4'b1000; // shift right arithmetic
      6'd7:  ALUCtrl_o = 4'b1001; // shift right arithmetic variable
      6'd24: ALUCtrl_o = 4'b1100; // multiply
      6'd8:  begin
        ALUCtrl_o = 4'b0000; // jr
        Jr_o = 1;
      end
    endcase
    3'b011: ALUCtrl_o = 4'b0001; // ori: please OR
    3'b100: ALUCtrl_o = 4'b0111; // sltiu: please set less than
    3'b101: ALUCtrl_o = 4'b0011; // ble: please set less than or equal
  endcase
end

endmodule
