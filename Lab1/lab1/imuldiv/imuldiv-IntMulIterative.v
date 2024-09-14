//========================================================================
// Lab 1 - Iterative Mul Unit
//========================================================================

`ifndef RISCV_INT_MUL_ITERATIVE_V
`define RISCV_INT_MUL_ITERATIVE_V

module imuldiv_IntMulIterative
(
  input                clk,
  input                reset,

  input  [31:0] mulreq_msg_a,
  input  [31:0] mulreq_msg_b,
  input         mulreq_val,
  output        mulreq_rdy,

  output [63:0] mulresp_msg_result,
  output        mulresp_val,
  input         mulresp_rdy
);

  wire        a_mux_sel;
  wire        b_mux_sel;
  wire        result_mux_sel;
  wire        add_mux_sel;
  wire        sign_mux_sel;
  wire [4:0]  counter;
  wire        b_reg_0;
  wire        sign;
  wire [1:0]  state;

  imuldiv_IntMulIterativeDpath dpath
  (
    .clk                (clk),
    .reset              (reset),
    .mulreq_msg_a       (mulreq_msg_a),
    .mulreq_msg_b       (mulreq_msg_b),
    .mulresp_msg_result (mulresp_msg_result),
    .mulreq_val         (mulreq_val),
    .mulresp_rdy        (mulresp_rdy),
    .a_mux_sel          (a_mux_sel),
    .b_mux_sel          (b_mux_sel),
    .result_mux_sel     (result_mux_sel),
    .add_mux_sel        (add_mux_sel),
    .sign_mux_sel       (sign_mux_sel),
    .counter            (counter),
    .b_reg_0            (b_reg_0),
    .sign               (sign),
    .state              (state)
  );

  imuldiv_IntMulIterativeCtrl ctrl
  (
    .clk            (clk),
    .reset          (reset),
    .a_mux_sel      (a_mux_sel),
    .b_mux_sel      (b_mux_sel),
    .result_mux_sel (result_mux_sel),
    .add_mux_sel    (add_mux_sel),
    .sign_mux_sel   (sign_mux_sel),
    .counter        (counter),
    .b_reg_0        (b_reg_0),
    .sign           (sign),
    .mulreq_val     (mulreq_val),
    .mulreq_rdy     (mulreq_rdy),
    .mulresp_val    (mulresp_val),
    .mulresp_rdy    (mulresp_rdy),
    .state          (state)
  );

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntMulIterativeDpath
(
  input         clk,
  input         reset,

  input  [31:0] mulreq_msg_a,       // Operand A
  input  [31:0] mulreq_msg_b,       // Operand B

  output [63:0] mulresp_msg_result, // Result of operation
  input         mulreq_val,
  input         mulresp_rdy,        // Response rdy Signal

  input         a_mux_sel,
  input         b_mux_sel,
  input         result_mux_sel,
  input         add_mux_sel,
  input         sign_mux_sel,

  output [4:0]  counter,
  output        b_reg_0,
  output        sign,
  input  [1:0]  state
);

  parameter DEFAULT = 2'b00;
  parameter RUN = 2'b01;
  parameter TRANS = 2'b10;

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  reg  [63:0] result_reg;  // Register for storing result
  reg  [31:0] a_reg;
  reg  [31:0] b_reg;
  reg         sign_bit_a;
  reg         sign_bit_b;

  always @( posedge clk ) begin
    
    if (reset) begin
      result_reg <= 0;
      a_reg <= 0;
      b_reg <= 0;
    end
    else
      case(state)
        DEFAULT: begin
          result_reg <= 0;
          a_reg <= mulreq_msg_a;
          b_reg <= mulreq_msg_b;
          sign_bit_a <= mulreq_msg_a[31];
          sign_bit_b <= mulreq_msg_b[31];
        end
        RUN:
          result_reg <= result_mux_out;
        TRANS:
          result_reg <= result_mux_out;
        default:
          result_reg <= 0;
      endcase

  end

  //----------------------------------------------------------------------
  // Combinational Logic
  //----------------------------------------------------------------------

  // Extract sign bits
  assign sign = sign_bit_a ^ sign_bit_b;

  // Unsign operands if necessary

  wire [31:0] unsigned_a_32 = ( mulreq_msg_a[31] ) ? (~mulreq_msg_a + 1'b1) : mulreq_msg_a;
  wire [63:0] unsigned_a_64 = {32'b0, unsigned_a_32};
  wire [31:0] unsigned_b = ( mulreq_msg_b[31] ) ? (~mulreq_msg_b + 1'b1) : mulreq_msg_b;

  wire [63:0] a_out;
  wire [31:0] b_out;

  shift_module #(
    .dir(1), .W(64))
    shift_module_a(
      .clk(clk),
      .unsigned_num(unsigned_a_64),
      .sel(a_mux_sel),
      .out(a_out)
    );

  shift_module #(
    .dir(0), .W(32))
    shift_module_b(
      .clk(clk),
      .unsigned_num(unsigned_b),
      .sel(b_mux_sel),
      .out(b_out)
    );

  assign b_reg_0 = b_out[0];

  wire [63:0] result_mux_in;
  wire [63:0] result_mux_out;
  wire [63:0] result_reg_out;
  wire [63:0] adder_out;

  Mux2 #(
    .W(64))
    result_mux(
      .in0(64'b0),
      .in1(result_mux_in),
      .sel(result_mux_sel),
      .out(result_mux_out)
    );

  assign result_reg_out = result_reg;

  vc_Adder_simple #(
    .W(64))
    adder(
      .in0(result_reg_out),
      .in1(a_out),
      .out(adder_out)
    );

  Mux2 #(
    .W(64))
    adder_mux(
      .in0(adder_out),
      .in1(result_reg_out),
      .sel(add_mux_sel),
      .out(result_mux_in)
    );

  // Determine whether or not result is signed. Usually the result is
  // signed if one and only one of the input operands is signed. In other
  // words, the result is signed if the xor of the sign bits of the input
  // operands is true. Remainder opeartions are a bit trickier, and here
  // we simply assume that the result is signed if the dividend for the
  // rem operation is signed.
  wire [63:0] sign_in = ~result_reg_out + 1'b1;
  Mux2 #(
    .W(64))
    sign_mux(
      .in0(sign_in),
      .in1(result_reg_out),
      .sel(sign_mux_sel),
      .out(mulresp_msg_result)
    );

  Counter cnter(
    .clk        (clk),
    .val        (5'd31),
    .mulreq_val (mulreq_val),
    .b_mux_sel  (b_mux_sel),
    .counter    (counter)
  );

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntMulIterativeCtrl
(
  input        clk,
  input        reset,
  output       a_mux_sel,
  output       b_mux_sel,
  output       result_mux_sel,
  output       add_mux_sel,
  output       sign_mux_sel,

  input [4:0]  counter,
  input        b_reg_0,
  input        sign,

  input        mulreq_val,
  output reg   mulreq_rdy,
  output reg   mulresp_val,
  input        mulresp_rdy,
  output [1:0] state
);


  parameter DEFAULT = 2'b00;
  parameter RUN = 2'b01;
  parameter TRANS = 2'b10;

  reg [1:0] curr_state;
  reg [1:0] next_state;

  reg a_mux_sel_reg;
  reg b_mux_sel_reg;
  reg result_mux_sel_reg;

  always @(posedge clk) begin
    if (reset)
      curr_state <= DEFAULT;
    else
      curr_state <= next_state;
  end

  always @(*) begin
    case(curr_state)
      DEFAULT: begin
        if (mulreq_val == 1)
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
        if (mulresp_rdy == 1)
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
        b_mux_sel_reg = 0;
        result_mux_sel_reg = 0;
        mulreq_rdy = 1;
        mulresp_val = 0;
      end
      RUN: begin
        a_mux_sel_reg = 1;
        b_mux_sel_reg = 1;
        result_mux_sel_reg = 1;
        mulreq_rdy = 0;
        mulresp_val = 0;
      end
      TRANS: begin
        mulresp_val = 1;
      end
      default: begin
        a_mux_sel_reg = 0;
        b_mux_sel_reg = 0;
        result_mux_sel_reg = 0;
        mulreq_rdy = 0;
        mulresp_val = 0;
      end
    endcase
  end

  assign sign_mux_sel = (sign) ? 0 : 1;
  assign add_mux_sel = (b_reg_0) ? 0 : 1;
  assign a_mux_sel = a_mux_sel_reg;
  assign b_mux_sel = b_mux_sel_reg;
  assign result_mux_sel = result_mux_sel_reg;

  assign state = curr_state;

endmodule



//------------------------------------------------------------------------
// Local Modules
//------------------------------------------------------------------------

//------------------------------------------------------------------------
// Adder
//------------------------------------------------------------------------

module vc_Adder_simple #( parameter W = 1 )
(
  input  [W-1:0] in0, in1,
  output [W-1:0] out
);

  assign out = in0 + in1;

endmodule

//------------------------------------------------------------------------
// Subtractor
//------------------------------------------------------------------------

module vc_Subtractor #( parameter W = 1 )
(
  input  [W-1:0] in0, in1,
  output [W-1:0] out
);

  assign out = in0 - in1;

endmodule

//------------------------------------------------------------------------
// 2 Input Mux
//------------------------------------------------------------------------

module Mux2 #( parameter W = 1 )
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

//------------------------------------------------------------------------
// Shift Logic
//------------------------------------------------------------------------

module shift_module #(parameter dir = 0, parameter W = 1)
(
  input          clk,
  input  [W-1:0] unsigned_num,
  input          sel,
  output [W-1:0] out
);

  reg   [W-1:0] num_reg;
  wire  [W-1:0] mux_in;
  wire  [W-1:0] mux_out;

  Mux2 #(
    .W(W))
    mux(
      .in0(unsigned_num),
      .in1(mux_in),
      .sel(sel),
      .out(mux_out)
    );

  always @(posedge clk) begin
    num_reg = mux_out;
  end

  assign mux_in = (dir) ? (num_reg << 1) : (num_reg >> 1);
  assign out = num_reg;

endmodule

//------------------------------------------------------------------------
// Counter
//------------------------------------------------------------------------

module Counter
(
  input        clk,
  input  [4:0] val,
  input        mulreq_val,
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

  Mux2 #(
    .W(5))
    counter_mux(
      .in0(val),
      .in1(sub_out),
      .sel(b_mux_sel),
      .out(counter_mux_out)
    );

  vc_Subtractor #(
    .W(5))
    subtractor(
      .in0(counter_reg_out),
      .in1(5'b00001),
      .out(sub_out)
    );

  assign counter = counter_reg;

endmodule

`endif




