
























`timescale 1ns / 1ps

module vadd_vv_path #(
    parameter int VLEN = 128,
    parameter int NFREG = 32
) (
    input  wire             clock,
    input  wire             reset,


    input  wire             valid,
    input  wire [1:0]       sew,
    input  wire [4:0]       vs1_idx,
    input  wire [4:0]       vs2_idx,
    input  wire [4:0]       vd_idx,
    input  wire             vm,
    input  wire [VLEN-1:0]  v0,
    input  wire [7:0]       vl,
    input  wire             vta,
    input  wire             vma,

    output reg  [VLEN-1:0]  vd_out,
    output reg              wb_valid,
    output reg  [4:0]       wb_idx
);

  localparam int LANES64 = 64;


  reg [VLEN-1:0] fpr [0:NFREG-1];
  integer i;
  always @(posedge clock) begin
    if (wb_valid) fpr[wb_idx] <= vd_out;
  end


  wire [VLEN-1:0] vs1 = fpr[vs1_idx];
  wire [VLEN-1:0] vs2 = fpr[vs2_idx];
  wire [VLEN-1:0] old_vd = fpr[vd_idx];


  wire [63:0] vs1_lo = vs1[63:0];
  wire [63:0] vs1_hi = vs1[127:64];
  wire [63:0] vs2_lo = vs2[63:0];
  wire [63:0] vs2_hi = vs2[127:64];








  function automatic [63:0] slice_add;
    input [63:0] a;
    input [63:0] b;
    input [1:0]  sew_i;
    integer l, j, lane, w, idx, carry;
    reg [63:0] acc;
    begin
      acc   = 64'd0;
      w     = 8 << sew_i;
      lane  = 64 / w;
      carry = 0;
      for (l = 0; l < lane; l = l + 1) begin
        carry = 0;
        for (j = 0; j < w; j = j + 1) begin
          idx = l*w + j;
          acc[idx] = a[idx] ^ b[idx] ^ carry[0];
          carry    = ((a[idx] & b[idx]) | (b[idx] & carry[0]) | (a[idx] & carry[0])) ? 1 : 0;
        end
      end
      slice_add = acc;
    end
  endfunction

  wire [63:0] res_lo = slice_add(vs1_lo, vs2_lo, sew);
  wire [63:0] res_hi = slice_add(vs1_hi, vs2_hi, sew);
  wire [VLEN-1:0] raw = {res_hi, res_lo};


  reg [VLEN-1:0] raw_r;
  reg            valid_r;
  reg [VLEN-1:0] old_vd_r, v0_r;
  reg [4:0]      vd_idx_r;
  reg [1:0]      sew_r;
  reg [7:0]      vl_r;
  reg            vm_r, vta_r, vma_r;
  always @(posedge clock) begin
    valid_r   <= valid & ~reset;
    raw_r     <= raw;
    old_vd_r  <= old_vd;
    v0_r      <= v0;
    vd_idx_r  <= vd_idx;
    sew_r     <= sew;
    vl_r      <= vl;
    vm_r      <= vm;
    vta_r     <= vta;
    vma_r     <= vma;
  end








  reg [VLEN-1:0] merged;
  integer e, j, w, nlane, idx;
  reg masked_off, past_vl;
  always @(*) begin
    merged  = {VLEN{1'b0}};
    w       = 8 << sew_r;
    nlane   = VLEN / w;
    past_vl = 1'b0;
    for (e = 0; e < nlane; e = e + 1) begin
      masked_off = (vm_r == 1'b0) && (v0_r[e] == 1'b0);
      past_vl    = (e >= vl_r);
      for (j = 0; j < w; j = j + 1) begin
        idx = e*w + j;
        if (past_vl)
          merged[idx] = vta_r ? 1'b1 : old_vd_r[idx];
        else if (masked_off)
          merged[idx] = vma_r ? 1'b1 : old_vd_r[idx];
        else
          merged[idx] = raw_r[idx];
      end
    end
  end

  always @(posedge clock) begin
    wb_valid  <= valid_r;
    wb_idx    <= vd_idx_r;
    vd_out    <= merged;
  end


  task automatic preload(input [4:0] idx, input [VLEN-1:0] val);
    fpr[idx] = val;
  endtask

  initial begin
    for (i = 0; i < NFREG; i = i + 1) fpr[i] = {VLEN{1'b0}};
    wb_valid = 1'b0; wb_idx = 5'd0; vd_out = {VLEN{1'b0}};
  end

endmodule
