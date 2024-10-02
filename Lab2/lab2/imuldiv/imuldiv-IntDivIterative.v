//========================================================================
// Lab 1 - Iterative Div Unit
//========================================================================

`ifndef RISCV_INT_DIV_ITERATIVE_V
`define RISCV_INT_DIV_ITERATIVE_V

`include "imuldiv-DivReqMsg.v"

module imuldiv_IntDivIterative
(

  input         clk,
  input         reset,

  input         divreq_msg_fn,
  input  [31:0] divreq_msg_a,
  input  [31:0] divreq_msg_b,
  input         divreq_val,
  output        divreq_rdy,

  output [63:0] divresp_msg_result,
  output        divresp_val,
  input         divresp_rdy
);

  wire       a_mux_sel;
  wire       sub_mux_sel;
  wire       rem_sign_mux_sel;
  wire       div_sign_mux_sel;
  wire [4:0] counter;
  wire       div_sign;
  wire       rem_sign;
  wire       sub_out_64;
  wire [1:0] state;

  imuldiv_IntDivIterativeDpath dpath
  (
    .clk                (clk),
    .reset              (reset),
    .divreq_msg_fn      (divreq_msg_fn),
    .divreq_msg_a       (divreq_msg_a),
    .divreq_msg_b       (divreq_msg_b),
    .divreq_val         (divreq_val),
    .divreq_rdy         (divreq_rdy),
    .divresp_msg_result (divresp_msg_result),
    .divresp_val        (divresp_val),
    .divresp_rdy        (divresp_rdy),
    .a_mux_sel          (a_mux_sel),
    .sub_mux_sel        (sub_mux_sel),
    .rem_sign_mux_sel   (rem_sign_mux_sel),
    .div_sign_mux_sel   (div_sign_mux_sel),
    .counter            (counter),
    .div_sign           (div_sign),
    .rem_sign           (rem_sign),
    .sub_out_64         (sub_out_64),
    .state              (state)
  );

  imuldiv_IntDivIterativeCtrl ctrl
  (
    .clk                (clk),
    .reset              (reset),
    .divreq_val         (divreq_val),
    .divreq_rdy         (divreq_rdy),
    .divresp_val        (divresp_val),
    .divresp_rdy        (divresp_rdy),
    .a_mux_sel          (a_mux_sel),
    .sub_mux_sel        (sub_mux_sel),
    .rem_sign_mux_sel   (rem_sign_mux_sel),
    .div_sign_mux_sel   (div_sign_mux_sel),
    .counter            (counter),
    .div_sign           (div_sign),
    .rem_sign           (rem_sign),
    .sub_out_64         (sub_out_64),
    .state              (state)
  );

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeDpath
(
  input         clk,
  input         reset,

  input         divreq_msg_fn,      // Function of MulDiv Unit
  input  [31:0] divreq_msg_a,       // Operand A
  input  [31:0] divreq_msg_b,       // Operand B
  input         divreq_val,         // Request val Signal
  output        divreq_rdy,         // Request rdy Signal

  output [63:0] divresp_msg_result, // Result of operation
  output        divresp_val,        // Response val Signal
  input         divresp_rdy,        // Response rdy Signal
  input         a_mux_sel,
  input         sub_mux_sel,
  input         rem_sign_mux_sel,
  input         div_sign_mux_sel,
  output [4:0]  counter,
  output        div_sign,
  output        rem_sign,
  output        sub_out_64,
  input  [1:0]  state
);

  parameter DEFAULT = 2'b00;
  parameter RUN = 2'b01;
  parameter TRANS = 2'b10;

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  reg         fn_reg;      // Register for storing function
  reg  [64:0] a_reg;       // Register for storing operand A
  reg  [64:0] b_reg;       // Register for storing operand B
  reg         sign_bit_a;
  reg         sign_bit_b;

  always @( posedge clk ) begin

    // Stall the pipeline if the response interface is not ready
    if ( reset ) begin
      a_reg <= 0;
      b_reg <= 0;
      sign_bit_a <= 0;
      sign_bit_b <= 0;
    end
    else begin
      case(state)
        DEFAULT: begin
          sign_bit_a <= divreq_msg_a[31];
          sign_bit_b <= divreq_msg_b[31];
          b_reg <= {1'b0, unsigned_b_32, 32'b0};
          a_reg <= a_mux_out;
          fn_reg <= divreq_msg_fn;
        end
        RUN: begin
          a_reg <= a_mux_out;
        end
        TRANS: begin
          if (!divresp_val)
            a_reg <= a_mux_out;
        end
        default:
          a_reg <= 0;
      endcase
    end

  end

  //----------------------------------------------------------------------
  // Combinational Logic
  //----------------------------------------------------------------------

  wire [64:0] a_reg_w = a_reg;
  
  assign div_sign = sign_bit_a ^ sign_bit_b;
  assign rem_sign = sign_bit_a;

  wire [31:0] unsigned_a_32 = (divreq_msg_a[31] & (divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED)) ? (~divreq_msg_a + 1'b1) : divreq_msg_a;
  wire [64:0] unsigned_a_65 = {33'b0, unsigned_a_32};
  wire [31:0] unsigned_b_32 = (divreq_msg_b[31] & (divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED)) ? (~divreq_msg_b + 1'b1) : divreq_msg_b;
  wire [64:0] unsigned_b_65 = b_reg;

  wire [64:0] a_mux_out;
  wire [64:0] sub_mux_out;
  wire [64:0] sub_out;

  div_Mux2 #(
    .W(65))
    a_mux(
      .in0(unsigned_a_65),
      .in1(sub_mux_out),
      .sel(a_mux_sel),
      .out(a_mux_out)
    );

  wire [64:0] a_shift_out = a_reg << 1;

  div_Subtractor #(
    .W(65))
    subtractor(
      .in0(a_shift_out),
      .in1(unsigned_b_65),
      .out(sub_out)
    );

  assign sub_out_64 = sub_out[64];

  div_Mux2 #(
    .W(65))
    sub_mux(
      .in0(a_shift_out),
      .in1({sub_out[64:1], 1'b1}),
      .sel(sub_mux_sel),
      .out(sub_mux_out)
    );

  wire [31:0] signed_rem = ~a_reg_w[63:32] + 1'b1;
  wire [31:0] signed_res = ~a_reg_w[31:0] + 1'b1;
  wire [31:0] rem_mux_out;
  wire [31:0] res_mux_out;

  div_Mux2 #(
    .W(32))
    rem_mux(
      .in0(a_reg_w[63:32]),
      .in1(signed_rem),
      .sel(rem_sign_mux_sel & (fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED)),
      .out(rem_mux_out)
    );

  div_Mux2 #(
    .W(32))
    res_mux(
      .in0(a_reg_w[31:0]),
      .in1(signed_res),
      .sel(div_sign_mux_sel & (fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED)),
      .out(res_mux_out)
    );
    
  assign divresp_msg_result = {rem_mux_out, res_mux_out};

  div_Counter cnter(
    .clk        (clk),
    .val        (5'd31),
    .divreq_val (divreq_val),
    .b_mux_sel  (a_mux_sel),
    .counter    (counter)
  );

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeCtrl
(
  input         clk,
  input         reset,
  input         divreq_val,         // Request val Signal
  output reg    divreq_rdy,         // Request rdy Signal
  output reg    divresp_val,        // Response val Signal
  input         divresp_rdy,        // Response rdy Signal
  output        a_mux_sel,
  output        sub_mux_sel,
  output        rem_sign_mux_sel,
  output        div_sign_mux_sel,
  input  [4:0]  counter,
  input         div_sign,
  input         rem_sign,
  input         sub_out_64,
  output [1:0]  state
);

  parameter DEFAULT = 2'b00;
  parameter RUN = 2'b01;
  parameter TRANS = 2'b10;

  reg [1:0] curr_state;
  reg [1:0] next_state;

  reg a_mux_sel_reg;

  always @(posedge clk) begin
    if (reset)
      curr_state <= DEFAULT;
    else
      curr_state <= next_state;
  end

  always @(*) begin
    case(curr_state)
      DEFAULT: begin
        if (divreq_val == 1)
          next_state = RUN;
        else
          next_state = DEFAULT;
      end
      RUN: begin
        if (counter == 0)
          next_state = TRANS;
        else
          next_state = RUN;
      end
      TRANS:
        if (divresp_rdy == 1)
          next_state = DEFAULT;
        else
          next_state = TRANS;
      default: next_state = DEFAULT;
    endcase
  end

  always @(*) begin
    case(curr_state)
      DEFAULT: begin
        a_mux_sel_reg = 0;
        divreq_rdy = 1;
        divresp_val = 0;
      end
      RUN: begin
        a_mux_sel_reg = 1;
        divreq_rdy = 0;
        divresp_val = 0;
      end
      TRANS: begin
        divresp_val = 1;
      end
      default: begin
        a_mux_sel_reg = 0;
        divreq_rdy = 0;
        divresp_val = 0;
      end
    endcase
  end

  assign state = curr_state;
  assign a_mux_sel = a_mux_sel_reg;
  assign rem_sign_mux_sel = rem_sign;
  assign div_sign_mux_sel = div_sign;
  assign sub_mux_sel = (sub_out_64) ? 0 : 1;

endmodule

//------------------------------------------------------------------------
// Counter
//------------------------------------------------------------------------

module div_Counter
(
  input        clk,
  input  [4:0] val,
  input        divreq_val,
  input        b_mux_sel,
  output [4:0] counter
);

  reg   [4:0] counter_reg;
  wire  [4:0] counter_reg_out;
  wire  [4:0] counter_mux_out;
  wire  [4:0] sub_out;

  always @(posedge clk) begin
    counter_reg <= counter_mux_out;
  end

  assign counter_reg_out = counter_reg;

  div_Mux2 #(
    .W(5))
    counter_mux(
      .in0(val),
      .in1(sub_out),
      .sel(b_mux_sel),
      .out(counter_mux_out)
    );

  div_Subtractor #(
    .W(5))
    subtractor(
      .in0(counter_reg_out),
      .in1(5'b00001),
      .out(sub_out)
    );

  assign counter = counter_reg;

endmodule

//------------------------------------------------------------------------
// Subtractor
//------------------------------------------------------------------------

module div_Subtractor #( parameter W = 1 )
(
  input  [W-1:0] in0, in1,
  output [W-1:0] out
);

  assign out = in0 - in1;

endmodule

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module div_Mux2 #( parameter W = 1 )
(
  input      [W-1:0] in0, in1,
  input              sel,
  output reg [W-1:0] out
);

  always @(*)
  begin
    case ( sel )
      1'd0 : out = in0;
      1'd1 : out = in1;
      default : out = {W{1'bx}};
    endcase
  end

endmodule

`endif
