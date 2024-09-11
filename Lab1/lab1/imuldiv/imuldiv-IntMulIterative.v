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

  imuldiv_IntMulIterativeDpath dpath
  (
    .clk                (clk),
    .reset              (reset),
    .mulreq_msg_a       (mulreq_msg_a),
    .mulreq_msg_b       (mulreq_msg_b),
    .mulreq_val         (mulreq_val),
    .mulreq_rdy         (mulreq_rdy),
    .mulresp_msg_result (mulresp_msg_result),
    .mulresp_val        (mulresp_val),
    .mulresp_rdy        (mulresp_rdy)
  );

  imuldiv_IntMulIterativeCtrl ctrl
  (
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
  input         mulreq_val,         // Request val Signal
  output        mulreq_rdy,         // Request rdy Signal

  output [63:0] mulresp_msg_result, // Result of operation
  output        mulresp_val,        // Response val Signal
  input         mulresp_rdy         // Response rdy Signal
);

  //----------------------------------------------------------------------
  // Sequential Logic
  //----------------------------------------------------------------------

  reg  [63:0] a_reg;       // Register for storing operand A
  reg  [31:0] b_reg;       // Register for storing operand B
  reg  [63:0] result_reg;  // Register for storing result
  reg         val_reg;     // Register for storing valid bit

  always @( posedge clk ) begin

    // Stall the pipeline if the response interface is not ready
    if ( mulresp_rdy ) begin
      a_reg   <= mulreq_msg_a;
      b_reg   <= mulreq_msg_b;
      val_reg <= mulreq_val;
    end

    // assign mux output to reigster
    a_reg <= a_out;
    b_reg <= b_out;
    result_reg <= result_mux_out;

  end

  //----------------------------------------------------------------------
  // Combinational Logic
  //----------------------------------------------------------------------

  // Extract sign bits
  wire sign_bit_a = mulreq_msg_a[31];
  wire sign_bit_b = mulreq_msg_b[31];

  // Unsign operands if necessary

  wire [63:0] unsigned_a = ( sign_bit_a ) ? (~a_reg + 1'b1) : a_reg;
  wire [31:0] unsigned_b = ( sign_bit_b ) ? (~b_reg + 1'b1) : b_reg;

  wire [63:0] a_out;
  wire [31:0] b_out;

  shift_module #(
    .dir(1), .W(64))
    shift_module_a(
      .unsigned_num(unsigned_a),
      .sel(a_mux_sel),
      .out(a_out)
    );

  shift_module #(
    .dir(0), .W(32))
    shift_module_b(
      .unsigned_num(unsigned_b),
      .sel(b_mux_sel),
      .out(b_out)
    );

  wire [63:0] result_mux_in;
  wire [63:0] result_mux_out;
  wire [63:0] result_reg_out;
  wire [63:0] adder_out;

  vc_Mux2 #(
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

  vc_Mux2 #(
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
  vc_Mux2 #(
    .W(64))
    sign_mux(
      .in0(sign_in),
      .in1(result_reg_out),
      .sel(sign_mux_sel),
      .out(mulresp_msg_result)
    );










  // wire is_result_signed = sign_bit_a ^ sign_bit_b;
  // assign mulresp_msg_result = ( is_result_signed ) ? (~result_reg + 1'b1) : result_reg;

  // Set the val/rdy signals. The request is ready when the response is
  // ready, and the response is valid when there is valid data in the
  // input registers.
  // assign mulreq_rdy  = mulresp_rdy;
  // assign mulresp_val = val_reg;

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntMulIterativeCtrl
(
);

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

module vc_Mux2 #( parameter W = 1 )
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
  input       [W-1:0] unsigned_num,
  input               sel,
  output reg  [W-1:0] out
);

  reg   [W-1:0] num_reg;
  wire  [W-1:0] mux_in;
  wire  [W-1:0] mux_out;

  vc_Mux2 #(
    .W(W))
    mux(
      .in0(unsigned_num),
      .in1(mux_in),
      .sel(sel),
      .out(mux_out)
    );

  always @(*) begin
    num_reg = mux_out;
    out = num_reg;
  end

  assign mux_in = (dir) ? (num_reg << 1) : (num_reg >> 1);

endmodule

//------------------------------------------------------------------------
// Counter
//------------------------------------------------------------------------

module Counter
(
  input        clk,
  input  [4:0] val,
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

  vc_Mux2 #(
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