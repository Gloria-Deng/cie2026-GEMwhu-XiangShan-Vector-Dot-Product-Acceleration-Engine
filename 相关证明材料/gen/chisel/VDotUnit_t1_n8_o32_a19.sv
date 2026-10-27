

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

module VDotUnit(
  input          clock,
                 reset,
                 io_fire,
  input  [127:0] io_vs1,
                 io_vs2,
  output [127:0] io_vd,
  output         io_valid
);

  reg  [18:0] prod_0;
  reg  [18:0] prod_1;
  reg  [18:0] prod_2;
  reg  [18:0] prod_3;
  reg  [18:0] prod_4;
  reg  [18:0] prod_5;
  reg  [18:0] prod_6;
  reg  [18:0] prod_7;
  reg         fireS1;
  reg  [18:0] red;
  reg         validS1;
  wire [15:0] prodComb_prod =
    {{8{io_vs1[7]}}, io_vs1[7:0]} * {{8{io_vs2[7]}}, io_vs2[7:0]};
  wire [15:0] prodComb_prod_1 =
    {{8{io_vs1[15]}}, io_vs1[15:8]} * {{8{io_vs2[15]}}, io_vs2[15:8]};
  wire [15:0] prodComb_prod_2 =
    {{8{io_vs1[23]}}, io_vs1[23:16]} * {{8{io_vs2[23]}}, io_vs2[23:16]};
  wire [15:0] prodComb_prod_3 =
    {{8{io_vs1[31]}}, io_vs1[31:24]} * {{8{io_vs2[31]}}, io_vs2[31:24]};
  wire [15:0] prodComb_prod_4 =
    {{8{io_vs1[39]}}, io_vs1[39:32]} * {{8{io_vs2[39]}}, io_vs2[39:32]};
  wire [15:0] prodComb_prod_5 =
    {{8{io_vs1[47]}}, io_vs1[47:40]} * {{8{io_vs2[47]}}, io_vs2[47:40]};
  wire [15:0] prodComb_prod_6 =
    {{8{io_vs1[55]}}, io_vs1[55:48]} * {{8{io_vs2[55]}}, io_vs2[55:48]};
  wire [15:0] prodComb_prod_7 =
    {{8{io_vs1[63]}}, io_vs1[63:56]} * {{8{io_vs2[63]}}, io_vs2[63:56]};
  wire [18:0] redCsa_r_out_0 = prod_0 ^ prod_1 ^ prod_2;
  wire [17:0] redCsa_r_out_maj =
    prod_0[17:0] & prod_1[17:0] | prod_1[17:0] & prod_2[17:0] | prod_0[17:0]
    & prod_2[17:0];
  wire [18:0] redCsa_r_out_2 = prod_3 ^ prod_4 ^ prod_5;
  wire [17:0] redCsa_r_out_maj_1 =
    prod_3[17:0] & prod_4[17:0] | prod_4[17:0] & prod_5[17:0] | prod_3[17:0]
    & prod_5[17:0];
  wire [18:0] _redCsa_r_out_sum_T_2 = prod_6 ^ prod_7;
  wire [17:0] _redCsa_r_out_T_4 = prod_6[17:0] & prod_7[17:0];
  wire [18:0] redCsa_r_out_0_1 =
    redCsa_r_out_0 ^ {redCsa_r_out_maj, 1'h0} ^ redCsa_r_out_2;
  wire [17:0] _GEN = {redCsa_r_out_maj[16:0], 1'h0};
  wire [17:0] redCsa_r_out_maj_5 =
    redCsa_r_out_0[17:0] & _GEN | _GEN & redCsa_r_out_2[17:0] | redCsa_r_out_0[17:0]
    & redCsa_r_out_2[17:0];
  wire [18:0] redCsa_r_out_2_1 =
    {redCsa_r_out_maj_1, 1'h0} ^ _redCsa_r_out_sum_T_2 ^ {_redCsa_r_out_T_4, 1'h0};
  wire [17:0] _GEN_0 = {redCsa_r_out_maj_1[16:0], 1'h0};
  wire [17:0] _GEN_1 = {_redCsa_r_out_T_4[16:0], 1'h0};
  wire [17:0] redCsa_r_out_maj_6 =
    _GEN_0 & _redCsa_r_out_sum_T_2[17:0] | _redCsa_r_out_sum_T_2[17:0] & _GEN_1 | _GEN_0
    & _GEN_1;
  wire [18:0] redCsa_r_out_0_2 =
    redCsa_r_out_0_1 ^ {redCsa_r_out_maj_5, 1'h0} ^ redCsa_r_out_2_1;
  wire [17:0] _GEN_2 = {redCsa_r_out_maj_5[16:0], 1'h0};
  wire [17:0] redCsa_r_out_maj_8 =
    redCsa_r_out_0_1[17:0] & _GEN_2 | _GEN_2 & redCsa_r_out_2_1[17:0]
    | redCsa_r_out_0_1[17:0] & redCsa_r_out_2_1[17:0];
  wire [18:0] redCsa_r_out_0_3 =
    redCsa_r_out_0_2 ^ {redCsa_r_out_maj_8, 1'h0} ^ {redCsa_r_out_maj_6, 1'h0};
  wire [17:0] _GEN_3 = {redCsa_r_out_maj_8[16:0], 1'h0};
  wire [17:0] _GEN_4 = {redCsa_r_out_maj_6[16:0], 1'h0};
  wire [17:0] redCsa_r_out_maj_10 =
    redCsa_r_out_0_2[17:0] & _GEN_3 | _GEN_3 & _GEN_4 | redCsa_r_out_0_2[17:0] & _GEN_4;
  wire [18:0] _redCsa_r_out_sum_T_12 = redCsa_r_out_0_3 ^ {redCsa_r_out_maj_10, 1'h0};
  wire [17:0] _redCsa_r_out_T_24 =
    redCsa_r_out_0_3[17:0] & {redCsa_r_out_maj_10[16:0], 1'h0};
  always @(posedge clock) begin
    if (reset) begin
      prod_0 <= 19'h0;
      prod_1 <= 19'h0;
      prod_2 <= 19'h0;
      prod_3 <= 19'h0;
      prod_4 <= 19'h0;
      prod_5 <= 19'h0;
      prod_6 <= 19'h0;
      prod_7 <= 19'h0;
      fireS1 <= 1'h0;
      red <= 19'h0;
      validS1 <= 1'h0;
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
      fireS1 <= io_fire;
      red <=
        (_redCsa_r_out_sum_T_12 ^ {_redCsa_r_out_T_24, 1'h0})
        + {_redCsa_r_out_sum_T_12[17:0] & {_redCsa_r_out_T_24[16:0], 1'h0}, 1'h0};
      validS1 <= fireS1;
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
        fireS1 = _RANDOM[4'h9][16];
        red = {_RANDOM[4'h9][31:17], _RANDOM[4'hA][3:0]};
        validS1 = _RANDOM[4'hA][4];
      `endif
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign io_vd = {96'h0, {13{red[18]}}, red};
  assign io_valid = ~reset & validS1;
endmodule

