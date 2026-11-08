module VDotUnit (
	clock,
	reset,
	io_fire,
	io_vs1,
	io_vs2,
	io_vd
);
	input clock;
	input reset;
	input io_fire;
	input [127:0] io_vs1;
	input [127:0] io_vs2;
	output wire [127:0] io_vd;
	reg [18:0] prod_0;
	reg [18:0] prod_1;
	reg [18:0] prod_2;
	reg [18:0] prod_3;
	reg [18:0] prod_4;
	reg [18:0] prod_5;
	reg [18:0] prod_6;
	reg [18:0] prod_7;
	reg [18:0] red;
	function automatic [15:0] sv2v_cast_16;
		input reg [15:0] inp;
		sv2v_cast_16 = inp;
	endfunction
	wire [15:0] prodComb_prod = sv2v_cast_16({{8 {io_vs1[7]}}, io_vs1[7:0]} * {{8 {io_vs2[7]}}, io_vs2[7:0]});
	wire [15:0] prodComb_prod_1 = sv2v_cast_16({{8 {io_vs1[15]}}, io_vs1[15:8]} * {{8 {io_vs2[15]}}, io_vs2[15:8]});
	wire [15:0] prodComb_prod_2 = sv2v_cast_16({{8 {io_vs1[23]}}, io_vs1[23:16]} * {{8 {io_vs2[23]}}, io_vs2[23:16]});
	wire [15:0] prodComb_prod_3 = sv2v_cast_16({{8 {io_vs1[31]}}, io_vs1[31:24]} * {{8 {io_vs2[31]}}, io_vs2[31:24]});
	wire [15:0] prodComb_prod_4 = sv2v_cast_16({{8 {io_vs1[39]}}, io_vs1[39:32]} * {{8 {io_vs2[39]}}, io_vs2[39:32]});
	wire [15:0] prodComb_prod_5 = sv2v_cast_16({{8 {io_vs1[47]}}, io_vs1[47:40]} * {{8 {io_vs2[47]}}, io_vs2[47:40]});
	wire [15:0] prodComb_prod_6 = sv2v_cast_16({{8 {io_vs1[55]}}, io_vs1[55:48]} * {{8 {io_vs2[55]}}, io_vs2[55:48]});
	wire [15:0] prodComb_prod_7 = sv2v_cast_16({{8 {io_vs1[63]}}, io_vs1[63:56]} * {{8 {io_vs2[63]}}, io_vs2[63:56]});
	always @(posedge clock)
		if (reset) begin
			prod_0 <= 19'h00000;
			prod_1 <= 19'h00000;
			prod_2 <= 19'h00000;
			prod_3 <= 19'h00000;
			prod_4 <= 19'h00000;
			prod_5 <= 19'h00000;
			prod_6 <= 19'h00000;
			prod_7 <= 19'h00000;
			red <= 19'h00000;
		end
		else begin
			if (io_fire) begin
				prod_0 <= {{3 {prodComb_prod[15]}}, prodComb_prod};
				prod_1 <= {{3 {prodComb_prod_1[15]}}, prodComb_prod_1};
				prod_2 <= {{3 {prodComb_prod_2[15]}}, prodComb_prod_2};
				prod_3 <= {{3 {prodComb_prod_3[15]}}, prodComb_prod_3};
				prod_4 <= {{3 {prodComb_prod_4[15]}}, prodComb_prod_4};
				prod_5 <= {{3 {prodComb_prod_5[15]}}, prodComb_prod_5};
				prod_6 <= {{3 {prodComb_prod_6[15]}}, prodComb_prod_6};
				prod_7 <= {{3 {prodComb_prod_7[15]}}, prodComb_prod_7};
			end
			red <= ((prod_0 + prod_1) + (prod_2 + prod_3)) + ((prod_4 + prod_5) + (prod_6 + prod_7));
		end
	assign io_vd = {96'h000000000000000000000000, {13 {red[18]}}, red};
endmodule
module VDotU (
	clock,
	reset,
	io_flush_valid,
	io_flush_bits_isRVC,
	io_flush_bits_robIdx_flag,
	io_flush_bits_robIdx_value,
	io_flush_bits_ftqIdx_flag,
	io_flush_bits_ftqIdx_value,
	io_flush_bits_ftqOffset,
	io_flush_bits_level,
	io_flush_bits_interrupt,
	io_flush_bits_cfiUpdate_pc,
	io_flush_bits_cfiUpdate_pd_valid,
	io_flush_bits_cfiUpdate_pd_isRVC,
	io_flush_bits_cfiUpdate_pd_brType,
	io_flush_bits_cfiUpdate_pd_isCall,
	io_flush_bits_cfiUpdate_pd_isRet,
	io_flush_bits_cfiUpdate_ssp,
	io_flush_bits_cfiUpdate_sctr,
	io_flush_bits_cfiUpdate_TOSW_flag,
	io_flush_bits_cfiUpdate_TOSW_value,
	io_flush_bits_cfiUpdate_TOSR_flag,
	io_flush_bits_cfiUpdate_TOSR_value,
	io_flush_bits_cfiUpdate_NOS_flag,
	io_flush_bits_cfiUpdate_NOS_value,
	io_flush_bits_cfiUpdate_topAddr,
	io_flush_bits_cfiUpdate_folded_hist_hist_17_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_16_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_15_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_14_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_13_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_12_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_11_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_10_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_9_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_8_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_7_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_6_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_5_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_4_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_3_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_2_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_1_folded_hist,
	io_flush_bits_cfiUpdate_folded_hist_hist_0_folded_hist,
	io_flush_bits_cfiUpdate_afhob_afhob_5_bits_0,
	io_flush_bits_cfiUpdate_afhob_afhob_5_bits_1,
	io_flush_bits_cfiUpdate_afhob_afhob_5_bits_2,
	io_flush_bits_cfiUpdate_afhob_afhob_5_bits_3,
	io_flush_bits_cfiUpdate_afhob_afhob_4_bits_0,
	io_flush_bits_cfiUpdate_afhob_afhob_4_bits_1,
	io_flush_bits_cfiUpdate_afhob_afhob_4_bits_2,
	io_flush_bits_cfiUpdate_afhob_afhob_4_bits_3,
	io_flush_bits_cfiUpdate_afhob_afhob_3_bits_0,
	io_flush_bits_cfiUpdate_afhob_afhob_3_bits_1,
	io_flush_bits_cfiUpdate_afhob_afhob_3_bits_2,
	io_flush_bits_cfiUpdate_afhob_afhob_3_bits_3,
	io_flush_bits_cfiUpdate_afhob_afhob_2_bits_0,
	io_flush_bits_cfiUpdate_afhob_afhob_2_bits_1,
	io_flush_bits_cfiUpdate_afhob_afhob_2_bits_2,
	io_flush_bits_cfiUpdate_afhob_afhob_2_bits_3,
	io_flush_bits_cfiUpdate_afhob_afhob_1_bits_0,
	io_flush_bits_cfiUpdate_afhob_afhob_1_bits_1,
	io_flush_bits_cfiUpdate_afhob_afhob_1_bits_2,
	io_flush_bits_cfiUpdate_afhob_afhob_1_bits_3,
	io_flush_bits_cfiUpdate_afhob_afhob_0_bits_0,
	io_flush_bits_cfiUpdate_afhob_afhob_0_bits_1,
	io_flush_bits_cfiUpdate_afhob_afhob_0_bits_2,
	io_flush_bits_cfiUpdate_afhob_afhob_0_bits_3,
	io_flush_bits_cfiUpdate_lastBrNumOH,
	io_flush_bits_cfiUpdate_ghr,
	io_flush_bits_cfiUpdate_histPtr_flag,
	io_flush_bits_cfiUpdate_histPtr_value,
	io_flush_bits_cfiUpdate_specCnt_0,
	io_flush_bits_cfiUpdate_specCnt_1,
	io_flush_bits_cfiUpdate_br_hit,
	io_flush_bits_cfiUpdate_jr_hit,
	io_flush_bits_cfiUpdate_sc_hit,
	io_flush_bits_cfiUpdate_predTaken,
	io_flush_bits_cfiUpdate_target,
	io_flush_bits_cfiUpdate_taken,
	io_flush_bits_cfiUpdate_isMisPred,
	io_flush_bits_cfiUpdate_shift,
	io_flush_bits_cfiUpdate_addIntoHist,
	io_flush_bits_cfiUpdate_backendIGPF,
	io_flush_bits_cfiUpdate_backendIPF,
	io_flush_bits_cfiUpdate_backendIAF,
	io_flush_bits_fullTarget,
	io_flush_bits_satpFlush,
	io_flush_bits_isVlsException,
	io_flush_bits_stFtqIdx_flag,
	io_flush_bits_stFtqIdx_value,
	io_flush_bits_stFtqOffset,
	io_flush_bits_debug_runahead_checkpoint_id,
	io_flush_bits_debugIsCtrl,
	io_flush_bits_debugIsMemVio,
	io_in_ready,
	io_in_valid,
	io_in_bits_ctrl_fuOpType,
	io_in_bits_ctrl_robIdx_flag,
	io_in_bits_ctrl_robIdx_value,
	io_in_bits_ctrl_pdest,
	io_in_bits_ctrl_vecWen,
	io_in_bits_ctrl_v0Wen,
	io_in_bits_ctrl_vpu_vill,
	io_in_bits_ctrl_vpu_vma,
	io_in_bits_ctrl_vpu_vta,
	io_in_bits_ctrl_vpu_vsew,
	io_in_bits_ctrl_vpu_vlmul,
	io_in_bits_ctrl_vpu_specVill,
	io_in_bits_ctrl_vpu_specVma,
	io_in_bits_ctrl_vpu_specVta,
	io_in_bits_ctrl_vpu_specVsew,
	io_in_bits_ctrl_vpu_specVlmul,
	io_in_bits_ctrl_vpu_vm,
	io_in_bits_ctrl_vpu_vstart,
	io_in_bits_ctrl_vpu_frm,
	io_in_bits_ctrl_vpu_fpu_isFpToVecInst,
	io_in_bits_ctrl_vpu_fpu_isFP32Instr,
	io_in_bits_ctrl_vpu_fpu_isFP64Instr,
	io_in_bits_ctrl_vpu_fpu_isReduction,
	io_in_bits_ctrl_vpu_fpu_isFoldTo1_2,
	io_in_bits_ctrl_vpu_fpu_isFoldTo1_4,
	io_in_bits_ctrl_vpu_fpu_isFoldTo1_8,
	io_in_bits_ctrl_vpu_vxrm,
	io_in_bits_ctrl_vpu_vuopIdx,
	io_in_bits_ctrl_vpu_lastUop,
	io_in_bits_ctrl_vpu_vmask,
	io_in_bits_ctrl_vpu_vl,
	io_in_bits_ctrl_vpu_nf,
	io_in_bits_ctrl_vpu_veew,
	io_in_bits_ctrl_vpu_isReverse,
	io_in_bits_ctrl_vpu_isExt,
	io_in_bits_ctrl_vpu_isNarrow,
	io_in_bits_ctrl_vpu_isDstMask,
	io_in_bits_ctrl_vpu_isOpMask,
	io_in_bits_ctrl_vpu_isMove,
	io_in_bits_ctrl_vpu_isDependOldVd,
	io_in_bits_ctrl_vpu_isWritePartVd,
	io_in_bits_ctrl_vpu_isVleff,
	io_in_bits_ctrlPipe_0_fuOpType,
	io_in_bits_ctrlPipe_0_robIdx_flag,
	io_in_bits_ctrlPipe_0_robIdx_value,
	io_in_bits_ctrlPipe_0_pdest,
	io_in_bits_ctrlPipe_0_vecWen,
	io_in_bits_ctrlPipe_0_v0Wen,
	io_in_bits_ctrlPipe_0_vpu_vill,
	io_in_bits_ctrlPipe_0_vpu_vma,
	io_in_bits_ctrlPipe_0_vpu_vta,
	io_in_bits_ctrlPipe_0_vpu_vsew,
	io_in_bits_ctrlPipe_0_vpu_vlmul,
	io_in_bits_ctrlPipe_0_vpu_specVill,
	io_in_bits_ctrlPipe_0_vpu_specVma,
	io_in_bits_ctrlPipe_0_vpu_specVta,
	io_in_bits_ctrlPipe_0_vpu_specVsew,
	io_in_bits_ctrlPipe_0_vpu_specVlmul,
	io_in_bits_ctrlPipe_0_vpu_vm,
	io_in_bits_ctrlPipe_0_vpu_vstart,
	io_in_bits_ctrlPipe_0_vpu_frm,
	io_in_bits_ctrlPipe_0_vpu_fpu_isFpToVecInst,
	io_in_bits_ctrlPipe_0_vpu_fpu_isFP32Instr,
	io_in_bits_ctrlPipe_0_vpu_fpu_isFP64Instr,
	io_in_bits_ctrlPipe_0_vpu_fpu_isReduction,
	io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_2,
	io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_4,
	io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_8,
	io_in_bits_ctrlPipe_0_vpu_vxrm,
	io_in_bits_ctrlPipe_0_vpu_vuopIdx,
	io_in_bits_ctrlPipe_0_vpu_lastUop,
	io_in_bits_ctrlPipe_0_vpu_vmask,
	io_in_bits_ctrlPipe_0_vpu_vl,
	io_in_bits_ctrlPipe_0_vpu_nf,
	io_in_bits_ctrlPipe_0_vpu_veew,
	io_in_bits_ctrlPipe_0_vpu_isReverse,
	io_in_bits_ctrlPipe_0_vpu_isExt,
	io_in_bits_ctrlPipe_0_vpu_isNarrow,
	io_in_bits_ctrlPipe_0_vpu_isDstMask,
	io_in_bits_ctrlPipe_0_vpu_isOpMask,
	io_in_bits_ctrlPipe_0_vpu_isMove,
	io_in_bits_ctrlPipe_0_vpu_isDependOldVd,
	io_in_bits_ctrlPipe_0_vpu_isWritePartVd,
	io_in_bits_ctrlPipe_0_vpu_isVleff,
	io_in_bits_ctrlPipe_1_fuOpType,
	io_in_bits_ctrlPipe_1_robIdx_flag,
	io_in_bits_ctrlPipe_1_robIdx_value,
	io_in_bits_ctrlPipe_1_pdest,
	io_in_bits_ctrlPipe_1_vecWen,
	io_in_bits_ctrlPipe_1_v0Wen,
	io_in_bits_ctrlPipe_1_vpu_vill,
	io_in_bits_ctrlPipe_1_vpu_vma,
	io_in_bits_ctrlPipe_1_vpu_vta,
	io_in_bits_ctrlPipe_1_vpu_vsew,
	io_in_bits_ctrlPipe_1_vpu_vlmul,
	io_in_bits_ctrlPipe_1_vpu_specVill,
	io_in_bits_ctrlPipe_1_vpu_specVma,
	io_in_bits_ctrlPipe_1_vpu_specVta,
	io_in_bits_ctrlPipe_1_vpu_specVsew,
	io_in_bits_ctrlPipe_1_vpu_specVlmul,
	io_in_bits_ctrlPipe_1_vpu_vm,
	io_in_bits_ctrlPipe_1_vpu_vstart,
	io_in_bits_ctrlPipe_1_vpu_frm,
	io_in_bits_ctrlPipe_1_vpu_fpu_isFpToVecInst,
	io_in_bits_ctrlPipe_1_vpu_fpu_isFP32Instr,
	io_in_bits_ctrlPipe_1_vpu_fpu_isFP64Instr,
	io_in_bits_ctrlPipe_1_vpu_fpu_isReduction,
	io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_2,
	io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_4,
	io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_8,
	io_in_bits_ctrlPipe_1_vpu_vxrm,
	io_in_bits_ctrlPipe_1_vpu_vuopIdx,
	io_in_bits_ctrlPipe_1_vpu_lastUop,
	io_in_bits_ctrlPipe_1_vpu_vmask,
	io_in_bits_ctrlPipe_1_vpu_vl,
	io_in_bits_ctrlPipe_1_vpu_nf,
	io_in_bits_ctrlPipe_1_vpu_veew,
	io_in_bits_ctrlPipe_1_vpu_isReverse,
	io_in_bits_ctrlPipe_1_vpu_isExt,
	io_in_bits_ctrlPipe_1_vpu_isNarrow,
	io_in_bits_ctrlPipe_1_vpu_isDstMask,
	io_in_bits_ctrlPipe_1_vpu_isOpMask,
	io_in_bits_ctrlPipe_1_vpu_isMove,
	io_in_bits_ctrlPipe_1_vpu_isDependOldVd,
	io_in_bits_ctrlPipe_1_vpu_isWritePartVd,
	io_in_bits_ctrlPipe_1_vpu_isVleff,
	io_in_bits_ctrlPipe_2_fuOpType,
	io_in_bits_ctrlPipe_2_robIdx_flag,
	io_in_bits_ctrlPipe_2_robIdx_value,
	io_in_bits_ctrlPipe_2_pdest,
	io_in_bits_ctrlPipe_2_vecWen,
	io_in_bits_ctrlPipe_2_v0Wen,
	io_in_bits_ctrlPipe_2_vpu_vill,
	io_in_bits_ctrlPipe_2_vpu_vma,
	io_in_bits_ctrlPipe_2_vpu_vta,
	io_in_bits_ctrlPipe_2_vpu_vsew,
	io_in_bits_ctrlPipe_2_vpu_vlmul,
	io_in_bits_ctrlPipe_2_vpu_specVill,
	io_in_bits_ctrlPipe_2_vpu_specVma,
	io_in_bits_ctrlPipe_2_vpu_specVta,
	io_in_bits_ctrlPipe_2_vpu_specVsew,
	io_in_bits_ctrlPipe_2_vpu_specVlmul,
	io_in_bits_ctrlPipe_2_vpu_vm,
	io_in_bits_ctrlPipe_2_vpu_vstart,
	io_in_bits_ctrlPipe_2_vpu_frm,
	io_in_bits_ctrlPipe_2_vpu_fpu_isFpToVecInst,
	io_in_bits_ctrlPipe_2_vpu_fpu_isFP32Instr,
	io_in_bits_ctrlPipe_2_vpu_fpu_isFP64Instr,
	io_in_bits_ctrlPipe_2_vpu_fpu_isReduction,
	io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_2,
	io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_4,
	io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_8,
	io_in_bits_ctrlPipe_2_vpu_vxrm,
	io_in_bits_ctrlPipe_2_vpu_vuopIdx,
	io_in_bits_ctrlPipe_2_vpu_lastUop,
	io_in_bits_ctrlPipe_2_vpu_vmask,
	io_in_bits_ctrlPipe_2_vpu_vl,
	io_in_bits_ctrlPipe_2_vpu_nf,
	io_in_bits_ctrlPipe_2_vpu_veew,
	io_in_bits_ctrlPipe_2_vpu_isReverse,
	io_in_bits_ctrlPipe_2_vpu_isExt,
	io_in_bits_ctrlPipe_2_vpu_isNarrow,
	io_in_bits_ctrlPipe_2_vpu_isDstMask,
	io_in_bits_ctrlPipe_2_vpu_isOpMask,
	io_in_bits_ctrlPipe_2_vpu_isMove,
	io_in_bits_ctrlPipe_2_vpu_isDependOldVd,
	io_in_bits_ctrlPipe_2_vpu_isWritePartVd,
	io_in_bits_ctrlPipe_2_vpu_isVleff,
	io_in_bits_validPipe_0,
	io_in_bits_validPipe_1,
	io_in_bits_validPipe_2,
	io_in_bits_data_src_4,
	io_in_bits_data_src_3,
	io_in_bits_data_src_2,
	io_in_bits_data_src_1,
	io_in_bits_data_src_0,
	io_in_bits_data_imm,
	io_in_bits_dataPipe_0_src_4,
	io_in_bits_dataPipe_0_src_3,
	io_in_bits_dataPipe_0_src_2,
	io_in_bits_dataPipe_0_src_1,
	io_in_bits_dataPipe_0_src_0,
	io_in_bits_dataPipe_0_imm,
	io_in_bits_dataPipe_1_src_4,
	io_in_bits_dataPipe_1_src_3,
	io_in_bits_dataPipe_1_src_2,
	io_in_bits_dataPipe_1_src_1,
	io_in_bits_dataPipe_1_src_0,
	io_in_bits_dataPipe_1_imm,
	io_in_bits_dataPipe_2_src_4,
	io_in_bits_dataPipe_2_src_3,
	io_in_bits_dataPipe_2_src_2,
	io_in_bits_dataPipe_2_src_1,
	io_in_bits_dataPipe_2_src_0,
	io_in_bits_dataPipe_2_imm,
	io_in_bits_perfDebugInfo_eliminatedMove,
	io_in_bits_perfDebugInfo_renameTime,
	io_in_bits_perfDebugInfo_dispatchTime,
	io_in_bits_perfDebugInfo_enqRsTime,
	io_in_bits_perfDebugInfo_selectTime,
	io_in_bits_perfDebugInfo_issueTime,
	io_in_bits_perfDebugInfo_writebackTime,
	io_in_bits_perfDebugInfo_runahead_checkpoint_id,
	io_in_bits_perfDebugInfo_tlbFirstReqTime,
	io_in_bits_perfDebugInfo_tlbRespTime,
	io_in_bits_debug_seqNum_seqNum,
	io_in_bits_debug_seqNum_uopIdx,
	io_out_ready,
	io_out_valid,
	io_out_bits_ctrl_robIdx_flag,
	io_out_bits_ctrl_robIdx_value,
	io_out_bits_ctrl_pdest,
	io_out_bits_ctrl_vecWen,
	io_out_bits_ctrl_v0Wen,
	io_out_bits_ctrl_exceptionVec_0,
	io_out_bits_ctrl_exceptionVec_1,
	io_out_bits_ctrl_exceptionVec_2,
	io_out_bits_ctrl_exceptionVec_3,
	io_out_bits_ctrl_exceptionVec_4,
	io_out_bits_ctrl_exceptionVec_5,
	io_out_bits_ctrl_exceptionVec_6,
	io_out_bits_ctrl_exceptionVec_7,
	io_out_bits_ctrl_exceptionVec_8,
	io_out_bits_ctrl_exceptionVec_9,
	io_out_bits_ctrl_exceptionVec_10,
	io_out_bits_ctrl_exceptionVec_11,
	io_out_bits_ctrl_exceptionVec_12,
	io_out_bits_ctrl_exceptionVec_13,
	io_out_bits_ctrl_exceptionVec_14,
	io_out_bits_ctrl_exceptionVec_15,
	io_out_bits_ctrl_exceptionVec_16,
	io_out_bits_ctrl_exceptionVec_17,
	io_out_bits_ctrl_exceptionVec_18,
	io_out_bits_ctrl_exceptionVec_19,
	io_out_bits_ctrl_exceptionVec_20,
	io_out_bits_ctrl_exceptionVec_21,
	io_out_bits_ctrl_exceptionVec_22,
	io_out_bits_ctrl_exceptionVec_23,
	io_out_bits_ctrl_vpu_vill,
	io_out_bits_ctrl_vpu_vma,
	io_out_bits_ctrl_vpu_vta,
	io_out_bits_ctrl_vpu_vsew,
	io_out_bits_ctrl_vpu_vlmul,
	io_out_bits_ctrl_vpu_specVill,
	io_out_bits_ctrl_vpu_specVma,
	io_out_bits_ctrl_vpu_specVta,
	io_out_bits_ctrl_vpu_specVsew,
	io_out_bits_ctrl_vpu_specVlmul,
	io_out_bits_ctrl_vpu_vm,
	io_out_bits_ctrl_vpu_vstart,
	io_out_bits_ctrl_vpu_frm,
	io_out_bits_ctrl_vpu_fpu_isFpToVecInst,
	io_out_bits_ctrl_vpu_fpu_isFP32Instr,
	io_out_bits_ctrl_vpu_fpu_isFP64Instr,
	io_out_bits_ctrl_vpu_fpu_isReduction,
	io_out_bits_ctrl_vpu_fpu_isFoldTo1_2,
	io_out_bits_ctrl_vpu_fpu_isFoldTo1_4,
	io_out_bits_ctrl_vpu_fpu_isFoldTo1_8,
	io_out_bits_ctrl_vpu_vxrm,
	io_out_bits_ctrl_vpu_vuopIdx,
	io_out_bits_ctrl_vpu_lastUop,
	io_out_bits_ctrl_vpu_vmask,
	io_out_bits_ctrl_vpu_vl,
	io_out_bits_ctrl_vpu_nf,
	io_out_bits_ctrl_vpu_veew,
	io_out_bits_ctrl_vpu_isReverse,
	io_out_bits_ctrl_vpu_isExt,
	io_out_bits_ctrl_vpu_isNarrow,
	io_out_bits_ctrl_vpu_isDstMask,
	io_out_bits_ctrl_vpu_isOpMask,
	io_out_bits_ctrl_vpu_isMove,
	io_out_bits_ctrl_vpu_isDependOldVd,
	io_out_bits_ctrl_vpu_isWritePartVd,
	io_out_bits_ctrl_vpu_isVleff,
	io_out_bits_res_data,
	io_out_bits_perfDebugInfo_eliminatedMove,
	io_out_bits_perfDebugInfo_renameTime,
	io_out_bits_perfDebugInfo_dispatchTime,
	io_out_bits_perfDebugInfo_enqRsTime,
	io_out_bits_perfDebugInfo_selectTime,
	io_out_bits_perfDebugInfo_issueTime,
	io_out_bits_perfDebugInfo_writebackTime,
	io_out_bits_perfDebugInfo_runahead_checkpoint_id,
	io_out_bits_perfDebugInfo_tlbFirstReqTime,
	io_out_bits_perfDebugInfo_tlbRespTime,
	io_out_bits_debug_seqNum_seqNum,
	io_out_bits_debug_seqNum_uopIdx
);
	input clock;
	input reset;
	input io_flush_valid;
	input io_flush_bits_isRVC;
	input io_flush_bits_robIdx_flag;
	input [7:0] io_flush_bits_robIdx_value;
	input io_flush_bits_ftqIdx_flag;
	input [5:0] io_flush_bits_ftqIdx_value;
	input [3:0] io_flush_bits_ftqOffset;
	input io_flush_bits_level;
	input io_flush_bits_interrupt;
	input [49:0] io_flush_bits_cfiUpdate_pc;
	input io_flush_bits_cfiUpdate_pd_valid;
	input io_flush_bits_cfiUpdate_pd_isRVC;
	input [1:0] io_flush_bits_cfiUpdate_pd_brType;
	input io_flush_bits_cfiUpdate_pd_isCall;
	input io_flush_bits_cfiUpdate_pd_isRet;
	input [3:0] io_flush_bits_cfiUpdate_ssp;
	input [2:0] io_flush_bits_cfiUpdate_sctr;
	input io_flush_bits_cfiUpdate_TOSW_flag;
	input [4:0] io_flush_bits_cfiUpdate_TOSW_value;
	input io_flush_bits_cfiUpdate_TOSR_flag;
	input [4:0] io_flush_bits_cfiUpdate_TOSR_value;
	input io_flush_bits_cfiUpdate_NOS_flag;
	input [4:0] io_flush_bits_cfiUpdate_NOS_value;
	input [50:0] io_flush_bits_cfiUpdate_topAddr;
	input [10:0] io_flush_bits_cfiUpdate_folded_hist_hist_17_folded_hist;
	input [10:0] io_flush_bits_cfiUpdate_folded_hist_hist_16_folded_hist;
	input [6:0] io_flush_bits_cfiUpdate_folded_hist_hist_15_folded_hist;
	input [7:0] io_flush_bits_cfiUpdate_folded_hist_hist_14_folded_hist;
	input [8:0] io_flush_bits_cfiUpdate_folded_hist_hist_13_folded_hist;
	input [3:0] io_flush_bits_cfiUpdate_folded_hist_hist_12_folded_hist;
	input [7:0] io_flush_bits_cfiUpdate_folded_hist_hist_11_folded_hist;
	input [8:0] io_flush_bits_cfiUpdate_folded_hist_hist_10_folded_hist;
	input [6:0] io_flush_bits_cfiUpdate_folded_hist_hist_9_folded_hist;
	input [7:0] io_flush_bits_cfiUpdate_folded_hist_hist_8_folded_hist;
	input [6:0] io_flush_bits_cfiUpdate_folded_hist_hist_7_folded_hist;
	input [8:0] io_flush_bits_cfiUpdate_folded_hist_hist_6_folded_hist;
	input [6:0] io_flush_bits_cfiUpdate_folded_hist_hist_5_folded_hist;
	input [7:0] io_flush_bits_cfiUpdate_folded_hist_hist_4_folded_hist;
	input [7:0] io_flush_bits_cfiUpdate_folded_hist_hist_3_folded_hist;
	input [7:0] io_flush_bits_cfiUpdate_folded_hist_hist_2_folded_hist;
	input [10:0] io_flush_bits_cfiUpdate_folded_hist_hist_1_folded_hist;
	input [7:0] io_flush_bits_cfiUpdate_folded_hist_hist_0_folded_hist;
	input io_flush_bits_cfiUpdate_afhob_afhob_5_bits_0;
	input io_flush_bits_cfiUpdate_afhob_afhob_5_bits_1;
	input io_flush_bits_cfiUpdate_afhob_afhob_5_bits_2;
	input io_flush_bits_cfiUpdate_afhob_afhob_5_bits_3;
	input io_flush_bits_cfiUpdate_afhob_afhob_4_bits_0;
	input io_flush_bits_cfiUpdate_afhob_afhob_4_bits_1;
	input io_flush_bits_cfiUpdate_afhob_afhob_4_bits_2;
	input io_flush_bits_cfiUpdate_afhob_afhob_4_bits_3;
	input io_flush_bits_cfiUpdate_afhob_afhob_3_bits_0;
	input io_flush_bits_cfiUpdate_afhob_afhob_3_bits_1;
	input io_flush_bits_cfiUpdate_afhob_afhob_3_bits_2;
	input io_flush_bits_cfiUpdate_afhob_afhob_3_bits_3;
	input io_flush_bits_cfiUpdate_afhob_afhob_2_bits_0;
	input io_flush_bits_cfiUpdate_afhob_afhob_2_bits_1;
	input io_flush_bits_cfiUpdate_afhob_afhob_2_bits_2;
	input io_flush_bits_cfiUpdate_afhob_afhob_2_bits_3;
	input io_flush_bits_cfiUpdate_afhob_afhob_1_bits_0;
	input io_flush_bits_cfiUpdate_afhob_afhob_1_bits_1;
	input io_flush_bits_cfiUpdate_afhob_afhob_1_bits_2;
	input io_flush_bits_cfiUpdate_afhob_afhob_1_bits_3;
	input io_flush_bits_cfiUpdate_afhob_afhob_0_bits_0;
	input io_flush_bits_cfiUpdate_afhob_afhob_0_bits_1;
	input io_flush_bits_cfiUpdate_afhob_afhob_0_bits_2;
	input io_flush_bits_cfiUpdate_afhob_afhob_0_bits_3;
	input [2:0] io_flush_bits_cfiUpdate_lastBrNumOH;
	input [3:0] io_flush_bits_cfiUpdate_ghr;
	input io_flush_bits_cfiUpdate_histPtr_flag;
	input [7:0] io_flush_bits_cfiUpdate_histPtr_value;
	input [9:0] io_flush_bits_cfiUpdate_specCnt_0;
	input [9:0] io_flush_bits_cfiUpdate_specCnt_1;
	input io_flush_bits_cfiUpdate_br_hit;
	input io_flush_bits_cfiUpdate_jr_hit;
	input io_flush_bits_cfiUpdate_sc_hit;
	input io_flush_bits_cfiUpdate_predTaken;
	input [50:0] io_flush_bits_cfiUpdate_target;
	input io_flush_bits_cfiUpdate_taken;
	input io_flush_bits_cfiUpdate_isMisPred;
	input [1:0] io_flush_bits_cfiUpdate_shift;
	input io_flush_bits_cfiUpdate_addIntoHist;
	input io_flush_bits_cfiUpdate_backendIGPF;
	input io_flush_bits_cfiUpdate_backendIPF;
	input io_flush_bits_cfiUpdate_backendIAF;
	input [63:0] io_flush_bits_fullTarget;
	input io_flush_bits_satpFlush;
	input io_flush_bits_isVlsException;
	input io_flush_bits_stFtqIdx_flag;
	input [5:0] io_flush_bits_stFtqIdx_value;
	input [3:0] io_flush_bits_stFtqOffset;
	input [63:0] io_flush_bits_debug_runahead_checkpoint_id;
	input io_flush_bits_debugIsCtrl;
	input io_flush_bits_debugIsMemVio;
	output wire io_in_ready;
	input io_in_valid;
	input [8:0] io_in_bits_ctrl_fuOpType;
	input io_in_bits_ctrl_robIdx_flag;
	input [7:0] io_in_bits_ctrl_robIdx_value;
	input [7:0] io_in_bits_ctrl_pdest;
	input io_in_bits_ctrl_vecWen;
	input io_in_bits_ctrl_v0Wen;
	input io_in_bits_ctrl_vpu_vill;
	input io_in_bits_ctrl_vpu_vma;
	input io_in_bits_ctrl_vpu_vta;
	input [1:0] io_in_bits_ctrl_vpu_vsew;
	input [2:0] io_in_bits_ctrl_vpu_vlmul;
	input io_in_bits_ctrl_vpu_specVill;
	input io_in_bits_ctrl_vpu_specVma;
	input io_in_bits_ctrl_vpu_specVta;
	input [1:0] io_in_bits_ctrl_vpu_specVsew;
	input [2:0] io_in_bits_ctrl_vpu_specVlmul;
	input io_in_bits_ctrl_vpu_vm;
	input [7:0] io_in_bits_ctrl_vpu_vstart;
	input [2:0] io_in_bits_ctrl_vpu_frm;
	input io_in_bits_ctrl_vpu_fpu_isFpToVecInst;
	input io_in_bits_ctrl_vpu_fpu_isFP32Instr;
	input io_in_bits_ctrl_vpu_fpu_isFP64Instr;
	input io_in_bits_ctrl_vpu_fpu_isReduction;
	input io_in_bits_ctrl_vpu_fpu_isFoldTo1_2;
	input io_in_bits_ctrl_vpu_fpu_isFoldTo1_4;
	input io_in_bits_ctrl_vpu_fpu_isFoldTo1_8;
	input [1:0] io_in_bits_ctrl_vpu_vxrm;
	input [6:0] io_in_bits_ctrl_vpu_vuopIdx;
	input io_in_bits_ctrl_vpu_lastUop;
	input [127:0] io_in_bits_ctrl_vpu_vmask;
	input [7:0] io_in_bits_ctrl_vpu_vl;
	input [2:0] io_in_bits_ctrl_vpu_nf;
	input [1:0] io_in_bits_ctrl_vpu_veew;
	input io_in_bits_ctrl_vpu_isReverse;
	input io_in_bits_ctrl_vpu_isExt;
	input io_in_bits_ctrl_vpu_isNarrow;
	input io_in_bits_ctrl_vpu_isDstMask;
	input io_in_bits_ctrl_vpu_isOpMask;
	input io_in_bits_ctrl_vpu_isMove;
	input io_in_bits_ctrl_vpu_isDependOldVd;
	input io_in_bits_ctrl_vpu_isWritePartVd;
	input io_in_bits_ctrl_vpu_isVleff;
	input [8:0] io_in_bits_ctrlPipe_0_fuOpType;
	input io_in_bits_ctrlPipe_0_robIdx_flag;
	input [7:0] io_in_bits_ctrlPipe_0_robIdx_value;
	input [7:0] io_in_bits_ctrlPipe_0_pdest;
	input io_in_bits_ctrlPipe_0_vecWen;
	input io_in_bits_ctrlPipe_0_v0Wen;
	input io_in_bits_ctrlPipe_0_vpu_vill;
	input io_in_bits_ctrlPipe_0_vpu_vma;
	input io_in_bits_ctrlPipe_0_vpu_vta;
	input [1:0] io_in_bits_ctrlPipe_0_vpu_vsew;
	input [2:0] io_in_bits_ctrlPipe_0_vpu_vlmul;
	input io_in_bits_ctrlPipe_0_vpu_specVill;
	input io_in_bits_ctrlPipe_0_vpu_specVma;
	input io_in_bits_ctrlPipe_0_vpu_specVta;
	input [1:0] io_in_bits_ctrlPipe_0_vpu_specVsew;
	input [2:0] io_in_bits_ctrlPipe_0_vpu_specVlmul;
	input io_in_bits_ctrlPipe_0_vpu_vm;
	input [7:0] io_in_bits_ctrlPipe_0_vpu_vstart;
	input [2:0] io_in_bits_ctrlPipe_0_vpu_frm;
	input io_in_bits_ctrlPipe_0_vpu_fpu_isFpToVecInst;
	input io_in_bits_ctrlPipe_0_vpu_fpu_isFP32Instr;
	input io_in_bits_ctrlPipe_0_vpu_fpu_isFP64Instr;
	input io_in_bits_ctrlPipe_0_vpu_fpu_isReduction;
	input io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_2;
	input io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_4;
	input io_in_bits_ctrlPipe_0_vpu_fpu_isFoldTo1_8;
	input [1:0] io_in_bits_ctrlPipe_0_vpu_vxrm;
	input [6:0] io_in_bits_ctrlPipe_0_vpu_vuopIdx;
	input io_in_bits_ctrlPipe_0_vpu_lastUop;
	input [127:0] io_in_bits_ctrlPipe_0_vpu_vmask;
	input [7:0] io_in_bits_ctrlPipe_0_vpu_vl;
	input [2:0] io_in_bits_ctrlPipe_0_vpu_nf;
	input [1:0] io_in_bits_ctrlPipe_0_vpu_veew;
	input io_in_bits_ctrlPipe_0_vpu_isReverse;
	input io_in_bits_ctrlPipe_0_vpu_isExt;
	input io_in_bits_ctrlPipe_0_vpu_isNarrow;
	input io_in_bits_ctrlPipe_0_vpu_isDstMask;
	input io_in_bits_ctrlPipe_0_vpu_isOpMask;
	input io_in_bits_ctrlPipe_0_vpu_isMove;
	input io_in_bits_ctrlPipe_0_vpu_isDependOldVd;
	input io_in_bits_ctrlPipe_0_vpu_isWritePartVd;
	input io_in_bits_ctrlPipe_0_vpu_isVleff;
	input [8:0] io_in_bits_ctrlPipe_1_fuOpType;
	input io_in_bits_ctrlPipe_1_robIdx_flag;
	input [7:0] io_in_bits_ctrlPipe_1_robIdx_value;
	input [7:0] io_in_bits_ctrlPipe_1_pdest;
	input io_in_bits_ctrlPipe_1_vecWen;
	input io_in_bits_ctrlPipe_1_v0Wen;
	input io_in_bits_ctrlPipe_1_vpu_vill;
	input io_in_bits_ctrlPipe_1_vpu_vma;
	input io_in_bits_ctrlPipe_1_vpu_vta;
	input [1:0] io_in_bits_ctrlPipe_1_vpu_vsew;
	input [2:0] io_in_bits_ctrlPipe_1_vpu_vlmul;
	input io_in_bits_ctrlPipe_1_vpu_specVill;
	input io_in_bits_ctrlPipe_1_vpu_specVma;
	input io_in_bits_ctrlPipe_1_vpu_specVta;
	input [1:0] io_in_bits_ctrlPipe_1_vpu_specVsew;
	input [2:0] io_in_bits_ctrlPipe_1_vpu_specVlmul;
	input io_in_bits_ctrlPipe_1_vpu_vm;
	input [7:0] io_in_bits_ctrlPipe_1_vpu_vstart;
	input [2:0] io_in_bits_ctrlPipe_1_vpu_frm;
	input io_in_bits_ctrlPipe_1_vpu_fpu_isFpToVecInst;
	input io_in_bits_ctrlPipe_1_vpu_fpu_isFP32Instr;
	input io_in_bits_ctrlPipe_1_vpu_fpu_isFP64Instr;
	input io_in_bits_ctrlPipe_1_vpu_fpu_isReduction;
	input io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_2;
	input io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_4;
	input io_in_bits_ctrlPipe_1_vpu_fpu_isFoldTo1_8;
	input [1:0] io_in_bits_ctrlPipe_1_vpu_vxrm;
	input [6:0] io_in_bits_ctrlPipe_1_vpu_vuopIdx;
	input io_in_bits_ctrlPipe_1_vpu_lastUop;
	input [127:0] io_in_bits_ctrlPipe_1_vpu_vmask;
	input [7:0] io_in_bits_ctrlPipe_1_vpu_vl;
	input [2:0] io_in_bits_ctrlPipe_1_vpu_nf;
	input [1:0] io_in_bits_ctrlPipe_1_vpu_veew;
	input io_in_bits_ctrlPipe_1_vpu_isReverse;
	input io_in_bits_ctrlPipe_1_vpu_isExt;
	input io_in_bits_ctrlPipe_1_vpu_isNarrow;
	input io_in_bits_ctrlPipe_1_vpu_isDstMask;
	input io_in_bits_ctrlPipe_1_vpu_isOpMask;
	input io_in_bits_ctrlPipe_1_vpu_isMove;
	input io_in_bits_ctrlPipe_1_vpu_isDependOldVd;
	input io_in_bits_ctrlPipe_1_vpu_isWritePartVd;
	input io_in_bits_ctrlPipe_1_vpu_isVleff;
	input [8:0] io_in_bits_ctrlPipe_2_fuOpType;
	input io_in_bits_ctrlPipe_2_robIdx_flag;
	input [7:0] io_in_bits_ctrlPipe_2_robIdx_value;
	input [7:0] io_in_bits_ctrlPipe_2_pdest;
	input io_in_bits_ctrlPipe_2_vecWen;
	input io_in_bits_ctrlPipe_2_v0Wen;
	input io_in_bits_ctrlPipe_2_vpu_vill;
	input io_in_bits_ctrlPipe_2_vpu_vma;
	input io_in_bits_ctrlPipe_2_vpu_vta;
	input [1:0] io_in_bits_ctrlPipe_2_vpu_vsew;
	input [2:0] io_in_bits_ctrlPipe_2_vpu_vlmul;
	input io_in_bits_ctrlPipe_2_vpu_specVill;
	input io_in_bits_ctrlPipe_2_vpu_specVma;
	input io_in_bits_ctrlPipe_2_vpu_specVta;
	input [1:0] io_in_bits_ctrlPipe_2_vpu_specVsew;
	input [2:0] io_in_bits_ctrlPipe_2_vpu_specVlmul;
	input io_in_bits_ctrlPipe_2_vpu_vm;
	input [7:0] io_in_bits_ctrlPipe_2_vpu_vstart;
	input [2:0] io_in_bits_ctrlPipe_2_vpu_frm;
	input io_in_bits_ctrlPipe_2_vpu_fpu_isFpToVecInst;
	input io_in_bits_ctrlPipe_2_vpu_fpu_isFP32Instr;
	input io_in_bits_ctrlPipe_2_vpu_fpu_isFP64Instr;
	input io_in_bits_ctrlPipe_2_vpu_fpu_isReduction;
	input io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_2;
	input io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_4;
	input io_in_bits_ctrlPipe_2_vpu_fpu_isFoldTo1_8;
	input [1:0] io_in_bits_ctrlPipe_2_vpu_vxrm;
	input [6:0] io_in_bits_ctrlPipe_2_vpu_vuopIdx;
	input io_in_bits_ctrlPipe_2_vpu_lastUop;
	input [127:0] io_in_bits_ctrlPipe_2_vpu_vmask;
	input [7:0] io_in_bits_ctrlPipe_2_vpu_vl;
	input [2:0] io_in_bits_ctrlPipe_2_vpu_nf;
	input [1:0] io_in_bits_ctrlPipe_2_vpu_veew;
	input io_in_bits_ctrlPipe_2_vpu_isReverse;
	input io_in_bits_ctrlPipe_2_vpu_isExt;
	input io_in_bits_ctrlPipe_2_vpu_isNarrow;
	input io_in_bits_ctrlPipe_2_vpu_isDstMask;
	input io_in_bits_ctrlPipe_2_vpu_isOpMask;
	input io_in_bits_ctrlPipe_2_vpu_isMove;
	input io_in_bits_ctrlPipe_2_vpu_isDependOldVd;
	input io_in_bits_ctrlPipe_2_vpu_isWritePartVd;
	input io_in_bits_ctrlPipe_2_vpu_isVleff;
	input io_in_bits_validPipe_0;
	input io_in_bits_validPipe_1;
	input io_in_bits_validPipe_2;
	input [7:0] io_in_bits_data_src_4;
	input [127:0] io_in_bits_data_src_3;
	input [127:0] io_in_bits_data_src_2;
	input [127:0] io_in_bits_data_src_1;
	input [127:0] io_in_bits_data_src_0;
	input [127:0] io_in_bits_data_imm;
	input [7:0] io_in_bits_dataPipe_0_src_4;
	input [127:0] io_in_bits_dataPipe_0_src_3;
	input [127:0] io_in_bits_dataPipe_0_src_2;
	input [127:0] io_in_bits_dataPipe_0_src_1;
	input [127:0] io_in_bits_dataPipe_0_src_0;
	input [127:0] io_in_bits_dataPipe_0_imm;
	input [7:0] io_in_bits_dataPipe_1_src_4;
	input [127:0] io_in_bits_dataPipe_1_src_3;
	input [127:0] io_in_bits_dataPipe_1_src_2;
	input [127:0] io_in_bits_dataPipe_1_src_1;
	input [127:0] io_in_bits_dataPipe_1_src_0;
	input [127:0] io_in_bits_dataPipe_1_imm;
	input [7:0] io_in_bits_dataPipe_2_src_4;
	input [127:0] io_in_bits_dataPipe_2_src_3;
	input [127:0] io_in_bits_dataPipe_2_src_2;
	input [127:0] io_in_bits_dataPipe_2_src_1;
	input [127:0] io_in_bits_dataPipe_2_src_0;
	input [127:0] io_in_bits_dataPipe_2_imm;
	input io_in_bits_perfDebugInfo_eliminatedMove;
	input [63:0] io_in_bits_perfDebugInfo_renameTime;
	input [63:0] io_in_bits_perfDebugInfo_dispatchTime;
	input [63:0] io_in_bits_perfDebugInfo_enqRsTime;
	input [63:0] io_in_bits_perfDebugInfo_selectTime;
	input [63:0] io_in_bits_perfDebugInfo_issueTime;
	input [63:0] io_in_bits_perfDebugInfo_writebackTime;
	input [63:0] io_in_bits_perfDebugInfo_runahead_checkpoint_id;
	input [63:0] io_in_bits_perfDebugInfo_tlbFirstReqTime;
	input [63:0] io_in_bits_perfDebugInfo_tlbRespTime;
	input [55:0] io_in_bits_debug_seqNum_seqNum;
	input [7:0] io_in_bits_debug_seqNum_uopIdx;
	input io_out_ready;
	output wire io_out_valid;
	output wire io_out_bits_ctrl_robIdx_flag;
	output wire [7:0] io_out_bits_ctrl_robIdx_value;
	output wire [7:0] io_out_bits_ctrl_pdest;
	output wire io_out_bits_ctrl_vecWen;
	output wire io_out_bits_ctrl_v0Wen;
	output wire io_out_bits_ctrl_exceptionVec_0;
	output wire io_out_bits_ctrl_exceptionVec_1;
	output wire io_out_bits_ctrl_exceptionVec_2;
	output wire io_out_bits_ctrl_exceptionVec_3;
	output wire io_out_bits_ctrl_exceptionVec_4;
	output wire io_out_bits_ctrl_exceptionVec_5;
	output wire io_out_bits_ctrl_exceptionVec_6;
	output wire io_out_bits_ctrl_exceptionVec_7;
	output wire io_out_bits_ctrl_exceptionVec_8;
	output wire io_out_bits_ctrl_exceptionVec_9;
	output wire io_out_bits_ctrl_exceptionVec_10;
	output wire io_out_bits_ctrl_exceptionVec_11;
	output wire io_out_bits_ctrl_exceptionVec_12;
	output wire io_out_bits_ctrl_exceptionVec_13;
	output wire io_out_bits_ctrl_exceptionVec_14;
	output wire io_out_bits_ctrl_exceptionVec_15;
	output wire io_out_bits_ctrl_exceptionVec_16;
	output wire io_out_bits_ctrl_exceptionVec_17;
	output wire io_out_bits_ctrl_exceptionVec_18;
	output wire io_out_bits_ctrl_exceptionVec_19;
	output wire io_out_bits_ctrl_exceptionVec_20;
	output wire io_out_bits_ctrl_exceptionVec_21;
	output wire io_out_bits_ctrl_exceptionVec_22;
	output wire io_out_bits_ctrl_exceptionVec_23;
	output wire io_out_bits_ctrl_vpu_vill;
	output wire io_out_bits_ctrl_vpu_vma;
	output wire io_out_bits_ctrl_vpu_vta;
	output wire [1:0] io_out_bits_ctrl_vpu_vsew;
	output wire [2:0] io_out_bits_ctrl_vpu_vlmul;
	output wire io_out_bits_ctrl_vpu_specVill;
	output wire io_out_bits_ctrl_vpu_specVma;
	output wire io_out_bits_ctrl_vpu_specVta;
	output wire [1:0] io_out_bits_ctrl_vpu_specVsew;
	output wire [2:0] io_out_bits_ctrl_vpu_specVlmul;
	output wire io_out_bits_ctrl_vpu_vm;
	output wire [7:0] io_out_bits_ctrl_vpu_vstart;
	output wire [2:0] io_out_bits_ctrl_vpu_frm;
	output wire io_out_bits_ctrl_vpu_fpu_isFpToVecInst;
	output wire io_out_bits_ctrl_vpu_fpu_isFP32Instr;
	output wire io_out_bits_ctrl_vpu_fpu_isFP64Instr;
	output wire io_out_bits_ctrl_vpu_fpu_isReduction;
	output wire io_out_bits_ctrl_vpu_fpu_isFoldTo1_2;
	output wire io_out_bits_ctrl_vpu_fpu_isFoldTo1_4;
	output wire io_out_bits_ctrl_vpu_fpu_isFoldTo1_8;
	output wire [1:0] io_out_bits_ctrl_vpu_vxrm;
	output wire [6:0] io_out_bits_ctrl_vpu_vuopIdx;
	output wire io_out_bits_ctrl_vpu_lastUop;
	output wire [127:0] io_out_bits_ctrl_vpu_vmask;
	output wire [7:0] io_out_bits_ctrl_vpu_vl;
	output wire [2:0] io_out_bits_ctrl_vpu_nf;
	output wire [1:0] io_out_bits_ctrl_vpu_veew;
	output wire io_out_bits_ctrl_vpu_isReverse;
	output wire io_out_bits_ctrl_vpu_isExt;
	output wire io_out_bits_ctrl_vpu_isNarrow;
	output wire io_out_bits_ctrl_vpu_isDstMask;
	output wire io_out_bits_ctrl_vpu_isOpMask;
	output wire io_out_bits_ctrl_vpu_isMove;
	output wire io_out_bits_ctrl_vpu_isDependOldVd;
	output wire io_out_bits_ctrl_vpu_isWritePartVd;
	output wire io_out_bits_ctrl_vpu_isVleff;
	output wire [127:0] io_out_bits_res_data;
	output wire io_out_bits_perfDebugInfo_eliminatedMove;
	output wire [63:0] io_out_bits_perfDebugInfo_renameTime;
	output wire [63:0] io_out_bits_perfDebugInfo_dispatchTime;
	output wire [63:0] io_out_bits_perfDebugInfo_enqRsTime;
	output wire [63:0] io_out_bits_perfDebugInfo_selectTime;
	output wire [63:0] io_out_bits_perfDebugInfo_issueTime;
	output wire [63:0] io_out_bits_perfDebugInfo_writebackTime;
	output wire [63:0] io_out_bits_perfDebugInfo_runahead_checkpoint_id;
	output wire [63:0] io_out_bits_perfDebugInfo_tlbFirstReqTime;
	output wire [63:0] io_out_bits_perfDebugInfo_tlbRespTime;
	output wire [55:0] io_out_bits_debug_seqNum_seqNum;
	output wire [7:0] io_out_bits_debug_seqNum_uopIdx;
	wire rdyVec_1;
	reg validVecThisFu_1;
	reg validVecThisFu_2;
	reg perfVec_1_eliminatedMove;
	reg [63:0] perfVec_1_renameTime;
	reg [63:0] perfVec_1_dispatchTime;
	reg [63:0] perfVec_1_enqRsTime;
	reg [63:0] perfVec_1_selectTime;
	reg [63:0] perfVec_1_issueTime;
	reg [63:0] perfVec_1_writebackTime;
	reg [63:0] perfVec_1_runahead_checkpoint_id;
	reg [63:0] perfVec_1_tlbFirstReqTime;
	reg [63:0] perfVec_1_tlbRespTime;
	reg perfVec_2_eliminatedMove;
	reg [63:0] perfVec_2_renameTime;
	reg [63:0] perfVec_2_dispatchTime;
	reg [63:0] perfVec_2_enqRsTime;
	reg [63:0] perfVec_2_selectTime;
	reg [63:0] perfVec_2_issueTime;
	reg [63:0] perfVec_2_writebackTime;
	reg [63:0] perfVec_2_runahead_checkpoint_id;
	reg [63:0] perfVec_2_tlbFirstReqTime;
	reg [63:0] perfVec_2_tlbRespTime;
	reg [55:0] seqNumVec_1_seqNum;
	reg [7:0] seqNumVec_1_uopIdx;
	reg [55:0] seqNumVec_2_seqNum;
	reg [7:0] seqNumVec_2_uopIdx;
	wire rdyVec_0 = ~validVecThisFu_1 | rdyVec_1;
	assign rdyVec_1 = ~validVecThisFu_2 | io_out_ready;
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
	VDotUnit VDotDatapath(
		.clock(clock),
		.reset(reset),
		.io_fire(io_in_valid),
		.io_vs1(io_in_bits_data_src_0),
		.io_vs2(io_in_bits_data_src_1),
		.io_vd(io_out_bits_res_data)
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
	assign io_out_bits_ctrl_exceptionVec_2 = (((io_in_bits_ctrlPipe_2_vpu_vill | (|io_in_bits_ctrlPipe_2_vpu_vsew)) | (|io_in_bits_ctrlPipe_2_vpu_vlmul)) | ~io_in_bits_ctrlPipe_2_vpu_vm) | (|io_in_bits_ctrlPipe_2_vpu_vstart);
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
	assign io_out_bits_ctrl_vpu_fpu_isFpToVecInst = io_in_bits_ctrlPipe_2_vpu_fpu_isFpToVecInst;
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
	assign io_out_bits_perfDebugInfo_runahead_checkpoint_id = perfVec_2_runahead_checkpoint_id;
	assign io_out_bits_perfDebugInfo_tlbFirstReqTime = perfVec_2_tlbFirstReqTime;
	assign io_out_bits_perfDebugInfo_tlbRespTime = perfVec_2_tlbRespTime;
	assign io_out_bits_debug_seqNum_seqNum = seqNumVec_2_seqNum;
	assign io_out_bits_debug_seqNum_uopIdx = seqNumVec_2_uopIdx;
endmodule
