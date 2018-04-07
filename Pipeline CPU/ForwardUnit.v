// Date:    2017/6/2 PM 9:54
// Writer:  0416024 ³¯¬ýÂ×

module ForwardUnit(
    rs_EX_i,
    rt_EX_i,
    rd_MEM_i,
    RegWrite_MEM_i,
    rd_WB_i,
    RegWrite_WB_i,
    Forward1_o,
    Forward2_o
  );

input  [4:0] rs_EX_i; // rs address from ID/EX stage
input  [4:0] rt_EX_i; // rt address from ID/EX stage
input  [4:0] rd_MEM_i; // register destination from EX/MEM stage
input        RegWrite_MEM_i; // will instruction in EX/MEM stage write register?
input  [4:0] rd_WB_i; // register destination from MEM/WB stage
input        RegWrite_WB_i; // will instruction in MEM/WB stage write register?
output [1:0] Forward1_o; // source to forward to rs
output [1:0] Forward2_o; // source to forward to rt

reg    [1:0] Forward1_o;
reg    [1:0] Forward2_o;

always @(*) begin
  // default to no forwarding
  Forward1_o = 2'b00;
  Forward2_o = 2'b00;
  // EX hazard
  if (RegWrite_MEM_i && rd_MEM_i != 0) begin
    if (rs_EX_i == rd_MEM_i)
      Forward1_o = 2'b10;
    if (rt_EX_i == rd_MEM_i)
      Forward2_o = 2'b10;
  end
  // MEM hazard
  if (RegWrite_WB_i && rd_WB_i != 0) begin
    if (!(RegWrite_MEM_i && rd_MEM_i != 0
          && rs_EX_i == rd_MEM_i) // also EX hazard
        && rs_EX_i == rd_WB_i)
      Forward1_o = 2'b01;
    if (!(RegWrite_MEM_i && rd_MEM_i != 0
          && rt_EX_i == rd_MEM_i) // also EX hazard
        && rt_EX_i == rd_WB_i)
      Forward2_o = 2'b01;
  end
end

endmodule
