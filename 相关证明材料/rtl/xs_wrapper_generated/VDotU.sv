




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
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  assign io_vd = {96'h0, {13{red[18]}}, red};
endmodule

module VDotU(
  input          clock,
  input          reset,
  input          io_flush_valid,
  input          io_flush_bits_isRVC,
  input          io_flush_bits_robIdx_flag,
  input  [7:0]   io_flush_bits_robIdx_value,
  input          io_flush_bits_ftqIdx_flag,
  input  [5:0]   io_flush_bits_ftqIdx_value,
  input  [3:0]   io_flush_bits_ftqOffset,
  input          io_flush_bits_level,
  input          io_flush_bits_interrupt,
  input  [49:0]  io_flush_bits_cfiUpdate_pc,
  input          io_flush_bits_cfiUpdate_pd_valid,
  input          io_flush_bits_cfiUpdate_pd_isRVC,
  input  [1:0]   io_flush_bits_cfiUpdate_pd_brType,
  input          io_flush_bits_cfiUpdate_pd_isCall,
  input          io_flush_bits_cfiUpdate_pd_isRet,
  input  [3:0]   io_flush_bits_cfiUpdate_ssp,
  input  [2:0]   io_flush_bits_cfiUpdate_sctr,
  input          io_flush_bits_cfiUpdate_TOSW_flag,
  input  [4:0]   io_flush_bits_cfiUpdate_TOSW_value,
  input          io_flush_bits_cfiUpdate_TOSR_flag,
  input  [4:0]   io_flush_bits_cfiUpdate_TOSR_value,
  input          io_flush_bits_cfiUpdate_NOS_flag,
  input  [4:0]   io_flush_bits_cfiUpdate_NOS_value,
  input  [50:0]  io_flush_bits_cfiUpdate_topAddr,
  input  [10:0]  io_flush_bits_cfiUpdate_folded_hist_hist_17_folded_hist,
  input  [10:0]  io_flush_bits_cfiUpdate_folded_hist_hist_16_folded_hist,
  input  [6:0]   io_flush_bits_cfiUpdate_folded_hist_hist_15_folded_hist,
  input  [7:0]   io_flush_bits_cfiUpdate_folded_hist_hist_14_folded_hist,
  input  [8:0]   io_flush_bits_cfiUpdate_folded_hist_hist_13_folded_hist,
  input  [3:0]   io_flush_bits_cfiUpdate_folded_hist_hist_12_folded_hist,
  input  [7:0]   io_flush_bits_cfiUpdate_folded_hist_hist_11_folded_hist,
  input  [8:0]   io_flush_bits_cfiUpdate_folded_hist_hist_10_folded_hist,
  input  [6:0]   io_flush_bits_cfiUpdate_folded_hist_hist_9_folded_hist,
  input  [7:0]   io_flush_bits_cfiUpdate_folded_hist_hist_8_folded_hist,
  input  [6:0]   io_flush_bits_cfiUpdate_folded_hist_hist_7_folded_hist,
  input  [8:0]   io_flush_bits_cfiUpdate_folded_hist_hist_6_folded_hist,
  input  [6:0]   io_flush_bits_cfiUpdate_folded_hist_hist_5_folded_hist,
  input  [7:0]   io_flush_bits_cfiUpdate_folded_hist_hist_4_folded_hist,
  input  [7:0]   io_flush_bits_cfiUpdate_folded_hist_hist_3_folded_hist,
  input  [7:0]   io_flush_bits_cfiUpdate_folded_hist_hist_2_folded_hist,
  input  [10:0]  io_flush_bits_cfiUpdate_folded_hist_hist_1_folded_hist,
  input  [7:0]   io_flush_bits_cfiUpdate_folded_hist_hist_0_folded_hist,
  input          io_flush_bits_cfiUpdate_afhob_afhob_5_bits_0,
  input          io_flush_bits_cfiUpdate_afhob_afhob_5_bits_1,
  input          io_flush_bits_cfiUpdate_afhob_afhob_5_bits_2,
  input          io_flush_bits_cfiUpdate_afhob_afhob_5_bits_3,
  input          io_flush_bits_cfiUpdate_afhob_afhob_4_bits_0,
  input          io_flush_bits_cfiUpdate_afhob_afhob_4_bits_1,
  input          io_flush_bits_cfiUpdate_afhob_afhob_4_bits_2,
  input          io_flush_bits_cfiUpdate_afhob_afhob_4_bits_3,
  input          io_flush_bits_cfiUpdate_afhob_afhob_3_bits_0,
  input          io_flush_bits_cfiUpdate_afhob_afhob_3_bits_1,
  input          io_flush_bits_cfiUpdate_afhob_afhob_3_bits_2,
  input          io_flush_bits_cfiUpdate_afhob_afhob_3_bits_3,
  input          io_flush_bits_cfiUpdate_afhob_afhob_2_bits_0,
  input          io_flush_bits_cfiUpdate_afhob_afhob_2_bits_1,
  input          io_flush_bits_cfiUpdate_afhob_afhob_2_bits_2,
  input          io_flush_bits_cfiUpdate_afhob_afhob_2_bits_3,
  input          io_flush_bits_cfiUpdate_afhob_afhob_1_bits_0,
  input          io_flush_bits_cfiUpdate_afhob_afhob_1_bits_1,
  input          io_flush_bits_cfiUpdate_afhob_afhob_1_bits_2,
  input          io_flush_bits_cfiUpdate_afhob_afhob_1_bits_3,
  input          io_flush_bits_cfiUpdate_afhob_afhob_0_bits_0,
  input          io_flush_bits_cfiUpdate_afhob_afhob_0_bits_1,
  input          io_flush_bits_cfiUpdate_afhob_afhob_0_bits_2,
  input          io_flush_bits_cfiUpdate_afhob_afhob_0_bits_3,
  input  [2:0]   io_flush_bits_cfiUpdate_lastBrNumOH,
  input  [3:0]   io_flush_bits_cfiUpdate_ghr,
  input          io_flush_bits_cfiUpdate_histPtr_flag,
  input  [7:0]   io_flush_bits_cfiUpdate_histPtr_value,
  input  [9:0]   io_flush_bits_cfiUpdate_specCnt_0,
  input  [9:0]   io_flush_bits_cfiUpdate_specCnt_1,
  input          io_flush_bits_cfiUpdate_br_hit,
  input          io_flush_bits_cfiUpdate_jr_hit,
  input          io_flush_bits_cfiUpdate_sc_hit,
  input          io_flush_bits_cfiUpdate_predTaken,
  input  [50:0]  io_flush_bits_cfiUpdate_target,
  input          io_flush_bits_cfiUpdate_taken,
  input          io_flush_bits_cfiUpdate_isMisPred,
  input  [1:0]   io_flush_bits_cfiUpdate_shift,
  input          io_flush_bits_cfiUpdate_addIntoHist,
  input          io_flush_bits_cfiUpdate_backendIGPF,
  input          io_flush_bits_cfiUpdate_backendIPF,
  input          io_flush_bits_cfiUpdate_backendIAF,
  input  [63:0]  io_flush_bits_fullTarget,
  input          io_flush_bits_satpFlush,
  input          io_flush_bits_isVlsException,
  input          io_flush_bits_stFtqIdx_flag,
  input  [5:0]   io_flush_bits_stFtqIdx_value,
  input  [3:0]   io_flush_bits_stFtqOffset,
  input  [63:0]  io_flush_bits_debug_runahead_checkpoint_id,
  input          io_flush_bits_debugIsCtrl,
  input          io_flush_bits_debugIsMemVio,
  output         io_in_ready,
  input          io_in_valid,
  input  [8:0]   io_in_bits_ctrl_fuOpType,
  input          io_in_bits_ctrl_robIdx_flag,
  input  [7:0]   io_in_bits_ctrl_robIdx_value,
  input  [7:0]   io_in_bits_ctrl_pdest,
  input          io_in_bits_ctrl_vecWen,
  input          io_in_bits_ctrl_v0Wen,
  input          io_in_bits_ctrl_vpu_vill,
  input          io_in_bits_ctrl_vpu_vma,
  input          io_in_bits_ctrl_vpu_vta,
  input  [1:0]   io_in_bits_ctrl_vpu_vsew,
  input  [2:0]   io_in_bits_ctrl_vpu_vlmul,
  input          io_in_bits_ctrl_vpu_specVill,
  input          io_in_bits_ctrl_vpu_specVma,
  input          io_in_bits_ctrl_vpu_specVta,
  input  [1:0]   io_in_bits_ctrl_vpu_specVsew,
  input  [2:0]   io_in_bits_ctrl_vpu_specVlmul,
  input          io_in_bits_ctrl_vpu_vm,
  input  [7:0]   io_in_bits_ctrl_vpu_vstart,
  input  [2:0]   io_in_bits_ctrl_vpu_frm,
  input          io_in_bits_ctrl_vpu_fpu_isFpToVecInst,
  input          io_in_bits_ctrl_vpu_fpu_isFP32Instr,
  input          io_in_bits_ctrl_vpu_fpu_isFP64Instr,
  input          io_in_bits_ctrl_vpu_fpu_isReduction,
  input          io_in_bits_ctrl_vpu_fpu_isFoldTo1_2,
  input          io_in_bits_ctrl_vpu_fpu_isFoldTo1_4,
  input          io_in_bits_ctrl_vpu_fpu_isFoldTo1_8,
  input  [1:0]   io_in_bits_ctrl_vpu_vxrm,
  input  [6:0]   io_in_bits_ctrl_vpu_vuopIdx,
  input          io_in_bits_ctrl_vpu_lastUop,
  input  [127:0] io_in_bits_ctrl_vpu_vmask,
  input  [7:0]   io_in_bits_ctrl_vpu_vl,
  input  [2:0]   io_in_bits_ctrl_vpu_nf,
  input  [1:0]   io_in_bits_ctrl_vpu_veew,
  input          io_in_bits_ctrl_vpu_isReverse,
  input          io_in_bits_ctrl_vpu_isExt,
  input          io_in_bits_ctrl_vpu_isNarrow,
  input          io_in_bits_ctrl_vpu_isDstMask,
  input          io_in_bits_ctrl_vpu_isOpMask,
  input          io_in_bits_ctrl_vpu_isMove,
  input          io_in_bits_ctrl_vpu_isDependOldVd,
  input          io_in_bits_ctrl_vpu_isWritePartVd,
  input          io_in_bits_ctrl_vpu_isVleff,
  input  [8:0]   io_in_bits_ctrlPipe_0_fuOpType,
  input          io_in_bits_ctrlPipe_0_robIdx_flag,
  input  [7:0]   io_in_bits_ctrlPipe_0_robIdx_value,
  input  [7:0]   io_in_bits_ctrlPipe_0_pdest,
  input          io_in_bits_ctrlPipe_0_vecWen,
  input          io_in_bits_ctrlPipe_0_v0Wen,
  input          io_in_bits_ctrlPipe_0_vpu_vill,
  input          io_in_bits_ctrlPipe_0_vpu_vma,
  input          io_in_bits_ctrlPipe_0_vpu_vta,
  input  [1:0]   io_in_bits_ctrlPipe_0_vpu_vsew,
  input  [2:0]   io_in_bits_ctrlPipe_0_vpu_vlmul,
  input          io_in_bits_ctrlPipe_0_vpu_specVill,
  input          io_in_bits_ctrlPipe_0_vpu_specVma,
  input          io_in_bits_ctrlPipe_0_vpu_specVta,
  input  [1:0]   io_in_bits_ctrlPipe_0_vpu_specVsew,
  input  [2:0]   io_in_bits_ctrlPipe_0_vpu_specVlmul,
  input          io_in_bits_ctrlPipe_0_vpu_vm,
  input  [7:0]   io_in_bits_ctrlPipe_0_vpu_vstart,
  input  [2:0]   io_in_bits_ctrlPipe_0_vpu_frm,
  input          io_in_bits_ctrlPipe_0_vpu_fpu_isFpToVecInst,
  input          io_in_bits_ctrlPipe_0_vpu_fpu_isFP32Instr,
  input          io_in_bits_ctrlPipe_0_vpu_fpu_isFP64Instr,
  input          io_in_bits_ctrlPipe_0_vpu_fpu_isReduction,
  input          io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_2,
  input          io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_4,
  input          io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_8,
  input  [1:0]   io_in_bits_ctrlPipe_0_vpu_vxrm,
  input  [6:0]   io_in_bits_ctrlPipe_0_vpu_vuopIdx,
  input          io_in_bits_ctrlPipe_0_vpu_lastUop,
  input  [127:0] io_in_bits_ctrlPipe_0_vpu_vmask,
  input  [7:0]   io_in_bits_ctrlPipe_0_vpu_vl,
  input  [2:0]   io_in_bits_ctrlPipe_0_vpu_nf,
  input  [1:0]   io_in_bits_ctrlPipe_0_vpu_veew,
  input          io_in_bits_ctrlPipe_0_vpu_isReverse,
  input          io_in_bits_ctrlPipe_0_vpu_isExt,
  input          io_in_bits_ctrlPipe_0_vpu_isNarrow,
  input          io_in_bits_ctrlPipe_0_vpu_isDstMask,
  input          io_in_bits_ctrlPipe_0_vpu_isOpMask,
  input          io_in_bits_ctrlPipe_0_vpu_isMove,
  input          io_in_bits_ctrlPipe_0_vpu_isDependOldVd,
  input          io_in_bits_ctrlPipe_0_vpu_isWritePartVd,
  input          io_in_bits_ctrlPipe_0_vpu_isVleff,
  input  [8:0]   io_in_bits_ctrlPipe_1_fuOpType,
  input          io_in_bits_ctrlPipe_1_robIdx_flag,
  input  [7:0]   io_in_bits_ctrlPipe_1_robIdx_value,
  input  [7:0]   io_in_bits_ctrlPipe_1_pdest,
  input          io_in_bits_ctrlPipe_1_vecWen,
  input          io_in_bits_ctrlPipe_1_v0Wen,
  input          io_in_bits_ctrlPipe_1_vpu_vill,
  input          io_in_bits_ctrlPipe_1_vpu_vma,
  input          io_in_bits_ctrlPipe_1_vpu_vta,
  input  [1:0]   io_in_bits_ctrlPipe_1_vpu_vsew,
  input  [2:0]   io_in_bits_ctrlPipe_1_vpu_vlmul,
  input          io_in_bits_ctrlPipe_1_vpu_specVill,
  input          io_in_bits_ctrlPipe_1_vpu_specVma,
  input          io_in_bits_ctrlPipe_1_vpu_specVta,
  input  [1:0]   io_in_bits_ctrlPipe_1_vpu_specVsew,
  input  [2:0]   io_in_bits_ctrlPipe_1_vpu_specVlmul,
  input          io_in_bits_ctrlPipe_1_vpu_vm,
  input  [7:0]   io_in_bits_ctrlPipe_1_vpu_vstart,
  input  [2:0]   io_in_bits_ctrlPipe_1_vpu_frm,
  input          io_in_bits_ctrlPipe_1_vpu_fpu_isFpToVecInst,
  input          io_in_bits_ctrlPipe_1_vpu_fpu_isFP32Instr,
  input          io_in_bits_ctrlPipe_1_vpu_fpu_isFP64Instr,
  input          io_in_bits_ctrlPipe_1_vpu_fpu_isReduction,
  input          io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_2,
  input          io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_4,
  input          io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_8,
  input  [1:0]   io_in_bits_ctrlPipe_1_vpu_vxrm,
  input  [6:0]   io_in_bits_ctrlPipe_1_vpu_vuopIdx,
  input          io_in_bits_ctrlPipe_1_vpu_lastUop,
  input  [127:0] io_in_bits_ctrlPipe_1_vpu_vmask,
  input  [7:0]   io_in_bits_ctrlPipe_1_vpu_vl,
  input  [2:0]   io_in_bits_ctrlPipe_1_vpu_nf,
  input  [1:0]   io_in_bits_ctrlPipe_1_vpu_veew,
  input          io_in_bits_ctrlPipe_1_vpu_isReverse,
  input          io_in_bits_ctrlPipe_1_vpu_isExt,
  input          io_in_bits_ctrlPipe_1_vpu_isNarrow,
  input          io_in_bits_ctrlPipe_1_vpu_isDstMask,
  input          io_in_bits_ctrlPipe_1_vpu_isOpMask,
  input          io_in_bits_ctrlPipe_1_vpu_isMove,
  input          io_in_bits_ctrlPipe_1_vpu_isDependOldVd,
  input          io_in_bits_ctrlPipe_1_vpu_isWritePartVd,
  input          io_in_bits_ctrlPipe_1_vpu_isVleff,
  input  [8:0]   io_in_bits_ctrlPipe_2_fuOpType,
  input          io_in_bits_ctrlPipe_2_robIdx_flag,
  input  [7:0]   io_in_bits_ctrlPipe_2_robIdx_value,
  input  [7:0]   io_in_bits_ctrlPipe_2_pdest,
  input          io_in_bits_ctrlPipe_2_vecWen,
  input          io_in_bits_ctrlPipe_2_v0Wen,
  input          io_in_bits_ctrlPipe_2_vpu_vill,
  input          io_in_bits_ctrlPipe_2_vpu_vma,
  input          io_in_bits_ctrlPipe_2_vpu_vta,
  input  [1:0]   io_in_bits_ctrlPipe_2_vpu_vsew,
  input  [2:0]   io_in_bits_ctrlPipe_2_vpu_vlmul,
  input          io_in_bits_ctrlPipe_2_vpu_specVill,
  input          io_in_bits_ctrlPipe_2_vpu_specVma,
  input          io_in_bits_ctrlPipe_2_vpu_specVta,
  input  [1:0]   io_in_bits_ctrlPipe_2_vpu_specVsew,
  input  [2:0]   io_in_bits_ctrlPipe_2_vpu_specVlmul,
  input          io_in_bits_ctrlPipe_2_vpu_vm,
  input  [7:0]   io_in_bits_ctrlPipe_2_vpu_vstart,
  input  [2:0]   io_in_bits_ctrlPipe_2_vpu_frm,
  input          io_in_bits_ctrlPipe_2_vpu_fpu_isFpToVecInst,
  input          io_in_bits_ctrlPipe_2_vpu_fpu_isFP32Instr,
  input          io_in_bits_ctrlPipe_2_vpu_fpu_isFP64Instr,
  input          io_in_bits_ctrlPipe_2_vpu_fpu_isReduction,
  input          io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_2,
  input          io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_4,
  input          io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_8,
  input  [1:0]   io_in_bits_ctrlPipe_2_vpu_vxrm,
  input  [6:0]   io_in_bits_ctrlPipe_2_vpu_vuopIdx,
  input          io_in_bits_ctrlPipe_2_vpu_lastUop,
  input  [127:0] io_in_bits_ctrlPipe_2_vpu_vmask,
  input  [7:0]   io_in_bits_ctrlPipe_2_vpu_vl,
  input  [2:0]   io_in_bits_ctrlPipe_2_vpu_nf,
  input  [1:0]   io_in_bits_ctrlPipe_2_vpu_veew,
  input          io_in_bits_ctrlPipe_2_vpu_isReverse,
  input          io_in_bits_ctrlPipe_2_vpu_isExt,
  input          io_in_bits_ctrlPipe_2_vpu_isNarrow,
  input          io_in_bits_ctrlPipe_2_vpu_isDstMask,
  input          io_in_bits_ctrlPipe_2_vpu_isOpMask,
  input          io_in_bits_ctrlPipe_2_vpu_isMove,
  input          io_in_bits_ctrlPipe_2_vpu_isDependOldVd,
  input          io_in_bits_ctrlPipe_2_vpu_isWritePartVd,
  input          io_in_bits_ctrlPipe_2_vpu_isVleff,
  input          io_in_bits_validPipe_0,
  input          io_in_bits_validPipe_1,
  input          io_in_bits_validPipe_2,
  input  [7:0]   io_in_bits_data_src_4,
  input  [127:0] io_in_bits_data_src_3,
  input  [127:0] io_in_bits_data_src_2,
  input  [127:0] io_in_bits_data_src_1,
  input  [127:0] io_in_bits_data_src_0,
  input  [127:0] io_in_bits_data_imm,
  input  [7:0]   io_in_bits_dataPipe_0_src_4,
  input  [127:0] io_in_bits_dataPipe_0_src_3,
  input  [127:0] io_in_bits_dataPipe_0_src_2,
  input  [127:0] io_in_bits_dataPipe_0_src_1,
  input  [127:0] io_in_bits_dataPipe_0_src_0,
  input  [127:0] io_in_bits_dataPipe_0_imm,
  input  [7:0]   io_in_bits_dataPipe_1_src_4,
  input  [127:0] io_in_bits_dataPipe_1_src_3,
  input  [127:0] io_in_bits_dataPipe_1_src_2,
  input  [127:0] io_in_bits_dataPipe_1_src_1,
  input  [127:0] io_in_bits_dataPipe_1_src_0,
  input  [127:0] io_in_bits_dataPipe_1_imm,
  input  [7:0]   io_in_bits_dataPipe_2_src_4,
  input  [127:0] io_in_bits_dataPipe_2_src_3,
  input  [127:0] io_in_bits_dataPipe_2_src_2,
  input  [127:0] io_in_bits_dataPipe_2_src_1,
  input  [127:0] io_in_bits_dataPipe_2_src_0,
  input  [127:0] io_in_bits_dataPipe_2_imm,
  input          io_in_bits_perfDebugInfo_eliminatedMove,
  input  [63:0]  io_in_bits_perfDebugInfo_renameTime,
  input  [63:0]  io_in_bits_perfDebugInfo_dispatchTime,
  input  [63:0]  io_in_bits_perfDebugInfo_enqRsTime,
  input  [63:0]  io_in_bits_perfDebugInfo_selectTime,
  input  [63:0]  io_in_bits_perfDebugInfo_issueTime,
  input  [63:0]  io_in_bits_perfDebugInfo_writebackTime,
  input  [63:0]  io_in_bits_perfDebugInfo_runahead_checkpoint_id,
  input  [63:0]  io_in_bits_perfDebugInfo_tlbFirstReqTime,
  input  [63:0]  io_in_bits_perfDebugInfo_tlbRespTime,
  input  [55:0]  io_in_bits_debug_seqNum_seqNum,
  input  [7:0]   io_in_bits_debug_seqNum_uopIdx,
  input          io_out_ready,
  output         io_out_valid,
  output         io_out_bits_ctrl_robIdx_flag,
  output [7:0]   io_out_bits_ctrl_robIdx_value,
  output [7:0]   io_out_bits_ctrl_pdest,
  output         io_out_bits_ctrl_vecWen,
  output         io_out_bits_ctrl_v0Wen,
  output         io_out_bits_ctrl_exceptionVec_0,
  output         io_out_bits_ctrl_exceptionVec_1,
  output         io_out_bits_ctrl_exceptionVec_2,
  output         io_out_bits_ctrl_exceptionVec_3,
  output         io_out_bits_ctrl_exceptionVec_4,
  output         io_out_bits_ctrl_exceptionVec_5,
  output         io_out_bits_ctrl_exceptionVec_6,
  output         io_out_bits_ctrl_exceptionVec_7,
  output         io_out_bits_ctrl_exceptionVec_8,
  output         io_out_bits_ctrl_exceptionVec_9,
  output         io_out_bits_ctrl_exceptionVec_10,
  output         io_out_bits_ctrl_exceptionVec_11,
  output         io_out_bits_ctrl_exceptionVec_12,
  output         io_out_bits_ctrl_exceptionVec_13,
  output         io_out_bits_ctrl_exceptionVec_14,
  output         io_out_bits_ctrl_exceptionVec_15,
  output         io_out_bits_ctrl_exceptionVec_16,
  output         io_out_bits_ctrl_exceptionVec_17,
  output         io_out_bits_ctrl_exceptionVec_18,
  output         io_out_bits_ctrl_exceptionVec_19,
  output         io_out_bits_ctrl_exceptionVec_20,
  output         io_out_bits_ctrl_exceptionVec_21,
  output         io_out_bits_ctrl_exceptionVec_22,
  output         io_out_bits_ctrl_exceptionVec_23,
  output         io_out_bits_ctrl_vpu_vill,
  output         io_out_bits_ctrl_vpu_vma,
  output         io_out_bits_ctrl_vpu_vta,
  output [1:0]   io_out_bits_ctrl_vpu_vsew,
  output [2:0]   io_out_bits_ctrl_vpu_vlmul,
  output         io_out_bits_ctrl_vpu_specVill,
  output         io_out_bits_ctrl_vpu_specVma,
  output         io_out_bits_ctrl_vpu_specVta,
  output [1:0]   io_out_bits_ctrl_vpu_specVsew,
  output [2:0]   io_out_bits_ctrl_vpu_specVlmul,
  output         io_out_bits_ctrl_vpu_vm,
  output [7:0]   io_out_bits_ctrl_vpu_vstart,
  output [2:0]   io_out_bits_ctrl_vpu_frm,
  output         io_out_bits_ctrl_vpu_fpu_isFpToVecInst,
  output         io_out_bits_ctrl_vpu_fpu_isFP32Instr,
  output         io_out_bits_ctrl_vpu_fpu_isFP64Instr,
  output         io_out_bits_ctrl_vpu_fpu_isReduction,
  output         io_out_bits_ctrl_vpu_fpu_isFoldTo1_2,
  output         io_out_bits_ctrl_vpu_fpu_isFoldTo1_4,
  output         io_out_bits_ctrl_vpu_fpu_isFoldTo1_8,
  output [1:0]   io_out_bits_ctrl_vpu_vxrm,
  output [6:0]   io_out_bits_ctrl_vpu_vuopIdx,
  output         io_out_bits_ctrl_vpu_lastUop,
  output [127:0] io_out_bits_ctrl_vpu_vmask,
  output [7:0]   io_out_bits_ctrl_vpu_vl,
  output [2:0]   io_out_bits_ctrl_vpu_nf,
  output [1:0]   io_out_bits_ctrl_vpu_veew,
  output         io_out_bits_ctrl_vpu_isReverse,
  output         io_out_bits_ctrl_vpu_isExt,
  output         io_out_bits_ctrl_vpu_isNarrow,
  output         io_out_bits_ctrl_vpu_isDstMask,
  output         io_out_bits_ctrl_vpu_isOpMask,
  output         io_out_bits_ctrl_vpu_isMove,
  output         io_out_bits_ctrl_vpu_isDependOldVd,
  output         io_out_bits_ctrl_vpu_isWritePartVd,
  output         io_out_bits_ctrl_vpu_isVleff,
  output [127:0] io_out_bits_res_data,
  output         io_out_bits_perfDebugInfo_eliminatedMove,
  output [63:0]  io_out_bits_perfDebugInfo_renameTime,
  output [63:0]  io_out_bits_perfDebugInfo_dispatchTime,
  output [63:0]  io_out_bits_perfDebugInfo_enqRsTime,
  output [63:0]  io_out_bits_perfDebugInfo_selectTime,
  output [63:0]  io_out_bits_perfDebugInfo_issueTime,
  output [63:0]  io_out_bits_perfDebugInfo_writebackTime,
  output [63:0]  io_out_bits_perfDebugInfo_runahead_checkpoint_id,
  output [63:0]  io_out_bits_perfDebugInfo_tlbFirstReqTime,
  output [63:0]  io_out_bits_perfDebugInfo_tlbRespTime,
  output [55:0]  io_out_bits_debug_seqNum_seqNum,
  output [7:0]   io_out_bits_debug_seqNum_uopIdx
);

  wire        rdyVec_1;
  reg         validVecThisFu_1;
  reg         validVecThisFu_2;
  reg         perfVec_1_eliminatedMove;
  reg  [63:0] perfVec_1_renameTime;
  reg  [63:0] perfVec_1_dispatchTime;
  reg  [63:0] perfVec_1_enqRsTime;
  reg  [63:0] perfVec_1_selectTime;
  reg  [63:0] perfVec_1_issueTime;
  reg  [63:0] perfVec_1_writebackTime;
  reg  [63:0] perfVec_1_runahead_checkpoint_id;
  reg  [63:0] perfVec_1_tlbFirstReqTime;
  reg  [63:0] perfVec_1_tlbRespTime;
  reg         perfVec_2_eliminatedMove;
  reg  [63:0] perfVec_2_renameTime;
  reg  [63:0] perfVec_2_dispatchTime;
  reg  [63:0] perfVec_2_enqRsTime;
  reg  [63:0] perfVec_2_selectTime;
  reg  [63:0] perfVec_2_issueTime;
  reg  [63:0] perfVec_2_writebackTime;
  reg  [63:0] perfVec_2_runahead_checkpoint_id;
  reg  [63:0] perfVec_2_tlbFirstReqTime;
  reg  [63:0] perfVec_2_tlbRespTime;
  reg  [55:0] seqNumVec_1_seqNum;
  reg  [7:0]  seqNumVec_1_uopIdx;
  reg  [55:0] seqNumVec_2_seqNum;
  reg  [7:0]  seqNumVec_2_uopIdx;
  wire        rdyVec_0 = ~validVecThisFu_1 | rdyVec_1;
  assign rdyVec_1 = ~validVecThisFu_2 | io_out_ready;
  `ifndef SYNTHESIS
    always @(posedge clock) begin
      if (io_in_valid & io_in_bits_ctrl_fuOpType[2:0] != 3'h7 & ~reset) begin
        if (`ASSERT_VERBOSE_COND_)
          $error("Assertion failed\n    at LogUtils.scala:133 assert(false.B) //assert at current module for better error location\n");
        if (`STOP_COND_)
          $fatal;
      end
    end
  `endif
  always @(posedge clock) begin
    if (reset) begin
      validVecThisFu_1 <= 1'h0;
      validVecThisFu_2 <= 1'h0;
    end
    else begin
      validVecThisFu_1 <= io_in_valid;
      validVecThisFu_2 <= validVecThisFu_1;
    end
    if (rdyVec_0 & io_in_valid) begin
      perfVec_1_eliminatedMove <= io_in_bits_perfDebugInfo_eliminatedMove;
      perfVec_1_renameTime <= io_in_bits_perfDebugInfo_renameTime;
      perfVec_1_dispatchTime <= io_in_bits_perfDebugInfo_dispatchTime;
      perfVec_1_enqRsTime <= io_in_bits_perfDebugInfo_enqRsTime;
      perfVec_1_selectTime <= io_in_bits_perfDebugInfo_selectTime;
      perfVec_1_issueTime <= io_in_bits_perfDebugInfo_issueTime;
      perfVec_1_writebackTime <= io_in_bits_perfDebugInfo_writebackTime;
      perfVec_1_runahead_checkpoint_id <= io_in_bits_perfDebugInfo_runahead_checkpoint_id;
      perfVec_1_tlbFirstReqTime <= io_in_bits_perfDebugInfo_tlbFirstReqTime;
      perfVec_1_tlbRespTime <= io_in_bits_perfDebugInfo_tlbRespTime;
      seqNumVec_1_seqNum <= io_in_bits_debug_seqNum_seqNum;
      seqNumVec_1_uopIdx <= io_in_bits_debug_seqNum_uopIdx;
    end
    if (rdyVec_1 & validVecThisFu_1) begin
      perfVec_2_eliminatedMove <= perfVec_1_eliminatedMove;
      perfVec_2_renameTime <= perfVec_1_renameTime;
      perfVec_2_dispatchTime <= perfVec_1_dispatchTime;
      perfVec_2_enqRsTime <= perfVec_1_enqRsTime;
      perfVec_2_selectTime <= perfVec_1_selectTime;
      perfVec_2_issueTime <= perfVec_1_issueTime;
      perfVec_2_writebackTime <= perfVec_1_writebackTime;
      perfVec_2_runahead_checkpoint_id <= perfVec_1_runahead_checkpoint_id;
      perfVec_2_tlbFirstReqTime <= perfVec_1_tlbFirstReqTime;
      perfVec_2_tlbRespTime <= perfVec_1_tlbRespTime;
      seqNumVec_2_seqNum <= seqNumVec_1_seqNum;
      seqNumVec_2_uopIdx <= seqNumVec_1_uopIdx;
    end
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    logic [31:0] _RANDOM[0:94];
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif
      `ifdef RANDOMIZE_REG_INIT
        for (logic [6:0] i = 7'h0; i < 7'h5F; i += 7'h1) begin
          _RANDOM[i] = `RANDOM;
        end
        validVecThisFu_1 = _RANDOM[7'h0][0];
        validVecThisFu_2 = _RANDOM[7'h0][1];
        perfVec_1_eliminatedMove = _RANDOM[7'h36][16];
        perfVec_1_renameTime =
          {_RANDOM[7'h36][31:17], _RANDOM[7'h37], _RANDOM[7'h38][16:0]};
        perfVec_1_dispatchTime =
          {_RANDOM[7'h38][31:17], _RANDOM[7'h39], _RANDOM[7'h3A][16:0]};
        perfVec_1_enqRsTime =
          {_RANDOM[7'h3A][31:17], _RANDOM[7'h3B], _RANDOM[7'h3C][16:0]};
        perfVec_1_selectTime =
          {_RANDOM[7'h3C][31:17], _RANDOM[7'h3D], _RANDOM[7'h3E][16:0]};
        perfVec_1_issueTime =
          {_RANDOM[7'h3E][31:17], _RANDOM[7'h3F], _RANDOM[7'h40][16:0]};
        perfVec_1_writebackTime =
          {_RANDOM[7'h40][31:17], _RANDOM[7'h41], _RANDOM[7'h42][16:0]};
        perfVec_1_runahead_checkpoint_id =
          {_RANDOM[7'h42][31:17], _RANDOM[7'h43], _RANDOM[7'h44][16:0]};
        perfVec_1_tlbFirstReqTime =
          {_RANDOM[7'h44][31:17], _RANDOM[7'h45], _RANDOM[7'h46][16:0]};
        perfVec_1_tlbRespTime =
          {_RANDOM[7'h46][31:17], _RANDOM[7'h47], _RANDOM[7'h48][16:0]};
        perfVec_2_eliminatedMove = _RANDOM[7'h48][17];
        perfVec_2_renameTime =
          {_RANDOM[7'h48][31:18], _RANDOM[7'h49], _RANDOM[7'h4A][17:0]};
        perfVec_2_dispatchTime =
          {_RANDOM[7'h4A][31:18], _RANDOM[7'h4B], _RANDOM[7'h4C][17:0]};
        perfVec_2_enqRsTime =
          {_RANDOM[7'h4C][31:18], _RANDOM[7'h4D], _RANDOM[7'h4E][17:0]};
        perfVec_2_selectTime =
          {_RANDOM[7'h4E][31:18], _RANDOM[7'h4F], _RANDOM[7'h50][17:0]};
        perfVec_2_issueTime =
          {_RANDOM[7'h50][31:18], _RANDOM[7'h51], _RANDOM[7'h52][17:0]};
        perfVec_2_writebackTime =
          {_RANDOM[7'h52][31:18], _RANDOM[7'h53], _RANDOM[7'h54][17:0]};
        perfVec_2_runahead_checkpoint_id =
          {_RANDOM[7'h54][31:18], _RANDOM[7'h55], _RANDOM[7'h56][17:0]};
        perfVec_2_tlbFirstReqTime =
          {_RANDOM[7'h56][31:18], _RANDOM[7'h57], _RANDOM[7'h58][17:0]};
        perfVec_2_tlbRespTime =
          {_RANDOM[7'h58][31:18], _RANDOM[7'h59], _RANDOM[7'h5A][17:0]};
        seqNumVec_1_seqNum = {_RANDOM[7'h5A][31:18], _RANDOM[7'h5B], _RANDOM[7'h5C][9:0]};
        seqNumVec_1_uopIdx = _RANDOM[7'h5C][17:10];
        seqNumVec_2_seqNum = {_RANDOM[7'h5C][31:18], _RANDOM[7'h5D], _RANDOM[7'h5E][9:0]};
        seqNumVec_2_uopIdx = _RANDOM[7'h5E][17:10];
      `endif
    end
    `ifdef FIRRTL_AFTER_INITIAL
      `FIRRTL_AFTER_INITIAL
    `endif
  `endif
  VDotUnit VDotDatapath (
    .clock   (clock),
    .reset   (reset),
    .io_fire (io_in_valid),
    .io_vs1  (io_in_bits_data_src_0),
    .io_vs2  (io_in_bits_data_src_1),
    .io_vd   (io_out_bits_res_data)
  );
  assign io_in_ready = rdyVec_0;
  assign io_out_valid = io_in_bits_validPipe_2 & validVecThisFu_2;
  assign io_out_bits_ctrl_robIdx_flag = io_in_bits_ctrlPipe_2_robIdx_flag;
  assign io_out_bits_ctrl_robIdx_value = io_in_bits_ctrlPipe_2_robIdx_value;
  assign io_out_bits_ctrl_pdest = io_in_bits_ctrlPipe_2_pdest;
  assign io_out_bits_ctrl_vecWen = io_in_bits_ctrlPipe_2_vecWen;
  assign io_out_bits_ctrl_v0Wen = io_in_bits_ctrlPipe_2_v0Wen;
  assign io_out_bits_ctrl_exceptionVec_0 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_1 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_2 =
    io_in_bits_ctrlPipe_2_vpu_vill | (|io_in_bits_ctrlPipe_2_vpu_vsew)
    | (|io_in_bits_ctrlPipe_2_vpu_vlmul) | ~io_in_bits_ctrlPipe_2_vpu_vm
    | (|io_in_bits_ctrlPipe_2_vpu_vstart);
  assign io_out_bits_ctrl_exceptionVec_3 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_4 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_5 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_6 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_7 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_8 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_9 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_10 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_11 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_12 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_13 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_14 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_15 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_16 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_17 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_18 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_19 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_20 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_21 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_22 = 1'h0;
  assign io_out_bits_ctrl_exceptionVec_23 = 1'h0;
  assign io_out_bits_ctrl_vpu_vill = io_in_bits_ctrlPipe_2_vpu_vill;
  assign io_out_bits_ctrl_vpu_vma = io_in_bits_ctrlPipe_2_vpu_vma;
  assign io_out_bits_ctrl_vpu_vta = io_in_bits_ctrlPipe_2_vpu_vta;
  assign io_out_bits_ctrl_vpu_vsew = io_in_bits_ctrlPipe_2_vpu_vsew;
  assign io_out_bits_ctrl_vpu_vlmul = io_in_bits_ctrlPipe_2_vpu_vlmul;
  assign io_out_bits_ctrl_vpu_specVill = io_in_bits_ctrlPipe_2_vpu_specVill;
  assign io_out_bits_ctrl_vpu_specVma = io_in_bits_ctrlPipe_2_vpu_specVma;
  assign io_out_bits_ctrl_vpu_specVta = io_in_bits_ctrlPipe_2_vpu_specVta;
  assign io_out_bits_ctrl_vpu_specVsew = io_in_bits_ctrlPipe_2_vpu_specVsew;
  assign io_out_bits_ctrl_vpu_specVlmul = io_in_bits_ctrlPipe_2_vpu_specVlmul;
  assign io_out_bits_ctrl_vpu_vm = io_in_bits_ctrlPipe_2_vpu_vm;
  assign io_out_bits_ctrl_vpu_vstart = io_in_bits_ctrlPipe_2_vpu_vstart;
  assign io_out_bits_ctrl_vpu_frm = io_in_bits_ctrlPipe_2_vpu_frm;
  assign io_out_bits_ctrl_vpu_fpu_isFpToVecInst =
    io_in_bits_ctrlPipe_2_vpu_fpu_isFpToVecInst;
  assign io_out_bits_ctrl_vpu_fpu_isFP32Instr = io_in_bits_ctrlPipe_2_vpu_fpu_isFP32Instr;
  assign io_out_bits_ctrl_vpu_fpu_isFP64Instr = io_in_bits_ctrlPipe_2_vpu_fpu_isFP64Instr;
  assign io_out_bits_ctrl_vpu_fpu_isReduction = io_in_bits_ctrlPipe_2_vpu_fpu_isReduction;
  assign io_out_bits_ctrl_vpu_fpu_isFoldTo1_2 = io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_2;
  assign io_out_bits_ctrl_vpu_fpu_isFoldTo1_4 = io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_4;
  assign io_out_bits_ctrl_vpu_fpu_isFoldTo1_8 = io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_8;
  assign io_out_bits_ctrl_vpu_vxrm = io_in_bits_ctrlPipe_2_vpu_vxrm;
  assign io_out_bits_ctrl_vpu_vuopIdx = io_in_bits_ctrlPipe_2_vpu_vuopIdx;
  assign io_out_bits_ctrl_vpu_lastUop = io_in_bits_ctrlPipe_2_vpu_lastUop;
  assign io_out_bits_ctrl_vpu_vmask = io_in_bits_ctrlPipe_2_vpu_vmask;
  assign io_out_bits_ctrl_vpu_vl = io_in_bits_ctrlPipe_2_vpu_vl;
  assign io_out_bits_ctrl_vpu_nf = io_in_bits_ctrlPipe_2_vpu_nf;
  assign io_out_bits_ctrl_vpu_veew = io_in_bits_ctrlPipe_2_vpu_veew;
  assign io_out_bits_ctrl_vpu_isReverse = io_in_bits_ctrlPipe_2_vpu_isReverse;
  assign io_out_bits_ctrl_vpu_isExt = io_in_bits_ctrlPipe_2_vpu_isExt;
  assign io_out_bits_ctrl_vpu_isNarrow = io_in_bits_ctrlPipe_2_vpu_isNarrow;
  assign io_out_bits_ctrl_vpu_isDstMask = io_in_bits_ctrlPipe_2_vpu_isDstMask;
  assign io_out_bits_ctrl_vpu_isOpMask = io_in_bits_ctrlPipe_2_vpu_isOpMask;
  assign io_out_bits_ctrl_vpu_isMove = io_in_bits_ctrlPipe_2_vpu_isMove;
  assign io_out_bits_ctrl_vpu_isDependOldVd = io_in_bits_ctrlPipe_2_vpu_isDependOldVd;
  assign io_out_bits_ctrl_vpu_isWritePartVd = io_in_bits_ctrlPipe_2_vpu_isWritePartVd;
  assign io_out_bits_ctrl_vpu_isVleff = io_in_bits_ctrlPipe_2_vpu_isVleff;
  assign io_out_bits_perfDebugInfo_eliminatedMove = perfVec_2_eliminatedMove;
  assign io_out_bits_perfDebugInfo_renameTime = perfVec_2_renameTime;
  assign io_out_bits_perfDebugInfo_dispatchTime = perfVec_2_dispatchTime;
  assign io_out_bits_perfDebugInfo_enqRsTime = perfVec_2_enqRsTime;
  assign io_out_bits_perfDebugInfo_selectTime = perfVec_2_selectTime;
  assign io_out_bits_perfDebugInfo_issueTime = perfVec_2_issueTime;
  assign io_out_bits_perfDebugInfo_writebackTime = perfVec_2_writebackTime;
  assign io_out_bits_perfDebugInfo_runahead_checkpoint_id =
    perfVec_2_runahead_checkpoint_id;
  assign io_out_bits_perfDebugInfo_tlbFirstReqTime = perfVec_2_tlbFirstReqTime;
  assign io_out_bits_perfDebugInfo_tlbRespTime = perfVec_2_tlbRespTime;
  assign io_out_bits_debug_seqNum_seqNum = seqNumVec_2_seqNum;
  assign io_out_bits_debug_seqNum_uopIdx = seqNumVec_2_uopIdx;
endmodule

