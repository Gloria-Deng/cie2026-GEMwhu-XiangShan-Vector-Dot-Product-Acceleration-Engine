








module xs_vdot_unit #(
    parameter int VLEN   = 128,
    parameter int SEW    = 8,
    parameter int NLANES = 8,
    parameter int ACCW   = 19,
    parameter int OUTW   = 32,
    parameter int TREE   = 0
) (
    input  wire            clock,
    input  wire            reset,
    input  wire            fire,
    input  wire [VLEN-1:0] vs1,
    input  wire [VLEN-1:0] vs2,
    output wire [VLEN-1:0] vd,
    output wire            valid
);

  localparam int LANES = 16;
  localparam int DW    = LANES * SEW;








  wire [DW-1:0] vs1w, vs2w;
  assign vs1w = vs1;
  assign vs2w = vs2;






  wire [DW-1:0] vs1x;
  assign vs1x = vs1w;


  wire [DW-1:0] vs1g, vs2g;
  generate
    for (genvar gl = 0; gl < LANES; gl = gl + 1) begin : g_gate
      assign vs1g[gl*SEW +: SEW] = (gl < NLANES) ? vs1x[gl*SEW +: SEW] : {SEW{1'b0}};
      assign vs2g[gl*SEW +: SEW] = (gl < NLANES) ? vs2w[gl*SEW +: SEW] : {SEW{1'b0}};
    end
  endgenerate


  wire [ACCW-1:0] prod_comb [0:LANES-1];
  generate
    for (genvar gp = 0; gp < LANES; gp = gp + 1) begin : g_prod
      wire [SEW-1:0]   av = vs1g[gp*SEW +: SEW];
      wire [SEW-1:0]   bv = vs2g[gp*SEW +: SEW];
      wire [2*SEW-1:0] ae = {{SEW{av[SEW-1]}}, av};
      wire [2*SEW-1:0] be = {{SEW{bv[SEW-1]}}, bv};
      wire [4*SEW-1:0] pe = $signed(ae) * $signed(be);
      assign prod_comb[gp] = pe[ACCW-1:0];
    end
  endgenerate

  reg [ACCW-1:0] prod_r [0:LANES-1];
  reg fire_r;
  always @(posedge clock) begin
    if (reset) begin
      fire_r <= 1'b0;
      for (int i = 0; i < LANES; i++) prod_r[i] <= {ACCW{1'b0}};
    end else begin
      fire_r <= fire;
      if (fire)
        for (int i = 0; i < LANES; i++) prod_r[i] <= prod_comb[i];
    end
  end


  wire [ACCW-1:0] cpa_l0_0 = prod_r[0] + prod_r[1];
  wire [ACCW-1:0] cpa_l0_1 = prod_r[2] + prod_r[3];
  wire [ACCW-1:0] cpa_l0_2 = prod_r[4] + prod_r[5];
  wire [ACCW-1:0] cpa_l0_3 = prod_r[6] + prod_r[7];
  wire [ACCW-1:0] cpa_l0_4 = prod_r[8] + prod_r[9];
  wire [ACCW-1:0] cpa_l0_5 = prod_r[10] + prod_r[11];
  wire [ACCW-1:0] cpa_l0_6 = prod_r[12] + prod_r[13];
  wire [ACCW-1:0] cpa_l0_7 = prod_r[14] + prod_r[15];

  wire [ACCW-1:0] cpa_l1_0 = cpa_l0_0 + cpa_l0_1;
  wire [ACCW-1:0] cpa_l1_1 = cpa_l0_2 + cpa_l0_3;
  wire [ACCW-1:0] cpa_l1_2 = cpa_l0_4 + cpa_l0_5;
  wire [ACCW-1:0] cpa_l1_3 = cpa_l0_6 + cpa_l0_7;

  wire [ACCW-1:0] cpa_l2_0 = cpa_l1_0 + cpa_l1_1;
  wire [ACCW-1:0] cpa_l2_1 = cpa_l1_2 + cpa_l1_3;

  wire [ACCW-1:0] cpa_l3_0 = cpa_l2_0 + cpa_l2_1;

  wire [ACCW-1:0] csa_l0_g0_s, csa_l0_g0_cw, csa_l0_g0;
  genvar gv_csa_l0_g0;
  generate
    for (gv_csa_l0_g0 = 0; gv_csa_l0_g0 < ACCW; gv_csa_l0_g0 = gv_csa_l0_g0 + 1) begin : g_csa_l0_g0
      wire x = prod_r[0][gv_csa_l0_g0] ^ prod_r[1][gv_csa_l0_g0] ^ prod_r[2][gv_csa_l0_g0];
      wire cy = (prod_r[0][gv_csa_l0_g0] & prod_r[1][gv_csa_l0_g0]) | (prod_r[1][gv_csa_l0_g0] & prod_r[2][gv_csa_l0_g0]) | (prod_r[0][gv_csa_l0_g0] & prod_r[2][gv_csa_l0_g0]);
      assign csa_l0_g0_s[gv_csa_l0_g0] = x;
      assign csa_l0_g0_cw[gv_csa_l0_g0] = cy;
    end
  endgenerate
  assign csa_l0_g0 = {csa_l0_g0_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l0_g1_s, csa_l0_g1_cw, csa_l0_g1;
  genvar gv_csa_l0_g1;
  generate
    for (gv_csa_l0_g1 = 0; gv_csa_l0_g1 < ACCW; gv_csa_l0_g1 = gv_csa_l0_g1 + 1) begin : g_csa_l0_g1
      wire x = prod_r[3][gv_csa_l0_g1] ^ prod_r[4][gv_csa_l0_g1] ^ prod_r[5][gv_csa_l0_g1];
      wire cy = (prod_r[3][gv_csa_l0_g1] & prod_r[4][gv_csa_l0_g1]) | (prod_r[4][gv_csa_l0_g1] & prod_r[5][gv_csa_l0_g1]) | (prod_r[3][gv_csa_l0_g1] & prod_r[5][gv_csa_l0_g1]);
      assign csa_l0_g1_s[gv_csa_l0_g1] = x;
      assign csa_l0_g1_cw[gv_csa_l0_g1] = cy;
    end
  endgenerate
  assign csa_l0_g1 = {csa_l0_g1_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l0_g2_s, csa_l0_g2_cw, csa_l0_g2;
  genvar gv_csa_l0_g2;
  generate
    for (gv_csa_l0_g2 = 0; gv_csa_l0_g2 < ACCW; gv_csa_l0_g2 = gv_csa_l0_g2 + 1) begin : g_csa_l0_g2
      wire x = prod_r[6][gv_csa_l0_g2] ^ prod_r[7][gv_csa_l0_g2] ^ prod_r[8][gv_csa_l0_g2];
      wire cy = (prod_r[6][gv_csa_l0_g2] & prod_r[7][gv_csa_l0_g2]) | (prod_r[7][gv_csa_l0_g2] & prod_r[8][gv_csa_l0_g2]) | (prod_r[6][gv_csa_l0_g2] & prod_r[8][gv_csa_l0_g2]);
      assign csa_l0_g2_s[gv_csa_l0_g2] = x;
      assign csa_l0_g2_cw[gv_csa_l0_g2] = cy;
    end
  endgenerate
  assign csa_l0_g2 = {csa_l0_g2_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l0_g3_s, csa_l0_g3_cw, csa_l0_g3;
  genvar gv_csa_l0_g3;
  generate
    for (gv_csa_l0_g3 = 0; gv_csa_l0_g3 < ACCW; gv_csa_l0_g3 = gv_csa_l0_g3 + 1) begin : g_csa_l0_g3
      wire x = prod_r[9][gv_csa_l0_g3] ^ prod_r[10][gv_csa_l0_g3] ^ prod_r[11][gv_csa_l0_g3];
      wire cy = (prod_r[9][gv_csa_l0_g3] & prod_r[10][gv_csa_l0_g3]) | (prod_r[10][gv_csa_l0_g3] & prod_r[11][gv_csa_l0_g3]) | (prod_r[9][gv_csa_l0_g3] & prod_r[11][gv_csa_l0_g3]);
      assign csa_l0_g3_s[gv_csa_l0_g3] = x;
      assign csa_l0_g3_cw[gv_csa_l0_g3] = cy;
    end
  endgenerate
  assign csa_l0_g3 = {csa_l0_g3_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l0_g4_s, csa_l0_g4_cw, csa_l0_g4;
  genvar gv_csa_l0_g4;
  generate
    for (gv_csa_l0_g4 = 0; gv_csa_l0_g4 < ACCW; gv_csa_l0_g4 = gv_csa_l0_g4 + 1) begin : g_csa_l0_g4
      wire x = prod_r[12][gv_csa_l0_g4] ^ prod_r[13][gv_csa_l0_g4] ^ prod_r[14][gv_csa_l0_g4];
      wire cy = (prod_r[12][gv_csa_l0_g4] & prod_r[13][gv_csa_l0_g4]) | (prod_r[13][gv_csa_l0_g4] & prod_r[14][gv_csa_l0_g4]) | (prod_r[12][gv_csa_l0_g4] & prod_r[14][gv_csa_l0_g4]);
      assign csa_l0_g4_s[gv_csa_l0_g4] = x;
      assign csa_l0_g4_cw[gv_csa_l0_g4] = cy;
    end
  endgenerate
  assign csa_l0_g4 = {csa_l0_g4_cw[ACCW-2:0], 1'b0};

  wire [ACCW-1:0] csa_l1_g0_s, csa_l1_g0_cw, csa_l1_g0;
  genvar gv_csa_l1_g0;
  generate
    for (gv_csa_l1_g0 = 0; gv_csa_l1_g0 < ACCW; gv_csa_l1_g0 = gv_csa_l1_g0 + 1) begin : g_csa_l1_g0
      wire x = csa_l0_g0_s[gv_csa_l1_g0] ^ csa_l0_g0[gv_csa_l1_g0] ^ csa_l0_g1_s[gv_csa_l1_g0];
      wire cy = (csa_l0_g0_s[gv_csa_l1_g0] & csa_l0_g0[gv_csa_l1_g0]) | (csa_l0_g0[gv_csa_l1_g0] & csa_l0_g1_s[gv_csa_l1_g0]) | (csa_l0_g0_s[gv_csa_l1_g0] & csa_l0_g1_s[gv_csa_l1_g0]);
      assign csa_l1_g0_s[gv_csa_l1_g0] = x;
      assign csa_l1_g0_cw[gv_csa_l1_g0] = cy;
    end
  endgenerate
  assign csa_l1_g0 = {csa_l1_g0_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l1_g1_s, csa_l1_g1_cw, csa_l1_g1;
  genvar gv_csa_l1_g1;
  generate
    for (gv_csa_l1_g1 = 0; gv_csa_l1_g1 < ACCW; gv_csa_l1_g1 = gv_csa_l1_g1 + 1) begin : g_csa_l1_g1
      wire x = csa_l0_g1[gv_csa_l1_g1] ^ csa_l0_g2_s[gv_csa_l1_g1] ^ csa_l0_g2[gv_csa_l1_g1];
      wire cy = (csa_l0_g1[gv_csa_l1_g1] & csa_l0_g2_s[gv_csa_l1_g1]) | (csa_l0_g2_s[gv_csa_l1_g1] & csa_l0_g2[gv_csa_l1_g1]) | (csa_l0_g1[gv_csa_l1_g1] & csa_l0_g2[gv_csa_l1_g1]);
      assign csa_l1_g1_s[gv_csa_l1_g1] = x;
      assign csa_l1_g1_cw[gv_csa_l1_g1] = cy;
    end
  endgenerate
  assign csa_l1_g1 = {csa_l1_g1_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l1_g2_s, csa_l1_g2_cw, csa_l1_g2;
  genvar gv_csa_l1_g2;
  generate
    for (gv_csa_l1_g2 = 0; gv_csa_l1_g2 < ACCW; gv_csa_l1_g2 = gv_csa_l1_g2 + 1) begin : g_csa_l1_g2
      wire x = csa_l0_g3_s[gv_csa_l1_g2] ^ csa_l0_g3[gv_csa_l1_g2] ^ csa_l0_g4_s[gv_csa_l1_g2];
      wire cy = (csa_l0_g3_s[gv_csa_l1_g2] & csa_l0_g3[gv_csa_l1_g2]) | (csa_l0_g3[gv_csa_l1_g2] & csa_l0_g4_s[gv_csa_l1_g2]) | (csa_l0_g3_s[gv_csa_l1_g2] & csa_l0_g4_s[gv_csa_l1_g2]);
      assign csa_l1_g2_s[gv_csa_l1_g2] = x;
      assign csa_l1_g2_cw[gv_csa_l1_g2] = cy;
    end
  endgenerate
  assign csa_l1_g2 = {csa_l1_g2_cw[ACCW-2:0], 1'b0};

  wire [ACCW-1:0] csa_l2_g0_s, csa_l2_g0_cw, csa_l2_g0;
  genvar gv_csa_l2_g0;
  generate
    for (gv_csa_l2_g0 = 0; gv_csa_l2_g0 < ACCW; gv_csa_l2_g0 = gv_csa_l2_g0 + 1) begin : g_csa_l2_g0
      wire x = csa_l1_g0_s[gv_csa_l2_g0] ^ csa_l1_g0[gv_csa_l2_g0] ^ csa_l1_g1_s[gv_csa_l2_g0];
      wire cy = (csa_l1_g0_s[gv_csa_l2_g0] & csa_l1_g0[gv_csa_l2_g0]) | (csa_l1_g0[gv_csa_l2_g0] & csa_l1_g1_s[gv_csa_l2_g0]) | (csa_l1_g0_s[gv_csa_l2_g0] & csa_l1_g1_s[gv_csa_l2_g0]);
      assign csa_l2_g0_s[gv_csa_l2_g0] = x;
      assign csa_l2_g0_cw[gv_csa_l2_g0] = cy;
    end
  endgenerate
  assign csa_l2_g0 = {csa_l2_g0_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l2_g1_s, csa_l2_g1_cw, csa_l2_g1;
  genvar gv_csa_l2_g1;
  generate
    for (gv_csa_l2_g1 = 0; gv_csa_l2_g1 < ACCW; gv_csa_l2_g1 = gv_csa_l2_g1 + 1) begin : g_csa_l2_g1
      wire x = csa_l1_g1[gv_csa_l2_g1] ^ csa_l1_g2_s[gv_csa_l2_g1] ^ csa_l1_g2[gv_csa_l2_g1];
      wire cy = (csa_l1_g1[gv_csa_l2_g1] & csa_l1_g2_s[gv_csa_l2_g1]) | (csa_l1_g2_s[gv_csa_l2_g1] & csa_l1_g2[gv_csa_l2_g1]) | (csa_l1_g1[gv_csa_l2_g1] & csa_l1_g2[gv_csa_l2_g1]);
      assign csa_l2_g1_s[gv_csa_l2_g1] = x;
      assign csa_l2_g1_cw[gv_csa_l2_g1] = cy;
    end
  endgenerate
  assign csa_l2_g1 = {csa_l2_g1_cw[ACCW-2:0], 1'b0};

  wire [ACCW-1:0] csa_l3_g0_s, csa_l3_g0_cw, csa_l3_g0;
  genvar gv_csa_l3_g0;
  generate
    for (gv_csa_l3_g0 = 0; gv_csa_l3_g0 < ACCW; gv_csa_l3_g0 = gv_csa_l3_g0 + 1) begin : g_csa_l3_g0
      wire x = csa_l2_g0_s[gv_csa_l3_g0] ^ csa_l2_g0[gv_csa_l3_g0] ^ csa_l2_g1_s[gv_csa_l3_g0];
      wire cy = (csa_l2_g0_s[gv_csa_l3_g0] & csa_l2_g0[gv_csa_l3_g0]) | (csa_l2_g0[gv_csa_l3_g0] & csa_l2_g1_s[gv_csa_l3_g0]) | (csa_l2_g0_s[gv_csa_l3_g0] & csa_l2_g1_s[gv_csa_l3_g0]);
      assign csa_l3_g0_s[gv_csa_l3_g0] = x;
      assign csa_l3_g0_cw[gv_csa_l3_g0] = cy;
    end
  endgenerate
  assign csa_l3_g0 = {csa_l3_g0_cw[ACCW-2:0], 1'b0};
  wire [ACCW-1:0] csa_l3_g1_s, csa_l3_g1_cw, csa_l3_g1;
  genvar gv_csa_l3_g1;
  generate
    for (gv_csa_l3_g1 = 0; gv_csa_l3_g1 < ACCW; gv_csa_l3_g1 = gv_csa_l3_g1 + 1) begin : g_csa_l3_g1
      wire x = csa_l2_g1[gv_csa_l3_g1] ^ csa_l0_g4[gv_csa_l3_g1] ^ prod_r[15][gv_csa_l3_g1];
      wire cy = (csa_l2_g1[gv_csa_l3_g1] & csa_l0_g4[gv_csa_l3_g1]) | (csa_l0_g4[gv_csa_l3_g1] & prod_r[15][gv_csa_l3_g1]) | (csa_l2_g1[gv_csa_l3_g1] & prod_r[15][gv_csa_l3_g1]);
      assign csa_l3_g1_s[gv_csa_l3_g1] = x;
      assign csa_l3_g1_cw[gv_csa_l3_g1] = cy;
    end
  endgenerate
  assign csa_l3_g1 = {csa_l3_g1_cw[ACCW-2:0], 1'b0};

  wire [ACCW-1:0] csa_l4_g0_s, csa_l4_g0_cw, csa_l4_g0;
  genvar gv_csa_l4_g0;
  generate
    for (gv_csa_l4_g0 = 0; gv_csa_l4_g0 < ACCW; gv_csa_l4_g0 = gv_csa_l4_g0 + 1) begin : g_csa_l4_g0
      wire x = csa_l3_g0_s[gv_csa_l4_g0] ^ csa_l3_g0[gv_csa_l4_g0] ^ csa_l3_g1_s[gv_csa_l4_g0];
      wire cy = (csa_l3_g0_s[gv_csa_l4_g0] & csa_l3_g0[gv_csa_l4_g0]) | (csa_l3_g0[gv_csa_l4_g0] & csa_l3_g1_s[gv_csa_l4_g0]) | (csa_l3_g0_s[gv_csa_l4_g0] & csa_l3_g1_s[gv_csa_l4_g0]);
      assign csa_l4_g0_s[gv_csa_l4_g0] = x;
      assign csa_l4_g0_cw[gv_csa_l4_g0] = cy;
    end
  endgenerate
  assign csa_l4_g0 = {csa_l4_g0_cw[ACCW-2:0], 1'b0};

  wire [ACCW-1:0] csa_l5_g0_s, csa_l5_g0_cw, csa_l5_g0;
  genvar gv_csa_l5_g0;
  generate
    for (gv_csa_l5_g0 = 0; gv_csa_l5_g0 < ACCW; gv_csa_l5_g0 = gv_csa_l5_g0 + 1) begin : g_csa_l5_g0
      wire x = csa_l4_g0_s[gv_csa_l5_g0] ^ csa_l4_g0[gv_csa_l5_g0] ^ csa_l3_g1[gv_csa_l5_g0];
      wire cy = (csa_l4_g0_s[gv_csa_l5_g0] & csa_l4_g0[gv_csa_l5_g0]) | (csa_l4_g0[gv_csa_l5_g0] & csa_l3_g1[gv_csa_l5_g0]) | (csa_l4_g0_s[gv_csa_l5_g0] & csa_l3_g1[gv_csa_l5_g0]);
      assign csa_l5_g0_s[gv_csa_l5_g0] = x;
      assign csa_l5_g0_cw[gv_csa_l5_g0] = cy;
    end
  endgenerate
  assign csa_l5_g0 = {csa_l5_g0_cw[ACCW-2:0], 1'b0};

  wire [ACCW-1:0] ser_0 = prod_r[0] + prod_r[1];
  wire [ACCW-1:0] ser_1 = ser_0 + prod_r[2];
  wire [ACCW-1:0] ser_2 = ser_1 + prod_r[3];
  wire [ACCW-1:0] ser_3 = ser_2 + prod_r[4];
  wire [ACCW-1:0] ser_4 = ser_3 + prod_r[5];
  wire [ACCW-1:0] ser_5 = ser_4 + prod_r[6];
  wire [ACCW-1:0] ser_6 = ser_5 + prod_r[7];
  wire [ACCW-1:0] ser_7 = ser_6 + prod_r[8];
  wire [ACCW-1:0] ser_8 = ser_7 + prod_r[9];
  wire [ACCW-1:0] ser_9 = ser_8 + prod_r[10];
  wire [ACCW-1:0] ser_10 = ser_9 + prod_r[11];
  wire [ACCW-1:0] ser_11 = ser_10 + prod_r[12];
  wire [ACCW-1:0] ser_12 = ser_11 + prod_r[13];
  wire [ACCW-1:0] ser_13 = ser_12 + prod_r[14];
  wire [ACCW-1:0] ser_14 = ser_13 + prod_r[15];
  wire [ACCW-1:0] red_cpa = cpa_l3_0;
  wire [ACCW-1:0] red_csa = csa_l5_g0_s + csa_l5_g0;
  wire [ACCW-1:0] red_ser = ser_14;

  wire [ACCW-1:0] red_comb;
  generate
    if (TREE == 0)      assign red_comb = red_cpa;
    else if (TREE == 1) assign red_comb = red_csa;
    else                assign red_comb = red_ser;
  endgenerate

  reg [ACCW-1:0] red_r;
  reg valid_r;
  always @(posedge clock) begin
    if (reset) begin
      red_r   <= {ACCW{1'b0}};
      valid_r <= 1'b0;
    end else begin
      red_r   <= red_comb;
      valid_r <= fire_r;
    end
  end









  wire [OUTW-1:0] out_field;
  generate
    if (OUTW > ACCW) begin : g_sext
      assign out_field = {{(OUTW-ACCW){red_r[ACCW-1]}}, red_r};
    end else begin : g_trunc
      assign out_field = red_r[OUTW-1:0];
    end
  endgenerate



  assign vd    = { {(VLEN-OUTW){1'b0}}, out_field };
  assign valid = reset ? 1'b0 : valid_r;

endmodule
