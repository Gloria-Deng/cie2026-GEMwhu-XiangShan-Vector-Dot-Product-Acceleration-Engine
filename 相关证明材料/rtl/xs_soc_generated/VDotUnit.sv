

`ifndef RANDOMIZE
  `ifdef RANDOMIZE_MEM_INIT
    `define RANDOMIZE
  `endif
`endif
`ifndef RANDOMIZE
  `ifdef RANDOMIZE_REG_INIT
    `define RANDOMIZE
  `endif
`endif


`ifndef RANDOM
  `define RANDOM $random
`endif



`ifndef INIT_RANDOM
  `define INIT_RANDOM
`endif



`ifndef RANDOMIZE_DELAY
  `define RANDOMIZE_DELAY 0.002
`endif


`ifndef INIT_RANDOM_PROLOG_
  `ifdef RANDOMIZE
    `ifdef VERILATOR
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM
    `else
      `define INIT_RANDOM_PROLOG_ `INIT_RANDOM #`RANDOMIZE_DELAY begin end
    `endif
  `else
    `define INIT_RANDOM_PROLOG_
  `endif
`endif


`ifndef SYNTHESIS
  `ifndef ENABLE_INITIAL_REG_
    `define ENABLE_INITIAL_REG_
  `endif
`endif


`ifndef SYNTHESIS
  `ifndef ENABLE_INITIAL_MEM_
    `define ENABLE_INITIAL_MEM_
  `endif
`endif




`ifndef ASSERT_VERBOSE_COND_
  `ifdef ASSERT_VERBOSE_COND
    `define ASSERT_VERBOSE_COND_ (`ASSERT_VERBOSE_COND)
  `else
    `define ASSERT_VERBOSE_COND_ 1
  `endif
`endif


`ifndef STOP_COND_
  `ifdef STOP_COND
    `define STOP_COND_ (`STOP_COND)
  `else
    `define STOP_COND_ 1
  `endif
`endif

module VDotUnit(
  input          clock,
  input          reset,
  input          io_fire,
  input  [127:0] io_vs1,
  input  [127:0] io_vs2,
  output [127:0] io_vd
);

  reg  [18:0] prod_0;
  reg  [18:0] prod_1;
  reg  [18:0] prod_2;
  reg  [18:0] prod_3;
  reg  [18:0] prod_4;
  reg  [18:0] prod_5;
  reg  [18:0] prod_6;
  reg  [18:0] prod_7;
  reg  [18:0] red;
  wire [15:0] prodComb_prod =
    16'({{8{io_vs1[7]}}, io_vs1[7:0]} * {{8{io_vs2[7]}}, io_vs2[7:0]});
  wire [15:0] prodComb_prod_1 =
    16'({{8{io_vs1[15]}}, io_vs1[15:8]} * {{8{io_vs2[15]}}, io_vs2[15:8]});
  wire [15:0] prodComb_prod_2 =
    16'({{8{io_vs1[23]}}, io_vs1[23:16]} * {{8{io_vs2[23]}}, io_vs2[23:16]});
  wire [15:0] prodComb_prod_3 =
    16'({{8{io_vs1[31]}}, io_vs1[31:24]} * {{8{io_vs2[31]}}, io_vs2[31:24]});
  wire [15:0] prodComb_prod_4 =
    16'({{8{io_vs1[39]}}, io_vs1[39:32]} * {{8{io_vs2[39]}}, io_vs2[39:32]});
  wire [15:0] prodComb_prod_5 =
    16'({{8{io_vs1[47]}}, io_vs1[47:40]} * {{8{io_vs2[47]}}, io_vs2[47:40]});
  wire [15:0] prodComb_prod_6 =
    16'({{8{io_vs1[55]}}, io_vs1[55:48]} * {{8{io_vs2[55]}}, io_vs2[55:48]});
  wire [15:0] prodComb_prod_7 =
    16'({{8{io_vs1[63]}}, io_vs1[63:56]} * {{8{io_vs2[63]}}, io_vs2[63:56]});
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      prod_0 <= 19'h0;
      prod_1 <= 19'h0;
      prod_2 <= 19'h0;
      prod_3 <= 19'h0;
      prod_4 <= 19'h0;
      prod_5 <= 19'h0;
      prod_6 <= 19'h0;
      prod_7 <= 19'h0;
      red <= 19'h0;
    end
    else begin
      if (io_fire) begin
        prod_0 <= {{3{prodComb_prod[15]}}, prodComb_prod};
        prod_1 <= {{3{prodComb_prod_1[15]}}, prodComb_prod_1};
        prod_2 <= {{3{prodComb_prod_2[15]}}, prodComb_prod_2};
        prod_3 <= {{3{prodComb_prod_3[15]}}, prodComb_prod_3};
        prod_4 <= {{3{prodComb_prod_4[15]}}, prodComb_prod_4};
        prod_5 <= {{3{prodComb_prod_5[15]}}, prodComb_prod_5};
        prod_6 <= {{3{prodComb_prod_6[15]}}, prodComb_prod_6};
        prod_7 <= {{3{prodComb_prod_7[15]}}, prodComb_prod_7};
      end
      red <=
        19'(19'(19'(prod_0 + prod_1) + 19'(prod_2 + prod_3))
            + 19'(19'(prod_4 + prod_5) + 19'(prod_6 + prod_7)));
    end
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    logic [31:0] _RANDOM[0:10];
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif
      `ifdef RANDOMIZE_REG_INIT
        for (logic [3:0] i = 4'h0; i < 4'hB; i += 4'h1) begin
          _RANDOM[i] = `RANDOM;
        end
        prod_0 = _RANDOM[4'h0][18:0];
        prod_1 = {_RANDOM[4'h0][31:19], _RANDOM[4'h1][5:0]};
        prod_2 = _RANDOM[4'h1][24:6];
        prod_3 = {_RANDOM[4'h1][31:25], _RANDOM[4'h2][11:0]};
        prod_4 = _RANDOM[4'h2][30:12];
        prod_5 = {_RANDOM[4'h2][31], _RANDOM[4'h3][17:0]};
        prod_6 = {_RANDOM[4'h3][31:18], _RANDOM[4'h4][4:0]};
        prod_7 = _RANDOM[4'h4][23:5];
        red = {_RANDOM[4'h9][31:17], _RANDOM[4'hA][3:0]};
      `endif
      if (reset) begin
        prod_0 = 19'h0;
        prod_1 = 19'h0;
        prod_2 = 19'h0;
        prod_3 = 19'h0;
        prod_4 = 19'h0;
        prod_5 = 19'h0;
        prod_6 = 19'h0;
        prod_7 = 19'h0;
        red = 19'h0;
      end
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign io_vd = {96'h0, {13{red[18]}}, red};
endmodule

