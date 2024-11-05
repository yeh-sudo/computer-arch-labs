//=========================================================================
// 7-Stage RISCV Control Unit
//=========================================================================

`ifndef RISCV_CORE_CTRL_V
`define RISCV_CORE_CTRL_V

`define RISCV_SB_PENDING   6:6
`define RISCV_SB_FUNC_UNIT 5:5
`define RISCV_SB_X0        4:4
`define RISCV_SB_X1        3:3
`define RISCV_SB_X2        2:2
`define RISCV_SB_X3        1:1
`define RISCV_SB_W         0:0
`define RISCV_SB_PIPELINE  4:0

`include "riscvssc-InstMsg.v"

module riscv_CoreCtrl
(
  input clk,
  input reset,

  // Instruction Memory Port
  output        imemreq0_val,
  input         imemreq0_rdy,
  input  [31:0] imemresp0_msg_data,
  input         imemresp0_val,

  // Instruction Memory Port
  output        imemreq1_val,
  input         imemreq1_rdy,
  input  [31:0] imemresp1_msg_data,
  input         imemresp1_val,

  // Data Memory Port

  output        dmemreq_msg_rw,
  output  [1:0] dmemreq_msg_len,
  output        dmemreq_val,
  input         dmemreq_rdy,
  input         dmemresp_val,

  // Controls Signals (ctrl->dpath)

  output  [1:0] pc_mux_sel_Phl,
  output  [3:0] steering_mux_sel_Dhl,
  output  [3:0] opA0_byp_mux_sel_Dhl,
  output  [1:0] opA0_mux_sel_Dhl,
  output  [3:0] opA1_byp_mux_sel_Dhl,
  output  [2:0] opA1_mux_sel_Dhl,
  output  [3:0] opB0_byp_mux_sel_Dhl,
  output  [1:0] opB0_mux_sel_Dhl,
  output  [3:0] opB1_byp_mux_sel_Dhl,
  output  [2:0] opB1_mux_sel_Dhl,
  output [31:0] instA_Dhl,
  output [31:0] instB_Dhl,
  output  [3:0] aluA_fn_X0hl,
  output  [3:0] aluB_fn_X0hl,
  output  [2:0] muldivreq_msg_fn_Dhl,
  output        muldivreq_val,
  input         muldivreq_rdy,
  input         muldivresp_val,
  output        muldivresp_rdy,
  output        muldiv_stall_mult1,
  output  [2:0] dmemresp_mux_sel_X1hl,
  output        dmemresp_queue_en_X1hl,
  output        dmemresp_queue_val_X1hl,
  output        muldiv_mux_sel_X3hl,
  output        execute_mux_sel_X3hl,
  output        memex_mux_sel_X1hl,
  output        rfA_wen_out_Whl,
  output  [4:0] rfA_waddr_Whl,
  output        rfB_wen_out_Whl,
  output  [4:0] rfB_waddr_Whl,
  output        stall_Fhl,
  output        stall_Dhl,
  output        stall_X0hl,
  output        stall_X1hl,
  output        stall_X2hl,
  output        stall_X3hl,
  output        stall_Whl,

  // Control Signals (dpath->ctrl)

  input         branch_cond_eq_X0hl,
  input         branch_cond_ne_X0hl,
  input         branch_cond_lt_X0hl,
  input         branch_cond_ltu_X0hl,
  input         branch_cond_ge_X0hl,
  input         branch_cond_geu_X0hl,
  input  [31:0] proc2csr_data_Whl,

  // CSR Status

  output [31:0] csr_status
);

  //----------------------------------------------------------------------
  // PC Stage: Instruction Memory Request
  //----------------------------------------------------------------------

  // PC Mux Select

  assign pc_mux_sel_Phl
    = brj_taken_X0hl    ? pm_b
    : brj_taken_Dhl     ? pc_mux_sel_Dhl
    :                     pm_p;

  // Only send a valid imem request if not stalled

  wire   imemreq_val_Phl = reset || !stall_Phl;
  assign imemreq0_val     = imemreq_val_Phl;
  assign imemreq1_val     = imemreq_val_Phl;

  // Dummy Squash Signal

  wire squash_Phl = 1'b0;

  // Stall in PC if F is stalled

  wire stall_Phl = stall_Fhl;

  // Next bubble bit

  wire bubble_next_Phl = ( squash_Phl || stall_Phl );

  //----------------------------------------------------------------------
  // F <- P
  //----------------------------------------------------------------------

  reg imemreq_val_Fhl;

  reg bubble_Fhl;

  always @ ( posedge clk ) begin
    // Only pipeline the bubble bit if the next stage is not stalled
    if ( reset ) begin
      imemreq_val_Fhl <= 1'b0;

      bubble_Fhl <= 1'b0;
    end
    else if( !stall_Fhl ) begin 
      imemreq_val_Fhl <= imemreq_val_Phl;

      bubble_Fhl <= bubble_next_Phl;
    end
    else begin 
      imemreq_val_Fhl <= imemreq_val_Phl;
    end
  end

  //----------------------------------------------------------------------
  // Fetch Stage: Instruction Memory Response
  //----------------------------------------------------------------------

  // Is the current stage valid?

  wire inst_val_Fhl = ( !bubble_Fhl && !squash_Fhl );

  // Squash instruction in F stage if branch taken for a valid
  // instruction or if there was an exception in X stage

  wire squash_Fhl
    = ( inst_val_Dhl && brj_taken_Dhl )
   || ( inst_val_X0hl && brj_taken_X0hl );

  // Stall in F if D is stalled

  assign stall_Fhl = stall_Dhl && !( steering_state == 2'd3 && brj_taken_Dhl );

  // Next bubble bit

  wire bubble_sel_Fhl  = ( squash_Fhl || stall_Fhl );
  wire bubble_next_Fhl = ( !bubble_sel_Fhl ) ? bubble_Fhl
                       : ( bubble_sel_Fhl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // Queue for instruction memory response
  //----------------------------------------------------------------------

  wire imemresp0_queue_en_Fhl = ( stall_Dhl && imemresp0_val );
  wire imemresp0_queue_val_next_Fhl
    = stall_Dhl && ( imemresp0_val || imemresp0_queue_val_Fhl );

  wire imemresp1_queue_en_Fhl = ( stall_Dhl && imemresp1_val );
  wire imemresp1_queue_val_next_Fhl
    = stall_Dhl && ( imemresp1_val || imemresp1_queue_val_Fhl );

  reg [31:0] imemresp0_queue_reg_Fhl;
  reg        imemresp0_queue_val_Fhl;

  reg [31:0] imemresp1_queue_reg_Fhl;
  reg        imemresp1_queue_val_Fhl;

  always @ ( posedge clk ) begin
    if ( imemresp0_queue_en_Fhl ) begin
      imemresp0_queue_reg_Fhl <= imemresp0_msg_data;
    end
    if ( imemresp1_queue_en_Fhl ) begin
      imemresp1_queue_reg_Fhl <= imemresp1_msg_data;
    end
    imemresp0_queue_val_Fhl <= imemresp0_queue_val_next_Fhl;
    imemresp1_queue_val_Fhl <= imemresp1_queue_val_next_Fhl;
  end

  //----------------------------------------------------------------------
  // Instruction memory queue mux
  //----------------------------------------------------------------------

  wire [31:0] imemresp0_queue_mux_out_Fhl
    = ( !imemresp0_queue_val_Fhl ) ? imemresp0_msg_data
    : ( imemresp0_queue_val_Fhl )  ? imemresp0_queue_reg_Fhl
    :                               32'bx;

  wire [31:0] imemresp1_queue_mux_out_Fhl
    = ( !imemresp1_queue_val_Fhl ) ? imemresp1_msg_data
    : ( imemresp1_queue_val_Fhl )  ? imemresp1_queue_reg_Fhl
    :                               32'bx;

  //----------------------------------------------------------------------
  // D <- F
  //----------------------------------------------------------------------

  wire [31:0]     inst_nop = 32'h00000013;
  reg [31:0]      ir0_Dhl;
  reg [31:0]      ir1_Dhl;
  reg [31:0]      irA_reg_Dhl;
  reg [31:0]      irB_reg_Dhl;
  reg [cs_sz-1:0] csA_reg;
  reg [cs_sz-1:0] csB_reg;
  reg             bubble_Dhl;
  reg [1:0]       next_inst;

  reg [31:0][6:0] SB;

  initial begin
    SB[0]  = 7'b0;
    SB[1]  = 7'b0;
    SB[2]  = 7'b0;
    SB[3]  = 7'b0;
    SB[4]  = 7'b0;
    SB[5]  = 7'b0;
    SB[6]  = 7'b0;
    SB[7]  = 7'b0;
    SB[8]  = 7'b0;
    SB[9]  = 7'b0;
    SB[10] = 7'b0;
    SB[11] = 7'b0;
    SB[12] = 7'b0;
    SB[13] = 7'b0;
    SB[14] = 7'b0;
    SB[15] = 7'b0;
    SB[16] = 7'b0;
    SB[17] = 7'b0;
    SB[18] = 7'b0;
    SB[19] = 7'b0;
    SB[20] = 7'b0;
    SB[21] = 7'b0;
    SB[22] = 7'b0;
    SB[23] = 7'b0;
    SB[24] = 7'b0;
    SB[25] = 7'b0;
    SB[26] = 7'b0;
    SB[27] = 7'b0;
    SB[28] = 7'b0;
    SB[29] = 7'b0;
    SB[30] = 7'b0;
    SB[31] = 7'b0;
  end

  // TODO: Finish score board

  wire squash_first_D_inst =
    (inst_val_Dhl && !stall_0_Dhl && stall_1_Dhl);

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_Dhl <= 1'b1;
      next_inst  <= 2'd0;
    end
    else if( !stall_Dhl ) begin
      ir0_Dhl     <= imemresp0_queue_mux_out_Fhl;
      ir1_Dhl     <= imemresp1_queue_mux_out_Fhl;
      bubble_Dhl  <= bubble_next_Fhl;
      next_inst   <= 2'd0;
    end
    else begin
      if ( !stall_X0hl && !stall_0_Dhl && !stall_1_Dhl ) begin
        if ( stall_B_state == 2'd1 ) begin
          next_inst <= 2'd1;
          ir0_Dhl   <= irB_reg_Dhl;
          ir1_Dhl   <= inst_nop;
        end
        else if (stall_B_state == 2'd2 ) begin
          next_inst <= 2'd2;
          ir0_Dhl <= irB_reg_Dhl;
          ir1_Dhl <= inst_nop;
        end
        else if (stall_B_state == 2'd3) begin
          next_inst <= 2'd3;
          ir0_Dhl <= irA_reg_Dhl;
          ir1_Dhl <= inst_nop;
        end
      end
    end
  end

  always @ (*) begin
    if ( next_inst == 2'd0 ) begin
      irA_reg_Dhl = ir0_Dhl;
      irB_reg_Dhl = ( brj_taken_Dhl ) ? inst_nop : ir1_Dhl;
      csA_reg     = csA;
      csB_reg     = ( brj_taken_Dhl ) ? cs_nop : csB;
    end
  end

  //----------------------------------------------------------------------
  // Decode Stage: Constants
  //----------------------------------------------------------------------

  // Generic Parameters

  localparam n = 1'd0;
  localparam y = 1'd1;

  // Register specifiers

  localparam rx = 5'bx;
  localparam r0 = 5'd0;

  // Branch Type

  localparam br_x    = 3'bx;
  localparam br_none = 3'd0;
  localparam br_beq  = 3'd1;
  localparam br_bne  = 3'd2;
  localparam br_blt  = 3'd3;
  localparam br_bltu = 3'd4;
  localparam br_bge  = 3'd5;
  localparam br_bgeu = 3'd6;

  // PC Mux Select

  localparam pm_x   = 2'bx;  // Don't care
  localparam pm_p   = 2'd0;  // Use pc+4
  localparam pm_b   = 2'd1;  // Use branch address
  localparam pm_j   = 2'd2;  // Use jump address
  localparam pm_r   = 2'd3;  // Use jump register

  // Operand 0 Bypass Mux Select

  localparam am_r0    = 4'd0; // Use rdata0
  localparam am_AX0_byp = 4'd1; // Bypass from X0
  localparam am_AX1_byp = 4'd2; // Bypass from X1
  localparam am_AX2_byp = 4'd3; // Bypass from X2
  localparam am_AX3_byp = 4'd4; // Bypass from X3
  localparam am_AW_byp = 4'd5; // Bypass from W
  localparam am_BX0_byp = 4'd6; // Bypass from X0
  localparam am_BX1_byp = 4'd7; // Bypass from X1
  localparam am_BX2_byp = 4'd8; // Bypass from X2
  localparam am_BX3_byp = 4'd9; // Bypass from X3
  localparam am_BW_byp = 4'd10; // Bypass from W

  // Operand 0 Mux Select

  localparam am_x     = 2'bx;
  localparam am_rdat  = 2'd0; // Use output of bypass mux for rs1
  localparam am_pc    = 2'd1; // Use current PC
  localparam am_pc4   = 2'd2; // Use PC + 4
  localparam am_0     = 2'd3; // Use constant 0

  // Operand 1 Bypass Mux Select

  localparam bm_r1    = 4'd0; // Use rdata1
  localparam bm_AX0_byp = 4'd1; // Bypass from X0
  localparam bm_AX1_byp = 4'd2; // Bypass from X1
  localparam bm_AX2_byp = 4'd3; // Bypass from X2
  localparam bm_AX3_byp = 4'd4; // Bypass from X3
  localparam bm_AW_byp = 4'd5; // Bypass from W
  localparam bm_BX0_byp = 4'd6; // Bypass from X0
  localparam bm_BX1_byp = 4'd7; // Bypass from X1
  localparam bm_BX2_byp = 4'd8; // Bypass from X2
  localparam bm_BX3_byp = 4'd9; // Bypass from X3
  localparam bm_BW_byp = 4'd10; // Bypass from W

  // Operand 1 Mux Select

  localparam bm_x      = 3'bx; // Don't care
  localparam bm_rdat   = 3'd0; // Use output of bypass mux for rs2
  localparam bm_shamt  = 3'd1; // Use shift amount
  localparam bm_imm_u  = 3'd2; // Use U-type immediate
  localparam bm_imm_sb = 3'd3; // Use SB-type immediate
  localparam bm_imm_i  = 3'd4; // Use I-type immediate
  localparam bm_imm_s  = 3'd5; // Use S-type immediate
  localparam bm_0      = 3'd6; // Use constant 0

  // ALU Function

  localparam alu_x    = 4'bx;
  localparam alu_add  = 4'd0;
  localparam alu_sub  = 4'd1;
  localparam alu_sll  = 4'd2;
  localparam alu_or   = 4'd3;
  localparam alu_lt   = 4'd4;
  localparam alu_ltu  = 4'd5;
  localparam alu_and  = 4'd6;
  localparam alu_xor  = 4'd7;
  localparam alu_nor  = 4'd8;
  localparam alu_srl  = 4'd9;
  localparam alu_sra  = 4'd10;

  // Muldiv Function

  localparam md_x    = 3'bx;
  localparam md_mul  = 3'd0;
  localparam md_div  = 3'd1;
  localparam md_divu = 3'd2;
  localparam md_rem  = 3'd3;
  localparam md_remu = 3'd4;

  // MulDiv Mux Select

  localparam mdm_x = 1'bx; // Don't Care
  localparam mdm_l = 1'd0; // Take lower half of 64-bit result, mul/div/divu
  localparam mdm_u = 1'd1; // Take upper half of 64-bit result, rem/remu

  // Execute Mux Select

  localparam em_x   = 1'bx; // Don't Care
  localparam em_alu = 1'd0; // Use ALU output
  localparam em_md  = 1'd1; // Use muldiv output

  // Memory Request Type

  localparam nr = 2'b0; // No request
  localparam ld = 2'd1; // Load
  localparam st = 2'd2; // Store

  // Subword Memop Length

  localparam ml_x  = 2'bx;
  localparam ml_w  = 2'd0;
  localparam ml_b  = 2'd1;
  localparam ml_h  = 2'd2;

  // Memory Response Mux Select

  localparam dmm_x  = 3'bx;
  localparam dmm_w  = 3'd0;
  localparam dmm_b  = 3'd1;
  localparam dmm_bu = 3'd2;
  localparam dmm_h  = 3'd3;
  localparam dmm_hu = 3'd4;

  // Writeback Mux 1

  localparam wm_x   = 1'bx; // Don't care
  localparam wm_alu = 1'd0; // Use ALU output
  localparam wm_mem = 1'd1; // Use data memory response

  //----------------------------------------------------------------------
  // Decode Stage: Logic
  //----------------------------------------------------------------------

  // Is the current stage valid?

  wire inst_val_Dhl = ( !bubble_Dhl && !squash_Dhl );

  wire   [4:0] inst0_rs1_Dhl;
  wire   [4:0] inst0_rs2_Dhl;
  wire   [4:0] inst0_rd_Dhl;

  riscv_InstMsgFromBits inst0_msg_from_bits
  (
    .msg      (ir0_Dhl),
    .opcode   (),
    .rs1      (inst0_rs1_Dhl),
    .rs2      (inst0_rs2_Dhl),
    .rd       (inst0_rd_Dhl),
    .funct3   (),
    .funct7   (),
    .shamt    (),
    .imm_i    (),
    .imm_s    (),
    .imm_sb   (),
    .imm_u    (),
    .imm_uj   ()
  );

  wire   [4:0] inst1_rs1_Dhl;
  wire   [4:0] inst1_rs2_Dhl;
  wire   [4:0] inst1_rd_Dhl;

  riscv_InstMsgFromBits inst1_msg_from_bits
  (
    .msg      (ir1_Dhl),
    .opcode   (),
    .rs1      (inst1_rs1_Dhl),
    .rs2      (inst1_rs2_Dhl),
    .rd       (inst1_rd_Dhl),
    .funct3   (),
    .funct7   (),
    .shamt    (),
    .imm_i    (),
    .imm_s    (),
    .imm_sb   (),
    .imm_u    (),
    .imm_uj   ()
  );

  // Parse instruction fields

  wire   [4:0] instA_rs1_Dhl;
  wire   [4:0] instA_rs2_Dhl;
  wire   [4:0] instA_rd_Dhl;

  riscv_InstMsgFromBits instA_msg_from_bits
  (
    .msg      (instA_Dhl),
    .opcode   (),
    .rs1      (instA_rs1_Dhl),
    .rs2      (instA_rs2_Dhl),
    .rd       (instA_rd_Dhl),
    .funct3   (),
    .funct7   (),
    .shamt    (),
    .imm_i    (),
    .imm_s    (),
    .imm_sb   (),
    .imm_u    (),
    .imm_uj   ()
  );

  wire   [4:0] instB_rs1_Dhl;
  wire   [4:0] instB_rs2_Dhl;
  wire   [4:0] instB_rd_Dhl;

  riscv_InstMsgFromBits instB_msg_from_bits
  (
    .msg      (instB_Dhl),
    .opcode   (),
    .rs1      (instB_rs1_Dhl),
    .rs2      (instB_rs2_Dhl),
    .rd       (instB_rd_Dhl),
    .funct3   (),
    .funct7   (),
    .shamt    (),
    .imm_i    (),
    .imm_s    (),
    .imm_sb   (),
    .imm_u    (),
    .imm_uj   ()
  );

  // Shorten register specifier name for table

  wire [4:0] rs10 = instA_rs1_Dhl;
  wire [4:0] rs20 = instA_rs2_Dhl;
  wire [4:0] rd0 = instA_rd_Dhl;

  wire [4:0] rs11 = instB_rs1_Dhl;
  wire [4:0] rs21 = instB_rs2_Dhl;
  wire [4:0] rd1 = instB_rd_Dhl;

  // Instruction Decode

  localparam cs_sz = 39;
  reg [cs_sz-1:0] cs0;
  reg [cs_sz-1:0] cs1;
  wire [cs_sz-1:0] cs_nop = 39'h4030XxXx40;

  always @ (*) begin

    cs0 = {cs_sz{1'bx}}; // Default to invalid instruction

    casez ( ir0_Dhl )

      //                                j     br       pc      op0      rs1 op1       rs2 alu       md       md md     ex      mem  mem   memresp wb      rf      csr
      //                            val taken type     muxsel  muxsel   en  muxsel    en  fn        fn       en muxsel muxsel  rq   len   muxsel  muxsel  wen wa  wen
      `RISCV_INST_MSG_LUI     :cs0={ y,  n,    br_none, pm_p,   am_0,    n,  bm_imm_u, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_AUIPC   :cs0={ y,  n,    br_none, pm_p,   am_pc,   n,  bm_imm_u, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };

      `RISCV_INST_MSG_ADDI    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_ORI     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_or,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SLTI    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_lt,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SLTIU   :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_ltu,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_XORI    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_xor,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_ANDI    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_and,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SLLI    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_sll,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SRLI    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_srl,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SRAI    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_sra,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };

      `RISCV_INST_MSG_ADD     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SUB     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SLL     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sll,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SLT     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_lt,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SLTU    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_ltu,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_XOR     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SRL     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_srl,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_SRA     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sra,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_OR      :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_or,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_AND     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_and,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };

      `RISCV_INST_MSG_LW      :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_w, dmm_w,  wm_mem, y,  rd0, n   };
      `RISCV_INST_MSG_LB      :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_b, dmm_b,  wm_mem, y,  rd0, n   };
      `RISCV_INST_MSG_LH      :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_h, dmm_h,  wm_mem, y,  rd0, n   };
      `RISCV_INST_MSG_LBU     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_b, dmm_bu, wm_mem, y,  rd0, n   };
      `RISCV_INST_MSG_LHU     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_h, dmm_hu, wm_mem, y,  rd0, n   };
      `RISCV_INST_MSG_SW      :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_x,   st,  ml_w, dmm_w,  wm_mem, n,  rx, n   };
      `RISCV_INST_MSG_SB      :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_x,   st,  ml_b, dmm_b,  wm_mem, n,  rx, n   };
      `RISCV_INST_MSG_SH      :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_x,   st,  ml_h, dmm_h,  wm_mem, n,  rx, n   };

      `RISCV_INST_MSG_JAL     :cs0={ y,  y,    br_none, pm_j,   am_pc4,  n,  bm_0,     n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_JALR    :cs0={ y,  y,    br_none, pm_r,   am_pc4,  y,  bm_0,     n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };

      `RISCV_INST_MSG_BNE     :cs0={ y,  n,    br_bne,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BEQ     :cs0={ y,  n,    br_beq,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BLT     :cs0={ y,  n,    br_blt,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BGE     :cs0={ y,  n,    br_bge,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BLTU    :cs0={ y,  n,    br_bltu, pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BGEU    :cs0={ y,  n,    br_bgeu, pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };

      `RISCV_INST_MSG_MUL     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_mul,  y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_DIV     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_div,  y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_REM     :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_rem,  y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_DIVU    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_divu, y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };
      `RISCV_INST_MSG_REMU    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_remu, y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd0, n   };

      `RISCV_INST_MSG_CSRW    :cs0={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_0,     y,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, n,  rx, y   };

    endcase

  end

  always @ (*) begin

    cs1 = {cs_sz{1'bx}}; // Default to invalid instruction

    casez ( ir1_Dhl )

      //                                j     br       pc      op0      rs1 op1       rs2 alu       md       md md     ex      mem  mem   memresp wb      rf      csr
      //                            val taken type     muxsel  muxsel   en  muxsel    en  fn        fn       en muxsel muxsel  rq   len   muxsel  muxsel  wen wa  wen
      `RISCV_INST_MSG_LUI     :cs1={ y,  n,    br_none, pm_p,   am_0,    n,  bm_imm_u, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_AUIPC   :cs1={ y,  n,    br_none, pm_p,   am_pc,   n,  bm_imm_u, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };

      `RISCV_INST_MSG_ADDI    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_ORI     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_or,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SLTI    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_lt,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SLTIU   :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_ltu,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_XORI    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_xor,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_ANDI    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_and,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SLLI    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_sll,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SRLI    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_srl,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SRAI    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_sra,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };

      `RISCV_INST_MSG_ADD     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SUB     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SLL     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sll,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SLT     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_lt,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SLTU    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_ltu,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_XOR     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SRL     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_srl,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_SRA     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_sra,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_OR      :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_or,   md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_AND     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_and,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };

      `RISCV_INST_MSG_LW      :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_w, dmm_w,  wm_mem, y,  rd1, n   };
      `RISCV_INST_MSG_LB      :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_b, dmm_b,  wm_mem, y,  rd1, n   };
      `RISCV_INST_MSG_LH      :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_h, dmm_h,  wm_mem, y,  rd1, n   };
      `RISCV_INST_MSG_LBU     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_b, dmm_bu, wm_mem, y,  rd1, n   };
      `RISCV_INST_MSG_LHU     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_i, n,  alu_add,  md_x,    n, mdm_x, em_x,   ld,  ml_h, dmm_hu, wm_mem, y,  rd1, n   };
      `RISCV_INST_MSG_SW      :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_x,   st,  ml_w, dmm_w,  wm_mem, n,  rx, n   };
      `RISCV_INST_MSG_SB      :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_x,   st,  ml_b, dmm_b,  wm_mem, n,  rx, n   };
      `RISCV_INST_MSG_SH      :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_imm_s, y,  alu_add,  md_x,    n, mdm_x, em_x,   st,  ml_h, dmm_h,  wm_mem, n,  rx, n   };

      `RISCV_INST_MSG_JAL     :cs1={ y,  y,    br_none, pm_j,   am_pc4,  n,  bm_0,     n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_JALR    :cs1={ y,  y,    br_none, pm_r,   am_pc4,  y,  bm_0,     n,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };

      `RISCV_INST_MSG_BNE     :cs1={ y,  n,    br_bne,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BEQ     :cs1={ y,  n,    br_beq,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_xor,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BLT     :cs1={ y,  n,    br_blt,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BGE     :cs1={ y,  n,    br_bge,  pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BLTU    :cs1={ y,  n,    br_bltu, pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };
      `RISCV_INST_MSG_BGEU    :cs1={ y,  n,    br_bgeu, pm_b,   am_rdat, y,  bm_rdat,  y,  alu_sub,  md_x,    n, mdm_x, em_x,   nr,  ml_x, dmm_x,  wm_x,   n,  rx, n   };

      `RISCV_INST_MSG_MUL     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_mul,  y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_DIV     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_div,  y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_REM     :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_rem,  y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_DIVU    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_divu, y, mdm_l, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };
      `RISCV_INST_MSG_REMU    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_rdat,  y,  alu_x,    md_remu, y, mdm_u, em_md,  nr,  ml_x, dmm_x,  wm_alu, y,  rd1, n   };

      `RISCV_INST_MSG_CSRW    :cs1={ y,  n,    br_none, pm_p,   am_rdat, y,  bm_0,     y,  alu_add,  md_x,    n, mdm_x, em_alu, nr,  ml_x, dmm_x,  wm_alu, n,  rx, y   };

    endcase

  end

  /*
  instA_sel:
    0. stall_B_state == 2'd0 && (steering_state == 2'd0 || steering_state == 2'd2) -> instA = ir0_Dhl, csA = cs0
    1. stall_B_state == 2'd0 && steering_state == 2'd1 -> instA = ir1_Dhl, csA = cs1
    2. stall_B_state == 2'd1 -> instA = ir0_Dhl, csA = cs0
    3. stall_B_state == 2'd2 -> instA = ir0_Dhl, csA = cs0
    4. stall_B_state == 2'd3 -> instA = ir1_Dhl, csA = cs1
    5. stall_B_state == 2'd1 next round -> instA = irB_reg_Dhl, csA = csB_reg
    6. stall_B_state == 2'd2 next round -> instA = irB_reg_Dhl, csA = csB_reg
    7. stall_B_state == 2'd3 next round -> instA = irA_reg_Dhl, csA = csA_reg

  instB_sel:
    0. stall_B_state == 2'd0 && (steering_state == 2'd0 || steering_state) == 2'd0 -> instB = ir1_Dhl, csB = cs1
    1. stall_B_state == 2'd0 && steering_state == 2'd1 -> instB = ir0_Dhl, csB = cs0
    2. stall_B_state == 2'd1 -> instB = inst_nop, csB = cs_nop
    3. stall_B_state == 2'd2 -> instB = inst_nop, csB = cs_nop
    4. stall_B_state == 2'd3 -> instB = inst_nop, csB = cs_nop
    5. stall_B_state == 2'd1 next round -> instB = inst_nop, csB = cs_nop
    6. stall_B_state == 2'd2 next round -> instB = inst_nop, csB = cs_nop
    7. stall_B_state == 2'd3 next round -> instB = inst_nop, csB = cs_nop
  */

  wire [3:0] inst_sel = ( stall_B_state == 2'd0 && next_inst == 2'd0 && ( steering_state == 2'd0 || steering_state == 2'd2 ) ) ? 4'd0
                      : ( stall_B_state == 2'd0 && next_inst == 2'd0 && ( steering_state == 2'd1 ))                            ? 4'd1
                      : ( stall_B_state == 2'd1 && next_inst == 2'd0 )                                                         ? 4'd2
                      : ( stall_B_state == 2'd2 && next_inst == 2'd0 )                                                         ? 4'd3
                      : ( stall_B_state == 2'd3 && next_inst == 2'd0 )                                                         ? 4'd4
                      : ( next_inst == 2'd1 )                                                                                  ? 4'd5
                      : ( next_inst == 2'd2 )                                                                                  ? 4'd6
                      : ( next_inst == 2'd3 )                                                                                  ? 4'd7
                      :                                                                                                          4'd0;

  // Steering Logic

  wire is_inst0_ld_st = ( cs0[`RISCV_INST_MSG_MEM_REQ] == ld || cs0[`RISCV_INST_MSG_MEM_REQ] == st );
  wire is_inst1_ld_st = ( cs1[`RISCV_INST_MSG_MEM_REQ] == ld || cs1[`RISCV_INST_MSG_MEM_REQ] == st );

  wire is_inst0_muldiv = cs0[`RISCV_INST_MSG_MULDIV_EN];
  wire is_inst1_muldiv = cs1[`RISCV_INST_MSG_MULDIV_EN];

  wire is_inst0_j = cs0[`RISCV_INST_MSG_J_EN];
  wire is_inst1_j = cs1[`RISCV_INST_MSG_J_EN];

  wire is_inst0_br = ( cs0[`RISCV_INST_MSG_BR_SEL] != br_none );
  wire is_inst1_br = ( cs1[`RISCV_INST_MSG_BR_SEL] != br_none );

  wire is_inst0_rs1_en = cs0[`RISCV_INST_MSG_RS1_EN];
  wire is_inst1_rs1_en = cs1[`RISCV_INST_MSG_RS1_EN];

  wire is_inst0_ALU = inst_val_Dhl
                   && ( !is_inst0_j )
                   && ( !is_inst0_br )
                   && ( !is_inst0_ld_st )
                   && ( !is_inst0_muldiv )
                   && ( is_inst0_rs1_en )
                   && ( !cs0[`RISCV_INST_MSG_CSR_WEN] );


  wire is_inst1_ALU = inst_val_Dhl
                   && ( !is_inst1_j )
                   && ( !is_inst1_br )
                   && ( !is_inst1_ld_st )
                   && ( !is_inst1_muldiv )
                   && ( is_inst1_rs1_en )
                   && ( !cs1[`RISCV_INST_MSG_CSR_WEN] );

  wire [1:0] steering_state = inst_val_Dhl && (is_inst0_ALU && is_inst1_ALU)   ? 2'd0
                            : inst_val_Dhl && (is_inst0_ALU && !is_inst1_ALU)  ? 2'd1
                            : inst_val_Dhl && (!is_inst0_ALU && is_inst1_ALU)  ? 2'd2
                            : inst_val_Dhl && (!is_inst0_ALU && !is_inst1_ALU) ? 2'd3
                            :                                                    2'd0;


  assign instA_Dhl = ( inst_sel == 4'd0 ) ? ir0_Dhl
                   : ( inst_sel == 4'd1 ) ? ir1_Dhl
                   : ( inst_sel == 4'd2 ) ? ir0_Dhl
                   : ( inst_sel == 4'd3 ) ? ir0_Dhl
                   : ( inst_sel == 4'd4 ) ? ir1_Dhl
                   : ( inst_sel == 4'd5 ) ? irB_reg_Dhl
                   : ( inst_sel == 4'd6 ) ? irB_reg_Dhl
                   : ( inst_sel == 4'd7 ) ? irA_reg_Dhl
                   :                        ir0_Dhl;

  wire [cs_sz-1:0] csA = ( inst_sel == 4'd0 ) ? cs0
                       : ( inst_sel == 4'd1 ) ? cs1
                       : ( inst_sel == 4'd2 ) ? cs0
                       : ( inst_sel == 4'd3 ) ? cs0
                       : ( inst_sel == 4'd4 ) ? cs1
                       : ( inst_sel == 4'd5 ) ? cs0
                       : ( inst_sel == 4'd6 ) ? cs0
                       : ( inst_sel == 4'd7 ) ? cs0
                       :                        cs0;

  wire [31:0] instB = ( inst_sel == 4'd0 ) ? ir1_Dhl
                    : ( inst_sel == 4'd1 ) ? ir0_Dhl
                    : ( inst_sel == 4'd2 ) ? inst_nop
                    : ( inst_sel == 4'd3 ) ? inst_nop
                    : ( inst_sel == 4'd4 ) ? inst_nop
                    : ( inst_sel == 4'd5 ) ? inst_nop
                    : ( inst_sel == 4'd6 ) ? inst_nop
                    : ( inst_sel == 4'd7 ) ? inst_nop
                    :                        ir1_Dhl;

  assign instB_Dhl = ( steering_state == 2'd2 && brj_taken_Dhl ) ? inst_nop : instB;

  wire [cs_sz-1:0] csB_mux_out = ( inst_sel == 4'd0 ) ? cs1
                               : ( inst_sel == 4'd1 ) ? cs0
                               : ( inst_sel == 4'd2 ) ? cs_nop
                               : ( inst_sel == 4'd3 ) ? cs_nop
                               : ( inst_sel == 4'd4 ) ? cs_nop
                               : ( inst_sel == 4'd5 ) ? cs_nop
                               : ( inst_sel == 4'd6 ) ? cs_nop
                               : ( inst_sel == 4'd7 ) ? cs_nop
                               :                        cs1;

  wire [cs_sz-1:0] csB = ( steering_state == 2'd2 && brj_taken_Dhl ) ? cs_nop : csB_mux_out;
  
  assign steering_mux_sel_Dhl = inst_sel;

  // Jump and Branch Controls

  wire       brj_taken_Dhl = ( inst_val_Dhl && csA[`RISCV_INST_MSG_J_EN] );
  wire [2:0] br_sel_Dhl    = csA[`RISCV_INST_MSG_BR_SEL];

  // PC Mux Select

  wire [1:0] pc_mux_sel_Dhl = csA[`RISCV_INST_MSG_PC_SEL];

  // Operand Bypassing Logic

  wire [4:0] rs10_addr_Dhl  = rs10;
  wire [4:0] rs20_addr_Dhl  = rs20;

  wire [4:0] rs11_addr_Dhl  = rs11;
  wire [4:0] rs21_addr_Dhl  = rs21;

  wire       rs10_en_Dhl    = csA[`RISCV_INST_MSG_RS1_EN];
  wire       rs20_en_Dhl    = csA[`RISCV_INST_MSG_RS2_EN];

  wire       rs11_en_Dhl    = csB[`RISCV_INST_MSG_RS1_EN];
  wire       rs21_en_Dhl    = csB[`RISCV_INST_MSG_RS2_EN];

  // For Part 2 and Optionaly Part 1, replace the following control logic with a scoreboard

  // pipeline A rs1 ------------------------------------------------
  wire       rs10_AX0_byp_Dhl = rs10_en_Dhl
                         && rfA_wen_X0hl
                         && (rs10_addr_Dhl == rfA_waddr_X0hl)
                         && !(rfA_waddr_X0hl == 5'd0)
                         && inst_val_X0hl && !is_muldiv_X0hl;

  wire       rs10_AX1_byp_Dhl = rs10_en_Dhl
                         && rfA_wen_X1hl
                         && (rs10_addr_Dhl == rfA_waddr_X1hl)
                         && !(rfA_waddr_X1hl == 5'd0)
                         && inst_val_X1hl && !is_muldiv_X1hl;

  wire       rs10_AX2_byp_Dhl = rs10_en_Dhl
                         && rfA_wen_X2hl
                         && (rs10_addr_Dhl == rfA_waddr_X2hl)
                         && !(rfA_waddr_X2hl == 5'd0)
                         && inst_val_X2hl && !is_muldiv_X2hl;

  wire       rs10_AX3_byp_Dhl = rs10_en_Dhl
                         && rfA_wen_X3hl
                         && (rs10_addr_Dhl == rfA_waddr_X3hl)
                         && !(rfA_waddr_X3hl == 5'd0)
                         && inst_val_X3hl && !is_muldiv_X3hl;

  wire       rs10_AW_byp_Dhl = rs10_en_Dhl
                         && rfA_wen_Whl
                         && (rs10_addr_Dhl == rfA_waddr_Whl)
                         && !(rfA_waddr_Whl == 5'd0)
                         && inst_val_Whl;

  wire       rs10_BX0_byp_Dhl = rs10_en_Dhl
                         && rfB_wen_X0hl
                         && (rs10_addr_Dhl == rfB_waddr_X0hl)
                         && !(rfB_waddr_X0hl == 5'd0)
                         && inst_val_X0hl;

  wire       rs10_BX1_byp_Dhl = rs10_en_Dhl
                         && rfB_wen_X1hl
                         && (rs10_addr_Dhl == rfB_waddr_X1hl)
                         && !(rfB_waddr_X1hl == 5'd0)
                         && inst_val_X1hl;

  wire       rs10_BX2_byp_Dhl = rs10_en_Dhl
                         && rfB_wen_X2hl
                         && (rs10_addr_Dhl == rfB_waddr_X2hl)
                         && !(rfB_waddr_X2hl == 5'd0)
                         && inst_val_X2hl;

  wire       rs10_BX3_byp_Dhl = rs10_en_Dhl
                         && rfB_wen_X3hl
                         && (rs10_addr_Dhl == rfB_waddr_X3hl)
                         && !(rfB_waddr_X3hl == 5'd0)
                         && inst_val_X3hl;

  wire       rs10_BW_byp_Dhl = rs10_en_Dhl
                         && rfB_wen_Whl
                         && (rs10_addr_Dhl == rfB_waddr_Whl)
                         && !(rfB_waddr_Whl == 5'd0)
                         && inst_val_Whl;
  // ---------------------------------------------------------------

  // pipeline A rs2 ------------------------------------------------
  wire       rs20_AX0_byp_Dhl = rs20_en_Dhl
                         && rfA_wen_X0hl
                         && (rs20_addr_Dhl == rfA_waddr_X0hl)
                         && !(rfA_waddr_X0hl == 5'd0)
                         && inst_val_X0hl && !is_muldiv_X0hl;

  wire       rs20_AX1_byp_Dhl = rs20_en_Dhl
                         && rfA_wen_X1hl
                         && (rs20_addr_Dhl == rfA_waddr_X1hl)
                         && !(rfA_waddr_X1hl == 5'd0)
                         && inst_val_X1hl && !is_muldiv_X1hl;

  wire       rs20_AX2_byp_Dhl = rs20_en_Dhl
                         && rfA_wen_X2hl
                         && (rs20_addr_Dhl == rfA_waddr_X2hl)
                         && !(rfA_waddr_X2hl == 5'd0)
                         && inst_val_X2hl && !is_muldiv_X2hl;

  wire       rs20_AX3_byp_Dhl = rs20_en_Dhl
                         && rfA_wen_X3hl
                         && (rs20_addr_Dhl == rfA_waddr_X3hl)
                         && !(rfA_waddr_X3hl == 5'd0)
                         && inst_val_X3hl && !is_muldiv_X3hl;

  wire       rs20_AW_byp_Dhl = rs20_en_Dhl
                         && rfA_wen_Whl
                         && (rs20_addr_Dhl == rfA_waddr_Whl)
                         && !(rfA_waddr_Whl == 5'd0)
                         && inst_val_Whl;

  wire       rs20_BX0_byp_Dhl = rs20_en_Dhl
                         && rfB_wen_X0hl
                         && (rs20_addr_Dhl == rfB_waddr_X0hl)
                         && !(rfB_waddr_X0hl == 5'd0)
                         && inst_val_X0hl;

  wire       rs20_BX1_byp_Dhl = rs20_en_Dhl
                         && rfB_wen_X1hl
                         && (rs20_addr_Dhl == rfB_waddr_X1hl)
                         && !(rfB_waddr_X1hl == 5'd0)
                         && inst_val_X1hl;

  wire       rs20_BX2_byp_Dhl = rs20_en_Dhl
                         && rfB_wen_X2hl
                         && (rs20_addr_Dhl == rfB_waddr_X2hl)
                         && !(rfB_waddr_X2hl == 5'd0)
                         && inst_val_X2hl;

  wire       rs20_BX3_byp_Dhl = rs20_en_Dhl
                         && rfB_wen_X3hl
                         && (rs20_addr_Dhl == rfB_waddr_X3hl)
                         && !(rfB_waddr_X3hl == 5'd0)
                         && inst_val_X3hl;

  wire       rs20_BW_byp_Dhl = rs20_en_Dhl
                         && rfB_wen_Whl
                         && (rs20_addr_Dhl == rfB_waddr_Whl)
                         && !(rfB_waddr_Whl == 5'd0)
                         && inst_val_Whl;
  // ---------------------------------------------------------------

  // pipeline B rs1 ------------------------------------------------
  wire       rs11_AX0_byp_Dhl = rs11_en_Dhl
                         && rfA_wen_X0hl
                         && (rs11_addr_Dhl == rfA_waddr_X0hl)
                         && !(rfA_waddr_X0hl == 5'd0)
                         && inst_val_X0hl && !is_muldiv_X0hl;

  wire       rs11_AX1_byp_Dhl = rs11_en_Dhl
                         && rfA_wen_X1hl
                         && (rs11_addr_Dhl == rfA_waddr_X1hl)
                         && !(rfA_waddr_X1hl == 5'd0)
                         && inst_val_X1hl && !is_muldiv_X1hl;

  wire       rs11_AX2_byp_Dhl = rs11_en_Dhl
                         && rfA_wen_X2hl
                         && (rs11_addr_Dhl == rfA_waddr_X2hl)
                         && !(rfA_waddr_X2hl == 5'd0)
                         && inst_val_X2hl && !is_muldiv_X2hl;

  wire       rs11_AX3_byp_Dhl = rs11_en_Dhl
                         && rfA_wen_X3hl
                         && (rs11_addr_Dhl == rfA_waddr_X3hl)
                         && !(rfA_waddr_X3hl == 5'd0)
                         && inst_val_X3hl && !is_muldiv_X3hl;

  wire       rs11_AW_byp_Dhl = rs11_en_Dhl
                         && rfA_wen_Whl
                         && (rs11_addr_Dhl == rfA_waddr_Whl)
                         && !(rfA_waddr_Whl == 5'd0)
                         && inst_val_Whl;
  
  wire       rs11_BX0_byp_Dhl = rs11_en_Dhl
                         && rfB_wen_X0hl
                         && (rs11_addr_Dhl == rfB_waddr_X0hl)
                         && !(rfB_waddr_X0hl == 5'd0)
                         && inst_val_X0hl;

  wire       rs11_BX1_byp_Dhl = rs11_en_Dhl
                         && rfB_wen_X1hl
                         && (rs11_addr_Dhl == rfB_waddr_X1hl)
                         && !(rfB_waddr_X1hl == 5'd0)
                         && inst_val_X1hl;

  wire       rs11_BX2_byp_Dhl = rs11_en_Dhl
                         && rfB_wen_X2hl
                         && (rs11_addr_Dhl == rfB_waddr_X2hl)
                         && !(rfB_waddr_X2hl == 5'd0)
                         && inst_val_X2hl;

  wire       rs11_BX3_byp_Dhl = rs11_en_Dhl
                         && rfB_wen_X3hl
                         && (rs11_addr_Dhl == rfB_waddr_X3hl)
                         && !(rfB_waddr_X3hl == 5'd0)
                         && inst_val_X3hl;

  wire       rs11_BW_byp_Dhl = rs11_en_Dhl
                         && rfB_wen_Whl
                         && (rs11_addr_Dhl == rfB_waddr_Whl)
                         && !(rfB_waddr_Whl == 5'd0)
                         && inst_val_Whl;
  // ---------------------------------------------------------------

  // pipeline B rs2 ------------------------------------------------
  wire       rs21_AX0_byp_Dhl = rs21_en_Dhl
                         && rfA_wen_X0hl
                         && (rs21_addr_Dhl == rfA_waddr_X0hl)
                         && !(rfA_waddr_X0hl == 5'd0)
                         && inst_val_X0hl && !is_muldiv_X0hl;

  wire       rs21_AX1_byp_Dhl = rs21_en_Dhl
                         && rfA_wen_X1hl
                         && (rs21_addr_Dhl == rfA_waddr_X1hl)
                         && !(rfA_waddr_X1hl == 5'd0)
                         && inst_val_X1hl && !is_muldiv_X1hl;

  wire       rs21_AX2_byp_Dhl = rs21_en_Dhl
                         && rfA_wen_X2hl
                         && (rs21_addr_Dhl == rfA_waddr_X2hl)
                         && !(rfA_waddr_X2hl == 5'd0)
                         && inst_val_X2hl && !is_muldiv_X2hl;

  wire       rs21_AX3_byp_Dhl = rs21_en_Dhl
                         && rfA_wen_X3hl
                         && (rs21_addr_Dhl == rfA_waddr_X3hl)
                         && !(rfA_waddr_X3hl == 5'd0)
                         && inst_val_X3hl && !is_muldiv_X3hl;

  wire       rs21_AW_byp_Dhl = rs21_en_Dhl
                         && rfA_wen_Whl
                         && (rs21_addr_Dhl == rfA_waddr_Whl)
                         && !(rfA_waddr_Whl == 5'd0)
                         && inst_val_Whl;

  wire       rs21_BX0_byp_Dhl = rs21_en_Dhl
                         && rfB_wen_X0hl
                         && (rs21_addr_Dhl == rfB_waddr_X0hl)
                         && !(rfB_waddr_X0hl == 5'd0)
                         && inst_val_X0hl;

  wire       rs21_BX1_byp_Dhl = rs21_en_Dhl
                         && rfB_wen_X1hl
                         && (rs21_addr_Dhl == rfB_waddr_X1hl)
                         && !(rfB_waddr_X1hl == 5'd0)
                         && inst_val_X1hl;

  wire       rs21_BX2_byp_Dhl = rs21_en_Dhl
                         && rfB_wen_X2hl
                         && (rs21_addr_Dhl == rfB_waddr_X2hl)
                         && !(rfB_waddr_X2hl == 5'd0)
                         && inst_val_X2hl;

  wire       rs21_BX3_byp_Dhl = rs21_en_Dhl
                         && rfB_wen_X3hl
                         && (rs21_addr_Dhl == rfB_waddr_X3hl)
                         && !(rfB_waddr_X3hl == 5'd0)
                         && inst_val_X3hl;

  wire       rs21_BW_byp_Dhl = rs21_en_Dhl
                         && rfB_wen_Whl
                         && (rs21_addr_Dhl == rfB_waddr_Whl)
                         && !(rfB_waddr_Whl == 5'd0)
                         && inst_val_Whl;
  // ---------------------------------------------------------------


  // Operand Bypass Mux Select

  assign opA0_byp_mux_sel_Dhl
    = (rs10_AX0_byp_Dhl) ? am_AX0_byp
    : (rs10_BX0_byp_Dhl) ? am_BX0_byp
    : (rs10_AX1_byp_Dhl) ? am_AX1_byp
    : (rs10_BX1_byp_Dhl) ? am_BX1_byp
    : (rs10_AX2_byp_Dhl) ? am_AX2_byp
    : (rs10_BX2_byp_Dhl) ? am_BX2_byp
    : (rs10_AX3_byp_Dhl) ? am_AX3_byp
    : (rs10_BX3_byp_Dhl) ? am_BX3_byp
    : (rs10_AW_byp_Dhl)  ? am_AW_byp
    : (rs10_BW_byp_Dhl) ? am_BW_byp
    :                    am_r0;

  assign opA1_byp_mux_sel_Dhl
    = (rs20_AX0_byp_Dhl) ? bm_AX0_byp
    : (rs20_BX0_byp_Dhl) ? bm_BX0_byp
    : (rs20_AX1_byp_Dhl) ? bm_AX1_byp
    : (rs20_BX1_byp_Dhl) ? bm_BX1_byp
    : (rs20_AX2_byp_Dhl) ? bm_AX2_byp
    : (rs20_BX2_byp_Dhl) ? bm_BX2_byp
    : (rs20_AX3_byp_Dhl) ? bm_AX3_byp
    : (rs20_BX3_byp_Dhl) ? bm_BX3_byp
    : (rs20_AW_byp_Dhl)  ? bm_AW_byp
    : (rs20_BW_byp_Dhl)  ? bm_BW_byp
    :                     bm_r1;

  assign opB0_byp_mux_sel_Dhl
    = (rs11_AX0_byp_Dhl) ? am_AX0_byp
    : (rs11_BX0_byp_Dhl) ? am_BX0_byp
    : (rs11_AX1_byp_Dhl) ? am_AX1_byp
    : (rs11_BX1_byp_Dhl) ? am_BX1_byp
    : (rs11_AX2_byp_Dhl) ? am_AX2_byp
    : (rs11_BX2_byp_Dhl) ? am_BX2_byp
    : (rs11_AX3_byp_Dhl) ? am_AX3_byp
    : (rs11_BX3_byp_Dhl) ? am_BX3_byp
    : (rs11_AW_byp_Dhl) ? am_AW_byp
    : (rs11_BW_byp_Dhl) ? am_BW_byp
    :                    am_r0;

  assign opB1_byp_mux_sel_Dhl
    = (rs21_AX0_byp_Dhl) ? bm_AX0_byp
    : (rs21_BX0_byp_Dhl) ? bm_BX0_byp
    : (rs21_AX1_byp_Dhl) ? bm_AX1_byp
    : (rs21_BX1_byp_Dhl) ? bm_BX1_byp
    : (rs21_AX2_byp_Dhl) ? bm_AX2_byp
    : (rs21_BX2_byp_Dhl) ? bm_BX2_byp
    : (rs21_AX3_byp_Dhl) ? bm_AX3_byp
    : (rs21_BX3_byp_Dhl) ? bm_BX3_byp
    : (rs21_AW_byp_Dhl) ? bm_AW_byp
    : (rs21_BW_byp_Dhl) ? bm_BW_byp
    :                    bm_r1;

  // Operand Mux Select

  assign opA0_mux_sel_Dhl = csA[`RISCV_INST_MSG_OP0_SEL];
  assign opA1_mux_sel_Dhl = csA[`RISCV_INST_MSG_OP1_SEL];

  assign opB0_mux_sel_Dhl = csB[`RISCV_INST_MSG_OP0_SEL];
  assign opB1_mux_sel_Dhl = csB[`RISCV_INST_MSG_OP1_SEL];

  // ALU Function

  wire [3:0] alu0_fn_Dhl = csA[`RISCV_INST_MSG_ALU_FN];
  wire [3:0] alu1_fn_Dhl = csB[`RISCV_INST_MSG_ALU_FN];

  // Muldiv Function

  wire [2:0] muldivreq_msg_fn_Dhl = csA[`RISCV_INST_MSG_MULDIV_FN];

  // Muldiv Controls

  wire muldivreq_val_Dhl = csA[`RISCV_INST_MSG_MULDIV_EN];

  // Muldiv Mux Select

  wire muldiv_mux_sel_Dhl = csA[`RISCV_INST_MSG_MULDIV_SEL];

  // Execute Mux Select

  wire execute_mux_sel_Dhl = csA[`RISCV_INST_MSG_MULDIV_EN];

  wire       is_load_Dhl         = ( csA[`RISCV_INST_MSG_MEM_REQ] == ld );

  wire       dmemreq_msg_rw_Dhl  = ( csA[`RISCV_INST_MSG_MEM_REQ] == st );
  wire [1:0] dmemreq_msg_len_Dhl = csA[`RISCV_INST_MSG_MEM_LEN];
  wire       dmemreq_val_Dhl     = ( csA[`RISCV_INST_MSG_MEM_REQ] != nr );

  // Memory response mux select

  wire [2:0] dmemresp_mux_sel_Dhl = csA[`RISCV_INST_MSG_MEM_SEL];

  // Writeback Mux Select

  wire memex_mux_sel_Dhl = csA[`RISCV_INST_MSG_WB_SEL];

  // Register Writeback Controls

  wire rf0_wen_Dhl         = csA[`RISCV_INST_MSG_RF_WEN];
  wire [4:0] rf0_waddr_Dhl = instA_rd_Dhl;

  wire rf1_wen_Dhl         = csB[`RISCV_INST_MSG_RF_WEN];
  wire [4:0] rf1_waddr_Dhl = instB_rd_Dhl;

  // CSR register write enable

  wire csr_wen_Dhl = csA[`RISCV_INST_MSG_CSR_WEN];

  // CSR register address

  wire [11:0] csr_addr_Dhl  = instA_Dhl[31:20];

  //----------------------------------------------------------------------
  // Squash and Stall Logic
  //----------------------------------------------------------------------

  // Squash instruction in D if a valid branch in X is taken

  wire squash_Dhl = ( inst_val_X0hl && brj_taken_X0hl );

  // For Part 2 of this lab, replace the multdiv and ld stall logic with a scoreboard based stall logic

  // Stall in D if muldiv unit is not ready and there is a valid request
  
  wire stall_0_muldiv_use_Dhl = inst_val_Dhl && (
                              ( inst_val_X0hl && rs10_en_Dhl && rfA_wen_X0hl
                                && ( rs10_addr_Dhl == rfA_waddr_X0hl )
                                && ( rfA_waddr_X0hl != 5'd0 ) && is_muldiv_X0hl )
                           || ( inst_val_X1hl && rs10_en_Dhl && rfA_wen_X1hl
                                && ( rs10_addr_Dhl == rfA_waddr_X1hl )
                                && ( rfA_waddr_X1hl != 5'd0 ) && is_muldiv_X1hl )
                           || ( inst_val_X2hl && rs10_en_Dhl && rfA_wen_X2hl
                                && ( rs10_addr_Dhl == rfA_waddr_X2hl )
                                && ( rfA_waddr_X2hl != 5'd0 ) && is_muldiv_X2hl )
                           || ( inst_val_X3hl && rs10_en_Dhl && rfA_wen_X3hl
                                && ( rs10_addr_Dhl == rfA_waddr_X3hl )
                                && ( rfA_waddr_X3hl != 5'd0 ) && is_muldiv_X3hl )
                           || ( inst_val_X0hl && rs20_en_Dhl && rfA_wen_X0hl
                                && ( rs20_addr_Dhl == rfA_waddr_X0hl )
                                && ( rfA_waddr_X0hl != 5'd0 ) && is_muldiv_X0hl )
                           || ( inst_val_X1hl && rs20_en_Dhl && rfA_wen_X1hl
                                && ( rs20_addr_Dhl == rfA_waddr_X1hl )
                                && ( rfA_waddr_X1hl != 5'd0 ) && is_muldiv_X1hl )
                           || ( inst_val_X2hl && rs20_en_Dhl && rfA_wen_X2hl
                                && ( rs20_addr_Dhl == rfA_waddr_X2hl )
                                && ( rfA_waddr_X2hl != 5'd0 ) && is_muldiv_X2hl )
                           || ( inst_val_X3hl && rs20_en_Dhl && rfA_wen_X3hl
                                && ( rs20_addr_Dhl == rfA_waddr_X3hl )
                                && ( rfA_waddr_X3hl != 5'd0 ) && is_muldiv_X3hl ));
  wire stall_1_muldiv_use_Dhl = inst_val_Dhl && (
                              ( inst_val_X0hl && rs11_en_Dhl && rfA_wen_X0hl
                                && ( rs11_addr_Dhl == rfA_waddr_X0hl )
                                && ( rfA_waddr_X0hl != 5'd0 ) && is_muldiv_X0hl )
                           || ( inst_val_X1hl && rs11_en_Dhl && rfA_wen_X1hl
                                && ( rs11_addr_Dhl == rfA_waddr_X1hl )
                                && ( rfA_waddr_X1hl != 5'd0 ) && is_muldiv_X1hl )
                           || ( inst_val_X2hl && rs11_en_Dhl && rfA_wen_X2hl
                                && ( rs11_addr_Dhl == rfA_waddr_X2hl )
                                && ( rfA_waddr_X2hl != 5'd0 ) && is_muldiv_X2hl )
                           || ( inst_val_X3hl && rs11_en_Dhl && rfA_wen_X3hl
                                && ( rs11_addr_Dhl == rfA_waddr_X3hl )
                                && ( rfA_waddr_X3hl != 5'd0 ) && is_muldiv_X3hl )
                           || ( inst_val_X0hl && rs21_en_Dhl && rfA_wen_X0hl
                                && ( rs21_addr_Dhl == rfA_waddr_X0hl )
                                && ( rfA_waddr_X0hl != 5'd0 ) && is_muldiv_X0hl )
                           || ( inst_val_X1hl && rs21_en_Dhl && rfA_wen_X1hl
                                && ( rs21_addr_Dhl == rfA_waddr_X1hl )
                                && ( rfA_waddr_X1hl != 5'd0 ) && is_muldiv_X1hl )
                           || ( inst_val_X2hl && rs21_en_Dhl && rfA_wen_X2hl
                                && ( rs21_addr_Dhl == rfA_waddr_X2hl )
                                && ( rfA_waddr_X2hl != 5'd0 ) && is_muldiv_X2hl )
                           || ( inst_val_X3hl && rs21_en_Dhl && rfA_wen_X3hl
                                && ( rs21_addr_Dhl == rfA_waddr_X3hl )
                                && ( rfA_waddr_X3hl != 5'd0 ) && is_muldiv_X3hl ));

  // Stall for load-use only if instruction in D is valid and either of
  // the source registers match the destination register of of a valid
  // instruction in a later stage.

  wire stall_0_load_use_Dhl = inst_val_Dhl && (
                            ( inst_val_X0hl && rs10_en_Dhl && rfA_wen_X0hl
                              && ( rs10_addr_Dhl == rfA_waddr_X0hl )
                              && ( rfA_waddr_X0hl != 5'd0 ) && is_load_X0hl )
                         || ( inst_val_X1hl && rs10_en_Dhl && rfA_wen_X1hl
                              && ( rs10_addr_Dhl == rfA_waddr_X1hl )
                              && ( rfA_waddr_X1hl != 5'd0 ) && is_load_X1hl )
                         || ( inst_val_X0hl && rs20_en_Dhl && rfA_wen_X0hl
                              && ( rs20_addr_Dhl == rfA_waddr_X0hl )
                              && ( rfA_waddr_X0hl != 5'd0 ) && is_load_X0hl )
                         || ( inst_val_X1hl && rs20_en_Dhl && rfA_wen_X1hl
                              && ( rs20_addr_Dhl == rfA_waddr_X1hl )
                              && ( rfA_waddr_X1hl != 5'd0 ) && is_load_X1hl ) );

  wire stall_1_load_use_Dhl = inst_val_Dhl && (
                            ( inst_val_X0hl && rs11_en_Dhl && rfA_wen_X0hl
                              && ( rs11_addr_Dhl == rfA_waddr_X0hl )
                              && ( rfA_waddr_X0hl != 5'd0 ) && is_load_X0hl )
                         || ( inst_val_X1hl && rs11_en_Dhl && rfA_wen_X1hl
                              && ( rs11_addr_Dhl == rfA_waddr_X1hl )
                              && ( rfA_waddr_X1hl != 5'd0 ) && is_load_X1hl )
                         || ( inst_val_X0hl && rs21_en_Dhl && rfA_wen_X0hl
                              && ( rs21_addr_Dhl == rfA_waddr_X0hl )
                              && ( rfA_waddr_X0hl != 5'd0 ) && is_load_X0hl )
                         || ( inst_val_X1hl && rs21_en_Dhl && rfA_wen_X1hl
                              && ( rs21_addr_Dhl == rfA_waddr_X1hl )
                              && ( rfA_waddr_X1hl != 5'd0 ) && is_load_X1hl ) );

  /*
  Stall pipeline B if
    1. steering_state == 2'd3
      cycle 1: inst A -> pipeline A
      cycle 2: inst B -> pipeline A
    2. inst1 has data hazard
      cycle 1: inst A -> pipeline A
      cycle 2: inst B -> pipeline A
    3. inst0 has data hazard
      cycle 1: inst B -> pipeline A
      cycle 2: inst A -> pipeline A
  */

  wire read_after_write = inst_val_Dhl && (
                     ( cs0[`RISCV_INST_MSG_RS1_EN] && cs1[`RISCV_INST_MSG_RF_WEN]
                      && ( inst0_rs1_Dhl == inst1_rd_Dhl )
                      && ( inst1_rd_Dhl != 5'd0 ) )
                  || ( cs0[`RISCV_INST_MSG_RS2_EN] && cs1[`RISCV_INST_MSG_RF_WEN]
                      && ( inst0_rs2_Dhl == inst1_rd_Dhl )
                      && ( inst1_rd_Dhl != 5'd0 ) ) );

  wire data_hazard_A = 0;

  wire data_hazard_B = inst_val_Dhl && (
                     ( cs1[`RISCV_INST_MSG_RS1_EN] && cs0[`RISCV_INST_MSG_RF_WEN]
                      && ( inst1_rs1_Dhl == inst0_rd_Dhl )
                      && ( inst0_rd_Dhl != 5'd0 ) )
                  || ( cs1[`RISCV_INST_MSG_RS2_EN] && cs0[`RISCV_INST_MSG_RF_WEN]
                      && ( inst1_rs2_Dhl == inst0_rd_Dhl )
                      && ( inst0_rd_Dhl != 5'd0 ) ) );

  wire write_after_write = inst_val_Dhl && (
                           ( cs0[`RISCV_INST_MSG_RF_WEN] )
                        && ( cs1[`RISCV_INST_MSG_RF_WEN] )
                        && ( inst0_rd_Dhl == inst1_rd_Dhl )
                        && ( inst0_rd_Dhl != 5'd0 )
                        && ( inst1_rd_Dhl != 5'd0 ) );

  wire [1:0] stall_B_state = ( !data_hazard_A && !data_hazard_B && steering_state == 2'd3 ) ? 2'd1
                           : ( data_hazard_B || write_after_write )                         ? 2'd2
                           : ( data_hazard_A )                                              ? 2'd3
                           :                                                                  2'd0;

  // Aggregate Stall Signal

  wire stall_0_Dhl = (stall_X0hl || stall_0_muldiv_use_Dhl || stall_0_load_use_Dhl);
  wire stall_1_Dhl = (stall_X0hl || stall_1_muldiv_use_Dhl || stall_1_load_use_Dhl);

  assign stall_Dhl = ( stall_0_Dhl || stall_1_Dhl || (stall_B_state != 2'd0 && !brj_taken_Dhl) );

  // Next bubble bit

  wire bubble_sel_Dhl  = ( squash_Dhl || stall_0_Dhl || stall_1_Dhl );
  wire bubble_next_Dhl = ( !bubble_sel_Dhl ) ? bubble_Dhl
                       : ( bubble_sel_Dhl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // X0 <- D
  //----------------------------------------------------------------------

  reg [31:0] ir0_X0hl;
  reg [31:0] ir1_X0hl;
  reg  [2:0] br_sel_X0hl;
  reg  [3:0] alu0_fn_X0hl;
  reg  [3:0] alu1_fn_X0hl;
  reg        muldivreq_val_X0hl;
  reg  [2:0] muldivreq_msg_fn_X0hl;
  reg        muldiv_mux_sel_X0hl;
  reg        execute_mux_sel_X0hl;
  reg        is_load_X0hl;
  reg        is_muldiv_X0hl;
  reg        dmemreq_msg_rw_X0hl;
  reg  [1:0] dmemreq_msg_len_X0hl;
  reg        dmemreq_val_X0hl;
  reg  [2:0] dmemresp_mux_sel_X0hl;
  reg        memex_mux_sel_X0hl;
  reg        rf0_wen_X0hl;
  reg  [4:0] rf0_waddr_X0hl;
  reg        rf1_wen_X0hl;
  reg  [4:0] rf1_waddr_X0hl;
  reg        csr_wen_X0hl;
  reg [11:0] csr_addr_X0hl;
  reg [1:0]  steering_state_reg;

  reg        bubble_X0hl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_X0hl <= 1'b1;
    end
    else if( !stall_X0hl ) begin
      ir0_X0hl              <= instA_Dhl;
      ir1_X0hl              <= instB_Dhl;
      br_sel_X0hl           <= br_sel_Dhl;
      alu0_fn_X0hl          <= alu0_fn_Dhl;
      alu1_fn_X0hl          <= alu1_fn_Dhl;
      muldivreq_val_X0hl    <= muldivreq_val_Dhl;
      muldivreq_msg_fn_X0hl <= muldivreq_msg_fn_Dhl;
      muldiv_mux_sel_X0hl   <= muldiv_mux_sel_Dhl;
      execute_mux_sel_X0hl  <= execute_mux_sel_Dhl;
      is_load_X0hl          <= is_load_Dhl;
      is_muldiv_X0hl        <= muldivreq_val_Dhl;
      dmemreq_msg_rw_X0hl   <= dmemreq_msg_rw_Dhl;
      dmemreq_msg_len_X0hl  <= dmemreq_msg_len_Dhl;
      dmemreq_val_X0hl      <= dmemreq_val_Dhl;
      dmemresp_mux_sel_X0hl <= dmemresp_mux_sel_Dhl;
      memex_mux_sel_X0hl    <= memex_mux_sel_Dhl;
      rf0_wen_X0hl          <= rf0_wen_Dhl;
      rf0_waddr_X0hl        <= rf0_waddr_Dhl;
      rf1_wen_X0hl          <= rf1_wen_Dhl;
      rf1_waddr_X0hl        <= rf1_waddr_Dhl;
      csr_wen_X0hl         <= csr_wen_Dhl;
      csr_addr_X0hl        <= csr_addr_Dhl;
      steering_state_reg   <= steering_state;

      bubble_X0hl           <= bubble_next_Dhl;
    end

  end

  assign aluA_fn_X0hl = alu0_fn_X0hl;
  assign aluB_fn_X0hl = alu1_fn_X0hl;

  wire rfA_wen_X0hl = rf0_wen_X0hl;
  wire rfB_wen_X0hl = rf1_wen_X0hl && !( brj_taken_X0hl && steering_state_reg == 2'd2);

  wire [4:0] rfA_waddr_X0hl = rf0_waddr_X0hl;
  wire [4:0] rfB_waddr_X0hl = !( brj_taken_X0hl && steering_state_reg == 2'd2) ? rf1_waddr_X0hl : 4'd0;

  wire [31:0] irA_X0hl = ir0_X0hl;
  wire [31:0] irB_X0hl = !( brj_taken_X0hl && steering_state_reg == 2'd2) ? ir1_X0hl : inst_nop;

  //----------------------------------------------------------------------
  // Execute Stage
  //----------------------------------------------------------------------

  // Is the current stage valid?

  wire inst_val_X0hl = ( !bubble_X0hl && !squash_X0hl );

  // Muldiv request

  assign muldivreq_val = muldivreq_val_Dhl && inst_val_Dhl && (!bubble_next_Dhl);
  assign muldivresp_rdy = 1'b1;
  wire muldiv_stall_mult1 = stall_X1hl;

  // Only send a valid dmem request if not stalled

  assign dmemreq_msg_rw  = dmemreq_msg_rw_X0hl;
  assign dmemreq_msg_len = dmemreq_msg_len_X0hl;
  assign dmemreq_val     = ( inst_val_X0hl && !stall_X0hl && dmemreq_val_X0hl );

  // Resolve Branch

  wire bne_taken_X0hl  = ( ( br_sel_X0hl == br_bne ) && branch_cond_ne_X0hl );
  wire beq_taken_X0hl  = ( ( br_sel_X0hl == br_beq ) && branch_cond_eq_X0hl );
  wire blt_taken_X0hl  = ( ( br_sel_X0hl == br_blt ) && branch_cond_lt_X0hl );
  wire bltu_taken_X0hl = ( ( br_sel_X0hl == br_bltu) && branch_cond_ltu_X0hl);
  wire bge_taken_X0hl  = ( ( br_sel_X0hl == br_bge ) && branch_cond_ge_X0hl );
  wire bgeu_taken_X0hl = ( ( br_sel_X0hl == br_bgeu) && branch_cond_geu_X0hl);

  wire any_br_taken_X0hl
    = ( beq_taken_X0hl
   ||   bne_taken_X0hl
   ||   blt_taken_X0hl
   ||   bltu_taken_X0hl
   ||   bge_taken_X0hl
   ||   bgeu_taken_X0hl );

  wire brj_taken_X0hl = ( inst_val_X0hl && any_br_taken_X0hl );

  // Dummy Squash Signal

  wire squash_X0hl = 1'b0;

  // Stall in X if muldiv reponse is not valid and there was a valid request

  wire stall_muldiv_X0hl = 1'b0; // ( muldivreq_val_X0hl && inst_val_X0hl && !muldivresp_val );

  // Stall in X if imem is not ready

  wire stall_imem_X0hl = !imemreq0_rdy || !imemreq1_rdy;

  // Stall in X if dmem is not ready and there was a valid request

  wire stall_dmem_X0hl = ( dmemreq_val_X0hl && inst_val_X0hl && !dmemreq_rdy );

  // Aggregate Stall Signal

  assign stall_X0hl = ( stall_X1hl || stall_muldiv_X0hl || stall_imem_X0hl || stall_dmem_X0hl );

  // Next bubble bit

  wire bubble_sel_X0hl  = ( squash_X0hl || stall_X0hl );
  wire bubble_next_X0hl = ( !bubble_sel_X0hl ) ? bubble_X0hl
                       : ( bubble_sel_X0hl )  ? 1'b1
                       :                        1'bx;

  //----------------------------------------------------------------------
  // X1 <- X0
  //----------------------------------------------------------------------

  reg [31:0] ir0_X1hl;
  reg [31:0] ir1_X1hl;
  reg        is_load_X1hl;
  reg        is_muldiv_X1hl;
  reg        dmemreq_val_X1hl;
  reg  [2:0] dmemresp_mux_sel_X1hl;
  reg        memex_mux_sel_X1hl;
  reg        execute_mux_sel_X1hl;
  reg        muldiv_mux_sel_X1hl;
  reg        rf0_wen_X1hl;
  reg  [4:0] rf0_waddr_X1hl;
  reg        rf1_wen_X1hl;
  reg  [4:0] rf1_waddr_X1hl;
  reg        csr_wen_X1hl;
  reg  [4:0] csr_addr_X1hl;

  reg        bubble_X1hl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      dmemreq_val_X1hl <= 1'b0;

      bubble_X1hl <= 1'b1;
    end
    else if( !stall_X1hl ) begin
      ir0_X1hl              <= ir0_X0hl;
      ir1_X1hl              <= ir1_X0hl;
      is_load_X1hl          <= is_load_X0hl;
      is_muldiv_X1hl        <= is_muldiv_X0hl;
      dmemreq_val_X1hl      <= dmemreq_val;
      dmemresp_mux_sel_X1hl <= dmemresp_mux_sel_X0hl;
      memex_mux_sel_X1hl    <= memex_mux_sel_X0hl;
      execute_mux_sel_X1hl  <= execute_mux_sel_X0hl;
      muldiv_mux_sel_X1hl   <= muldiv_mux_sel_X0hl;
      rf0_wen_X1hl          <= rfA_wen_X0hl;
      rf0_waddr_X1hl        <= rfA_waddr_X0hl;
      rf1_wen_X1hl          <= rfB_wen_X0hl;
      rf1_waddr_X1hl        <= rfB_waddr_X0hl;
      csr_wen_X1hl         <= csr_wen_X0hl;
      csr_addr_X1hl        <= csr_addr_X0hl;

      bubble_X1hl           <= bubble_next_X0hl;
    end
  end

  wire rfA_wen_X1hl = rf0_wen_X1hl;
  wire rfB_wen_X1hl = rf1_wen_X1hl;

  wire [4:0] rfA_waddr_X1hl = rf0_waddr_X1hl;
  wire [4:0] rfB_waddr_X1hl = rf1_waddr_X1hl;

  wire [31:0] irA_X1hl = ir0_X1hl;
  wire [31:0] irB_X1hl = ir1_X1hl;

  //----------------------------------------------------------------------
  // X1 Stage
  //----------------------------------------------------------------------

  // Is current stage valid?

  wire inst_val_X1hl = ( !bubble_X1hl && !squash_X1hl );

  // Data memory queue control signals

  assign dmemresp_queue_en_X1hl = ( stall_X1hl && dmemresp_val );
  wire   dmemresp_queue_val_next_X1hl
    = stall_X1hl && ( dmemresp_val || dmemresp_queue_val_X1hl );

  // Dummy Squash Signal

  wire squash_X1hl = 1'b0;

  // Stall in X1 if memory response is not returned for a valid request

  wire stall_dmem_X1hl
    = ( !reset && dmemreq_val_X1hl && inst_val_X1hl && !dmemresp_val && !dmemresp_queue_val_X1hl );
  wire stall_imem_X1hl
    = ( !reset && imemreq_val_Fhl && inst_val_Fhl && !imemresp0_val && !imemresp0_queue_val_Fhl )
   || ( !reset && imemreq_val_Fhl && inst_val_Fhl && !imemresp1_val && !imemresp1_queue_val_Fhl );

  // Aggregate Stall Signal

  wire stall_X1hl = ( stall_imem_X1hl || stall_dmem_X1hl );

  // Next bubble bit

  wire bubble_sel_X1hl  = ( squash_X1hl || stall_X1hl );
  wire bubble_next_X1hl = ( !bubble_sel_X1hl ) ? bubble_X1hl
                       : ( bubble_sel_X1hl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // X2 <- X1
  //----------------------------------------------------------------------

  reg [31:0] ir0_X2hl;
  reg [31:0] ir1_X2hl;
  reg        is_muldiv_X2hl;
  reg        dmemresp_queue_val_X1hl;
  reg        rf0_wen_X2hl;
  reg  [4:0] rf0_waddr_X2hl;
  reg        rf1_wen_X2hl;
  reg  [4:0] rf1_waddr_X2hl;
  reg        csr_wen_X2hl;
  reg  [4:0] csr_addr_X2hl;
  reg        execute_mux_sel_X2hl;
  reg        muldiv_mux_sel_X2hl;

  reg        bubble_X2hl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_X2hl <= 1'b1;
    end
    else if( !stall_X2hl ) begin
      ir0_X2hl              <= ir0_X1hl;
      ir1_X2hl              <= ir1_X1hl;
      is_muldiv_X2hl        <= is_muldiv_X1hl;
      muldiv_mux_sel_X2hl   <= muldiv_mux_sel_X1hl;
      rf0_wen_X2hl          <= rf0_wen_X1hl;
      rf0_waddr_X2hl        <= rf0_waddr_X1hl;
      rf1_wen_X2hl          <= rf1_wen_X1hl;
      rf1_waddr_X2hl        <= rf1_waddr_X1hl;
      csr_wen_X2hl         <= csr_wen_X1hl;
      csr_addr_X2hl        <= csr_addr_X1hl;
      execute_mux_sel_X2hl  <= execute_mux_sel_X1hl;

      bubble_X2hl           <= bubble_next_X1hl;
    end
    dmemresp_queue_val_X1hl <= dmemresp_queue_val_next_X1hl;
  end

  wire rfA_wen_X2hl = rf0_wen_X2hl;
  wire rfB_wen_X2hl = rf1_wen_X2hl;

  wire [4:0] rfA_waddr_X2hl = rf0_waddr_X2hl;
  wire [4:0] rfB_waddr_X2hl = rf1_waddr_X2hl;

  wire [31:0] irA_X2hl = ir0_X2hl;
  wire [31:0] irB_X2hl = ir1_X2hl;

  //----------------------------------------------------------------------
  // X2 Stage
  //----------------------------------------------------------------------

  // Is current stage valid?

  wire inst_val_X2hl = ( !bubble_X2hl && !squash_X2hl );

  // Dummy Squash Signal

  wire squash_X2hl = 1'b0;

  // Dummy Stall Signal

  wire stall_X2hl = 1'b0;

  // Next bubble bit

  wire bubble_sel_X2hl  = ( squash_X2hl || stall_X2hl );
  wire bubble_next_X2hl = ( !bubble_sel_X2hl ) ? bubble_X2hl
                       : ( bubble_sel_X2hl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // X3 <- X2
  //----------------------------------------------------------------------

  reg [31:0] ir0_X3hl;
  reg [31:0] ir1_X3hl;
  reg        is_muldiv_X3hl;
  reg        rf0_wen_X3hl;
  reg  [4:0] rf0_waddr_X3hl;
  reg        rf1_wen_X3hl;
  reg  [4:0] rf1_waddr_X3hl;
  reg        csr_wen_X3hl;
  reg  [4:0] csr_addr_X3hl;
  reg        execute_mux_sel_X3hl;
  reg        muldiv_mux_sel_X3hl;

  reg        bubble_X3hl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_X3hl <= 1'b1;
    end
    else if( !stall_X3hl ) begin
      ir0_X3hl              <= ir0_X2hl;
      ir1_X3hl              <= ir1_X2hl;
      is_muldiv_X3hl        <= is_muldiv_X2hl;
      muldiv_mux_sel_X3hl   <= muldiv_mux_sel_X2hl;
      rf0_wen_X3hl          <= rf0_wen_X2hl;
      rf0_waddr_X3hl        <= rf0_waddr_X2hl;
      rf1_wen_X3hl          <= rf1_wen_X2hl;
      rf1_waddr_X3hl        <= rf1_waddr_X2hl;
      csr_wen_X3hl         <= csr_wen_X2hl;
      csr_addr_X3hl        <= csr_addr_X2hl;
      execute_mux_sel_X3hl  <= execute_mux_sel_X2hl;

      bubble_X3hl           <= bubble_next_X2hl;
    end
  end

  wire rfA_wen_X3hl = rf0_wen_X3hl;
  wire rfB_wen_X3hl = rf1_wen_X3hl;

  wire [4:0] rfA_waddr_X3hl = rf0_waddr_X3hl;
  wire [4:0] rfB_waddr_X3hl = rf1_waddr_X3hl;

  wire [31:0] irA_X3hl = ir0_X3hl;
  wire [31:0] irB_X3hl = ir1_X3hl;

  //----------------------------------------------------------------------
  // X3 Stage
  //----------------------------------------------------------------------

  // Is current stage valid?

  wire inst_val_X3hl = ( !bubble_X3hl && !squash_X3hl );

  // Dummy Squash Signal

  wire squash_X3hl = 1'b0;

  // Dummy Stall Signal

  wire stall_X3hl = 1'b0;

  // Next bubble bit

  wire bubble_sel_X3hl  = ( squash_X3hl || stall_X3hl );
  wire bubble_next_X3hl = ( !bubble_sel_X3hl ) ? bubble_X3hl
                       : ( bubble_sel_X3hl )  ? 1'b1
                       :                       1'bx;

  //----------------------------------------------------------------------
  // W <- X3
  //----------------------------------------------------------------------

  reg [31:0] ir0_Whl;
  reg [31:0] ir1_Whl;
  reg        rf0_wen_Whl;
  reg  [4:0] rf0_waddr_Whl;
  reg        rf1_wen_Whl;
  reg  [4:0] rf1_waddr_Whl;
  reg        csr_wen_Whl;
  reg  [4:0] csr_addr_Whl;

  reg        bubble_Whl;

  // Pipeline Controls

  always @ ( posedge clk ) begin
    if ( reset ) begin
      bubble_Whl <= 1'b1;
    end
    else if( !stall_Whl ) begin
      ir0_Whl          <= ir0_X3hl;
      ir1_Whl          <= ir1_X3hl;
      rf0_wen_Whl      <= rf0_wen_X3hl;
      rf0_waddr_Whl    <= rf0_waddr_X3hl;
      rf1_wen_Whl      <= rf1_wen_X3hl;
      rf1_waddr_Whl    <= rf1_waddr_X3hl;
      csr_wen_Whl     <= csr_wen_X3hl;
      csr_addr_Whl    <= csr_addr_X3hl;

      bubble_Whl       <= bubble_next_X3hl;
    end
  end

  wire rfA_wen_Whl = rf0_wen_Whl;
  wire rfB_wen_Whl = rf1_wen_Whl;

  wire [4:0] rfA_waddr_Whl = rf0_waddr_Whl;
  wire [4:0] rfB_waddr_Whl = rf1_waddr_Whl;

  wire [31:0] irA_Whl = ir0_Whl;
  wire [31:0] irB_Whl = ir1_Whl;

  //----------------------------------------------------------------------
  // Writeback Stage
  //----------------------------------------------------------------------

  // Is current stage valid?

  wire inst_val_Whl = ( !bubble_Whl && !squash_Whl );

  // Only set register file wen if stage is valid

  assign rfA_wen_out_Whl = ( inst_val_Whl && !stall_Whl && rf0_wen_Whl );
  assign rfB_wen_out_Whl = ( inst_val_Whl && !stall_Whl && rf1_wen_Whl );

  // Dummy squash and stall signals

  wire squash_Whl = 1'b0;
  wire stall_Whl  = 1'b0;

  //----------------------------------------------------------------------
  // Debug registers for instruction disassembly
  //----------------------------------------------------------------------

  reg [31:0] irA_debug;
  reg [31:0] irB_debug;
  reg        inst_val_debug;

  always @ ( posedge clk ) begin
    irA_debug       <= irA_Whl;
    inst_val_debug  <= inst_val_Whl;
    irB_debug       <= irB_Whl;
  end

  //----------------------------------------------------------------------
  // CSR register
  //----------------------------------------------------------------------

  reg  [31:0] csr_status;
  reg         csr_stats;

  always @ ( posedge clk ) begin
    if ( csr_wen_Whl && inst_val_Whl ) begin
      case ( csr_addr_Whl )
        12'd10 : csr_stats  <= proc2csr_data_Whl[0];
        12'd21 : csr_status <= proc2csr_data_Whl;
      endcase
    end
  end

//========================================================================
// Disassemble instructions
//========================================================================

  `ifndef SYNTHESIS

  riscv_InstMsgDisasm inst0_msg_disasm_D
  (
    .msg ( ir0_Dhl )
  );

  riscv_InstMsgDisasm instA_msg_disasm_X0
  (
    .msg ( irA_X0hl )
  );

  riscv_InstMsgDisasm instA_msg_disasm_X1
  (
    .msg ( irA_X1hl )
  );

  riscv_InstMsgDisasm instA_msg_disasm_X2
  (
    .msg ( irA_X2hl )
  );

  riscv_InstMsgDisasm instA_msg_disasm_X3
  (
    .msg ( irA_X3hl )
  );

  riscv_InstMsgDisasm instA_msg_disasm_W
  (
    .msg ( irA_Whl )
  );

  riscv_InstMsgDisasm instA_msg_disasm_debug
  (
    .msg ( irA_debug )
  );

  riscv_InstMsgDisasm inst1_msg_disasm_D
  (
    .msg ( ir1_Dhl )
  );

  riscv_InstMsgDisasm instB_msg_disasm_X0
  (
    .msg ( irB_X0hl )
  );

  riscv_InstMsgDisasm instB_msg_disasm_X1
  (
    .msg ( irB_X1hl )
  );

  riscv_InstMsgDisasm instB_msg_disasm_X2
  (
    .msg ( irB_X2hl )
  );

  riscv_InstMsgDisasm instB_msg_disasm_X3
  (
    .msg ( irB_X3hl )
  );

  riscv_InstMsgDisasm instB_msg_disasm_W
  (
    .msg ( irB_Whl )
  );

  riscv_InstMsgDisasm instB_msg_disasm_debug
  (
    .msg ( irB_debug )
  );

  `endif

//========================================================================
// Assertions
//========================================================================
// Detect illegal instructions and terminate the simulation if multiple
// illegal instructions are detected in succession.

  `ifndef SYNTHESIS

  reg overload = 1'b0;

  always @ ( posedge clk ) begin
    if (( !csA[`RISCV_INST_MSG_INST_VAL] && !reset ) 
     || ( !csB[`RISCV_INST_MSG_INST_VAL] && !reset )) begin
      $display(" RTL-ERROR : %m : Illegal instruction!");

      if ( overload == 1'b1 ) begin
        $finish;
      end

      overload = 1'b1;
    end
    else begin
      overload = 1'b0;
    end
  end

  `endif

//========================================================================
// Stats
//========================================================================

  `ifndef SYNTHESIS

  reg [31:0] num_inst    = 32'b0;
  reg [31:0] num_cycles  = 32'b0;
  reg        stats_en    = 1'b0; // Used for enabling stats on asm tests

  always @( posedge clk ) begin
    if ( !reset ) begin

      // Count cycles if stats are enabled

      if ( stats_en || csr_stats ) begin
        num_cycles = num_cycles + 1;

        // Count instructions for every cycle not squashed or stalled

        if ( inst_val_Dhl && !( stall_Dhl && stall_B_state == 2'd0 ) ) begin
          num_inst = num_inst + 2;
        end

      end

    end
  end

  `endif

endmodule

`endif

// vim: set textwidth=0 ts=2 sw=2 sts=2 :
