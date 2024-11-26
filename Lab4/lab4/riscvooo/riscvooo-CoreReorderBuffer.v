//=========================================================================
// 5-Stage RISCV Scoreboard
//=========================================================================

`ifndef RISCV_CORE_REORDERBUFFER_V
`define RISCV_CORE_REORDERBUFFER_V

`define ROB_VALID_BIT     6:6 // Set: allocation, clear: commit
`define ROB_PENDING_BIT   5:5 // Set: allocation, clear: writeback
`define ROB_PHYSICAL_REG  4:0 // Set: allocation, clear: commit

module riscv_CoreReorderBuffer
(
  input         clk,
  input         reset,

  input         rob_alloc_req_val,
  output        rob_alloc_req_rdy,
  input  [ 4:0] rob_alloc_req_preg,
  
  output [ 3:0] rob_alloc_resp_slot,

  input         rob_fill_val,
  input  [ 3:0] rob_fill_slot,

  output        rob_commit_wen,
  output [ 3:0] rob_commit_slot,
  output [ 4:0] rob_commit_rf_waddr
);

  // wire rob_alloc_req_rdy   = 1'b1;
  // wire rob_alloc_resp_slot = 4'b0;
  // wire rob_commit_wen      = 1'b0;
  // wire rob_commit_rf_waddr = 1'b0;
  // wire rob_commit_slot     = 4'b0;

  wire rob_alloc_req_rdy   = 1'b1;

  reg [6:0] ROB [15:0];
  reg [3:0] tail;
  reg [3:0] head;
  reg [3:0] rob_alloc_resp_slot_reg;
  reg       rob_commit_wen_reg;
  reg [3:0] rob_commit_slot_reg;
  reg [4:0] rob_commit_rf_waddr_reg;

  wire [6:0] rob_temp0 = ROB[0];

  integer i;
  initial begin
    for (i = 0; i < 16; i = i + 1) begin
      ROB[i] = 7'b0;
    end
    tail = 4'd0;
    head = 4'd0;
    rob_alloc_resp_slot_reg = 4'b0;
    rob_commit_wen_reg = 0;
    rob_commit_slot_reg = 4'b0;
    rob_commit_rf_waddr_reg = 5'b0;
  end

  always @ (posedge clk) begin
    if (rob_alloc_req_val) begin
      tail <= tail + 1;
    end

    if (rob_fill_val) begin
      ROB[rob_fill_slot][`ROB_PENDING_BIT] = 0;
    end

    if (!ROB[head][`ROB_PENDING_BIT] && ROB[head][`ROB_VALID_BIT]) begin
      rob_commit_wen_reg        <= 1;
      rob_commit_slot_reg       <= head;
      rob_commit_rf_waddr_reg   <= ROB[head][`ROB_PHYSICAL_REG];
      ROB[head][`ROB_VALID_BIT] <= 0;
      head <= head + 1;
    end
    else begin
      rob_commit_wen_reg <= 0;
    end
  end

  always @ (*) begin
    if (rob_alloc_req_val) begin
      ROB[tail][`ROB_VALID_BIT]     = 1;
      ROB[tail][`ROB_PENDING_BIT]   = 1;
      ROB[tail][`ROB_PHYSICAL_REG]  = rob_alloc_req_preg;
      rob_alloc_resp_slot_reg       = tail;
    end
  end

  assign rob_alloc_resp_slot = rob_alloc_resp_slot_reg;
  assign rob_commit_wen      = rob_commit_wen_reg;
  assign rob_commit_slot     = rob_commit_slot_reg;
  assign rob_commit_rf_waddr = rob_commit_rf_waddr_reg;

  
endmodule

`endif

