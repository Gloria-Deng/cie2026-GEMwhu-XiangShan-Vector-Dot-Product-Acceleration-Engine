

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

  reg  [19:0] prod_0;
  reg  [19:0] prod_1;
  reg  [19:0] prod_2;
  reg  [19:0] prod_3;
  reg  [19:0] prod_4;
  reg  [19:0] prod_5;
  reg  [19:0] prod_6;
  reg  [19:0] prod_7;
  reg  [19:0] prod_8;
  reg  [19:0] prod_9;
  reg  [19:0] prod_10;
  reg  [19:0] prod_11;
  reg  [19:0] prod_12;
  reg  [19:0] prod_13;
  reg  [19:0] prod_14;
  reg  [19:0] prod_15;
  reg         fireS1;
  reg  [19:0] red;
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
  wire [15:0] prodComb_prod_8 =
    {{8{io_vs1[71]}}, io_vs1[71:64]} * {{8{io_vs2[71]}}, io_vs2[71:64]};
  wire [15:0] prodComb_prod_9 =
    {{8{io_vs1[79]}}, io_vs1[79:72]} * {{8{io_vs2[79]}}, io_vs2[79:72]};
  wire [15:0] prodComb_prod_10 =
    {{8{io_vs1[87]}}, io_vs1[87:80]} * {{8{io_vs2[87]}}, io_vs2[87:80]};
  wire [15:0] prodComb_prod_11 =
    {{8{io_vs1[95]}}, io_vs1[95:88]} * {{8{io_vs2[95]}}, io_vs2[95:88]};
  wire [15:0] prodComb_prod_12 =
    {{8{io_vs1[103]}}, io_vs1[103:96]} * {{8{io_vs2[103]}}, io_vs2[103:96]};
  wire [15:0] prodComb_prod_13 =
    {{8{io_vs1[111]}}, io_vs1[111:104]} * {{8{io_vs2[111]}}, io_vs2[111:104]};
  wire [15:0] prodComb_prod_14 =
    {{8{io_vs1[119]}}, io_vs1[119:112]} * {{8{io_vs2[119]}}, io_vs2[119:112]};
  wire [15:0] prodComb_prod_15 =
    {{8{io_vs1[127]}}, io_vs1[127:120]} * {{8{io_vs2[127]}}, io_vs2[127:120]};
  wire [19:0] redCsa_r_out_0 = prod_0 ^ prod_1 ^ prod_2;
  wire [18:0] redCsa_r_out_maj =
    prod_0[18:0] & prod_1[18:0] | prod_1[18:0] & prod_2[18:0] | prod_0[18:0]
    & prod_2[18:0];
  wire [19:0] redCsa_r_out_2 = prod_3 ^ prod_4 ^ prod_5;
  wire [18:0] redCsa_r_out_maj_1 =
    prod_3[18:0] & prod_4[18:0] | prod_4[18:0] & prod_5[18:0] | prod_3[18:0]
    & prod_5[18:0];
  wire [19:0] redCsa_r_out_4 = prod_6 ^ prod_7 ^ prod_8;
  wire [18:0] redCsa_r_out_maj_2 =
    prod_6[18:0] & prod_7[18:0] | prod_7[18:0] & prod_8[18:0] | prod_6[18:0]
    & prod_8[18:0];
  wire [19:0] redCsa_r_out_6 = prod_9 ^ prod_10 ^ prod_11;
  wire [18:0] redCsa_r_out_maj_3 =
    prod_9[18:0] & prod_10[18:0] | prod_10[18:0] & prod_11[18:0] | prod_9[18:0]
    & prod_11[18:0];
  wire [19:0] redCsa_r_out_8 = prod_12 ^ prod_13 ^ prod_14;
  wire [18:0] redCsa_r_out_maj_4 =
    prod_12[18:0] & prod_13[18:0] | prod_13[18:0] & prod_14[18:0] | prod_12[18:0]
    & prod_14[18:0];
  wire [19:0] redCsa_r_out_0_1 =
    redCsa_r_out_0 ^ {redCsa_r_out_maj, 1'h0} ^ redCsa_r_out_2;
  wire [18:0] _GEN = {redCsa_r_out_maj[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_5 =
    redCsa_r_out_0[18:0] & _GEN | _GEN & redCsa_r_out_2[18:0] | redCsa_r_out_0[18:0]
    & redCsa_r_out_2[18:0];
  wire [19:0] redCsa_r_out_2_1 =
    {redCsa_r_out_maj_1, 1'h0} ^ redCsa_r_out_4 ^ {redCsa_r_out_maj_2, 1'h0};
  wire [18:0] _GEN_0 = {redCsa_r_out_maj_1[17:0], 1'h0};
  wire [18:0] _GEN_1 = {redCsa_r_out_maj_2[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_6 =
    _GEN_0 & redCsa_r_out_4[18:0] | redCsa_r_out_4[18:0] & _GEN_1 | _GEN_0 & _GEN_1;
  wire [19:0] redCsa_r_out_4_1 =
    redCsa_r_out_6 ^ {redCsa_r_out_maj_3, 1'h0} ^ redCsa_r_out_8;
  wire [18:0] _GEN_2 = {redCsa_r_out_maj_3[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_7 =
    redCsa_r_out_6[18:0] & _GEN_2 | _GEN_2 & redCsa_r_out_8[18:0] | redCsa_r_out_6[18:0]
    & redCsa_r_out_8[18:0];
  wire [19:0] redCsa_r_out_0_2 =
    redCsa_r_out_0_1 ^ {redCsa_r_out_maj_5, 1'h0} ^ redCsa_r_out_2_1;
  wire [18:0] _GEN_3 = {redCsa_r_out_maj_5[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_8 =
    redCsa_r_out_0_1[18:0] & _GEN_3 | _GEN_3 & redCsa_r_out_2_1[18:0]
    | redCsa_r_out_0_1[18:0] & redCsa_r_out_2_1[18:0];
  wire [19:0] redCsa_r_out_2_2 =
    {redCsa_r_out_maj_6, 1'h0} ^ redCsa_r_out_4_1 ^ {redCsa_r_out_maj_7, 1'h0};
  wire [18:0] _GEN_4 = {redCsa_r_out_maj_6[17:0], 1'h0};
  wire [18:0] _GEN_5 = {redCsa_r_out_maj_7[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_9 =
    _GEN_4 & redCsa_r_out_4_1[18:0] | redCsa_r_out_4_1[18:0] & _GEN_5 | _GEN_4 & _GEN_5;
  wire [19:0] redCsa_r_out_0_3 =
    redCsa_r_out_0_2 ^ {redCsa_r_out_maj_8, 1'h0} ^ redCsa_r_out_2_2;
  wire [18:0] _GEN_6 = {redCsa_r_out_maj_8[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_10 =
    redCsa_r_out_0_2[18:0] & _GEN_6 | _GEN_6 & redCsa_r_out_2_2[18:0]
    | redCsa_r_out_0_2[18:0] & redCsa_r_out_2_2[18:0];
  wire [19:0] redCsa_r_out_2_3 =
    {redCsa_r_out_maj_9, 1'h0} ^ {redCsa_r_out_maj_4, 1'h0} ^ prod_15;
  wire [18:0] _GEN_7 = {redCsa_r_out_maj_9[17:0], 1'h0};
  wire [18:0] _GEN_8 = {redCsa_r_out_maj_4[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_11 =
    _GEN_7 & _GEN_8 | _GEN_8 & prod_15[18:0] | _GEN_7 & prod_15[18:0];
  wire [19:0] redCsa_r_out_0_4 =
    redCsa_r_out_0_3 ^ {redCsa_r_out_maj_10, 1'h0} ^ redCsa_r_out_2_3;
  wire [18:0] _GEN_9 = {redCsa_r_out_maj_10[17:0], 1'h0};
  wire [18:0] redCsa_r_out_maj_12 =
    redCsa_r_out_0_3[18:0] & _GEN_9 | _GEN_9 & redCsa_r_out_2_3[18:0]
    | redCsa_r_out_0_3[18:0] & redCsa_r_out_2_3[18:0];
  wire [18:0] _GEN_10 = {redCsa_r_out_maj_12[17:0], 1'h0};
  wire [18:0] _GEN_11 = {redCsa_r_out_maj_11[17:0], 1'h0};
  always @(posedge clock) begin
    if (reset) begin
      prod_0 <= 20'h0;
      prod_1 <= 20'h0;
      prod_2 <= 20'h0;
      prod_3 <= 20'h0;
      prod_4 <= 20'h0;
      prod_5 <= 20'h0;
      prod_6 <= 20'h0;
      prod_7 <= 20'h0;
      prod_8 <= 20'h0;
      prod_9 <= 20'h0;
      prod_10 <= 20'h0;
      prod_11 <= 20'h0;
      prod_12 <= 20'h0;
      prod_13 <= 20'h0;
      prod_14 <= 20'h0;
      prod_15 <= 20'h0;
      fireS1 <= 1'h0;
      red <= 20'h0;
      validS1 <= 1'h0;
    end
    else begin
      if (io_fire) begin
        prod_0 <= {{4{prodComb_prod[15]}}, prodComb_prod};
        prod_1 <= {{4{prodComb_prod_1[15]}}, prodComb_prod_1};
        prod_2 <= {{4{prodComb_prod_2[15]}}, prodComb_prod_2};
        prod_3 <= {{4{prodComb_prod_3[15]}}, prodComb_prod_3};
        prod_4 <= {{4{prodComb_prod_4[15]}}, prodComb_prod_4};
        prod_5 <= {{4{prodComb_prod_5[15]}}, prodComb_prod_5};
        prod_6 <= {{4{prodComb_prod_6[15]}}, prodComb_prod_6};
        prod_7 <= {{4{prodComb_prod_7[15]}}, prodComb_prod_7};
        prod_8 <= {{4{prodComb_prod_8[15]}}, prodComb_prod_8};
        prod_9 <= {{4{prodComb_prod_9[15]}}, prodComb_prod_9};
        prod_10 <= {{4{prodComb_prod_10[15]}}, prodComb_prod_10};
        prod_11 <= {{4{prodComb_prod_11[15]}}, prodComb_prod_11};
        prod_12 <= {{4{prodComb_prod_12[15]}}, prodComb_prod_12};
        prod_13 <= {{4{prodComb_prod_13[15]}}, prodComb_prod_13};
        prod_14 <= {{4{prodComb_prod_14[15]}}, prodComb_prod_14};
        prod_15 <= {{4{prodComb_prod_15[15]}}, prodComb_prod_15};
      end
      fireS1 <= io_fire;
      red <=
        (redCsa_r_out_0_4 ^ {redCsa_r_out_maj_12, 1'h0} ^ {redCsa_r_out_maj_11, 1'h0})
        + {redCsa_r_out_0_4[18:0] & _GEN_10 | _GEN_10 & _GEN_11 | redCsa_r_out_0_4[18:0]
             & _GEN_11,
           1'h0};
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
        prod_0 = _RANDOM[4'h0][19:0];
        prod_1 = {_RANDOM[4'h0][31:20], _RANDOM[4'h1][7:0]};
        prod_2 = _RANDOM[4'h1][27:8];
        prod_3 = {_RANDOM[4'h1][31:28], _RANDOM[4'h2][15:0]};
        prod_4 = {_RANDOM[4'h2][31:16], _RANDOM[4'h3][3:0]};
        prod_5 = _RANDOM[4'h3][23:4];
        prod_6 = {_RANDOM[4'h3][31:24], _RANDOM[4'h4][11:0]};
        prod_7 = _RANDOM[4'h4][31:12];
        prod_8 = _RANDOM[4'h5][19:0];
        prod_9 = {_RANDOM[4'h5][31:20], _RANDOM[4'h6][7:0]};
        prod_10 = _RANDOM[4'h6][27:8];
        prod_11 = {_RANDOM[4'h6][31:28], _RANDOM[4'h7][15:0]};
        prod_12 = {_RANDOM[4'h7][31:16], _RANDOM[4'h8][3:0]};
        prod_13 = _RANDOM[4'h8][23:4];
        prod_14 = {_RANDOM[4'h8][31:24], _RANDOM[4'h9][11:0]};
        prod_15 = _RANDOM[4'h9][31:12];
        fireS1 = _RANDOM[4'hA][0];
        red = _RANDOM[4'hA][20:1];
        validS1 = _RANDOM[4'hA][21];
      `endif
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign io_vd = {96'h0, {12{red[19]}}, red};
  assign io_valid = ~reset & validS1;
endmodule

