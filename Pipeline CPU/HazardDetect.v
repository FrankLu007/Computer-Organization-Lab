// Date:    2017/6/4 PM 10:02
// Writer:  0416024 ³¯¬ýÂ×

module HazardDetect (
  rs_ID_i,
  rt_ID_i,
  rt_EX_i,
  MemRead_EX_i,
  PCSrc_i,
  PCWrite_o,
  IFIDWrite_o,
  IDFlush_o,
  EXFlush_o,
  MEMFlush_o
);

input  [4:0] rs_ID_i; // rs address from IF/ID stage
input  [4:0] rt_ID_i; // rt address from IF/ID stage
input  [4:0] rt_EX_i; // rt address from ID/EX stage
input        MemRead_EX_i; // will instruction in ID/EX stage write memory?
input        PCSrc_i; // will instruction in EX/MEM stage take branch?
output       PCWrite_o; // 1 if PC will change in next cycle, 0 otherwise
output       IFIDWrite_o; // 1 if IF/ID pipeline register will change in next cycle
output       IDFlush_o; // 1 if IF/ID stage will be nop
output       EXFlush_o; // 1 if ID/EX stage will be nop
output       MEMFlush_o; // 1 if EX/MEM stage will be nop


reg          PCWrite_o;
reg          IFIDWrite_o;
reg          IDFlush_o;
reg          EXFlush_o;
reg          MEMFlush_o;

always @(*) begin
  PCWrite_o = 1;
  IFIDWrite_o = 1;
  IDFlush_o = 0;
  EXFlush_o = 0;
  MEMFlush_o = 0;
  // load-use hazard
  if (MemRead_EX_i && (
      rs_ID_i == rt_EX_i || rt_ID_i == rt_EX_i)) begin
    PCWrite_o = 0;
    IFIDWrite_o = 0;
    EXFlush_o = 1;
  end
  // branch hazard
  if (PCSrc_i) begin // branch taken
    IDFlush_o = 1;
    EXFlush_o = 1;
    MEMFlush_o = 1;
  end
end

endmodule
