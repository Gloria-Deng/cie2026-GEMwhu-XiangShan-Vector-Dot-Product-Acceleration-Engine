module Adder_chain_rnd (
	io_din_0,
	io_din_1,
	io_din_2,
	io_din_3,
	io_din_4,
	io_din_5,
	io_din_6,
	io_din_7,
	io_rndInc_0,
	io_rndInc_1,
	io_rndInc_2,
	io_rndInc_3,
	io_rndInc_4,
	io_rndInc_5,
	io_rndInc_6,
	io_rndInc_7,
	io_isNClip,
	io_sew_oneHot,
	io_dout_0,
	io_dout_1,
	io_dout_2,
	io_dout_3,
	io_dout_4,
	io_dout_5,
	io_dout_6,
	io_dout_7,
	io_cout_0,
	io_cout_1,
	io_cout_2,
	io_cout_3,
	io_cout_4,
	io_cout_5,
	io_cout_6,
	io_all_1s_1,
	io_all_1s_2,
	io_all_1s_3,
	io_all_1s_4,
	io_all_1s_5,
	io_all_1s_6,
	io_all_1s_7,
	io_all_0s_1,
	io_all_0s_2,
	io_all_0s_3,
	io_all_0s_4,
	io_all_0s_5,
	io_all_0s_6,
	io_all_0s_7
);
	input [7:0] io_din_0;
	input [7:0] io_din_1;
	input [7:0] io_din_2;
	input [7:0] io_din_3;
	input [7:0] io_din_4;
	input [7:0] io_din_5;
	input [7:0] io_din_6;
	input [7:0] io_din_7;
	input io_rndInc_0;
	input io_rndInc_1;
	input io_rndInc_2;
	input io_rndInc_3;
	input io_rndInc_4;
	input io_rndInc_5;
	input io_rndInc_6;
	input io_rndInc_7;
	input io_isNClip;
	input [3:0] io_sew_oneHot;
	output wire [7:0] io_dout_0;
	output wire [7:0] io_dout_1;
	output wire [7:0] io_dout_2;
	output wire [7:0] io_dout_3;
	output wire [7:0] io_dout_4;
	output wire [7:0] io_dout_5;
	output wire [7:0] io_dout_6;
	output wire [7:0] io_dout_7;
	output wire io_cout_0;
	output wire io_cout_1;
	output wire io_cout_2;
	output wire io_cout_3;
	output wire io_cout_4;
	output wire io_cout_5;
	output wire io_cout_6;
	output wire io_all_1s_1;
	output wire io_all_1s_2;
	output wire io_all_1s_3;
	output wire io_all_1s_4;
	output wire io_all_1s_5;
	output wire io_all_1s_6;
	output wire io_all_1s_7;
	output wire io_all_0s_1;
	output wire io_all_0s_2;
	output wire io_all_0s_3;
	output wire io_all_0s_4;
	output wire io_all_0s_5;
	output wire io_all_0s_6;
	output wire io_all_0s_7;
	wire cin_7;
	wire cin_6;
	wire cin_5;
	wire cin_4;
	wire cin_3;
	wire cin_2;
	wire cin_1;
	wire cout = &io_din_0 & io_rndInc_0;
	wire cout_1 = &io_din_1 & cin_1;
	assign cin_1 = (~io_isNClip & io_sew_oneHot[0] ? io_rndInc_1 : cout);
	wire cout_2 = &io_din_2 & cin_2;
	assign cin_2 = (|(io_isNClip ? io_sew_oneHot[2:1] : io_sew_oneHot[3:2]) ? cout_1 : io_rndInc_2);
	wire cout_3 = &io_din_3 & cin_3;
	assign cin_3 = (~io_isNClip & io_sew_oneHot[0] ? io_rndInc_3 : cout_2);
	wire cout_4 = &io_din_4 & cin_4;
	assign cin_4 = ((io_isNClip ? io_sew_oneHot[2] : io_sew_oneHot[3]) ? cout_3 : io_rndInc_4);
	wire cout_5 = &io_din_5 & cin_5;
	assign cin_5 = (~io_isNClip & io_sew_oneHot[0] ? io_rndInc_5 : cout_4);
	wire cout_6 = &io_din_6 & cin_6;
	assign cin_6 = (|(io_isNClip ? io_sew_oneHot[2:1] : io_sew_oneHot[3:2]) ? cout_5 : io_rndInc_6);
	assign cin_7 = (~io_isNClip & io_sew_oneHot[0] ? io_rndInc_7 : cout_6);
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	assign io_dout_0 = sv2v_cast_8(io_din_0 + {7'h00, io_rndInc_0});
	assign io_dout_1 = sv2v_cast_8(io_din_1 + {7'h00, cin_1});
	assign io_dout_2 = sv2v_cast_8(io_din_2 + {7'h00, cin_2});
	assign io_dout_3 = sv2v_cast_8(io_din_3 + {7'h00, cin_3});
	assign io_dout_4 = sv2v_cast_8(io_din_4 + {7'h00, cin_4});
	assign io_dout_5 = sv2v_cast_8(io_din_5 + {7'h00, cin_5});
	assign io_dout_6 = sv2v_cast_8(io_din_6 + {7'h00, cin_6});
	assign io_dout_7 = sv2v_cast_8(io_din_7 + {7'h00, cin_7});
	assign io_cout_0 = cout;
	assign io_cout_1 = cout_1;
	assign io_cout_2 = cout_2;
	assign io_cout_3 = cout_3;
	assign io_cout_4 = cout_4;
	assign io_cout_5 = cout_5;
	assign io_cout_6 = cout_6;
	assign io_all_1s_1 = &io_din_1;
	assign io_all_1s_2 = &io_din_2;
	assign io_all_1s_3 = &io_din_3;
	assign io_all_1s_4 = &io_din_4;
	assign io_all_1s_5 = &io_din_5;
	assign io_all_1s_6 = &io_din_6;
	assign io_all_1s_7 = &io_din_7;
	assign io_all_0s_1 = io_din_1 == 8'h00;
	assign io_all_0s_2 = io_din_2 == 8'h00;
	assign io_all_0s_3 = io_din_3 == 8'h00;
	assign io_all_0s_4 = io_din_4 == 8'h00;
	assign io_all_0s_5 = io_din_5 == 8'h00;
	assign io_all_0s_6 = io_din_6 == 8'h00;
	assign io_all_0s_7 = io_din_7 == 8'h00;
endmodule
module ByteMaskTailGen (
	io_in_begin,
	io_in_end,
	io_in_vma,
	io_in_vta,
	io_in_vsew,
	io_in_maskUsed,
	io_in_vdIdx,
	io_out_activeEn,
	io_out_agnosticEn
);
	input [7:0] io_in_begin;
	input [7:0] io_in_end;
	input io_in_vma;
	input io_in_vta;
	input [1:0] io_in_vsew;
	input [15:0] io_in_maskUsed;
	input [2:0] io_in_vdIdx;
	output wire [15:0] io_out_activeEn;
	output wire [15:0] io_out_agnosticEn;
	wire [15:0] _maskEn_maskExtractor_io_out_mask;
	wire [254:0] _tailEn_uintToContTail0sMod128Bits_io_dataOut;
	wire [254:0] _bodyEn_uintToContTail1sMod128Bits_io_dataOut;
	wire [254:0] _bodyEn_uintToContTail0sMod128Bits_io_dataOut;
	wire [254:0] _prestartEn_uintToContTail1sMod128Bits_io_dataOut;
	wire [3:0] eewOH_sew_oneHot = {&io_in_vsew, io_in_vsew == 2'h2, io_in_vsew == 2'h1, io_in_vsew == 2'h0};
	wire [7:0] startBytes = (((eewOH_sew_oneHot[0] ? io_in_begin : 8'h00) | (eewOH_sew_oneHot[1] ? {io_in_begin[6:0], 1'h0} : 8'h00)) | (eewOH_sew_oneHot[2] ? {io_in_begin[5:0], 2'h0} : 8'h00)) | (eewOH_sew_oneHot[3] ? {io_in_begin[4:0], 3'h0} : 8'h00);
	wire [7:0] vlBytes = (((eewOH_sew_oneHot[0] ? io_in_end : 8'h00) | (eewOH_sew_oneHot[1] ? {io_in_end[6:0], 1'h0} : 8'h00)) | (eewOH_sew_oneHot[2] ? {io_in_end[5:0], 2'h0} : 8'h00)) | (eewOH_sew_oneHot[3] ? {io_in_end[4:0], 3'h0} : 8'h00);
	wire [127:0] prestartEn = _prestartEn_uintToContTail1sMod128Bits_io_dataOut[127:0];
	wire [127:0] bodyEn = _bodyEn_uintToContTail0sMod128Bits_io_dataOut[127:0] & _bodyEn_uintToContTail1sMod128Bits_io_dataOut[127:0];
	wire [127:0] tailEn = _tailEn_uintToContTail0sMod128Bits_io_dataOut[127:0];
	wire _tailEnInVd_T_8 = io_in_vdIdx == 3'h0;
	wire _tailEnInVd_T_9 = io_in_vdIdx == 3'h1;
	wire _tailEnInVd_T_10 = io_in_vdIdx == 3'h2;
	wire _tailEnInVd_T_11 = io_in_vdIdx == 3'h3;
	wire _tailEnInVd_T_12 = io_in_vdIdx == 3'h4;
	wire _tailEnInVd_T_13 = io_in_vdIdx == 3'h5;
	wire _tailEnInVd_T_14 = io_in_vdIdx == 3'h6;
	wire [15:0] prestartEnInVd = (((((((_tailEnInVd_T_8 ? prestartEn[15:0] : 16'h0000) | (_tailEnInVd_T_9 ? prestartEn[31:16] : 16'h0000)) | (_tailEnInVd_T_10 ? prestartEn[47:32] : 16'h0000)) | (_tailEnInVd_T_11 ? prestartEn[63:48] : 16'h0000)) | (_tailEnInVd_T_12 ? prestartEn[79:64] : 16'h0000)) | (_tailEnInVd_T_13 ? prestartEn[95:80] : 16'h0000)) | (_tailEnInVd_T_14 ? prestartEn[111:96] : 16'h0000)) | (&io_in_vdIdx ? prestartEn[127:112] : 16'h0000);
	wire [15:0] bodyEnInVd = (((((((_tailEnInVd_T_8 ? bodyEn[15:0] : 16'h0000) | (_tailEnInVd_T_9 ? bodyEn[31:16] : 16'h0000)) | (_tailEnInVd_T_10 ? bodyEn[47:32] : 16'h0000)) | (_tailEnInVd_T_11 ? bodyEn[63:48] : 16'h0000)) | (_tailEnInVd_T_12 ? bodyEn[79:64] : 16'h0000)) | (_tailEnInVd_T_13 ? bodyEn[95:80] : 16'h0000)) | (_tailEnInVd_T_14 ? bodyEn[111:96] : 16'h0000)) | (&io_in_vdIdx ? bodyEn[127:112] : 16'h0000);
	wire [15:0] tailEnInVd = (((((((_tailEnInVd_T_8 ? tailEn[15:0] : 16'h0000) | (_tailEnInVd_T_9 ? tailEn[31:16] : 16'h0000)) | (_tailEnInVd_T_10 ? tailEn[47:32] : 16'h0000)) | (_tailEnInVd_T_11 ? tailEn[63:48] : 16'h0000)) | (_tailEnInVd_T_12 ? tailEn[79:64] : 16'h0000)) | (_tailEnInVd_T_13 ? tailEn[95:80] : 16'h0000)) | (_tailEnInVd_T_14 ? tailEn[111:96] : 16'h0000)) | (&io_in_vdIdx ? tailEn[127:112] : 16'h0000);
	wire [15:0] maskOffEn = ~_maskEn_maskExtractor_io_out_mask;
	wire [15:0] maskAgnosticEn = (io_in_vma ? maskOffEn : 16'h0000) & bodyEnInVd;
	wire [15:0] tailAgnosticEn = (io_in_vta ? tailEnInVd : 16'h0000);
	wire _agnosticEn_T = io_in_begin >= io_in_end;
	UIntToContLow1s prestartEn_uintToContTail1sMod128Bits(
		.io_dataIn(startBytes),
		.io_dataOut(_prestartEn_uintToContTail1sMod128Bits_io_dataOut)
	);
	UIntToContLow0s bodyEn_uintToContTail0sMod128Bits(
		.io_dataIn(startBytes),
		.io_dataOut(_bodyEn_uintToContTail0sMod128Bits_io_dataOut)
	);
	UIntToContLow1s bodyEn_uintToContTail1sMod128Bits(
		.io_dataIn(vlBytes),
		.io_dataOut(_bodyEn_uintToContTail1sMod128Bits_io_dataOut)
	);
	UIntToContLow0s tailEn_uintToContTail0sMod128Bits(
		.io_dataIn(vlBytes),
		.io_dataOut(_tailEn_uintToContTail0sMod128Bits_io_dataOut)
	);
	MaskExtractor maskEn_maskExtractor(
		.io_in_mask(io_in_maskUsed),
		.io_in_vsew(io_in_vsew),
		.io_out_mask(_maskEn_maskExtractor_io_out_mask)
	);
	assign io_out_activeEn = (_agnosticEn_T ? 16'h0000 : bodyEnInVd & _maskEn_maskExtractor_io_out_mask);
	assign io_out_agnosticEn = (_agnosticEn_T ? 16'h0000 : maskAgnosticEn | tailAgnosticEn);
endmodule
module CLZ_11 (
	io_in,
	io_out
);
	input [7:0] io_in;
	output wire [3:0] io_out;
	assign io_out = (io_in[7] ? 4'h0 : (io_in[6] ? 4'h1 : (io_in[5] ? 4'h2 : (io_in[4] ? 4'h3 : (io_in[3] ? 4'h4 : (io_in[2] ? 4'h5 : (io_in[1] ? 4'h6 : (io_in[0] ? 4'h7 : 4'h8))))))));
endmodule
module CLZ_6 (
	io_in,
	io_out
);
	input [63:0] io_in;
	output wire [6:0] io_out;
	assign io_out = (io_in[63] ? 7'h00 : (io_in[62] ? 7'h01 : (io_in[61] ? 7'h02 : (io_in[60] ? 7'h03 : (io_in[59] ? 7'h04 : (io_in[58] ? 7'h05 : (io_in[57] ? 7'h06 : (io_in[56] ? 7'h07 : (io_in[55] ? 7'h08 : (io_in[54] ? 7'h09 : (io_in[53] ? 7'h0a : (io_in[52] ? 7'h0b : (io_in[51] ? 7'h0c : (io_in[50] ? 7'h0d : (io_in[49] ? 7'h0e : (io_in[48] ? 7'h0f : (io_in[47] ? 7'h10 : (io_in[46] ? 7'h11 : (io_in[45] ? 7'h12 : (io_in[44] ? 7'h13 : (io_in[43] ? 7'h14 : (io_in[42] ? 7'h15 : (io_in[41] ? 7'h16 : (io_in[40] ? 7'h17 : (io_in[39] ? 7'h18 : (io_in[38] ? 7'h19 : (io_in[37] ? 7'h1a : (io_in[36] ? 7'h1b : (io_in[35] ? 7'h1c : (io_in[34] ? 7'h1d : (io_in[33] ? 7'h1e : (io_in[32] ? 7'h1f : (io_in[31] ? 7'h20 : (io_in[30] ? 7'h21 : (io_in[29] ? 7'h22 : (io_in[28] ? 7'h23 : (io_in[27] ? 7'h24 : (io_in[26] ? 7'h25 : (io_in[25] ? 7'h26 : (io_in[24] ? 7'h27 : (io_in[23] ? 7'h28 : (io_in[22] ? 7'h29 : (io_in[21] ? 7'h2a : (io_in[20] ? 7'h2b : (io_in[19] ? 7'h2c : (io_in[18] ? 7'h2d : (io_in[17] ? 7'h2e : (io_in[16] ? 7'h2f : (io_in[15] ? 7'h30 : (io_in[14] ? 7'h31 : (io_in[13] ? 7'h32 : (io_in[12] ? 7'h33 : (io_in[11] ? 7'h34 : (io_in[10] ? 7'h35 : (io_in[9] ? 7'h36 : (io_in[8] ? 7'h37 : (io_in[7] ? 7'h38 : (io_in[6] ? 7'h39 : (io_in[5] ? 7'h3a : (io_in[4] ? 7'h3b : (io_in[3] ? 7'h3c : (io_in[2] ? 7'h3d : (io_in[1] ? 7'h3e : (io_in[0] ? 7'h3f : 7'h40))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
endmodule
module CLZ_7 (
	io_in,
	io_out
);
	input [15:0] io_in;
	output wire [4:0] io_out;
	assign io_out = (io_in[15] ? 5'h00 : (io_in[14] ? 5'h01 : (io_in[13] ? 5'h02 : (io_in[12] ? 5'h03 : (io_in[11] ? 5'h04 : (io_in[10] ? 5'h05 : (io_in[9] ? 5'h06 : (io_in[8] ? 5'h07 : (io_in[7] ? 5'h08 : (io_in[6] ? 5'h09 : (io_in[5] ? 5'h0a : (io_in[4] ? 5'h0b : (io_in[3] ? 5'h0c : (io_in[2] ? 5'h0d : (io_in[1] ? 5'h0e : (io_in[0] ? 5'h0f : 5'h10))))))))))))))));
endmodule
module CLZ_9 (
	io_in,
	io_out
);
	input [31:0] io_in;
	output wire [5:0] io_out;
	assign io_out = (io_in[31] ? 6'h00 : (io_in[30] ? 6'h01 : (io_in[29] ? 6'h02 : (io_in[28] ? 6'h03 : (io_in[27] ? 6'h04 : (io_in[26] ? 6'h05 : (io_in[25] ? 6'h06 : (io_in[24] ? 6'h07 : (io_in[23] ? 6'h08 : (io_in[22] ? 6'h09 : (io_in[21] ? 6'h0a : (io_in[20] ? 6'h0b : (io_in[19] ? 6'h0c : (io_in[18] ? 6'h0d : (io_in[17] ? 6'h0e : (io_in[16] ? 6'h0f : (io_in[15] ? 6'h10 : (io_in[14] ? 6'h11 : (io_in[13] ? 6'h12 : (io_in[12] ? 6'h13 : (io_in[11] ? 6'h14 : (io_in[10] ? 6'h15 : (io_in[9] ? 6'h16 : (io_in[8] ? 6'h17 : (io_in[7] ? 6'h18 : (io_in[6] ? 6'h19 : (io_in[5] ? 6'h1a : (io_in[4] ? 6'h1b : (io_in[3] ? 6'h1c : (io_in[2] ? 6'h1d : (io_in[1] ? 6'h1e : (io_in[0] ? 6'h1f : 6'h20))))))))))))))))))))))))))))))));
endmodule
module MaskExtractor (
	io_in_mask,
	io_in_vsew,
	io_out_mask
);
	input [15:0] io_in_mask;
	input [1:0] io_in_vsew;
	output wire [15:0] io_out_mask;
	assign io_out_mask = (((io_in_vsew == 2'h0 ? io_in_mask : 16'h0000) | (io_in_vsew == 2'h1 ? {{2 {io_in_mask[7]}}, {2 {io_in_mask[6]}}, {2 {io_in_mask[5]}}, {2 {io_in_mask[4]}}, {2 {io_in_mask[3]}}, {2 {io_in_mask[2]}}, {2 {io_in_mask[1]}}, {2 {io_in_mask[0]}}} : 16'h0000)) | (io_in_vsew == 2'h2 ? {{4 {io_in_mask[3]}}, {4 {io_in_mask[2]}}, {4 {io_in_mask[1]}}, {4 {io_in_mask[0]}}} : 16'h0000)) | (&io_in_vsew ? {{8 {io_in_mask[1]}}, {8 {io_in_mask[0]}}} : 16'h0000);
endmodule
module Mgtu (
	io_in_vd,
	io_in_vl,
	io_out_vd
);
	input [127:0] io_in_vd;
	input [7:0] io_in_vl;
	output wire [127:0] io_out_vd;
	assign io_out_vd = {~io_in_vl[7] | io_in_vd[127], (io_in_vl < 8'h7f) | io_in_vd[126], (io_in_vl < 8'h7e) | io_in_vd[125], (io_in_vl < 8'h7d) | io_in_vd[124], (io_in_vl < 8'h7c) | io_in_vd[123], (io_in_vl < 8'h7b) | io_in_vd[122], (io_in_vl < 8'h7a) | io_in_vd[121], (io_in_vl < 8'h79) | io_in_vd[120], (io_in_vl < 8'h78) | io_in_vd[119], (io_in_vl < 8'h77) | io_in_vd[118], (io_in_vl < 8'h76) | io_in_vd[117], (io_in_vl < 8'h75) | io_in_vd[116], (io_in_vl < 8'h74) | io_in_vd[115], (io_in_vl < 8'h73) | io_in_vd[114], (io_in_vl < 8'h72) | io_in_vd[113], (io_in_vl < 8'h71) | io_in_vd[112], (io_in_vl < 8'h70) | io_in_vd[111], (io_in_vl < 8'h6f) | io_in_vd[110], (io_in_vl < 8'h6e) | io_in_vd[109], (io_in_vl < 8'h6d) | io_in_vd[108], (io_in_vl < 8'h6c) | io_in_vd[107], (io_in_vl < 8'h6b) | io_in_vd[106], (io_in_vl < 8'h6a) | io_in_vd[105], (io_in_vl < 8'h69) | io_in_vd[104], (io_in_vl < 8'h68) | io_in_vd[103], (io_in_vl < 8'h67) | io_in_vd[102], (io_in_vl < 8'h66) | io_in_vd[101], (io_in_vl < 8'h65) | io_in_vd[100], (io_in_vl < 8'h64) | io_in_vd[99], (io_in_vl < 8'h63) | io_in_vd[98], (io_in_vl < 8'h62) | io_in_vd[97], (io_in_vl < 8'h61) | io_in_vd[96], (io_in_vl < 8'h60) | io_in_vd[95], (io_in_vl < 8'h5f) | io_in_vd[94], (io_in_vl < 8'h5e) | io_in_vd[93], (io_in_vl < 8'h5d) | io_in_vd[92], (io_in_vl < 8'h5c) | io_in_vd[91], (io_in_vl < 8'h5b) | io_in_vd[90], (io_in_vl < 8'h5a) | io_in_vd[89], (io_in_vl < 8'h59) | io_in_vd[88], (io_in_vl < 8'h58) | io_in_vd[87], (io_in_vl < 8'h57) | io_in_vd[86], (io_in_vl < 8'h56) | io_in_vd[85], (io_in_vl < 8'h55) | io_in_vd[84], (io_in_vl < 8'h54) | io_in_vd[83], (io_in_vl < 8'h53) | io_in_vd[82], (io_in_vl < 8'h52) | io_in_vd[81], (io_in_vl < 8'h51) | io_in_vd[80], (io_in_vl < 8'h50) | io_in_vd[79], (io_in_vl < 8'h4f) | io_in_vd[78], (io_in_vl < 8'h4e) | io_in_vd[77], (io_in_vl < 8'h4d) | io_in_vd[76], (io_in_vl < 8'h4c) | io_in_vd[75], (io_in_vl < 8'h4b) | io_in_vd[74], (io_in_vl < 8'h4a) | io_in_vd[73], (io_in_vl < 8'h49) | io_in_vd[72], (io_in_vl < 8'h48) | io_in_vd[71], (io_in_vl < 8'h47) | io_in_vd[70], (io_in_vl < 8'h46) | io_in_vd[69], (io_in_vl < 8'h45) | io_in_vd[68], (io_in_vl < 8'h44) | io_in_vd[67], (io_in_vl < 8'h43) | io_in_vd[66], (io_in_vl < 8'h42) | io_in_vd[65], (io_in_vl < 8'h41) | io_in_vd[64], (io_in_vl[7:6] == 2'h0) | io_in_vd[63], (io_in_vl < 8'h3f) | io_in_vd[62], (io_in_vl < 8'h3e) | io_in_vd[61], (io_in_vl < 8'h3d) | io_in_vd[60], (io_in_vl < 8'h3c) | io_in_vd[59], (io_in_vl < 8'h3b) | io_in_vd[58], (io_in_vl < 8'h3a) | io_in_vd[57], (io_in_vl < 8'h39) | io_in_vd[56], (io_in_vl < 8'h38) | io_in_vd[55], (io_in_vl < 8'h37) | io_in_vd[54], (io_in_vl < 8'h36) | io_in_vd[53], (io_in_vl < 8'h35) | io_in_vd[52], (io_in_vl < 8'h34) | io_in_vd[51], (io_in_vl < 8'h33) | io_in_vd[50], (io_in_vl < 8'h32) | io_in_vd[49], (io_in_vl < 8'h31) | io_in_vd[48], (io_in_vl < 8'h30) | io_in_vd[47], (io_in_vl < 8'h2f) | io_in_vd[46], (io_in_vl < 8'h2e) | io_in_vd[45], (io_in_vl < 8'h2d) | io_in_vd[44], (io_in_vl < 8'h2c) | io_in_vd[43], (io_in_vl < 8'h2b) | io_in_vd[42], (io_in_vl < 8'h2a) | io_in_vd[41], (io_in_vl < 8'h29) | io_in_vd[40], (io_in_vl < 8'h28) | io_in_vd[39], (io_in_vl < 8'h27) | io_in_vd[38], (io_in_vl < 8'h26) | io_in_vd[37], (io_in_vl < 8'h25) | io_in_vd[36], (io_in_vl < 8'h24) | io_in_vd[35], (io_in_vl < 8'h23) | io_in_vd[34], (io_in_vl < 8'h22) | io_in_vd[33], (io_in_vl < 8'h21) | io_in_vd[32], (io_in_vl[7:5] == 3'h0) | io_in_vd[31], (io_in_vl < 8'h1f) | io_in_vd[30], (io_in_vl < 8'h1e) | io_in_vd[29], (io_in_vl < 8'h1d) | io_in_vd[28], (io_in_vl < 8'h1c) | io_in_vd[27], (io_in_vl < 8'h1b) | io_in_vd[26], (io_in_vl < 8'h1a) | io_in_vd[25], (io_in_vl < 8'h19) | io_in_vd[24], (io_in_vl < 8'h18) | io_in_vd[23], (io_in_vl < 8'h17) | io_in_vd[22], (io_in_vl < 8'h16) | io_in_vd[21], (io_in_vl < 8'h15) | io_in_vd[20], (io_in_vl < 8'h14) | io_in_vd[19], (io_in_vl < 8'h13) | io_in_vd[18], (io_in_vl < 8'h12) | io_in_vd[17], (io_in_vl < 8'h11) | io_in_vd[16], (io_in_vl[7:4] == 4'h0) | io_in_vd[15], (io_in_vl < 8'h0f) | io_in_vd[14], (io_in_vl < 8'h0e) | io_in_vd[13], (io_in_vl < 8'h0d) | io_in_vd[12], (io_in_vl < 8'h0c) | io_in_vd[11], (io_in_vl < 8'h0b) | io_in_vd[10], (io_in_vl < 8'h0a) | io_in_vd[9], (io_in_vl < 8'h09) | io_in_vd[8], (io_in_vl[7:3] == 5'h00) | io_in_vd[7], (io_in_vl < 8'h07) | io_in_vd[6], (io_in_vl < 8'h06) | io_in_vd[5], (io_in_vl < 8'h05) | io_in_vd[4], (io_in_vl[7:2] == 6'h00) | io_in_vd[3], (io_in_vl < 8'h03) | io_in_vd[2], (io_in_vl[7:1] == 7'h00) | io_in_vd[1], (io_in_vl == 8'h00) | io_in_vd[0]};
endmodule
module Mgu (
	io_in_vd,
	io_in_oldVd,
	io_in_mask,
	io_in_info_ta,
	io_in_info_ma,
	io_in_info_vl,
	io_in_info_vstart,
	io_in_info_eew,
	io_in_info_vdIdx,
	io_in_info_narrow,
	io_in_info_dstMask,
	io_out_vd,
	io_out_active
);
	input [127:0] io_in_vd;
	input [127:0] io_in_oldVd;
	input [127:0] io_in_mask;
	input io_in_info_ta;
	input io_in_info_ma;
	input [7:0] io_in_info_vl;
	input [7:0] io_in_info_vstart;
	input [1:0] io_in_info_eew;
	input [2:0] io_in_info_vdIdx;
	input io_in_info_narrow;
	input io_in_info_dstMask;
	output wire [127:0] io_out_vd;
	output wire [15:0] io_out_active;
	wire [15:0] _maskTailGen_io_out_activeEn;
	wire [15:0] _maskTailGen_io_out_agnosticEn;
	wire [2:0] vdIdx = (io_in_info_narrow ? {1'h0, io_in_info_vdIdx[2:1]} : io_in_info_vdIdx);
	wire _maskBits_sew_oneHot_T_1 = io_in_info_eew == 2'h1;
	wire _maskBits_sew_oneHot_T_2 = io_in_info_eew == 2'h2;
	wire _maskDataVec_maskDataVec_7_T_2 = io_in_info_eew == 2'h1;
	wire _maskDataVec_maskDataVec_7_T_4 = io_in_info_eew == 2'h2;
	wire [15:0] _maskDataVec_maskDataVec_0_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[15:0]);
	wire [7:0] _GEN = _maskDataVec_maskDataVec_0_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[7:0] : 8'h00);
	wire [3:0] _GEN_0 = _GEN[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[3:0] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_1_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[31:16]);
	wire [7:0] _GEN_1 = _maskDataVec_maskDataVec_1_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[15:8] : 8'h00);
	wire [3:0] _GEN_2 = _GEN_1[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[7:4] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_2_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[47:32]);
	wire [7:0] _GEN_3 = _maskDataVec_maskDataVec_2_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[23:16] : 8'h00);
	wire [3:0] _GEN_4 = _GEN_3[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[11:8] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_3_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[63:48]);
	wire [7:0] _GEN_5 = _maskDataVec_maskDataVec_3_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[31:24] : 8'h00);
	wire [3:0] _GEN_6 = _GEN_5[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[15:12] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_4_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[79:64]);
	wire [7:0] _GEN_7 = _maskDataVec_maskDataVec_4_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[39:32] : 8'h00);
	wire [3:0] _GEN_8 = _GEN_7[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[19:16] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_5_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[95:80]);
	wire [7:0] _GEN_9 = _maskDataVec_maskDataVec_5_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[47:40] : 8'h00);
	wire [3:0] _GEN_10 = _GEN_9[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[23:20] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_6_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[111:96]);
	wire [7:0] _GEN_11 = _maskDataVec_maskDataVec_6_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[55:48] : 8'h00);
	wire [3:0] _GEN_12 = _GEN_11[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[27:24] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_7_T_8 = (|io_in_info_eew ? 16'h0000 : io_in_mask[127:112]);
	wire [7:0] _GEN_13 = _maskDataVec_maskDataVec_7_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? io_in_mask[63:56] : 8'h00);
	wire [3:0] _GEN_14 = _GEN_13[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? io_in_mask[31:28] : 4'h0);
	wire [127:0] _GEN_15 = {_maskDataVec_maskDataVec_7_T_8[15:8], _GEN_13[7:4], _GEN_14[3:2], _GEN_14[1:0] | (&io_in_info_eew ? io_in_mask[15:14] : 2'h0), _maskDataVec_maskDataVec_6_T_8[15:8], _GEN_11[7:4], _GEN_12[3:2], _GEN_12[1:0] | (&io_in_info_eew ? io_in_mask[13:12] : 2'h0), _maskDataVec_maskDataVec_5_T_8[15:8], _GEN_9[7:4], _GEN_10[3:2], _GEN_10[1:0] | (&io_in_info_eew ? io_in_mask[11:10] : 2'h0), _maskDataVec_maskDataVec_4_T_8[15:8], _GEN_7[7:4], _GEN_8[3:2], _GEN_8[1:0] | (&io_in_info_eew ? io_in_mask[9:8] : 2'h0), _maskDataVec_maskDataVec_3_T_8[15:8], _GEN_5[7:4], _GEN_6[3:2], _GEN_6[1:0] | (&io_in_info_eew ? io_in_mask[7:6] : 2'h0), _maskDataVec_maskDataVec_2_T_8[15:8], _GEN_3[7:4], _GEN_4[3:2], _GEN_4[1:0] | (&io_in_info_eew ? io_in_mask[5:4] : 2'h0), _maskDataVec_maskDataVec_1_T_8[15:8], _GEN_1[7:4], _GEN_2[3:2], _GEN_2[1:0] | (&io_in_info_eew ? io_in_mask[3:2] : 2'h0), _maskDataVec_maskDataVec_0_T_8[15:8], _GEN[7:4], _GEN_0[3:2], _GEN_0[1:0] | (&io_in_info_eew ? io_in_mask[1:0] : 2'h0)};
	wire [127:0] _GEN_16 = {(((|io_in_info_eew ? 16'h0000 : io_in_mask[127:112]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[63:56]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[31:28]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[15:14]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_mask[111:96]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[55:48]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[27:24]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[13:12]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_mask[95:80]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[47:40]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[23:20]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[11:10]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_mask[79:64]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[39:32]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[19:16]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[9:8]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_mask[63:48]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[31:24]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[15:12]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[7:6]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_mask[47:32]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[23:16]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[11:8]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[5:4]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_mask[31:16]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[15:8]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[7:4]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[3:2]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_mask[15:0]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_mask[7:0]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_mask[3:0]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_mask[1:0]} : 16'h0000)};
	wire [127:0] _GEN_17 = {(((|io_in_info_eew ? 16'h0000 : io_in_oldVd[127:112]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[63:56]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[31:28]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[15:14]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_oldVd[111:96]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[55:48]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[27:24]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[13:12]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_oldVd[95:80]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[47:40]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[23:20]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[11:10]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_oldVd[79:64]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[39:32]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[19:16]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[9:8]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_oldVd[63:48]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[31:24]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[15:12]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[7:6]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_oldVd[47:32]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[23:16]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[11:8]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[5:4]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_oldVd[31:16]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[15:8]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[7:4]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[3:2]} : 16'h0000), (((|io_in_info_eew ? 16'h0000 : io_in_oldVd[15:0]) | (_maskBits_sew_oneHot_T_1 ? {8'h00, io_in_oldVd[7:0]} : 16'h0000)) | (_maskBits_sew_oneHot_T_2 ? {12'h000, io_in_oldVd[3:0]} : 16'h0000)) | (&io_in_info_eew ? {14'h0000, io_in_oldVd[1:0]} : 16'h0000)};
	wire maskVecByte_0 = (_GEN_16[vdIdx * 16] ? io_in_vd[0] : io_in_info_ma | _GEN_17[vdIdx * 16]);
	wire maskVecByte_1 = (_GEN_16[(vdIdx * 16) + 1] ? io_in_vd[1] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 1]);
	wire maskVecByte_2 = (_GEN_16[(vdIdx * 16) + 2] ? io_in_vd[2] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 2]);
	wire maskVecByte_3 = (_GEN_16[(vdIdx * 16) + 3] ? io_in_vd[3] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 3]);
	wire maskVecByte_4 = (_GEN_16[(vdIdx * 16) + 4] ? io_in_vd[4] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 4]);
	wire maskVecByte_5 = (_GEN_16[(vdIdx * 16) + 5] ? io_in_vd[5] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 5]);
	wire maskVecByte_6 = (_GEN_16[(vdIdx * 16) + 6] ? io_in_vd[6] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 6]);
	wire maskVecByte_7 = (_GEN_16[(vdIdx * 16) + 7] ? io_in_vd[7] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 7]);
	wire maskVecByte_8 = (_GEN_16[(vdIdx * 16) + 8] ? io_in_vd[8] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 8]);
	wire maskVecByte_9 = (_GEN_16[(vdIdx * 16) + 9] ? io_in_vd[9] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 9]);
	wire maskVecByte_10 = (_GEN_16[(vdIdx * 16) + 10] ? io_in_vd[10] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 10]);
	wire maskVecByte_11 = (_GEN_16[(vdIdx * 16) + 11] ? io_in_vd[11] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 11]);
	wire maskVecByte_12 = (_GEN_16[(vdIdx * 16) + 12] ? io_in_vd[12] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 12]);
	wire maskVecByte_13 = (_GEN_16[(vdIdx * 16) + 13] ? io_in_vd[13] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 13]);
	wire maskVecByte_14 = (_GEN_16[(vdIdx * 16) + 14] ? io_in_vd[14] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 14]);
	wire maskVecByte_15 = (_GEN_16[(vdIdx * 16) + 15] ? io_in_vd[15] : io_in_info_ma | _GEN_17[(vdIdx * 16) + 15]);
	wire [511:0] _GEN_18 = {io_in_oldVd[127:2], maskVecByte_1, maskVecByte_0, io_in_oldVd[127:4], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[127:8], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[127:16], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0};
	wire [511:0] _GEN_19 = {io_in_oldVd[127:4], maskVecByte_1, maskVecByte_0, io_in_oldVd[1:0], io_in_oldVd[127:8], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[3:0], io_in_oldVd[127:16], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[7:0], io_in_oldVd[127:32], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[15:0]};
	wire [511:0] _GEN_20 = {io_in_oldVd[127:6], maskVecByte_1, maskVecByte_0, io_in_oldVd[3:0], io_in_oldVd[127:12], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[7:0], io_in_oldVd[127:24], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[15:0], io_in_oldVd[127:48], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[31:0]};
	wire [511:0] _GEN_21 = {io_in_oldVd[127:8], maskVecByte_1, maskVecByte_0, io_in_oldVd[5:0], io_in_oldVd[127:16], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[11:0], io_in_oldVd[127:32], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[23:0], io_in_oldVd[127:64], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[47:0]};
	wire [511:0] _GEN_22 = {io_in_oldVd[127:10], maskVecByte_1, maskVecByte_0, io_in_oldVd[7:0], io_in_oldVd[127:20], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[15:0], io_in_oldVd[127:40], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[31:0], io_in_oldVd[127:80], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[63:0]};
	wire [511:0] _GEN_23 = {io_in_oldVd[127:12], maskVecByte_1, maskVecByte_0, io_in_oldVd[9:0], io_in_oldVd[127:24], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[19:0], io_in_oldVd[127:48], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[39:0], io_in_oldVd[127:96], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[79:0]};
	wire [511:0] _GEN_24 = {io_in_oldVd[127:14], maskVecByte_1, maskVecByte_0, io_in_oldVd[11:0], io_in_oldVd[127:28], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[23:0], io_in_oldVd[127:56], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[47:0], io_in_oldVd[127:112], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[95:0]};
	wire [511:0] _GEN_25 = {io_in_oldVd[127:16], maskVecByte_1, maskVecByte_0, io_in_oldVd[13:0], io_in_oldVd[127:32], maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[27:0], io_in_oldVd[127:64], maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[55:0], maskVecByte_15, maskVecByte_14, maskVecByte_13, maskVecByte_12, maskVecByte_11, maskVecByte_10, maskVecByte_9, maskVecByte_8, maskVecByte_7, maskVecByte_6, maskVecByte_5, maskVecByte_4, maskVecByte_3, maskVecByte_2, maskVecByte_1, maskVecByte_0, io_in_oldVd[111:0]};
	wire [1023:0] _GEN_26 = {_GEN_25[io_in_info_eew * 128+:128], _GEN_24[io_in_info_eew * 128+:128], _GEN_23[io_in_info_eew * 128+:128], _GEN_22[io_in_info_eew * 128+:128], _GEN_21[io_in_info_eew * 128+:128], _GEN_20[io_in_info_eew * 128+:128], _GEN_19[io_in_info_eew * 128+:128], _GEN_18[io_in_info_eew * 128+:128]};
	ByteMaskTailGen maskTailGen(
		.io_in_begin(io_in_info_vstart),
		.io_in_end(io_in_info_vl),
		.io_in_vma(io_in_info_ma),
		.io_in_vta(io_in_info_ta),
		.io_in_vsew(io_in_info_eew),
		.io_in_maskUsed(_GEN_15[vdIdx * 16+:16]),
		.io_in_vdIdx(vdIdx),
		.io_out_activeEn(_maskTailGen_io_out_activeEn),
		.io_out_agnosticEn(_maskTailGen_io_out_agnosticEn)
	);
	assign io_out_vd = (io_in_info_dstMask ? _GEN_26[vdIdx * 128+:128] : {(_maskTailGen_io_out_activeEn[15] ? io_in_vd[127:120] : (_maskTailGen_io_out_agnosticEn[15] ? 8'hff : io_in_oldVd[127:120])), (_maskTailGen_io_out_activeEn[14] ? io_in_vd[119:112] : (_maskTailGen_io_out_agnosticEn[14] ? 8'hff : io_in_oldVd[119:112])), (_maskTailGen_io_out_activeEn[13] ? io_in_vd[111:104] : (_maskTailGen_io_out_agnosticEn[13] ? 8'hff : io_in_oldVd[111:104])), (_maskTailGen_io_out_activeEn[12] ? io_in_vd[103:96] : (_maskTailGen_io_out_agnosticEn[12] ? 8'hff : io_in_oldVd[103:96])), (_maskTailGen_io_out_activeEn[11] ? io_in_vd[95:88] : (_maskTailGen_io_out_agnosticEn[11] ? 8'hff : io_in_oldVd[95:88])), (_maskTailGen_io_out_activeEn[10] ? io_in_vd[87:80] : (_maskTailGen_io_out_agnosticEn[10] ? 8'hff : io_in_oldVd[87:80])), (_maskTailGen_io_out_activeEn[9] ? io_in_vd[79:72] : (_maskTailGen_io_out_agnosticEn[9] ? 8'hff : io_in_oldVd[79:72])), (_maskTailGen_io_out_activeEn[8] ? io_in_vd[71:64] : (_maskTailGen_io_out_agnosticEn[8] ? 8'hff : io_in_oldVd[71:64])), (_maskTailGen_io_out_activeEn[7] ? io_in_vd[63:56] : (_maskTailGen_io_out_agnosticEn[7] ? 8'hff : io_in_oldVd[63:56])), (_maskTailGen_io_out_activeEn[6] ? io_in_vd[55:48] : (_maskTailGen_io_out_agnosticEn[6] ? 8'hff : io_in_oldVd[55:48])), (_maskTailGen_io_out_activeEn[5] ? io_in_vd[47:40] : (_maskTailGen_io_out_agnosticEn[5] ? 8'hff : io_in_oldVd[47:40])), (_maskTailGen_io_out_activeEn[4] ? io_in_vd[39:32] : (_maskTailGen_io_out_agnosticEn[4] ? 8'hff : io_in_oldVd[39:32])), (_maskTailGen_io_out_activeEn[3] ? io_in_vd[31:24] : (_maskTailGen_io_out_agnosticEn[3] ? 8'hff : io_in_oldVd[31:24])), (_maskTailGen_io_out_activeEn[2] ? io_in_vd[23:16] : (_maskTailGen_io_out_agnosticEn[2] ? 8'hff : io_in_oldVd[23:16])), (_maskTailGen_io_out_activeEn[1] ? io_in_vd[15:8] : (_maskTailGen_io_out_agnosticEn[1] ? 8'hff : io_in_oldVd[15:8])), (_maskTailGen_io_out_activeEn[0] ? io_in_vd[7:0] : (_maskTailGen_io_out_agnosticEn[0] ? 8'hff : io_in_oldVd[7:0]))});
	assign io_out_active = _maskTailGen_io_out_activeEn;
endmodule
module UIntToContLow0s (
	io_dataIn,
	io_dataOut
);
	input [7:0] io_dataIn;
	output wire [254:0] io_dataOut;
	wire [126:0] _io_dataOut_T_507 = (io_dataIn[6] ? {(io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})}), 32'h00000000} : {32'hffffffff, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})})}), 64'h0000000000000000} : {64'hffffffffffffffff, (io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})}), 32'h00000000} : {32'hffffffff, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})})})});
	wire [126:0] _io_dataOut_T_1015 = (io_dataIn[6] ? {(io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})}), 32'h00000000} : {32'hffffffff, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})})}), 64'h0000000000000000} : {64'hffffffffffffffff, (io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})}), 32'h00000000} : {32'hffffffff, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})}), 16'h0000} : {16'hffff, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})}), 8'h00} : {8'hff, (io_dataIn[2] ? {(io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]}), 4'h0} : {4'hf, (io_dataIn[1] ? {~io_dataIn[0], 2'h0} : {2'h3, ~io_dataIn[0]})})})})})});
	assign io_dataOut = (io_dataIn[7] ? {_io_dataOut_T_507, 128'h00000000000000000000000000000000} : {128'hffffffffffffffffffffffffffffffff, _io_dataOut_T_1015});
endmodule
module UIntToContLow1s (
	io_dataIn,
	io_dataOut
);
	input [7:0] io_dataIn;
	output wire [254:0] io_dataOut;
	assign io_dataOut = (io_dataIn[7] ? {(io_dataIn[6] ? {(io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})}), 32'hffffffff} : {32'h00000000, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})})}), 64'hffffffffffffffff} : {64'h0000000000000000, (io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})}), 32'hffffffff} : {32'h00000000, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})})})}), 128'hffffffffffffffffffffffffffffffff} : {128'h00000000000000000000000000000000, (io_dataIn[6] ? {(io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})}), 32'hffffffff} : {32'h00000000, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})})}), 64'hffffffffffffffff} : {64'h0000000000000000, (io_dataIn[5] ? {(io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})}), 32'hffffffff} : {32'h00000000, (io_dataIn[4] ? {(io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})}), 16'hffff} : {16'h0000, (io_dataIn[3] ? {(io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})}), 8'hff} : {8'h00, (io_dataIn[2] ? {(io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]}), 4'hf} : {4'h0, (io_dataIn[1] ? {io_dataIn[0], 2'h3} : {2'h0, io_dataIn[0]})})})})})})});
endmodule
module VFixPoint64b (
	io_opcode_op,
	io_info_vxrm,
	io_sew_oneHot,
	io_isSub,
	io_isSigned,
	io_isNClip,
	io_fromAdder_cout_0,
	io_fromAdder_cout_1,
	io_fromAdder_cout_2,
	io_fromAdder_cout_3,
	io_fromAdder_cout_4,
	io_fromAdder_cout_5,
	io_fromAdder_cout_6,
	io_fromAdder_cout_7,
	io_fromAdder_vd_0,
	io_fromAdder_vd_1,
	io_fromAdder_vd_2,
	io_fromAdder_vd_3,
	io_fromAdder_vd_4,
	io_fromAdder_vd_5,
	io_fromAdder_vd_6,
	io_fromAdder_vd_7,
	io_fromAdder_vs2H_0,
	io_fromAdder_vs2H_1,
	io_fromAdder_vs2H_2,
	io_fromAdder_vs2H_3,
	io_fromAdder_vs2H_4,
	io_fromAdder_vs2H_5,
	io_fromAdder_vs2H_6,
	io_fromAdder_vs2H_7,
	io_fromAdder_vs1H_0,
	io_fromAdder_vs1H_1,
	io_fromAdder_vs1H_2,
	io_fromAdder_vs1H_3,
	io_fromAdder_vs1H_4,
	io_fromAdder_vs1H_5,
	io_fromAdder_vs1H_6,
	io_fromAdder_vs1H_7,
	io_fromMisc_shiftOut,
	io_fromMisc_rnd_high,
	io_fromMisc_rnd_tail,
	io_vd,
	io_narrowVd,
	io_vxsat
);
	input [5:0] io_opcode_op;
	input [1:0] io_info_vxrm;
	input [3:0] io_sew_oneHot;
	input io_isSub;
	input io_isSigned;
	input io_isNClip;
	input io_fromAdder_cout_0;
	input io_fromAdder_cout_1;
	input io_fromAdder_cout_2;
	input io_fromAdder_cout_3;
	input io_fromAdder_cout_4;
	input io_fromAdder_cout_5;
	input io_fromAdder_cout_6;
	input io_fromAdder_cout_7;
	input [7:0] io_fromAdder_vd_0;
	input [7:0] io_fromAdder_vd_1;
	input [7:0] io_fromAdder_vd_2;
	input [7:0] io_fromAdder_vd_3;
	input [7:0] io_fromAdder_vd_4;
	input [7:0] io_fromAdder_vd_5;
	input [7:0] io_fromAdder_vd_6;
	input [7:0] io_fromAdder_vd_7;
	input io_fromAdder_vs2H_0;
	input io_fromAdder_vs2H_1;
	input io_fromAdder_vs2H_2;
	input io_fromAdder_vs2H_3;
	input io_fromAdder_vs2H_4;
	input io_fromAdder_vs2H_5;
	input io_fromAdder_vs2H_6;
	input io_fromAdder_vs2H_7;
	input io_fromAdder_vs1H_0;
	input io_fromAdder_vs1H_1;
	input io_fromAdder_vs1H_2;
	input io_fromAdder_vs1H_3;
	input io_fromAdder_vs1H_4;
	input io_fromAdder_vs1H_5;
	input io_fromAdder_vs1H_6;
	input io_fromAdder_vs1H_7;
	input [63:0] io_fromMisc_shiftOut;
	input [7:0] io_fromMisc_rnd_high;
	input [7:0] io_fromMisc_rnd_tail;
	output wire [63:0] io_vd;
	output wire [31:0] io_narrowVd;
	output wire [7:0] io_vxsat;
	wire [7:0] _adder_chain_rnd_io_dout_0;
	wire [7:0] _adder_chain_rnd_io_dout_1;
	wire [7:0] _adder_chain_rnd_io_dout_2;
	wire [7:0] _adder_chain_rnd_io_dout_3;
	wire [7:0] _adder_chain_rnd_io_dout_4;
	wire [7:0] _adder_chain_rnd_io_dout_5;
	wire [7:0] _adder_chain_rnd_io_dout_6;
	wire [7:0] _adder_chain_rnd_io_dout_7;
	wire _adder_chain_rnd_io_cout_0;
	wire _adder_chain_rnd_io_cout_1;
	wire _adder_chain_rnd_io_cout_2;
	wire _adder_chain_rnd_io_cout_3;
	wire _adder_chain_rnd_io_cout_4;
	wire _adder_chain_rnd_io_cout_5;
	wire _adder_chain_rnd_io_cout_6;
	wire _adder_chain_rnd_io_all_1s_1;
	wire _adder_chain_rnd_io_all_1s_2;
	wire _adder_chain_rnd_io_all_1s_3;
	wire _adder_chain_rnd_io_all_1s_4;
	wire _adder_chain_rnd_io_all_1s_5;
	wire _adder_chain_rnd_io_all_1s_6;
	wire _adder_chain_rnd_io_all_1s_7;
	wire _adder_chain_rnd_io_all_0s_1;
	wire _adder_chain_rnd_io_all_0s_2;
	wire _adder_chain_rnd_io_all_0s_3;
	wire _adder_chain_rnd_io_all_0s_4;
	wire _adder_chain_rnd_io_all_0s_5;
	wire _adder_chain_rnd_io_all_0s_6;
	wire _adder_chain_rnd_io_all_0s_7;
	wire sat_1 = (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_1 != io_fromAdder_vs1H_1 : io_fromAdder_vs2H_1 == io_fromAdder_vs1H_1) & (io_fromAdder_vs2H_1 != io_fromAdder_vd_1[7]) : io_fromAdder_cout_1 ^ io_isSub);
	wire sat_3 = (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_3 != io_fromAdder_vs1H_3 : io_fromAdder_vs2H_3 == io_fromAdder_vs1H_3) & (io_fromAdder_vs2H_3 != io_fromAdder_vd_3[7]) : io_fromAdder_cout_3 ^ io_isSub);
	wire sat_5 = (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_5 != io_fromAdder_vs1H_5 : io_fromAdder_vs2H_5 == io_fromAdder_vs1H_5) & (io_fromAdder_vs2H_5 != io_fromAdder_vd_5[7]) : io_fromAdder_cout_5 ^ io_isSub);
	wire sat_7 = (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_7 != io_fromAdder_vs1H_7 : io_fromAdder_vs2H_7 == io_fromAdder_vs1H_7) & (io_fromAdder_vs2H_7 != io_fromAdder_vd_7[7]) : io_fromAdder_cout_7 ^ io_isSub);
	wire [7:0] saturate = (((io_sew_oneHot[0] ? {sat_7, (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_6 != io_fromAdder_vs1H_6 : io_fromAdder_vs2H_6 == io_fromAdder_vs1H_6) & (io_fromAdder_vs2H_6 != io_fromAdder_vd_6[7]) : io_fromAdder_cout_6 ^ io_isSub), sat_5, (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_4 != io_fromAdder_vs1H_4 : io_fromAdder_vs2H_4 == io_fromAdder_vs1H_4) & (io_fromAdder_vs2H_4 != io_fromAdder_vd_4[7]) : io_fromAdder_cout_4 ^ io_isSub), sat_3, (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_2 != io_fromAdder_vs1H_2 : io_fromAdder_vs2H_2 == io_fromAdder_vs1H_2) & (io_fromAdder_vs2H_2 != io_fromAdder_vd_2[7]) : io_fromAdder_cout_2 ^ io_isSub), sat_1, (io_isSigned ? (io_isSub ? io_fromAdder_vs2H_0 != io_fromAdder_vs1H_0 : io_fromAdder_vs2H_0 == io_fromAdder_vs1H_0) & (io_fromAdder_vs2H_0 != io_fromAdder_vd_0[7]) : io_fromAdder_cout_0 ^ io_isSub)} : 8'h00) | (io_sew_oneHot[1] ? {{2 {sat_7}}, {2 {sat_5}}, {2 {sat_3}}, {2 {sat_1}}} : 8'h00)) | (io_sew_oneHot[2] ? {{4 {sat_7}}, {4 {sat_3}}} : 8'h00)) | {8 {io_sew_oneHot[3] & sat_7}};
	wire highestBits_1 = io_sew_oneHot[0] | io_sew_oneHot[1];
	wire highestBits_3 = (io_sew_oneHot[0] | io_sew_oneHot[1]) | io_sew_oneHot[2];
	wire highestBits_5 = io_sew_oneHot[0] | io_sew_oneHot[1];
	wire highBitAvg_1 = (io_fromAdder_cout_1 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_1 ^ io_fromAdder_vs2H_1));
	wire highBitAvg_3 = (io_fromAdder_cout_3 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_3 ^ io_fromAdder_vs2H_3));
	wire highBitAvg_5 = (io_fromAdder_cout_5 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_5 ^ io_fromAdder_vs2H_5));
	wire highBitAvg_7 = (io_fromAdder_cout_7 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_7 ^ io_fromAdder_vs2H_7));
	wire _shiftRndInc_7_T = io_info_vxrm == 2'h0;
	wire _shiftRndInc_7_T_2 = io_info_vxrm == 2'h1;
	wire _rndInc_T_21 = io_opcode_op == 6'h1f;
	wire _rndInc_T_22 = io_opcode_op == 6'h20;
	wire _nclipResult32_T_5 = ((_adder_chain_rnd_io_all_0s_4 & _adder_chain_rnd_io_all_0s_5) & _adder_chain_rnd_io_all_0s_6) & _adder_chain_rnd_io_all_0s_7;
	wire _nclipResult32_T_16 = ((_nclipResult32_T_5 & ~_adder_chain_rnd_io_cout_3) & ~_adder_chain_rnd_io_dout_3[7]) | ((((_adder_chain_rnd_io_all_1s_4 & _adder_chain_rnd_io_all_1s_5) & _adder_chain_rnd_io_all_1s_6) & _adder_chain_rnd_io_all_1s_7) & (_adder_chain_rnd_io_cout_3 | (~_adder_chain_rnd_io_cout_3 & _adder_chain_rnd_io_dout_3[7])));
	wire _nclipResult32_T_18 = _nclipResult32_T_5 & ~_adder_chain_rnd_io_cout_3;
	wire _nclipResult16_T_3 = _adder_chain_rnd_io_all_0s_2 & _adder_chain_rnd_io_all_0s_3;
	wire _nclipResult16_T_14 = ((_nclipResult16_T_3 & ~_adder_chain_rnd_io_cout_1) & ~_adder_chain_rnd_io_dout_1[7]) | ((_adder_chain_rnd_io_all_1s_2 & _adder_chain_rnd_io_all_1s_3) & (_adder_chain_rnd_io_cout_1 | (~_adder_chain_rnd_io_cout_1 & _adder_chain_rnd_io_dout_1[7])));
	wire _nclipResult16_T_16 = _nclipResult16_T_3 & ~_adder_chain_rnd_io_cout_1;
	wire _nclipResult16_T_18 = _adder_chain_rnd_io_all_0s_6 & _adder_chain_rnd_io_all_0s_7;
	wire _nclipResult16_T_29 = ((_nclipResult16_T_18 & ~_adder_chain_rnd_io_cout_5) & ~_adder_chain_rnd_io_dout_5[7]) | ((_adder_chain_rnd_io_all_1s_6 & _adder_chain_rnd_io_all_1s_7) & (_adder_chain_rnd_io_cout_5 | (~_adder_chain_rnd_io_cout_5 & _adder_chain_rnd_io_dout_5[7])));
	wire _nclipResult16_T_31 = _nclipResult16_T_18 & ~_adder_chain_rnd_io_cout_5;
	wire _nclipResult8_T_14 = ((_adder_chain_rnd_io_all_0s_1 & ~_adder_chain_rnd_io_cout_0) & ~_adder_chain_rnd_io_dout_0[7]) | (_adder_chain_rnd_io_all_1s_1 & (_adder_chain_rnd_io_cout_0 | (~_adder_chain_rnd_io_cout_0 & _adder_chain_rnd_io_dout_0[7])));
	wire _nclipResult8_T_16 = _adder_chain_rnd_io_all_0s_1 & ~_adder_chain_rnd_io_cout_0;
	wire _nclipResult8_T_27 = ((_adder_chain_rnd_io_all_0s_3 & ~_adder_chain_rnd_io_cout_2) & ~_adder_chain_rnd_io_dout_2[7]) | (_adder_chain_rnd_io_all_1s_3 & (_adder_chain_rnd_io_cout_2 | (~_adder_chain_rnd_io_cout_2 & _adder_chain_rnd_io_dout_2[7])));
	wire _nclipResult8_T_29 = _adder_chain_rnd_io_all_0s_3 & ~_adder_chain_rnd_io_cout_2;
	wire _nclipResult8_T_40 = ((_adder_chain_rnd_io_all_0s_5 & ~_adder_chain_rnd_io_cout_4) & ~_adder_chain_rnd_io_dout_4[7]) | (_adder_chain_rnd_io_all_1s_5 & (_adder_chain_rnd_io_cout_4 | (~_adder_chain_rnd_io_cout_4 & _adder_chain_rnd_io_dout_4[7])));
	wire _nclipResult8_T_42 = _adder_chain_rnd_io_all_0s_5 & ~_adder_chain_rnd_io_cout_4;
	wire _nclipResult8_T_53 = ((_adder_chain_rnd_io_all_0s_7 & ~_adder_chain_rnd_io_cout_6) & ~_adder_chain_rnd_io_dout_6[7]) | (_adder_chain_rnd_io_all_1s_7 & (_adder_chain_rnd_io_cout_6 | (~_adder_chain_rnd_io_cout_6 & _adder_chain_rnd_io_dout_6[7])));
	wire _nclipResult8_T_55 = _adder_chain_rnd_io_all_0s_7 & ~_adder_chain_rnd_io_cout_6;
	wire _io_vd_T = io_opcode_op == 6'h1b;
	wire _io_vd_T_1 = io_opcode_op == 6'h1c;
	Adder_chain_rnd adder_chain_rnd(
		.io_din_0((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[7:0] : {(((io_sew_oneHot[0] & ((io_fromAdder_cout_0 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_0 ^ io_fromAdder_vs2H_0)))) | (io_sew_oneHot[1] & io_fromAdder_vd_1[0])) | (io_sew_oneHot[2] & io_fromAdder_vd_1[0])) | (io_sew_oneHot[3] & io_fromAdder_vd_1[0]), io_fromAdder_vd_0[7:1]})),
		.io_din_1((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[15:8] : {(((io_sew_oneHot[0] & highBitAvg_1) | (io_sew_oneHot[1] & highBitAvg_1)) | (io_sew_oneHot[2] & io_fromAdder_vd_2[0])) | (io_sew_oneHot[3] & io_fromAdder_vd_2[0]), io_fromAdder_vd_1[7:1]})),
		.io_din_2((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[23:16] : {(((io_sew_oneHot[0] & ((io_fromAdder_cout_2 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_2 ^ io_fromAdder_vs2H_2)))) | (io_sew_oneHot[1] & io_fromAdder_vd_3[0])) | (io_sew_oneHot[2] & io_fromAdder_vd_3[0])) | (io_sew_oneHot[3] & io_fromAdder_vd_3[0]), io_fromAdder_vd_2[7:1]})),
		.io_din_3((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[31:24] : {(((io_sew_oneHot[0] & highBitAvg_3) | (io_sew_oneHot[1] & highBitAvg_3)) | (io_sew_oneHot[2] & highBitAvg_3)) | (io_sew_oneHot[3] & io_fromAdder_vd_4[0]), io_fromAdder_vd_3[7:1]})),
		.io_din_4((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[39:32] : {(((io_sew_oneHot[0] & ((io_fromAdder_cout_4 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_4 ^ io_fromAdder_vs2H_4)))) | (io_sew_oneHot[1] & io_fromAdder_vd_5[0])) | (io_sew_oneHot[2] & io_fromAdder_vd_5[0])) | (io_sew_oneHot[3] & io_fromAdder_vd_5[0]), io_fromAdder_vd_4[7:1]})),
		.io_din_5((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[47:40] : {(((io_sew_oneHot[0] & highBitAvg_5) | (io_sew_oneHot[1] & highBitAvg_5)) | (io_sew_oneHot[2] & io_fromAdder_vd_6[0])) | (io_sew_oneHot[3] & io_fromAdder_vd_6[0]), io_fromAdder_vd_5[7:1]})),
		.io_din_6((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[55:48] : {(((io_sew_oneHot[0] & ((io_fromAdder_cout_6 ^ io_isSub) ^ (io_isSigned & (io_fromAdder_vs1H_6 ^ io_fromAdder_vs2H_6)))) | (io_sew_oneHot[1] & io_fromAdder_vd_7[0])) | (io_sew_oneHot[2] & io_fromAdder_vd_7[0])) | (io_sew_oneHot[3] & io_fromAdder_vd_7[0]), io_fromAdder_vd_6[7:1]})),
		.io_din_7((_rndInc_T_21 | _rndInc_T_22 ? io_fromMisc_shiftOut[63:56] : {(((io_sew_oneHot[0] & highBitAvg_7) | (io_sew_oneHot[1] & highBitAvg_7)) | (io_sew_oneHot[2] & highBitAvg_7)) | (io_sew_oneHot[3] & highBitAvg_7), io_fromAdder_vd_7[7:1]})),
		.io_rndInc_0((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[0]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[0]) & (~io_fromMisc_rnd_tail[0] | io_fromMisc_shiftOut[0]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[0]) & (io_fromMisc_rnd_high[0] | ~io_fromMisc_rnd_tail[0])) : ((_shiftRndInc_7_T & io_fromAdder_vd_0[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_0[0]) & io_fromAdder_vd_0[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_0[1]) & io_fromAdder_vd_0[0]))),
		.io_rndInc_1((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[1]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[1]) & (~io_fromMisc_rnd_tail[1] | io_fromMisc_shiftOut[8]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[8]) & (io_fromMisc_rnd_high[1] | ~io_fromMisc_rnd_tail[1])) : ((_shiftRndInc_7_T & io_fromAdder_vd_1[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_1[0]) & io_fromAdder_vd_1[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_1[1]) & io_fromAdder_vd_1[0]))),
		.io_rndInc_2((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[2]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[2]) & (~io_fromMisc_rnd_tail[2] | io_fromMisc_shiftOut[16]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[16]) & (io_fromMisc_rnd_high[2] | ~io_fromMisc_rnd_tail[2])) : ((_shiftRndInc_7_T & io_fromAdder_vd_2[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_2[0]) & io_fromAdder_vd_2[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_2[1]) & io_fromAdder_vd_2[0]))),
		.io_rndInc_3((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[3]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[3]) & (~io_fromMisc_rnd_tail[3] | io_fromMisc_shiftOut[24]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[24]) & (io_fromMisc_rnd_high[3] | ~io_fromMisc_rnd_tail[3])) : ((_shiftRndInc_7_T & io_fromAdder_vd_3[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_3[0]) & io_fromAdder_vd_3[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_3[1]) & io_fromAdder_vd_3[0]))),
		.io_rndInc_4((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[4]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[4]) & (~io_fromMisc_rnd_tail[4] | io_fromMisc_shiftOut[32]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[32]) & (io_fromMisc_rnd_high[4] | ~io_fromMisc_rnd_tail[4])) : ((_shiftRndInc_7_T & io_fromAdder_vd_4[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_4[0]) & io_fromAdder_vd_4[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_4[1]) & io_fromAdder_vd_4[0]))),
		.io_rndInc_5((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[5]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[5]) & (~io_fromMisc_rnd_tail[5] | io_fromMisc_shiftOut[40]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[40]) & (io_fromMisc_rnd_high[5] | ~io_fromMisc_rnd_tail[5])) : ((_shiftRndInc_7_T & io_fromAdder_vd_5[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_5[0]) & io_fromAdder_vd_5[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_5[1]) & io_fromAdder_vd_5[0]))),
		.io_rndInc_6((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[6]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[6]) & (~io_fromMisc_rnd_tail[6] | io_fromMisc_shiftOut[48]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[48]) & (io_fromMisc_rnd_high[6] | ~io_fromMisc_rnd_tail[6])) : ((_shiftRndInc_7_T & io_fromAdder_vd_6[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_6[0]) & io_fromAdder_vd_6[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_6[1]) & io_fromAdder_vd_6[0]))),
		.io_rndInc_7((_rndInc_T_21 | _rndInc_T_22 ? ((_shiftRndInc_7_T & io_fromMisc_rnd_high[7]) | ((_shiftRndInc_7_T_2 & io_fromMisc_rnd_high[7]) & (~io_fromMisc_rnd_tail[7] | io_fromMisc_shiftOut[56]))) | ((&io_info_vxrm & ~io_fromMisc_shiftOut[56]) & (io_fromMisc_rnd_high[7] | ~io_fromMisc_rnd_tail[7])) : ((_shiftRndInc_7_T & io_fromAdder_vd_7[0]) | ((_shiftRndInc_7_T_2 & io_fromAdder_vd_7[0]) & io_fromAdder_vd_7[1])) | ((&io_info_vxrm & ~io_fromAdder_vd_7[1]) & io_fromAdder_vd_7[0]))),
		.io_isNClip(io_isNClip),
		.io_sew_oneHot(io_sew_oneHot),
		.io_dout_0(_adder_chain_rnd_io_dout_0),
		.io_dout_1(_adder_chain_rnd_io_dout_1),
		.io_dout_2(_adder_chain_rnd_io_dout_2),
		.io_dout_3(_adder_chain_rnd_io_dout_3),
		.io_dout_4(_adder_chain_rnd_io_dout_4),
		.io_dout_5(_adder_chain_rnd_io_dout_5),
		.io_dout_6(_adder_chain_rnd_io_dout_6),
		.io_dout_7(_adder_chain_rnd_io_dout_7),
		.io_cout_0(_adder_chain_rnd_io_cout_0),
		.io_cout_1(_adder_chain_rnd_io_cout_1),
		.io_cout_2(_adder_chain_rnd_io_cout_2),
		.io_cout_3(_adder_chain_rnd_io_cout_3),
		.io_cout_4(_adder_chain_rnd_io_cout_4),
		.io_cout_5(_adder_chain_rnd_io_cout_5),
		.io_cout_6(_adder_chain_rnd_io_cout_6),
		.io_all_1s_1(_adder_chain_rnd_io_all_1s_1),
		.io_all_1s_2(_adder_chain_rnd_io_all_1s_2),
		.io_all_1s_3(_adder_chain_rnd_io_all_1s_3),
		.io_all_1s_4(_adder_chain_rnd_io_all_1s_4),
		.io_all_1s_5(_adder_chain_rnd_io_all_1s_5),
		.io_all_1s_6(_adder_chain_rnd_io_all_1s_6),
		.io_all_1s_7(_adder_chain_rnd_io_all_1s_7),
		.io_all_0s_1(_adder_chain_rnd_io_all_0s_1),
		.io_all_0s_2(_adder_chain_rnd_io_all_0s_2),
		.io_all_0s_3(_adder_chain_rnd_io_all_0s_3),
		.io_all_0s_4(_adder_chain_rnd_io_all_0s_4),
		.io_all_0s_5(_adder_chain_rnd_io_all_0s_5),
		.io_all_0s_6(_adder_chain_rnd_io_all_0s_6),
		.io_all_0s_7(_adder_chain_rnd_io_all_0s_7)
	);
	assign io_vd = (_io_vd_T | _io_vd_T_1 ? {(saturate[7] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_7) | (io_sew_oneHot[1] & io_fromAdder_vs2H_7)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_7)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {|io_sew_oneHot, 7'h00} : {~(|io_sew_oneHot), 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_7) | (io_sew_oneHot[1] & io_fromAdder_cout_7)) | (io_sew_oneHot[2] & io_fromAdder_cout_7)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_7), (saturate[6] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_6) | (io_sew_oneHot[1] & io_fromAdder_vs2H_7)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_7)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {io_sew_oneHot[0], 7'h00} : {~io_sew_oneHot[0], 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_6) | (io_sew_oneHot[1] & io_fromAdder_cout_7)) | (io_sew_oneHot[2] & io_fromAdder_cout_7)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_6), (saturate[5] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_5) | (io_sew_oneHot[1] & io_fromAdder_vs2H_5)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_7)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {highestBits_5, 7'h00} : {~highestBits_5, 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_5) | (io_sew_oneHot[1] & io_fromAdder_cout_5)) | (io_sew_oneHot[2] & io_fromAdder_cout_7)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_5), (saturate[4] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_4) | (io_sew_oneHot[1] & io_fromAdder_vs2H_5)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_7)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {io_sew_oneHot[0], 7'h00} : {~io_sew_oneHot[0], 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_4) | (io_sew_oneHot[1] & io_fromAdder_cout_5)) | (io_sew_oneHot[2] & io_fromAdder_cout_7)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_4), (saturate[3] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_3) | (io_sew_oneHot[1] & io_fromAdder_vs2H_3)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_3)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {highestBits_3, 7'h00} : {~highestBits_3, 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_3) | (io_sew_oneHot[1] & io_fromAdder_cout_3)) | (io_sew_oneHot[2] & io_fromAdder_cout_3)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_3), (saturate[2] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_2) | (io_sew_oneHot[1] & io_fromAdder_vs2H_3)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_3)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {io_sew_oneHot[0], 7'h00} : {~io_sew_oneHot[0], 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_2) | (io_sew_oneHot[1] & io_fromAdder_cout_3)) | (io_sew_oneHot[2] & io_fromAdder_cout_3)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_2), (saturate[1] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_1) | (io_sew_oneHot[1] & io_fromAdder_vs2H_1)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_3)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {highestBits_1, 7'h00} : {~highestBits_1, 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_1) | (io_sew_oneHot[1] & io_fromAdder_cout_1)) | (io_sew_oneHot[2] & io_fromAdder_cout_3)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_1), (saturate[0] ? (io_isSigned ? ((((io_sew_oneHot[0] & io_fromAdder_vs2H_0) | (io_sew_oneHot[1] & io_fromAdder_vs2H_1)) | (io_sew_oneHot[2] & io_fromAdder_vs2H_3)) | (io_sew_oneHot[3] & io_fromAdder_vs2H_7) ? {io_sew_oneHot[0], 7'h00} : {~io_sew_oneHot[0], 7'h7f}) : {8 {(((io_sew_oneHot[0] & io_fromAdder_cout_0) | (io_sew_oneHot[1] & io_fromAdder_cout_1)) | (io_sew_oneHot[2] & io_fromAdder_cout_3)) | (io_sew_oneHot[3] & io_fromAdder_cout_7)}}) : io_fromAdder_vd_0)} : {_adder_chain_rnd_io_dout_7, _adder_chain_rnd_io_dout_6, _adder_chain_rnd_io_dout_5, _adder_chain_rnd_io_dout_4, _adder_chain_rnd_io_dout_3, _adder_chain_rnd_io_dout_2, _adder_chain_rnd_io_dout_1, _adder_chain_rnd_io_dout_0});
	assign io_narrowVd = ((io_sew_oneHot[2] ? (io_isSigned ? (_nclipResult32_T_16 ? {_adder_chain_rnd_io_dout_3, _adder_chain_rnd_io_dout_2, _adder_chain_rnd_io_dout_1, _adder_chain_rnd_io_dout_0} : {_adder_chain_rnd_io_dout_7[7], {31 {~_adder_chain_rnd_io_dout_7[7]}}}) : (_nclipResult32_T_18 ? {_adder_chain_rnd_io_dout_3, _adder_chain_rnd_io_dout_2, _adder_chain_rnd_io_dout_1, _adder_chain_rnd_io_dout_0} : 32'hffffffff)) : 32'h00000000) | (io_sew_oneHot[1] ? {(io_isSigned ? (_nclipResult16_T_29 ? {_adder_chain_rnd_io_dout_5, _adder_chain_rnd_io_dout_4} : {_adder_chain_rnd_io_dout_7[7], {15 {~_adder_chain_rnd_io_dout_7[7]}}}) : (_nclipResult16_T_31 ? {_adder_chain_rnd_io_dout_5, _adder_chain_rnd_io_dout_4} : 16'hffff)), (io_isSigned ? (_nclipResult16_T_14 ? {_adder_chain_rnd_io_dout_1, _adder_chain_rnd_io_dout_0} : {_adder_chain_rnd_io_dout_3[7], {15 {~_adder_chain_rnd_io_dout_3[7]}}}) : (_nclipResult16_T_16 ? {_adder_chain_rnd_io_dout_1, _adder_chain_rnd_io_dout_0} : 16'hffff))} : 32'h00000000)) | (io_sew_oneHot[0] ? {(io_isSigned ? (_nclipResult8_T_53 ? _adder_chain_rnd_io_dout_6 : {_adder_chain_rnd_io_dout_7[7], {7 {~_adder_chain_rnd_io_dout_7[7]}}}) : (_nclipResult8_T_55 ? _adder_chain_rnd_io_dout_6 : 8'hff)), (io_isSigned ? (_nclipResult8_T_40 ? _adder_chain_rnd_io_dout_4 : {_adder_chain_rnd_io_dout_5[7], {7 {~_adder_chain_rnd_io_dout_5[7]}}}) : (_nclipResult8_T_42 ? _adder_chain_rnd_io_dout_4 : 8'hff)), (io_isSigned ? (_nclipResult8_T_27 ? _adder_chain_rnd_io_dout_2 : {_adder_chain_rnd_io_dout_3[7], {7 {~_adder_chain_rnd_io_dout_3[7]}}}) : (_nclipResult8_T_29 ? _adder_chain_rnd_io_dout_2 : 8'hff)), (io_isSigned ? (_nclipResult8_T_14 ? _adder_chain_rnd_io_dout_0 : {_adder_chain_rnd_io_dout_1[7], {7 {~_adder_chain_rnd_io_dout_1[7]}}}) : (_nclipResult8_T_16 ? _adder_chain_rnd_io_dout_0 : 8'hff))} : 32'h00000000);
	assign io_vxsat = (io_isNClip ? {4'h0, ({4 {io_sew_oneHot[2] & (io_isSigned ? ~_nclipResult32_T_16 : ~_nclipResult32_T_18)}} | (io_sew_oneHot[1] ? {{2 {(io_isSigned ? ~_nclipResult16_T_29 : ~_nclipResult16_T_31)}}, {2 {(io_isSigned ? ~_nclipResult16_T_14 : ~_nclipResult16_T_16)}}} : 4'h0)) | (io_sew_oneHot[0] ? {(io_isSigned ? ~_nclipResult8_T_53 : ~_nclipResult8_T_55), (io_isSigned ? ~_nclipResult8_T_40 : ~_nclipResult8_T_42), (io_isSigned ? ~_nclipResult8_T_27 : ~_nclipResult8_T_29), (io_isSigned ? ~_nclipResult8_T_14 : ~_nclipResult8_T_16)} : 4'h0)} : (_io_vd_T | _io_vd_T_1 ? saturate : 8'h00));
endmodule
module VIAluFix (
	clock,
	reset,
	io_in_valid,
	io_in_bits_ctrl_fuOpType,
	io_in_bits_ctrl_vpu_vma,
	io_in_bits_ctrl_vpu_vsew,
	io_in_bits_ctrl_vpu_vm,
	io_in_bits_ctrl_vpu_vuopIdx,
	io_in_bits_ctrl_vpu_isExt,
	io_in_bits_ctrl_vpu_isNarrow,
	io_in_bits_ctrl_vpu_isDstMask,
	io_in_bits_ctrlPipe_1_fuOpType,
	io_in_bits_ctrlPipe_1_robIdx_flag,
	io_in_bits_ctrlPipe_1_robIdx_value,
	io_in_bits_ctrlPipe_1_pdest,
	io_in_bits_ctrlPipe_1_vecWen,
	io_in_bits_ctrlPipe_1_v0Wen,
	io_in_bits_ctrlPipe_1_vpu_vma,
	io_in_bits_ctrlPipe_1_vpu_vta,
	io_in_bits_ctrlPipe_1_vpu_vsew,
	io_in_bits_ctrlPipe_1_vpu_vm,
	io_in_bits_ctrlPipe_1_vpu_vstart,
	io_in_bits_ctrlPipe_1_vpu_vuopIdx,
	io_in_bits_ctrlPipe_1_vpu_isExt,
	io_in_bits_ctrlPipe_1_vpu_isNarrow,
	io_in_bits_ctrlPipe_1_vpu_isDstMask,
	io_in_bits_ctrlPipe_1_vpu_isOpMask,
	io_in_bits_validPipe_0,
	io_in_bits_validPipe_1,
	io_in_bits_data_src_3,
	io_in_bits_data_src_2,
	io_in_bits_data_src_1,
	io_in_bits_data_src_0,
	io_in_bits_dataPipe_1_src_4,
	io_in_bits_dataPipe_1_src_3,
	io_in_bits_dataPipe_1_src_2,
	io_out_valid,
	io_out_bits_ctrl_robIdx_flag,
	io_out_bits_ctrl_robIdx_value,
	io_out_bits_ctrl_pdest,
	io_out_bits_ctrl_vecWen,
	io_out_bits_ctrl_v0Wen,
	io_out_bits_res_data,
	io_out_bits_res_vxsat,
	io_vxrm
);
	input clock;
	input reset;
	input io_in_valid;
	input [8:0] io_in_bits_ctrl_fuOpType;
	input io_in_bits_ctrl_vpu_vma;
	input [1:0] io_in_bits_ctrl_vpu_vsew;
	input io_in_bits_ctrl_vpu_vm;
	input [6:0] io_in_bits_ctrl_vpu_vuopIdx;
	input io_in_bits_ctrl_vpu_isExt;
	input io_in_bits_ctrl_vpu_isNarrow;
	input io_in_bits_ctrl_vpu_isDstMask;
	input [8:0] io_in_bits_ctrlPipe_1_fuOpType;
	input io_in_bits_ctrlPipe_1_robIdx_flag;
	input [7:0] io_in_bits_ctrlPipe_1_robIdx_value;
	input [7:0] io_in_bits_ctrlPipe_1_pdest;
	input io_in_bits_ctrlPipe_1_vecWen;
	input io_in_bits_ctrlPipe_1_v0Wen;
	input io_in_bits_ctrlPipe_1_vpu_vma;
	input io_in_bits_ctrlPipe_1_vpu_vta;
	input [1:0] io_in_bits_ctrlPipe_1_vpu_vsew;
	input io_in_bits_ctrlPipe_1_vpu_vm;
	input [7:0] io_in_bits_ctrlPipe_1_vpu_vstart;
	input [6:0] io_in_bits_ctrlPipe_1_vpu_vuopIdx;
	input io_in_bits_ctrlPipe_1_vpu_isExt;
	input io_in_bits_ctrlPipe_1_vpu_isNarrow;
	input io_in_bits_ctrlPipe_1_vpu_isDstMask;
	input io_in_bits_ctrlPipe_1_vpu_isOpMask;
	input io_in_bits_validPipe_0;
	input io_in_bits_validPipe_1;
	input [127:0] io_in_bits_data_src_3;
	input [127:0] io_in_bits_data_src_2;
	input [127:0] io_in_bits_data_src_1;
	input [127:0] io_in_bits_data_src_0;
	input [7:0] io_in_bits_dataPipe_1_src_4;
	input [127:0] io_in_bits_dataPipe_1_src_3;
	input [127:0] io_in_bits_dataPipe_1_src_2;
	output wire io_out_valid;
	output wire io_out_bits_ctrl_robIdx_flag;
	output wire [7:0] io_out_bits_ctrl_robIdx_value;
	output wire [7:0] io_out_bits_ctrl_pdest;
	output wire io_out_bits_ctrl_vecWen;
	output wire io_out_bits_ctrl_v0Wen;
	output wire [127:0] io_out_bits_res_data;
	output wire io_out_bits_res_vxsat;
	input [1:0] io_vxrm;
	wire [3:0] _decoderOut_orMatrixOutputs_T_4;
	wire [7:0] _decoderOut_orMatrixOutputs_T_2;
	wire [127:0] _mgtu_io_out_vd;
	wire [127:0] _mgu_io_out_vd;
	wire [15:0] _mgu_io_out_active;
	wire [63:0] _vIntFixpAlus_1_io_vd;
	wire [31:0] _vIntFixpAlus_1_io_narrowVd;
	wire [7:0] _vIntFixpAlus_1_io_cmpOut;
	wire [7:0] _vIntFixpAlus_1_io_vxsat;
	wire [63:0] _vIntFixpAlus_0_io_vd;
	wire [31:0] _vIntFixpAlus_0_io_narrowVd;
	wire [7:0] _vIntFixpAlus_0_io_cmpOut;
	wire [7:0] _vIntFixpAlus_0_io_vxsat;
	wire [7:0] _vs1Split_io_outVec8b_0;
	wire [7:0] _vs1Split_io_outVec8b_1;
	wire [7:0] _vs1Split_io_outVec8b_2;
	wire [7:0] _vs1Split_io_outVec8b_3;
	wire [7:0] _vs1Split_io_outVec8b_4;
	wire [7:0] _vs1Split_io_outVec8b_5;
	wire [7:0] _vs1Split_io_outVec8b_6;
	wire [7:0] _vs1Split_io_outVec8b_7;
	wire [7:0] _vs1Split_io_outVec8b_8;
	wire [7:0] _vs1Split_io_outVec8b_9;
	wire [7:0] _vs1Split_io_outVec8b_10;
	wire [7:0] _vs1Split_io_outVec8b_11;
	wire [7:0] _vs1Split_io_outVec8b_12;
	wire [7:0] _vs1Split_io_outVec8b_13;
	wire [7:0] _vs1Split_io_outVec8b_14;
	wire [7:0] _vs1Split_io_outVec8b_15;
	wire [15:0] _vs1Split_io_outVec16b_0;
	wire [15:0] _vs1Split_io_outVec16b_1;
	wire [15:0] _vs1Split_io_outVec16b_2;
	wire [15:0] _vs1Split_io_outVec16b_3;
	wire [15:0] _vs1Split_io_outVec16b_4;
	wire [15:0] _vs1Split_io_outVec16b_5;
	wire [15:0] _vs1Split_io_outVec16b_6;
	wire [15:0] _vs1Split_io_outVec16b_7;
	wire [31:0] _vs1Split_io_outVec32b_0;
	wire [31:0] _vs1Split_io_outVec32b_1;
	wire [31:0] _vs1Split_io_outVec32b_2;
	wire [31:0] _vs1Split_io_outVec32b_3;
	wire [63:0] _vs1Split_io_outVec64b_0;
	wire [63:0] _vs1Split_io_outVec64b_1;
	wire [7:0] _vs2Split_io_outVec8b_0;
	wire [7:0] _vs2Split_io_outVec8b_1;
	wire [7:0] _vs2Split_io_outVec8b_2;
	wire [7:0] _vs2Split_io_outVec8b_3;
	wire [7:0] _vs2Split_io_outVec8b_4;
	wire [7:0] _vs2Split_io_outVec8b_5;
	wire [7:0] _vs2Split_io_outVec8b_6;
	wire [7:0] _vs2Split_io_outVec8b_7;
	wire [7:0] _vs2Split_io_outVec8b_8;
	wire [7:0] _vs2Split_io_outVec8b_9;
	wire [7:0] _vs2Split_io_outVec8b_10;
	wire [7:0] _vs2Split_io_outVec8b_11;
	wire [7:0] _vs2Split_io_outVec8b_12;
	wire [7:0] _vs2Split_io_outVec8b_13;
	wire [7:0] _vs2Split_io_outVec8b_14;
	wire [7:0] _vs2Split_io_outVec8b_15;
	wire [15:0] _vs2Split_io_outVec16b_0;
	wire [15:0] _vs2Split_io_outVec16b_1;
	wire [15:0] _vs2Split_io_outVec16b_2;
	wire [15:0] _vs2Split_io_outVec16b_3;
	wire [15:0] _vs2Split_io_outVec16b_4;
	wire [15:0] _vs2Split_io_outVec16b_5;
	wire [15:0] _vs2Split_io_outVec16b_6;
	wire [15:0] _vs2Split_io_outVec16b_7;
	wire [31:0] _vs2Split_io_outVec32b_0;
	wire [31:0] _vs2Split_io_outVec32b_1;
	wire [31:0] _vs2Split_io_outVec32b_2;
	wire [31:0] _vs2Split_io_outVec32b_3;
	wire [63:0] _vs2Split_io_outVec64b_0;
	wire [63:0] _vs2Split_io_outVec64b_1;
	wire [3:0] _typeMod_io_out_vs1Type;
	wire [3:0] _typeMod_io_out_vs2Type;
	wire [3:0] _typeMod_io_out_vdType;
	wire _typeMod_io_out_isVextF2;
	wire _typeMod_io_out_isVextF4;
	wire _typeMod_io_out_isVextF8;
	reg validVecThisFu_1;
	wire [127:0] srcMask = ((io_in_bits_ctrl_fuOpType == 9'h084) | (io_in_bits_ctrl_fuOpType == 9'h086) ? 128'h00000000000000000000000000000000 : (io_in_bits_ctrl_vpu_vm ? 128'hffffffffffffffffffffffffffffffff : io_in_bits_data_src_3));
	wire [63:0] vs2GroupedVec32b_0 = {_vs2Split_io_outVec32b_2, _vs2Split_io_outVec32b_0};
	wire [63:0] vs2GroupedVec32b_1 = {_vs2Split_io_outVec32b_3, _vs2Split_io_outVec32b_1};
	wire [5:0] decoderOut_invInputs = ~io_in_bits_ctrl_fuOpType[5:0];
	assign _decoderOut_orMatrixOutputs_T_2 = {&{decoderOut_invInputs[1], decoderOut_invInputs[3], decoderOut_invInputs[4], decoderOut_invInputs[5]}, &{io_in_bits_ctrl_fuOpType[0], decoderOut_invInputs[2], decoderOut_invInputs[3], decoderOut_invInputs[4], decoderOut_invInputs[5]}, &{decoderOut_invInputs[0], io_in_bits_ctrl_fuOpType[2], decoderOut_invInputs[3], decoderOut_invInputs[5]}, &{io_in_bits_ctrl_fuOpType[1], decoderOut_invInputs[3], io_in_bits_ctrl_fuOpType[4], decoderOut_invInputs[5]}, &{io_in_bits_ctrl_fuOpType[0], io_in_bits_ctrl_fuOpType[1], decoderOut_invInputs[2], io_in_bits_ctrl_fuOpType[4], decoderOut_invInputs[5]}, &{decoderOut_invInputs[0], io_in_bits_ctrl_fuOpType[2], io_in_bits_ctrl_fuOpType[4], decoderOut_invInputs[5]}, &{decoderOut_invInputs[1], io_in_bits_ctrl_fuOpType[2], io_in_bits_ctrl_fuOpType[4], decoderOut_invInputs[5]}, &{decoderOut_invInputs[0], decoderOut_invInputs[1], io_in_bits_ctrl_fuOpType[3], io_in_bits_ctrl_fuOpType[4], decoderOut_invInputs[5]}};
	assign _decoderOut_orMatrixOutputs_T_4 = {&{io_in_bits_ctrl_fuOpType[0], decoderOut_invInputs[1], decoderOut_invInputs[3], decoderOut_invInputs[4], decoderOut_invInputs[5]}, &{decoderOut_invInputs[0], io_in_bits_ctrl_fuOpType[1], io_in_bits_ctrl_fuOpType[2], decoderOut_invInputs[3], decoderOut_invInputs[5]}, &{decoderOut_invInputs[0], io_in_bits_ctrl_fuOpType[4], decoderOut_invInputs[5]}, &{decoderOut_invInputs[3], io_in_bits_ctrl_fuOpType[4], decoderOut_invInputs[5]}};
	wire isFixp = (|_decoderOut_orMatrixOutputs_T_2 ? (((io_in_bits_ctrl_fuOpType[5:0] == 6'h1b) | (io_in_bits_ctrl_fuOpType[5:0] == 6'h1c)) | (io_in_bits_ctrl_fuOpType[5:0] == 6'h1d)) | (io_in_bits_ctrl_fuOpType[5:0] == 6'h1e) : (io_in_bits_ctrl_fuOpType[5:0] == 6'h1f) | (io_in_bits_ctrl_fuOpType[5:0] == 6'h20));
	wire widen = ((io_in_bits_ctrl_fuOpType[5:0] == 6'h00) | (io_in_bits_ctrl_fuOpType[5:0] == 6'h01)) & (_typeMod_io_out_vs1Type[1:0] != _typeMod_io_out_vdType[1:0]);
	wire widen_vs2 = widen & (_typeMod_io_out_vs2Type[1:0] != _typeMod_io_out_vdType[1:0]);
	wire _eewVs1_sew_oneHot_T_1 = _typeMod_io_out_vs1Type[1:0] == 2'h1;
	wire _eewVs1_sew_oneHot_T_2 = _typeMod_io_out_vs1Type[1:0] == 2'h2;
	wire [3:0] eewVs1_oneHot = {&_typeMod_io_out_vs1Type[1:0], _eewVs1_sew_oneHot_T_2, _eewVs1_sew_oneHot_T_1, ~(|_typeMod_io_out_vs1Type[1:0])};
	wire _eewVd_sew_oneHot_T_1 = _typeMod_io_out_vdType[1:0] == 2'h1;
	wire _eewVd_sew_oneHot_T_2 = _typeMod_io_out_vdType[1:0] == 2'h2;
	wire isVwsll = io_in_bits_ctrl_fuOpType[5:0] == 6'h37;
	wire isVwsllEewVdIs64 = isVwsll & (&_typeMod_io_out_vdType[1:0]);
	wire isVwsllEewVdIs32 = isVwsll & _eewVd_sew_oneHot_T_2;
	wire isVwsllEewVdIs16 = isVwsll & _eewVd_sew_oneHot_T_1;
	wire _GEN = (widen | io_in_bits_ctrl_vpu_isNarrow) | isVwsllEewVdIs64;
	wire _GEN_0 = _typeMod_io_out_isVextF2 | isVwsllEewVdIs64;
	wire _GEN_1 = _typeMod_io_out_isVextF4 | isVwsllEewVdIs32;
	wire _GEN_2 = _typeMod_io_out_isVextF8 | isVwsllEewVdIs16;
	wire _maskDataVec_maskDataVec_7_T = io_in_bits_ctrl_vpu_vsew == 2'h0;
	wire _maskDataVec_maskDataVec_7_T_2 = io_in_bits_ctrl_vpu_vsew == 2'h1;
	wire _maskDataVec_maskDataVec_7_T_4 = io_in_bits_ctrl_vpu_vsew == 2'h2;
	wire [15:0] _maskDataVec_maskDataVec_0_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[15:0] : 16'h0000);
	wire [7:0] _GEN_3 = _maskDataVec_maskDataVec_0_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[7:0] : 8'h00);
	wire [3:0] _GEN_4 = _GEN_3[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[3:0] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_1_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[31:16] : 16'h0000);
	wire [7:0] _GEN_5 = _maskDataVec_maskDataVec_1_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[15:8] : 8'h00);
	wire [3:0] _GEN_6 = _GEN_5[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[7:4] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_2_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[47:32] : 16'h0000);
	wire [7:0] _GEN_7 = _maskDataVec_maskDataVec_2_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[23:16] : 8'h00);
	wire [3:0] _GEN_8 = _GEN_7[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[11:8] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_3_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[63:48] : 16'h0000);
	wire [7:0] _GEN_9 = _maskDataVec_maskDataVec_3_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[31:24] : 8'h00);
	wire [3:0] _GEN_10 = _GEN_9[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[15:12] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_4_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[79:64] : 16'h0000);
	wire [7:0] _GEN_11 = _maskDataVec_maskDataVec_4_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[39:32] : 8'h00);
	wire [3:0] _GEN_12 = _GEN_11[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[19:16] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_5_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[95:80] : 16'h0000);
	wire [7:0] _GEN_13 = _maskDataVec_maskDataVec_5_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[47:40] : 8'h00);
	wire [3:0] _GEN_14 = _GEN_13[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[23:20] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_6_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[111:96] : 16'h0000);
	wire [7:0] _GEN_15 = _maskDataVec_maskDataVec_6_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[55:48] : 8'h00);
	wire [3:0] _GEN_16 = _GEN_15[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[27:24] : 4'h0);
	wire [15:0] _maskDataVec_maskDataVec_7_T_8 = (_maskDataVec_maskDataVec_7_T ? srcMask[127:112] : 16'h0000);
	wire [7:0] _GEN_17 = _maskDataVec_maskDataVec_7_T_8[7:0] | (_maskDataVec_maskDataVec_7_T_2 ? srcMask[63:56] : 8'h00);
	wire [3:0] _GEN_18 = _GEN_17[3:0] | (_maskDataVec_maskDataVec_7_T_4 ? srcMask[31:28] : 4'h0);
	wire [3:0] _maskUsed_T_1_oneHot = (&_typeMod_io_out_vdType ? eewVs1_oneHot : {&_typeMod_io_out_vdType[1:0], _eewVd_sew_oneHot_T_2, _eewVd_sew_oneHot_T_1, _typeMod_io_out_vdType[1:0] == 2'h0});
	wire [127:0] _GEN_19 = {_maskDataVec_maskDataVec_7_T_8[15:8], _GEN_17[7:4], _GEN_18[3:2], _GEN_18[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[15:14] : 2'h0), _maskDataVec_maskDataVec_6_T_8[15:8], _GEN_15[7:4], _GEN_16[3:2], _GEN_16[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[13:12] : 2'h0), _maskDataVec_maskDataVec_5_T_8[15:8], _GEN_13[7:4], _GEN_14[3:2], _GEN_14[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[11:10] : 2'h0), _maskDataVec_maskDataVec_4_T_8[15:8], _GEN_11[7:4], _GEN_12[3:2], _GEN_12[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[9:8] : 2'h0), _maskDataVec_maskDataVec_3_T_8[15:8], _GEN_9[7:4], _GEN_10[3:2], _GEN_10[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[7:6] : 2'h0), _maskDataVec_maskDataVec_2_T_8[15:8], _GEN_7[7:4], _GEN_8[3:2], _GEN_8[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[5:4] : 2'h0), _maskDataVec_maskDataVec_1_T_8[15:8], _GEN_5[7:4], _GEN_6[3:2], _GEN_6[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[3:2] : 2'h0), _maskDataVec_maskDataVec_0_T_8[15:8], _GEN_3[7:4], _GEN_4[3:2], _GEN_4[1:0] | (&io_in_bits_ctrl_vpu_vsew ? srcMask[1:0] : 2'h0)};
	wire [15:0] _GEN_20 = _GEN_19[(io_in_bits_ctrl_vpu_isNarrow ? io_in_bits_ctrl_vpu_vuopIdx[3:1] : io_in_bits_ctrl_vpu_vuopIdx[2:0]) * 16+:16];
	wire _oldVdUsed_maskDataVec_7_T_2 = _typeMod_io_out_vs1Type[1:0] == 2'h1;
	wire _oldVdUsed_maskDataVec_7_T_4 = _typeMod_io_out_vs1Type[1:0] == 2'h2;
	wire [15:0] _oldVdUsed_maskDataVec_0_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[15:0]);
	wire [7:0] _GEN_21 = _oldVdUsed_maskDataVec_0_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[7:0] : 8'h00);
	wire [3:0] _GEN_22 = _GEN_21[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[3:0] : 4'h0);
	wire [15:0] _oldVdUsed_maskDataVec_1_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[31:16]);
	wire [7:0] _GEN_23 = _oldVdUsed_maskDataVec_1_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[15:8] : 8'h00);
	wire [3:0] _GEN_24 = _GEN_23[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[7:4] : 4'h0);
	wire [15:0] _oldVdUsed_maskDataVec_2_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[47:32]);
	wire [7:0] _GEN_25 = _oldVdUsed_maskDataVec_2_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[23:16] : 8'h00);
	wire [3:0] _GEN_26 = _GEN_25[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[11:8] : 4'h0);
	wire [15:0] _oldVdUsed_maskDataVec_3_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[63:48]);
	wire [7:0] _GEN_27 = _oldVdUsed_maskDataVec_3_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[31:24] : 8'h00);
	wire [3:0] _GEN_28 = _GEN_27[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[15:12] : 4'h0);
	wire [15:0] _oldVdUsed_maskDataVec_4_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[79:64]);
	wire [7:0] _GEN_29 = _oldVdUsed_maskDataVec_4_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[39:32] : 8'h00);
	wire [3:0] _GEN_30 = _GEN_29[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[19:16] : 4'h0);
	wire [15:0] _oldVdUsed_maskDataVec_5_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[95:80]);
	wire [7:0] _GEN_31 = _oldVdUsed_maskDataVec_5_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[47:40] : 8'h00);
	wire [3:0] _GEN_32 = _GEN_31[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[23:20] : 4'h0);
	wire [15:0] _oldVdUsed_maskDataVec_6_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[111:96]);
	wire [7:0] _GEN_33 = _oldVdUsed_maskDataVec_6_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[55:48] : 8'h00);
	wire [3:0] _GEN_34 = _GEN_33[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[27:24] : 4'h0);
	wire [15:0] _oldVdUsed_maskDataVec_7_T_8 = (|_typeMod_io_out_vs1Type[1:0] ? 16'h0000 : io_in_bits_data_src_2[127:112]);
	wire [7:0] _GEN_35 = _oldVdUsed_maskDataVec_7_T_8[7:0] | (_oldVdUsed_maskDataVec_7_T_2 ? io_in_bits_data_src_2[63:56] : 8'h00);
	wire [3:0] _GEN_36 = _GEN_35[3:0] | (_oldVdUsed_maskDataVec_7_T_4 ? io_in_bits_data_src_2[31:28] : 4'h0);
	wire [127:0] _GEN_37 = {_oldVdUsed_maskDataVec_7_T_8[15:8], _GEN_35[7:4], _GEN_36[3:2], _GEN_36[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[15:14] : 2'h0), _oldVdUsed_maskDataVec_6_T_8[15:8], _GEN_33[7:4], _GEN_34[3:2], _GEN_34[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[13:12] : 2'h0), _oldVdUsed_maskDataVec_5_T_8[15:8], _GEN_31[7:4], _GEN_32[3:2], _GEN_32[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[11:10] : 2'h0), _oldVdUsed_maskDataVec_4_T_8[15:8], _GEN_29[7:4], _GEN_30[3:2], _GEN_30[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[9:8] : 2'h0), _oldVdUsed_maskDataVec_3_T_8[15:8], _GEN_27[7:4], _GEN_28[3:2], _GEN_28[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[7:6] : 2'h0), _oldVdUsed_maskDataVec_2_T_8[15:8], _GEN_25[7:4], _GEN_26[3:2], _GEN_26[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[5:4] : 2'h0), _oldVdUsed_maskDataVec_1_T_8[15:8], _GEN_23[7:4], _GEN_24[3:2], _GEN_24[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[3:2] : 2'h0), _oldVdUsed_maskDataVec_0_T_8[15:8], _GEN_21[7:4], _GEN_22[3:2], _GEN_22[1:0] | (&_typeMod_io_out_vs1Type[1:0] ? io_in_bits_data_src_2[1:0] : 2'h0)};
	wire [15:0] _GEN_38 = _GEN_37[io_in_bits_ctrl_vpu_vuopIdx[2:0] * 16+:16];
	wire [7:0] _GEN_39 = {7'h00, io_in_bits_ctrl_vpu_isNarrow};
	reg outIsVwsll;
	reg outIsVwsllEewVdIs64;
	reg outIsVwsllEewVdIs32;
	reg outIsVwsllEewVdIs16;
	reg [3:0] outEewVs1_oneHot;
	wire [127:0] outVd = ((outIsVwsllEewVdIs64 | ~outIsVwsll ? {_vIntFixpAlus_1_io_vd, _vIntFixpAlus_0_io_vd} : 128'h00000000000000000000000000000000) | (outIsVwsllEewVdIs32 ? {_vIntFixpAlus_1_io_vd[63:32], _vIntFixpAlus_0_io_vd[63:32], _vIntFixpAlus_1_io_vd[31:0], _vIntFixpAlus_0_io_vd[31:0]} : 128'h00000000000000000000000000000000)) | (outIsVwsllEewVdIs16 ? {_vIntFixpAlus_1_io_vd[63:48], _vIntFixpAlus_0_io_vd[63:48], _vIntFixpAlus_1_io_vd[47:32], _vIntFixpAlus_0_io_vd[47:32], _vIntFixpAlus_1_io_vd[31:16], _vIntFixpAlus_0_io_vd[31:16], _vIntFixpAlus_1_io_vd[15:0], _vIntFixpAlus_0_io_vd[15:0]} : 128'h00000000000000000000000000000000);
	wire [15:0] _outCmp_T_16 = (outEewVs1_oneHot[0] ? {_vIntFixpAlus_1_io_cmpOut, _vIntFixpAlus_0_io_cmpOut} : 16'h0000);
	wire [7:0] _GEN_40 = _outCmp_T_16[7:0] | (outEewVs1_oneHot[1] ? {_vIntFixpAlus_1_io_cmpOut[3:0], _vIntFixpAlus_0_io_cmpOut[3:0]} : 8'h00);
	wire [3:0] _GEN_41 = _GEN_40[3:0] | (outEewVs1_oneHot[2] ? {_vIntFixpAlus_1_io_cmpOut[1:0], _vIntFixpAlus_0_io_cmpOut[1:0]} : 4'h0);
	wire [1:0] _GEN_42 = _GEN_41[1:0] | (outEewVs1_oneHot[3] ? {_vIntFixpAlus_1_io_cmpOut[0], _vIntFixpAlus_0_io_cmpOut[0]} : 2'h0);
	wire [7:0] _GEN_43 = {3'h0, outEewVs1_oneHot[0], outEewVs1_oneHot[1], outEewVs1_oneHot[2], outEewVs1_oneHot[3], 1'h0};
	function automatic [6:0] sv2v_cast_7;
		input reg [6:0] inp;
		sv2v_cast_7 = inp;
	endfunction
	wire [7:0] elementsComputed = ((({1'h0, ({1'h0, (io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0] == 3'h1 ? {1'h0, outEewVs1_oneHot[0], outEewVs1_oneHot[1], outEewVs1_oneHot[2], outEewVs1_oneHot[3], 1'h0} : 6'h00)} | (io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0] == 3'h2 ? {1'h0, outEewVs1_oneHot[0], outEewVs1_oneHot[1], outEewVs1_oneHot[2], outEewVs1_oneHot[3], 2'h0} : 7'h00)) | (io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0] == 3'h3 ? sv2v_cast_7({2'h0, outEewVs1_oneHot[0], outEewVs1_oneHot[1], outEewVs1_oneHot[2], outEewVs1_oneHot[3], 1'h0} * 7'h03) : 7'h00)} | (io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0] == 3'h4 ? {1'h0, outEewVs1_oneHot[0], outEewVs1_oneHot[1], outEewVs1_oneHot[2], outEewVs1_oneHot[3], 3'h0} : 8'h00)) | (io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0] == 3'h5 ? _GEN_43 * 8'h05 : 8'h00)) | (io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0] == 3'h6 ? _GEN_43 * 8'h06 : 8'h00)) | (&io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0] ? _GEN_43 * 8'h07 : 8'h00);
	wire [8:0] _GEN_44 = {1'h0, elementsComputed};
	wire [8:0] _GEN_45 = {1'h0, io_in_bits_dataPipe_1_src_4};
	wire [15:0] outVxsat = (io_in_bits_ctrlPipe_1_vpu_isNarrow ? {8'h00, _vIntFixpAlus_1_io_vxsat[3:0], _vIntFixpAlus_0_io_vxsat[3:0]} : {_vIntFixpAlus_1_io_vxsat, _vIntFixpAlus_0_io_vxsat});
	wire narrowNeedCat = io_in_bits_ctrlPipe_1_vpu_vuopIdx[0] & io_in_bits_ctrlPipe_1_vpu_isNarrow;
	wire outVstartGeVl = io_in_bits_ctrlPipe_1_vpu_vstart >= io_in_bits_dataPipe_1_src_4;
	always @(posedge clock or posedge reset)
		if (reset)
			validVecThisFu_1 <= 1'h0;
		else
			validVecThisFu_1 <= io_in_valid;
	always @(posedge clock) begin
		if (io_in_valid) begin
			outIsVwsll <= isVwsll;
			outIsVwsllEewVdIs64 <= isVwsllEewVdIs64;
			outIsVwsllEewVdIs32 <= isVwsllEewVdIs32;
			outIsVwsllEewVdIs16 <= isVwsllEewVdIs16;
		end
		if (io_in_bits_validPipe_0 & io_in_valid)
			outEewVs1_oneHot <= eewVs1_oneHot;
	end
	VIAluSrcTypeModule typeMod(
		.io_in_fuOpType(io_in_bits_ctrl_fuOpType),
		.io_in_vsew(io_in_bits_ctrl_vpu_vsew),
		.io_in_isExt(io_in_bits_ctrl_vpu_isExt),
		.io_in_isDstMask(io_in_bits_ctrl_vpu_isDstMask),
		.io_out_vs1Type(_typeMod_io_out_vs1Type),
		.io_out_vs2Type(_typeMod_io_out_vs2Type),
		.io_out_vdType(_typeMod_io_out_vdType),
		.io_out_isVextF2(_typeMod_io_out_isVextF2),
		.io_out_isVextF4(_typeMod_io_out_isVextF4),
		.io_out_isVextF8(_typeMod_io_out_isVextF8)
	);
	VecDataSplitModule vs2Split(
		.io_inVecData(io_in_bits_data_src_1),
		.io_outVec8b_0(_vs2Split_io_outVec8b_0),
		.io_outVec8b_1(_vs2Split_io_outVec8b_1),
		.io_outVec8b_2(_vs2Split_io_outVec8b_2),
		.io_outVec8b_3(_vs2Split_io_outVec8b_3),
		.io_outVec8b_4(_vs2Split_io_outVec8b_4),
		.io_outVec8b_5(_vs2Split_io_outVec8b_5),
		.io_outVec8b_6(_vs2Split_io_outVec8b_6),
		.io_outVec8b_7(_vs2Split_io_outVec8b_7),
		.io_outVec8b_8(_vs2Split_io_outVec8b_8),
		.io_outVec8b_9(_vs2Split_io_outVec8b_9),
		.io_outVec8b_10(_vs2Split_io_outVec8b_10),
		.io_outVec8b_11(_vs2Split_io_outVec8b_11),
		.io_outVec8b_12(_vs2Split_io_outVec8b_12),
		.io_outVec8b_13(_vs2Split_io_outVec8b_13),
		.io_outVec8b_14(_vs2Split_io_outVec8b_14),
		.io_outVec8b_15(_vs2Split_io_outVec8b_15),
		.io_outVec16b_0(_vs2Split_io_outVec16b_0),
		.io_outVec16b_1(_vs2Split_io_outVec16b_1),
		.io_outVec16b_2(_vs2Split_io_outVec16b_2),
		.io_outVec16b_3(_vs2Split_io_outVec16b_3),
		.io_outVec16b_4(_vs2Split_io_outVec16b_4),
		.io_outVec16b_5(_vs2Split_io_outVec16b_5),
		.io_outVec16b_6(_vs2Split_io_outVec16b_6),
		.io_outVec16b_7(_vs2Split_io_outVec16b_7),
		.io_outVec32b_0(_vs2Split_io_outVec32b_0),
		.io_outVec32b_1(_vs2Split_io_outVec32b_1),
		.io_outVec32b_2(_vs2Split_io_outVec32b_2),
		.io_outVec32b_3(_vs2Split_io_outVec32b_3),
		.io_outVec64b_0(_vs2Split_io_outVec64b_0),
		.io_outVec64b_1(_vs2Split_io_outVec64b_1)
	);
	VecDataSplitModule vs1Split(
		.io_inVecData(io_in_bits_data_src_0),
		.io_outVec8b_0(_vs1Split_io_outVec8b_0),
		.io_outVec8b_1(_vs1Split_io_outVec8b_1),
		.io_outVec8b_2(_vs1Split_io_outVec8b_2),
		.io_outVec8b_3(_vs1Split_io_outVec8b_3),
		.io_outVec8b_4(_vs1Split_io_outVec8b_4),
		.io_outVec8b_5(_vs1Split_io_outVec8b_5),
		.io_outVec8b_6(_vs1Split_io_outVec8b_6),
		.io_outVec8b_7(_vs1Split_io_outVec8b_7),
		.io_outVec8b_8(_vs1Split_io_outVec8b_8),
		.io_outVec8b_9(_vs1Split_io_outVec8b_9),
		.io_outVec8b_10(_vs1Split_io_outVec8b_10),
		.io_outVec8b_11(_vs1Split_io_outVec8b_11),
		.io_outVec8b_12(_vs1Split_io_outVec8b_12),
		.io_outVec8b_13(_vs1Split_io_outVec8b_13),
		.io_outVec8b_14(_vs1Split_io_outVec8b_14),
		.io_outVec8b_15(_vs1Split_io_outVec8b_15),
		.io_outVec16b_0(_vs1Split_io_outVec16b_0),
		.io_outVec16b_1(_vs1Split_io_outVec16b_1),
		.io_outVec16b_2(_vs1Split_io_outVec16b_2),
		.io_outVec16b_3(_vs1Split_io_outVec16b_3),
		.io_outVec16b_4(_vs1Split_io_outVec16b_4),
		.io_outVec16b_5(_vs1Split_io_outVec16b_5),
		.io_outVec16b_6(_vs1Split_io_outVec16b_6),
		.io_outVec16b_7(_vs1Split_io_outVec16b_7),
		.io_outVec32b_0(_vs1Split_io_outVec32b_0),
		.io_outVec32b_1(_vs1Split_io_outVec32b_1),
		.io_outVec32b_2(_vs1Split_io_outVec32b_2),
		.io_outVec32b_3(_vs1Split_io_outVec32b_3),
		.io_outVec64b_0(_vs1Split_io_outVec64b_0),
		.io_outVec64b_1(_vs1Split_io_outVec64b_1)
	);
	VIntFixpAlu64b vIntFixpAlus_0(
		.clock(clock),
		.io_fire(io_in_valid),
		.io_opcode_op(io_in_bits_ctrl_fuOpType[5:0]),
		.io_info_vm(io_in_bits_ctrl_vpu_vm),
		.io_info_ma(io_in_bits_ctrl_vpu_vma),
		.io_info_uopIdx(io_in_bits_ctrl_vpu_vuopIdx[5:0]),
		.io_info_vxrm(io_vxrm),
		.io_srcType_0(_typeMod_io_out_vs2Type),
		.io_srcType_1(_typeMod_io_out_vs1Type),
		.io_vdType(_typeMod_io_out_vdType),
		.io_vs1((_GEN ? {_vs1Split_io_outVec32b_2, _vs1Split_io_outVec32b_0} : (isVwsllEewVdIs32 ? {_vs1Split_io_outVec16b_6, _vs1Split_io_outVec16b_4, _vs1Split_io_outVec16b_2, _vs1Split_io_outVec16b_0} : (isVwsllEewVdIs16 ? {_vs1Split_io_outVec8b_14, _vs1Split_io_outVec8b_12, _vs1Split_io_outVec8b_10, _vs1Split_io_outVec8b_8, _vs1Split_io_outVec8b_6, _vs1Split_io_outVec8b_4, _vs1Split_io_outVec8b_2, _vs1Split_io_outVec8b_0} : _vs1Split_io_outVec64b_0)))),
		.io_vs2_adder((widen_vs2 ? vs2GroupedVec32b_0 : _vs2Split_io_outVec64b_0)),
		.io_vs2_misc((_GEN_0 ? vs2GroupedVec32b_0 : (_GEN_1 ? {_vs2Split_io_outVec16b_6, _vs2Split_io_outVec16b_4, _vs2Split_io_outVec16b_2, _vs2Split_io_outVec16b_0} : (_GEN_2 ? {_vs2Split_io_outVec8b_14, _vs2Split_io_outVec8b_12, _vs2Split_io_outVec8b_10, _vs2Split_io_outVec8b_8, _vs2Split_io_outVec8b_6, _vs2Split_io_outVec8b_4, _vs2Split_io_outVec8b_2, _vs2Split_io_outVec8b_0} : _vs2Split_io_outVec64b_0)))),
		.io_vmask((((_maskUsed_T_1_oneHot[0] ? _GEN_20[7:0] : 8'h00) | (_maskUsed_T_1_oneHot[1] ? {4'h0, _GEN_20[3:0]} : 8'h00)) | (_maskUsed_T_1_oneHot[2] ? {6'h00, _GEN_20[1:0]} : 8'h00)) | (_maskUsed_T_1_oneHot[3] ? {7'h00, _GEN_20[0]} : 8'h00)),
		.io_oldVd((((|_typeMod_io_out_vs1Type[1:0] ? 8'h00 : _GEN_38[7:0]) | (_eewVs1_sew_oneHot_T_1 ? {4'h0, _GEN_38[3:0]} : 8'h00)) | (_eewVs1_sew_oneHot_T_2 ? {6'h00, _GEN_38[1:0]} : 8'h00)) | (&_typeMod_io_out_vs1Type[1:0] ? {7'h00, _GEN_38[0]} : 8'h00)),
		.io_narrow(_GEN_39),
		.io_isSub(|_decoderOut_orMatrixOutputs_T_4),
		.io_isMisc(~(|_decoderOut_orMatrixOutputs_T_2)),
		.io_isFixp(isFixp),
		.io_widen(widen),
		.io_widen_vs2(widen_vs2),
		.io_vd(_vIntFixpAlus_0_io_vd),
		.io_narrowVd(_vIntFixpAlus_0_io_narrowVd),
		.io_cmpOut(_vIntFixpAlus_0_io_cmpOut),
		.io_vxsat(_vIntFixpAlus_0_io_vxsat)
	);
	VIntFixpAlu64b vIntFixpAlus_1(
		.clock(clock),
		.io_fire(io_in_valid),
		.io_opcode_op(io_in_bits_ctrl_fuOpType[5:0]),
		.io_info_vm(io_in_bits_ctrl_vpu_vm),
		.io_info_ma(io_in_bits_ctrl_vpu_vma),
		.io_info_uopIdx(io_in_bits_ctrl_vpu_vuopIdx[5:0]),
		.io_info_vxrm(io_vxrm),
		.io_srcType_0(_typeMod_io_out_vs2Type),
		.io_srcType_1(_typeMod_io_out_vs1Type),
		.io_vdType(_typeMod_io_out_vdType),
		.io_vs1((_GEN ? {_vs1Split_io_outVec32b_3, _vs1Split_io_outVec32b_1} : (isVwsllEewVdIs32 ? {_vs1Split_io_outVec16b_7, _vs1Split_io_outVec16b_5, _vs1Split_io_outVec16b_3, _vs1Split_io_outVec16b_1} : (isVwsllEewVdIs16 ? {_vs1Split_io_outVec8b_15, _vs1Split_io_outVec8b_13, _vs1Split_io_outVec8b_11, _vs1Split_io_outVec8b_9, _vs1Split_io_outVec8b_7, _vs1Split_io_outVec8b_5, _vs1Split_io_outVec8b_3, _vs1Split_io_outVec8b_1} : _vs1Split_io_outVec64b_1)))),
		.io_vs2_adder((widen_vs2 ? vs2GroupedVec32b_1 : _vs2Split_io_outVec64b_1)),
		.io_vs2_misc((_GEN_0 ? vs2GroupedVec32b_1 : (_GEN_1 ? {_vs2Split_io_outVec16b_7, _vs2Split_io_outVec16b_5, _vs2Split_io_outVec16b_3, _vs2Split_io_outVec16b_1} : (_GEN_2 ? {_vs2Split_io_outVec8b_15, _vs2Split_io_outVec8b_13, _vs2Split_io_outVec8b_11, _vs2Split_io_outVec8b_9, _vs2Split_io_outVec8b_7, _vs2Split_io_outVec8b_5, _vs2Split_io_outVec8b_3, _vs2Split_io_outVec8b_1} : _vs2Split_io_outVec64b_1)))),
		.io_vmask((((_maskUsed_T_1_oneHot[0] ? _GEN_20[15:8] : 8'h00) | (_maskUsed_T_1_oneHot[1] ? {4'h0, _GEN_20[7:4]} : 8'h00)) | (_maskUsed_T_1_oneHot[2] ? {6'h00, _GEN_20[3:2]} : 8'h00)) | (_maskUsed_T_1_oneHot[3] ? {7'h00, _GEN_20[1]} : 8'h00)),
		.io_oldVd((((|_typeMod_io_out_vs1Type[1:0] ? 8'h00 : _GEN_38[15:8]) | (_eewVs1_sew_oneHot_T_1 ? {4'h0, _GEN_38[7:4]} : 8'h00)) | (_eewVs1_sew_oneHot_T_2 ? {6'h00, _GEN_38[3:2]} : 8'h00)) | (&_typeMod_io_out_vs1Type[1:0] ? {7'h00, _GEN_38[1]} : 8'h00)),
		.io_narrow(_GEN_39),
		.io_isSub(|_decoderOut_orMatrixOutputs_T_4),
		.io_isMisc(~(|_decoderOut_orMatrixOutputs_T_2)),
		.io_isFixp(isFixp),
		.io_widen(widen),
		.io_widen_vs2(widen_vs2),
		.io_vd(_vIntFixpAlus_1_io_vd),
		.io_narrowVd(_vIntFixpAlus_1_io_narrowVd),
		.io_cmpOut(_vIntFixpAlus_1_io_cmpOut),
		.io_vxsat(_vIntFixpAlus_1_io_vxsat)
	);
	Mgu mgu(
		.io_in_vd((io_in_bits_ctrlPipe_1_vpu_isNarrow ? (narrowNeedCat ? {_vIntFixpAlus_1_io_narrowVd, _vIntFixpAlus_0_io_narrowVd, io_in_bits_dataPipe_1_src_2[63:0]} : {io_in_bits_dataPipe_1_src_2[127:64], _vIntFixpAlus_1_io_narrowVd, _vIntFixpAlus_0_io_narrowVd}) : (io_in_bits_ctrlPipe_1_vpu_isDstMask ? {112'h0000000000000000000000000000, ((_GEN_44 + 9'h00f) >= _GEN_45) | _outCmp_T_16[15], ((_GEN_44 + 9'h00e) >= _GEN_45) | _outCmp_T_16[14], ((_GEN_44 + 9'h00d) >= _GEN_45) | _outCmp_T_16[13], ((_GEN_44 + 9'h00c) >= _GEN_45) | _outCmp_T_16[12], ((_GEN_44 + 9'h00b) >= _GEN_45) | _outCmp_T_16[11], ((_GEN_44 + 9'h00a) >= _GEN_45) | _outCmp_T_16[10], ((_GEN_44 + 9'h009) >= _GEN_45) | _outCmp_T_16[9], ((_GEN_44 + 9'h008) >= _GEN_45) | _outCmp_T_16[8], ((_GEN_44 + 9'h007) >= _GEN_45) | _GEN_40[7], ((_GEN_44 + 9'h006) >= _GEN_45) | _GEN_40[6], ((_GEN_44 + 9'h005) >= _GEN_45) | _GEN_40[5], ((_GEN_44 + 9'h004) >= _GEN_45) | _GEN_40[4], ((_GEN_44 + 9'h003) >= _GEN_45) | _GEN_41[3], ((_GEN_44 + 9'h002) >= _GEN_45) | _GEN_41[2], ((_GEN_44 + 9'h001) >= _GEN_45) | _GEN_42[1], (elementsComputed >= io_in_bits_dataPipe_1_src_4) | _GEN_42[0]} : outVd))),
		.io_in_oldVd(io_in_bits_dataPipe_1_src_2),
		.io_in_mask((((((((io_in_bits_ctrlPipe_1_fuOpType == 9'h003) | (io_in_bits_ctrlPipe_1_fuOpType == 9'h104)) | (io_in_bits_ctrlPipe_1_fuOpType == 9'h084)) | (io_in_bits_ctrlPipe_1_fuOpType == 9'h005)) | (io_in_bits_ctrlPipe_1_fuOpType == 9'h106)) | (io_in_bits_ctrlPipe_1_fuOpType == 9'h086)) | (io_in_bits_ctrlPipe_1_fuOpType == 9'h019) ? 128'hffffffffffffffffffffffffffffffff : ((io_in_bits_ctrlPipe_1_fuOpType == 9'h084) | (io_in_bits_ctrlPipe_1_fuOpType == 9'h086) ? 128'h00000000000000000000000000000000 : (io_in_bits_ctrlPipe_1_vpu_vm ? 128'hffffffffffffffffffffffffffffffff : io_in_bits_dataPipe_1_src_3)))),
		.io_in_info_ta(io_in_bits_ctrlPipe_1_vpu_vta),
		.io_in_info_ma(io_in_bits_ctrlPipe_1_vpu_vma),
		.io_in_info_vl((io_in_bits_ctrlPipe_1_fuOpType[5:0] == 6'h2e ? 8'h01 : io_in_bits_dataPipe_1_src_4)),
		.io_in_info_vstart(io_in_bits_ctrlPipe_1_vpu_vstart),
		.io_in_info_eew(((((io_in_bits_ctrlPipe_1_fuOpType[8:7] == 2'h1) | (io_in_bits_ctrlPipe_1_fuOpType[8:7] == 2'h2)) & ~io_in_bits_ctrlPipe_1_vpu_isExt) & ~io_in_bits_ctrlPipe_1_vpu_isDstMask ? io_in_bits_ctrlPipe_1_vpu_vsew + 2'h1 : io_in_bits_ctrlPipe_1_vpu_vsew)),
		.io_in_info_vdIdx(io_in_bits_ctrlPipe_1_vpu_vuopIdx[2:0]),
		.io_in_info_narrow(io_in_bits_ctrlPipe_1_vpu_isNarrow),
		.io_in_info_dstMask(io_in_bits_ctrlPipe_1_vpu_isDstMask),
		.io_out_vd(_mgu_io_out_vd),
		.io_out_active(_mgu_io_out_active)
	);
	Mgtu mgtu(
		.io_in_vd((io_in_bits_ctrlPipe_1_vpu_isDstMask & ~io_in_bits_ctrlPipe_1_vpu_isOpMask ? _mgu_io_out_vd : outVd)),
		.io_in_vl(io_in_bits_dataPipe_1_src_4),
		.io_out_vd(_mgtu_io_out_vd)
	);
	assign io_out_valid = io_in_bits_validPipe_1 & validVecThisFu_1;
	assign io_out_bits_ctrl_robIdx_flag = io_in_bits_ctrlPipe_1_robIdx_flag;
	assign io_out_bits_ctrl_robIdx_value = io_in_bits_ctrlPipe_1_robIdx_value;
	assign io_out_bits_ctrl_pdest = io_in_bits_ctrlPipe_1_pdest;
	assign io_out_bits_ctrl_vecWen = io_in_bits_ctrlPipe_1_vecWen;
	assign io_out_bits_ctrl_v0Wen = io_in_bits_ctrlPipe_1_v0Wen;
	assign io_out_bits_res_data = (outVstartGeVl ? io_in_bits_dataPipe_1_src_2 : (io_in_bits_ctrlPipe_1_vpu_isDstMask ? _mgtu_io_out_vd : _mgu_io_out_vd));
	assign io_out_bits_res_vxsat = ~outVstartGeVl & |((narrowNeedCat ? {outVxsat[7:0], 8'h00} : outVxsat) & _mgu_io_out_active);
endmodule
module VIAluSrcTypeModule (
	io_in_fuOpType,
	io_in_vsew,
	io_in_isExt,
	io_in_isDstMask,
	io_out_vs1Type,
	io_out_vs2Type,
	io_out_vdType,
	io_out_isVextF2,
	io_out_isVextF4,
	io_out_isVextF8
);
	input [8:0] io_in_fuOpType;
	input [1:0] io_in_vsew;
	input io_in_isExt;
	input io_in_isDstMask;
	output wire [3:0] io_out_vs1Type;
	output wire [3:0] io_out_vs2Type;
	output wire [3:0] io_out_vdType;
	output wire io_out_isVextF2;
	output wire io_out_isVextF4;
	output wire io_out_isVextF8;
	wire [1:0] _vsewX2_T = io_in_vsew + 2'h1;
	wire isVext = io_in_fuOpType[5:0] == 6'h02;
	wire _vextSews_T = io_in_fuOpType[8:7] == 2'h0;
	wire _maskTypes_T = io_in_fuOpType[8:7] == 2'h1;
	wire _maskTypes_T_4 = io_in_fuOpType[8:7] == 2'h2;
	wire [5:0] _addSubSews_T_14 = (((_vextSews_T ? {3 {io_in_vsew}} : 6'h00) | (_maskTypes_T ? {{2 {io_in_vsew}}, _vsewX2_T} : 6'h00)) | (_maskTypes_T_4 ? {_vsewX2_T, io_in_vsew, _vsewX2_T} : 6'h00)) | (&io_in_fuOpType[8:7] ? {_vsewX2_T, {2 {io_in_vsew}}} : 6'h00);
	wire [5:0] _vextSews_T_10 = ((_vextSews_T ? {{2 {io_in_vsew - 2'h1}}, io_in_vsew} : 6'h00) | (_maskTypes_T ? {{2 {io_in_vsew - 2'h2}}, io_in_vsew} : 6'h00)) | (_maskTypes_T_4 ? {{2 {io_in_vsew + 2'h1}}, io_in_vsew} : 6'h00);
	wire [11:0] _maskTypes_T_14 = ((_maskTypes_T ? {1'h0, io_in_fuOpType[6], io_in_vsew, 1'h0, io_in_fuOpType[6], io_in_vsew, 4'hf} : 12'h000) | (_maskTypes_T_4 ? {1'h0, io_in_fuOpType[6], io_in_vsew, 1'h0, io_in_fuOpType[6], io_in_vsew, 4'hf} : 12'h000)) | {12 {&io_in_fuOpType[8:7]}};
	wire _GEN = io_in_isExt | io_in_isDstMask;
	assign io_out_vs1Type = ((io_in_isDstMask ? _maskTypes_T_14[7:4] : 4'h0) | (io_in_isExt ? {1'h0, io_in_fuOpType[6], _vextSews_T_10[3:2]} : 4'h0)) | (_GEN ? 4'h0 : {1'h0, io_in_fuOpType[6], _addSubSews_T_14[3:2]});
	assign io_out_vs2Type = ((io_in_isDstMask ? _maskTypes_T_14[11:8] : 4'h0) | (io_in_isExt ? {1'h0, io_in_fuOpType[6], _vextSews_T_10[5:4]} : 4'h0)) | (_GEN ? 4'h0 : {1'h0, io_in_fuOpType[6], _addSubSews_T_14[5:4]});
	assign io_out_vdType = ((io_in_isDstMask ? _maskTypes_T_14[3:0] : 4'h0) | (io_in_isExt ? {1'h0, io_in_fuOpType[6], _vextSews_T_10[1:0]} : 4'h0)) | (_GEN ? 4'h0 : {1'h0, io_in_fuOpType[6], _addSubSews_T_14[1:0]});
	assign io_out_isVextF2 = isVext & _vextSews_T;
	assign io_out_isVextF4 = isVext & _maskTypes_T;
	assign io_out_isVextF8 = isVext & _maskTypes_T_4;
endmodule
module VIntAdder64b (
	io_opcode_op,
	io_info_vm,
	io_info_ma,
	io_info_uopIdx,
	io_srcType_1,
	io_vdType,
	io_vs1,
	io_vs2,
	io_vmask,
	io_oldVd,
	io_isSub,
	io_widen,
	io_widen_vs2,
	io_vd,
	io_cmpOut,
	io_toFixP_cout_0,
	io_toFixP_cout_1,
	io_toFixP_cout_2,
	io_toFixP_cout_3,
	io_toFixP_cout_4,
	io_toFixP_cout_5,
	io_toFixP_cout_6,
	io_toFixP_cout_7,
	io_toFixP_vd_0,
	io_toFixP_vd_1,
	io_toFixP_vd_2,
	io_toFixP_vd_3,
	io_toFixP_vd_4,
	io_toFixP_vd_5,
	io_toFixP_vd_6,
	io_toFixP_vd_7,
	io_toFixP_vs2H_0,
	io_toFixP_vs2H_1,
	io_toFixP_vs2H_2,
	io_toFixP_vs2H_3,
	io_toFixP_vs2H_4,
	io_toFixP_vs2H_5,
	io_toFixP_vs2H_6,
	io_toFixP_vs2H_7,
	io_toFixP_vs1H_0,
	io_toFixP_vs1H_1,
	io_toFixP_vs1H_2,
	io_toFixP_vs1H_3,
	io_toFixP_vs1H_4,
	io_toFixP_vs1H_5,
	io_toFixP_vs1H_6,
	io_toFixP_vs1H_7
);
	input [5:0] io_opcode_op;
	input io_info_vm;
	input io_info_ma;
	input [5:0] io_info_uopIdx;
	input [3:0] io_srcType_1;
	input [3:0] io_vdType;
	input [63:0] io_vs1;
	input [63:0] io_vs2;
	input [7:0] io_vmask;
	input [7:0] io_oldVd;
	input io_isSub;
	input io_widen;
	input io_widen_vs2;
	output wire [63:0] io_vd;
	output wire [7:0] io_cmpOut;
	output wire io_toFixP_cout_0;
	output wire io_toFixP_cout_1;
	output wire io_toFixP_cout_2;
	output wire io_toFixP_cout_3;
	output wire io_toFixP_cout_4;
	output wire io_toFixP_cout_5;
	output wire io_toFixP_cout_6;
	output wire io_toFixP_cout_7;
	output wire [7:0] io_toFixP_vd_0;
	output wire [7:0] io_toFixP_vd_1;
	output wire [7:0] io_toFixP_vd_2;
	output wire [7:0] io_toFixP_vd_3;
	output wire [7:0] io_toFixP_vd_4;
	output wire [7:0] io_toFixP_vd_5;
	output wire [7:0] io_toFixP_vd_6;
	output wire [7:0] io_toFixP_vd_7;
	output wire io_toFixP_vs2H_0;
	output wire io_toFixP_vs2H_1;
	output wire io_toFixP_vs2H_2;
	output wire io_toFixP_vs2H_3;
	output wire io_toFixP_vs2H_4;
	output wire io_toFixP_vs2H_5;
	output wire io_toFixP_vs2H_6;
	output wire io_toFixP_vs2H_7;
	output wire io_toFixP_vs1H_0;
	output wire io_toFixP_vs1H_1;
	output wire io_toFixP_vs1H_2;
	output wire io_toFixP_vs1H_3;
	output wire io_toFixP_vs1H_4;
	output wire io_toFixP_vs1H_5;
	output wire io_toFixP_vs1H_6;
	output wire io_toFixP_vs1H_7;
	wire cin_7;
	wire cin_6;
	wire cin_5;
	wire cin_4;
	wire cin_3;
	wire cin_2;
	wire cin_1;
	wire carryIn_0;
	wire _eewVs1_sew_oneHot_T = io_srcType_1[1:0] == 2'h0;
	wire _eewVs1_sew_oneHot_T_1 = io_srcType_1[1:0] == 2'h1;
	wire _eewVs1_sew_oneHot_T_2 = io_srcType_1[1:0] == 2'h2;
	wire _eewVd_sew_oneHot_T = io_vdType[1:0] == 2'h0;
	wire signed_0 = io_srcType_1[3:2] == 2'h1;
	wire _cmpOut_T = io_opcode_op == 6'h06;
	wire addWithCarry = (((io_opcode_op == 6'h03) | (io_opcode_op == 6'h04)) | (io_opcode_op == 6'h05)) | _cmpOut_T;
	wire [31:0] vs2_32b = (io_info_uopIdx[0] ? io_vs2[63:32] : io_vs2[31:0]);
	wire [31:0] vs1_32b = (io_info_uopIdx[0] ? io_vs1[63:32] : io_vs1[31:0]);
	wire [63:0] vs2_adjust = (io_widen_vs2 ? ((_eewVs1_sew_oneHot_T ? {{8 {vs2_32b[31] & signed_0}}, vs2_32b[31:24], {8 {vs2_32b[23] & signed_0}}, vs2_32b[23:16], {8 {vs2_32b[15] & signed_0}}, vs2_32b[15:8], {8 {vs2_32b[7] & signed_0}}, vs2_32b[7:0]} : 64'h0000000000000000) | (_eewVs1_sew_oneHot_T_1 ? {{16 {vs2_32b[31] & signed_0}}, vs2_32b[31:16], {16 {vs2_32b[15] & signed_0}}, vs2_32b[15:0]} : 64'h0000000000000000)) | (_eewVs1_sew_oneHot_T_2 ? {{32 {vs2_32b[31] & signed_0}}, vs2_32b} : 64'h0000000000000000) : io_vs2);
	wire [63:0] vs1_adjust = (io_widen ? ((_eewVs1_sew_oneHot_T ? {{8 {vs1_32b[31] & signed_0}}, vs1_32b[31:24], {8 {vs1_32b[23] & signed_0}}, vs1_32b[23:16], {8 {vs1_32b[15] & signed_0}}, vs1_32b[15:8], {8 {vs1_32b[7] & signed_0}}, vs1_32b[7:0]} : 64'h0000000000000000) | (_eewVs1_sew_oneHot_T_1 ? {{16 {vs1_32b[31] & signed_0}}, vs1_32b[31:16], {16 {vs1_32b[15] & signed_0}}, vs1_32b[15:0]} : 64'h0000000000000000)) | (_eewVs1_sew_oneHot_T_2 ? {{32 {vs1_32b[31] & signed_0}}, vs1_32b} : 64'h0000000000000000) : io_vs1) ^ {64 {io_isSub}};
	wire [7:0] vmask_adjust = (_eewVs1_sew_oneHot_T_1 ? {1'h0, io_vmask[3], 1'h0, io_vmask[2], 1'h0, io_vmask[1], 1'h0, io_vmask[0]} : (_eewVs1_sew_oneHot_T_2 ? {3'h0, io_vmask[1], 3'h0, io_vmask[0]} : io_vmask));
	function automatic [9:0] sv2v_cast_10;
		input reg [9:0] inp;
		sv2v_cast_10 = inp;
	endfunction
	wire [9:0] _bits_T_2 = sv2v_cast_10({1'h0, vs1_adjust[7:0], carryIn_0} + {1'h0, vs2_adjust[7:0], carryIn_0});
	assign carryIn_0 = ((addWithCarry & ~io_info_vm) & vmask_adjust[0]) ^ io_isSub;
	wire _eewCin_oneHot_T_28 = io_opcode_op == 6'h00;
	wire _eewCin_oneHot_T_29 = io_opcode_op == 6'h01;
	wire [9:0] _bits_T_5 = sv2v_cast_10({1'h0, vs1_adjust[15:8], cin_1} + {1'h0, vs2_adjust[15:8], cin_1});
	assign cin_1 = ((_eewCin_oneHot_T_28 | _eewCin_oneHot_T_29 ? _eewVd_sew_oneHot_T : _eewVs1_sew_oneHot_T) ? ((addWithCarry & ~io_info_vm) & vmask_adjust[1]) ^ io_isSub : _bits_T_2[9]);
	wire [9:0] _bits_T_8 = sv2v_cast_10({1'h0, vs1_adjust[23:16], cin_2} + {1'h0, vs2_adjust[23:16], cin_2});
	wire [1:0] _GEN = {&io_vdType[1:0], io_vdType[1:0] == 2'h2};
	wire [1:0] _GEN_0 = {&io_srcType_1[1:0], _eewVs1_sew_oneHot_T_2};
	assign cin_2 = (|(_eewCin_oneHot_T_28 | _eewCin_oneHot_T_29 ? _GEN : _GEN_0) ? _bits_T_5[9] : ((addWithCarry & ~io_info_vm) & vmask_adjust[2]) ^ io_isSub);
	wire [9:0] _bits_T_11 = sv2v_cast_10({1'h0, vs1_adjust[31:24], cin_3} + {1'h0, vs2_adjust[31:24], cin_3});
	assign cin_3 = ((_eewCin_oneHot_T_28 | _eewCin_oneHot_T_29 ? _eewVd_sew_oneHot_T : _eewVs1_sew_oneHot_T) ? ((addWithCarry & ~io_info_vm) & vmask_adjust[3]) ^ io_isSub : _bits_T_8[9]);
	wire [9:0] _bits_T_14 = sv2v_cast_10({1'h0, vs1_adjust[39:32], cin_4} + {1'h0, vs2_adjust[39:32], cin_4});
	assign cin_4 = ((_eewCin_oneHot_T_28 | _eewCin_oneHot_T_29 ? &io_vdType[1:0] : &io_srcType_1[1:0]) ? _bits_T_11[9] : ((addWithCarry & ~io_info_vm) & vmask_adjust[4]) ^ io_isSub);
	wire [9:0] _bits_T_17 = sv2v_cast_10({1'h0, vs1_adjust[47:40], cin_5} + {1'h0, vs2_adjust[47:40], cin_5});
	assign cin_5 = ((_eewCin_oneHot_T_28 | _eewCin_oneHot_T_29 ? _eewVd_sew_oneHot_T : _eewVs1_sew_oneHot_T) ? ((addWithCarry & ~io_info_vm) & vmask_adjust[5]) ^ io_isSub : _bits_T_14[9]);
	wire [9:0] _bits_T_20 = sv2v_cast_10({1'h0, vs1_adjust[55:48], cin_6} + {1'h0, vs2_adjust[55:48], cin_6});
	assign cin_6 = (|(_eewCin_oneHot_T_28 | _eewCin_oneHot_T_29 ? _GEN : _GEN_0) ? _bits_T_17[9] : ((addWithCarry & ~io_info_vm) & vmask_adjust[6]) ^ io_isSub);
	wire [9:0] _bits_T_23 = sv2v_cast_10({1'h0, vs1_adjust[63:56], cin_7} + {1'h0, vs2_adjust[63:56], cin_7});
	assign cin_7 = ((_eewCin_oneHot_T_28 | _eewCin_oneHot_T_29 ? _eewVd_sew_oneHot_T : _eewVs1_sew_oneHot_T) ? ((addWithCarry & ~io_info_vm) & vmask_adjust[7]) ^ io_isSub : _bits_T_20[9]);
	wire lessThan_vec_0 = (signed_0 ? (io_vs2[7] ^ vs1_adjust[7]) ^ _bits_T_2[9] : ~_bits_T_2[9]);
	wire equal_vec_0 = io_vs2[7:0] == io_vs1[7:0];
	wire lessThan_vec_1 = (signed_0 ? (io_vs2[15] ^ vs1_adjust[15]) ^ _bits_T_5[9] : ~_bits_T_5[9]);
	wire equal_vec_1 = io_vs2[15:8] == io_vs1[15:8];
	wire lessThan_vec_2 = (signed_0 ? (io_vs2[23] ^ vs1_adjust[23]) ^ _bits_T_8[9] : ~_bits_T_8[9]);
	wire equal_vec_2 = io_vs2[23:16] == io_vs1[23:16];
	wire lessThan_vec_3 = (signed_0 ? (io_vs2[31] ^ vs1_adjust[31]) ^ _bits_T_11[9] : ~_bits_T_11[9]);
	wire equal_vec_3 = io_vs2[31:24] == io_vs1[31:24];
	wire lessThan_vec_4 = (signed_0 ? (io_vs2[39] ^ vs1_adjust[39]) ^ _bits_T_14[9] : ~_bits_T_14[9]);
	wire equal_vec_4 = io_vs2[39:32] == io_vs1[39:32];
	wire lessThan_vec_5 = (signed_0 ? (io_vs2[47] ^ vs1_adjust[47]) ^ _bits_T_17[9] : ~_bits_T_17[9]);
	wire equal_vec_5 = io_vs2[47:40] == io_vs1[47:40];
	wire lessThan_vec_6 = (signed_0 ? (io_vs2[55] ^ vs1_adjust[55]) ^ _bits_T_20[9] : ~_bits_T_20[9]);
	wire equal_vec_6 = io_vs2[55:48] == io_vs1[55:48];
	wire lessThan_vec_7 = (signed_0 ? (io_vs2[63] ^ vs1_adjust[63]) ^ _bits_T_23[9] : ~_bits_T_23[9]);
	wire equal_vec_7 = io_vs2[63:56] == io_vs1[63:56];
	wire [7:0] equal = {equal_vec_7, equal_vec_6, equal_vec_5, equal_vec_4, equal_vec_3, equal_vec_2, equal_vec_1, equal_vec_0};
	wire [7:0] cmpEq = (((_eewVs1_sew_oneHot_T ? equal : 8'h00) | (_eewVs1_sew_oneHot_T_1 ? {{2 {&{equal_vec_7, equal_vec_6}}}, {2 {&{equal_vec_5, equal_vec_4}}}, {2 {&{equal_vec_3, equal_vec_2}}}, {2 {&{equal_vec_1, equal_vec_0}}}} : 8'h00)) | (_eewVs1_sew_oneHot_T_2 ? {{4 {&{equal_vec_7, equal_vec_6, equal_vec_5, equal_vec_4}}}, {4 {&{equal_vec_3, equal_vec_2, equal_vec_1, equal_vec_0}}}} : 8'h00)) | {8 {&io_srcType_1[1:0] & (&equal)}};
	wire [7:0] lessThan = {lessThan_vec_7, lessThan_vec_6, lessThan_vec_5, lessThan_vec_4, lessThan_vec_3, lessThan_vec_2, lessThan_vec_1, lessThan_vec_0};
	wire [7:0] _cmpResult_T_6 = lessThan | cmpEq;
	wire _io_vd_T_1 = io_opcode_op == 6'h18;
	wire selectVs1_1 = lessThan_vec_1 == _io_vd_T_1;
	wire selectVs1_3 = lessThan_vec_3 == _io_vd_T_1;
	wire selectVs1_5 = lessThan_vec_5 == _io_vd_T_1;
	wire selectVs1_7 = lessThan_vec_7 == _io_vd_T_1;
	wire [7:0] cmpOut = (addWithCarry ? (_cmpOut_T ? ~{_bits_T_23[9], _bits_T_20[9], _bits_T_17[9], _bits_T_14[9], _bits_T_11[9], _bits_T_8[9], _bits_T_5[9], _bits_T_2[9]} : {_bits_T_23[9], _bits_T_20[9], _bits_T_17[9], _bits_T_14[9], _bits_T_11[9], _bits_T_8[9], _bits_T_5[9], _bits_T_2[9]}) : ((((io_opcode_op == 6'h12 ? cmpEq : 8'h00) | (io_opcode_op == 6'h13 ? ~cmpEq : 8'h00)) | (io_opcode_op == 6'h14 ? lessThan : 8'h00)) | (io_opcode_op == 6'h15 ? _cmpResult_T_6 : 8'h00)) | (io_opcode_op == 6'h16 ? ~_cmpResult_T_6 : 8'h00));
	wire [7:0] cmpOutAdjust = (((_eewVs1_sew_oneHot_T ? cmpOut : 8'h00) | (_eewVs1_sew_oneHot_T_1 ? {4'hf, cmpOut[7], cmpOut[5], cmpOut[3], cmpOut[1]} : 8'h00)) | (_eewVs1_sew_oneHot_T_2 ? {6'h3f, cmpOut[7], cmpOut[3]} : 8'h00)) | (&io_srcType_1[1:0] ? {7'h7f, cmpOut[7]} : 8'h00);
	assign io_vd = ((io_opcode_op == 6'h17) | _io_vd_T_1 ? {((((_eewVs1_sew_oneHot_T & selectVs1_7) | (_eewVs1_sew_oneHot_T_1 & selectVs1_7)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_7)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[63:56] : io_vs2[63:56]), ((((_eewVs1_sew_oneHot_T & (lessThan_vec_6 == _io_vd_T_1)) | (_eewVs1_sew_oneHot_T_1 & selectVs1_7)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_7)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[55:48] : io_vs2[55:48]), ((((_eewVs1_sew_oneHot_T & selectVs1_5) | (_eewVs1_sew_oneHot_T_1 & selectVs1_5)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_7)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[47:40] : io_vs2[47:40]), ((((_eewVs1_sew_oneHot_T & (lessThan_vec_4 == _io_vd_T_1)) | (_eewVs1_sew_oneHot_T_1 & selectVs1_5)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_7)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[39:32] : io_vs2[39:32]), ((((_eewVs1_sew_oneHot_T & selectVs1_3) | (_eewVs1_sew_oneHot_T_1 & selectVs1_3)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_3)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[31:24] : io_vs2[31:24]), ((((_eewVs1_sew_oneHot_T & (lessThan_vec_2 == _io_vd_T_1)) | (_eewVs1_sew_oneHot_T_1 & selectVs1_3)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_3)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[23:16] : io_vs2[23:16]), ((((_eewVs1_sew_oneHot_T & selectVs1_1) | (_eewVs1_sew_oneHot_T_1 & selectVs1_1)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_3)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[15:8] : io_vs2[15:8]), ((((_eewVs1_sew_oneHot_T & (lessThan_vec_0 == _io_vd_T_1)) | (_eewVs1_sew_oneHot_T_1 & selectVs1_1)) | (_eewVs1_sew_oneHot_T_2 & selectVs1_3)) | (&io_srcType_1[1:0] & selectVs1_7) ? io_vs1[7:0] : io_vs2[7:0])} : {_bits_T_23[8:1], _bits_T_20[8:1], _bits_T_17[8:1], _bits_T_14[8:1], _bits_T_11[8:1], _bits_T_8[8:1], _bits_T_5[8:1], _bits_T_2[8:1]});
	assign io_cmpOut = (addWithCarry ? cmpOutAdjust : {(io_info_vm | io_vmask[7] ? cmpOutAdjust[7] : io_info_ma | io_oldVd[7]), (io_info_vm | io_vmask[6] ? cmpOutAdjust[6] : io_info_ma | io_oldVd[6]), (io_info_vm | io_vmask[5] ? cmpOutAdjust[5] : io_info_ma | io_oldVd[5]), (io_info_vm | io_vmask[4] ? cmpOutAdjust[4] : io_info_ma | io_oldVd[4]), (io_info_vm | io_vmask[3] ? cmpOutAdjust[3] : io_info_ma | io_oldVd[3]), (io_info_vm | io_vmask[2] ? cmpOutAdjust[2] : io_info_ma | io_oldVd[2]), (io_info_vm | io_vmask[1] ? cmpOutAdjust[1] : io_info_ma | io_oldVd[1]), (io_info_vm | io_vmask[0] ? cmpOutAdjust[0] : io_info_ma | io_oldVd[0])});
	assign io_toFixP_cout_0 = _bits_T_2[9];
	assign io_toFixP_cout_1 = _bits_T_5[9];
	assign io_toFixP_cout_2 = _bits_T_8[9];
	assign io_toFixP_cout_3 = _bits_T_11[9];
	assign io_toFixP_cout_4 = _bits_T_14[9];
	assign io_toFixP_cout_5 = _bits_T_17[9];
	assign io_toFixP_cout_6 = _bits_T_20[9];
	assign io_toFixP_cout_7 = _bits_T_23[9];
	assign io_toFixP_vd_0 = _bits_T_2[8:1];
	assign io_toFixP_vd_1 = _bits_T_5[8:1];
	assign io_toFixP_vd_2 = _bits_T_8[8:1];
	assign io_toFixP_vd_3 = _bits_T_11[8:1];
	assign io_toFixP_vd_4 = _bits_T_14[8:1];
	assign io_toFixP_vd_5 = _bits_T_17[8:1];
	assign io_toFixP_vd_6 = _bits_T_20[8:1];
	assign io_toFixP_vd_7 = _bits_T_23[8:1];
	assign io_toFixP_vs2H_0 = io_vs2[7];
	assign io_toFixP_vs2H_1 = io_vs2[15];
	assign io_toFixP_vs2H_2 = io_vs2[23];
	assign io_toFixP_vs2H_3 = io_vs2[31];
	assign io_toFixP_vs2H_4 = io_vs2[39];
	assign io_toFixP_vs2H_5 = io_vs2[47];
	assign io_toFixP_vs2H_6 = io_vs2[55];
	assign io_toFixP_vs2H_7 = io_vs2[63];
	assign io_toFixP_vs1H_0 = io_vs1[7];
	assign io_toFixP_vs1H_1 = io_vs1[15];
	assign io_toFixP_vs1H_2 = io_vs1[23];
	assign io_toFixP_vs1H_3 = io_vs1[31];
	assign io_toFixP_vs1H_4 = io_vs1[39];
	assign io_toFixP_vs1H_5 = io_vs1[47];
	assign io_toFixP_vs1H_6 = io_vs1[55];
	assign io_toFixP_vs1H_7 = io_vs1[63];
endmodule
module VIntFixpAlu64b (
	clock,
	io_fire,
	io_opcode_op,
	io_info_vm,
	io_info_ma,
	io_info_uopIdx,
	io_info_vxrm,
	io_srcType_0,
	io_srcType_1,
	io_vdType,
	io_vs1,
	io_vs2_adder,
	io_vs2_misc,
	io_vmask,
	io_oldVd,
	io_narrow,
	io_isSub,
	io_isMisc,
	io_isFixp,
	io_widen,
	io_widen_vs2,
	io_vd,
	io_narrowVd,
	io_cmpOut,
	io_vxsat
);
	input clock;
	input io_fire;
	input [5:0] io_opcode_op;
	input io_info_vm;
	input io_info_ma;
	input [5:0] io_info_uopIdx;
	input [1:0] io_info_vxrm;
	input [3:0] io_srcType_0;
	input [3:0] io_srcType_1;
	input [3:0] io_vdType;
	input [63:0] io_vs1;
	input [63:0] io_vs2_adder;
	input [63:0] io_vs2_misc;
	input [7:0] io_vmask;
	input [7:0] io_oldVd;
	input [7:0] io_narrow;
	input io_isSub;
	input io_isMisc;
	input io_isFixp;
	input io_widen;
	input io_widen_vs2;
	output wire [63:0] io_vd;
	output wire [31:0] io_narrowVd;
	output wire [7:0] io_cmpOut;
	output wire [7:0] io_vxsat;
	wire [63:0] _vFixPoint64b_io_vd;
	wire [31:0] _vFixPoint64b_io_narrowVd;
	wire [63:0] _vIntMisc64b_io_vd;
	wire [31:0] _vIntMisc64b_io_narrowVd;
	wire [63:0] _vIntMisc64b_io_toFixP_shiftOut;
	wire [7:0] _vIntMisc64b_io_toFixP_rnd_high;
	wire [7:0] _vIntMisc64b_io_toFixP_rnd_tail;
	wire [63:0] _vIntAdder64b_io_vd;
	wire [7:0] _vIntAdder64b_io_cmpOut;
	wire _vIntAdder64b_io_toFixP_cout_0;
	wire _vIntAdder64b_io_toFixP_cout_1;
	wire _vIntAdder64b_io_toFixP_cout_2;
	wire _vIntAdder64b_io_toFixP_cout_3;
	wire _vIntAdder64b_io_toFixP_cout_4;
	wire _vIntAdder64b_io_toFixP_cout_5;
	wire _vIntAdder64b_io_toFixP_cout_6;
	wire _vIntAdder64b_io_toFixP_cout_7;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_0;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_1;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_2;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_3;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_4;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_5;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_6;
	wire [7:0] _vIntAdder64b_io_toFixP_vd_7;
	wire _vIntAdder64b_io_toFixP_vs2H_0;
	wire _vIntAdder64b_io_toFixP_vs2H_1;
	wire _vIntAdder64b_io_toFixP_vs2H_2;
	wire _vIntAdder64b_io_toFixP_vs2H_3;
	wire _vIntAdder64b_io_toFixP_vs2H_4;
	wire _vIntAdder64b_io_toFixP_vs2H_5;
	wire _vIntAdder64b_io_toFixP_vs2H_6;
	wire _vIntAdder64b_io_toFixP_vs2H_7;
	wire _vIntAdder64b_io_toFixP_vs1H_0;
	wire _vIntAdder64b_io_toFixP_vs1H_1;
	wire _vIntAdder64b_io_toFixP_vs1H_2;
	wire _vIntAdder64b_io_toFixP_vs1H_3;
	wire _vIntAdder64b_io_toFixP_vs1H_4;
	wire _vIntAdder64b_io_toFixP_vs1H_5;
	wire _vIntAdder64b_io_toFixP_vs1H_6;
	wire _vIntAdder64b_io_toFixP_vs1H_7;
	reg [63:0] vdAdderS1;
	reg [63:0] vdMiscS1;
	reg isMiscS1;
	reg [31:0] narrowVdMiscS1;
	reg [7:0] cmpOutS1;
	reg isFixpS1;
	reg [5:0] vFixPoint64b_io_opcode_r_op;
	reg [1:0] vFixPoint64b_io_info_r_vxrm;
	reg [3:0] vFixPoint64b_io_sew_r_oneHot;
	reg vFixPoint64b_io_isSub_r;
	reg vFixPoint64b_io_isSigned_r;
	reg vFixPoint64b_io_isNClip_r;
	reg vFixPoint64b_io_fromAdder_r_cout_0;
	reg vFixPoint64b_io_fromAdder_r_cout_1;
	reg vFixPoint64b_io_fromAdder_r_cout_2;
	reg vFixPoint64b_io_fromAdder_r_cout_3;
	reg vFixPoint64b_io_fromAdder_r_cout_4;
	reg vFixPoint64b_io_fromAdder_r_cout_5;
	reg vFixPoint64b_io_fromAdder_r_cout_6;
	reg vFixPoint64b_io_fromAdder_r_cout_7;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_0;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_1;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_2;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_3;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_4;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_5;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_6;
	reg [7:0] vFixPoint64b_io_fromAdder_r_vd_7;
	reg vFixPoint64b_io_fromAdder_r_vs2H_0;
	reg vFixPoint64b_io_fromAdder_r_vs2H_1;
	reg vFixPoint64b_io_fromAdder_r_vs2H_2;
	reg vFixPoint64b_io_fromAdder_r_vs2H_3;
	reg vFixPoint64b_io_fromAdder_r_vs2H_4;
	reg vFixPoint64b_io_fromAdder_r_vs2H_5;
	reg vFixPoint64b_io_fromAdder_r_vs2H_6;
	reg vFixPoint64b_io_fromAdder_r_vs2H_7;
	reg vFixPoint64b_io_fromAdder_r_vs1H_0;
	reg vFixPoint64b_io_fromAdder_r_vs1H_1;
	reg vFixPoint64b_io_fromAdder_r_vs1H_2;
	reg vFixPoint64b_io_fromAdder_r_vs1H_3;
	reg vFixPoint64b_io_fromAdder_r_vs1H_4;
	reg vFixPoint64b_io_fromAdder_r_vs1H_5;
	reg vFixPoint64b_io_fromAdder_r_vs1H_6;
	reg vFixPoint64b_io_fromAdder_r_vs1H_7;
	reg [63:0] vFixPoint64b_io_fromMisc_r_shiftOut;
	reg [7:0] vFixPoint64b_io_fromMisc_r_rnd_high;
	reg [7:0] vFixPoint64b_io_fromMisc_r_rnd_tail;
	always @(posedge clock)
		if (io_fire) begin
			vdAdderS1 <= _vIntAdder64b_io_vd;
			vdMiscS1 <= _vIntMisc64b_io_vd;
			isMiscS1 <= io_isMisc;
			narrowVdMiscS1 <= _vIntMisc64b_io_narrowVd;
			cmpOutS1 <= _vIntAdder64b_io_cmpOut;
			isFixpS1 <= io_isFixp;
			vFixPoint64b_io_opcode_r_op <= io_opcode_op;
			vFixPoint64b_io_info_r_vxrm <= io_info_vxrm;
			vFixPoint64b_io_sew_r_oneHot <= {&io_vdType[1:0], io_vdType[1:0] == 2'h2, io_vdType[1:0] == 2'h1, io_vdType[1:0] == 2'h0};
			vFixPoint64b_io_isSub_r <= io_isSub;
			vFixPoint64b_io_isSigned_r <= io_srcType_0[3:2] == 2'h1;
			vFixPoint64b_io_isNClip_r <= ((io_opcode_op == 6'h1f) | (io_opcode_op == 6'h20)) & (io_vdType[1:0] != io_srcType_0[1:0]);
			vFixPoint64b_io_fromAdder_r_cout_0 <= _vIntAdder64b_io_toFixP_cout_0;
			vFixPoint64b_io_fromAdder_r_cout_1 <= _vIntAdder64b_io_toFixP_cout_1;
			vFixPoint64b_io_fromAdder_r_cout_2 <= _vIntAdder64b_io_toFixP_cout_2;
			vFixPoint64b_io_fromAdder_r_cout_3 <= _vIntAdder64b_io_toFixP_cout_3;
			vFixPoint64b_io_fromAdder_r_cout_4 <= _vIntAdder64b_io_toFixP_cout_4;
			vFixPoint64b_io_fromAdder_r_cout_5 <= _vIntAdder64b_io_toFixP_cout_5;
			vFixPoint64b_io_fromAdder_r_cout_6 <= _vIntAdder64b_io_toFixP_cout_6;
			vFixPoint64b_io_fromAdder_r_cout_7 <= _vIntAdder64b_io_toFixP_cout_7;
			vFixPoint64b_io_fromAdder_r_vd_0 <= _vIntAdder64b_io_toFixP_vd_0;
			vFixPoint64b_io_fromAdder_r_vd_1 <= _vIntAdder64b_io_toFixP_vd_1;
			vFixPoint64b_io_fromAdder_r_vd_2 <= _vIntAdder64b_io_toFixP_vd_2;
			vFixPoint64b_io_fromAdder_r_vd_3 <= _vIntAdder64b_io_toFixP_vd_3;
			vFixPoint64b_io_fromAdder_r_vd_4 <= _vIntAdder64b_io_toFixP_vd_4;
			vFixPoint64b_io_fromAdder_r_vd_5 <= _vIntAdder64b_io_toFixP_vd_5;
			vFixPoint64b_io_fromAdder_r_vd_6 <= _vIntAdder64b_io_toFixP_vd_6;
			vFixPoint64b_io_fromAdder_r_vd_7 <= _vIntAdder64b_io_toFixP_vd_7;
			vFixPoint64b_io_fromAdder_r_vs2H_0 <= _vIntAdder64b_io_toFixP_vs2H_0;
			vFixPoint64b_io_fromAdder_r_vs2H_1 <= _vIntAdder64b_io_toFixP_vs2H_1;
			vFixPoint64b_io_fromAdder_r_vs2H_2 <= _vIntAdder64b_io_toFixP_vs2H_2;
			vFixPoint64b_io_fromAdder_r_vs2H_3 <= _vIntAdder64b_io_toFixP_vs2H_3;
			vFixPoint64b_io_fromAdder_r_vs2H_4 <= _vIntAdder64b_io_toFixP_vs2H_4;
			vFixPoint64b_io_fromAdder_r_vs2H_5 <= _vIntAdder64b_io_toFixP_vs2H_5;
			vFixPoint64b_io_fromAdder_r_vs2H_6 <= _vIntAdder64b_io_toFixP_vs2H_6;
			vFixPoint64b_io_fromAdder_r_vs2H_7 <= _vIntAdder64b_io_toFixP_vs2H_7;
			vFixPoint64b_io_fromAdder_r_vs1H_0 <= _vIntAdder64b_io_toFixP_vs1H_0;
			vFixPoint64b_io_fromAdder_r_vs1H_1 <= _vIntAdder64b_io_toFixP_vs1H_1;
			vFixPoint64b_io_fromAdder_r_vs1H_2 <= _vIntAdder64b_io_toFixP_vs1H_2;
			vFixPoint64b_io_fromAdder_r_vs1H_3 <= _vIntAdder64b_io_toFixP_vs1H_3;
			vFixPoint64b_io_fromAdder_r_vs1H_4 <= _vIntAdder64b_io_toFixP_vs1H_4;
			vFixPoint64b_io_fromAdder_r_vs1H_5 <= _vIntAdder64b_io_toFixP_vs1H_5;
			vFixPoint64b_io_fromAdder_r_vs1H_6 <= _vIntAdder64b_io_toFixP_vs1H_6;
			vFixPoint64b_io_fromAdder_r_vs1H_7 <= _vIntAdder64b_io_toFixP_vs1H_7;
			vFixPoint64b_io_fromMisc_r_shiftOut <= _vIntMisc64b_io_toFixP_shiftOut;
			vFixPoint64b_io_fromMisc_r_rnd_high <= _vIntMisc64b_io_toFixP_rnd_high;
			vFixPoint64b_io_fromMisc_r_rnd_tail <= _vIntMisc64b_io_toFixP_rnd_tail;
		end
	VIntAdder64b vIntAdder64b(
		.io_opcode_op(io_opcode_op),
		.io_info_vm(io_info_vm),
		.io_info_ma(io_info_ma),
		.io_info_uopIdx(io_info_uopIdx),
		.io_srcType_1(io_srcType_1),
		.io_vdType(io_vdType),
		.io_vs1(io_vs1),
		.io_vs2(io_vs2_adder),
		.io_vmask(io_vmask),
		.io_oldVd(io_oldVd),
		.io_isSub(io_isSub),
		.io_widen(io_widen),
		.io_widen_vs2(io_widen_vs2),
		.io_vd(_vIntAdder64b_io_vd),
		.io_cmpOut(_vIntAdder64b_io_cmpOut),
		.io_toFixP_cout_0(_vIntAdder64b_io_toFixP_cout_0),
		.io_toFixP_cout_1(_vIntAdder64b_io_toFixP_cout_1),
		.io_toFixP_cout_2(_vIntAdder64b_io_toFixP_cout_2),
		.io_toFixP_cout_3(_vIntAdder64b_io_toFixP_cout_3),
		.io_toFixP_cout_4(_vIntAdder64b_io_toFixP_cout_4),
		.io_toFixP_cout_5(_vIntAdder64b_io_toFixP_cout_5),
		.io_toFixP_cout_6(_vIntAdder64b_io_toFixP_cout_6),
		.io_toFixP_cout_7(_vIntAdder64b_io_toFixP_cout_7),
		.io_toFixP_vd_0(_vIntAdder64b_io_toFixP_vd_0),
		.io_toFixP_vd_1(_vIntAdder64b_io_toFixP_vd_1),
		.io_toFixP_vd_2(_vIntAdder64b_io_toFixP_vd_2),
		.io_toFixP_vd_3(_vIntAdder64b_io_toFixP_vd_3),
		.io_toFixP_vd_4(_vIntAdder64b_io_toFixP_vd_4),
		.io_toFixP_vd_5(_vIntAdder64b_io_toFixP_vd_5),
		.io_toFixP_vd_6(_vIntAdder64b_io_toFixP_vd_6),
		.io_toFixP_vd_7(_vIntAdder64b_io_toFixP_vd_7),
		.io_toFixP_vs2H_0(_vIntAdder64b_io_toFixP_vs2H_0),
		.io_toFixP_vs2H_1(_vIntAdder64b_io_toFixP_vs2H_1),
		.io_toFixP_vs2H_2(_vIntAdder64b_io_toFixP_vs2H_2),
		.io_toFixP_vs2H_3(_vIntAdder64b_io_toFixP_vs2H_3),
		.io_toFixP_vs2H_4(_vIntAdder64b_io_toFixP_vs2H_4),
		.io_toFixP_vs2H_5(_vIntAdder64b_io_toFixP_vs2H_5),
		.io_toFixP_vs2H_6(_vIntAdder64b_io_toFixP_vs2H_6),
		.io_toFixP_vs2H_7(_vIntAdder64b_io_toFixP_vs2H_7),
		.io_toFixP_vs1H_0(_vIntAdder64b_io_toFixP_vs1H_0),
		.io_toFixP_vs1H_1(_vIntAdder64b_io_toFixP_vs1H_1),
		.io_toFixP_vs1H_2(_vIntAdder64b_io_toFixP_vs1H_2),
		.io_toFixP_vs1H_3(_vIntAdder64b_io_toFixP_vs1H_3),
		.io_toFixP_vs1H_4(_vIntAdder64b_io_toFixP_vs1H_4),
		.io_toFixP_vs1H_5(_vIntAdder64b_io_toFixP_vs1H_5),
		.io_toFixP_vs1H_6(_vIntAdder64b_io_toFixP_vs1H_6),
		.io_toFixP_vs1H_7(_vIntAdder64b_io_toFixP_vs1H_7)
	);
	VIntMisc64b vIntMisc64b(
		.io_opcode_op(io_opcode_op),
		.io_info_vm(io_info_vm),
		.io_info_uopIdx(io_info_uopIdx),
		.io_srcType_0(io_srcType_0),
		.io_vdType(io_vdType),
		.io_vs1(io_vs1),
		.io_vs2(io_vs2_misc),
		.io_vmask(io_vmask),
		.io_narrow(io_narrow[0]),
		.io_vd(_vIntMisc64b_io_vd),
		.io_narrowVd(_vIntMisc64b_io_narrowVd),
		.io_toFixP_shiftOut(_vIntMisc64b_io_toFixP_shiftOut),
		.io_toFixP_rnd_high(_vIntMisc64b_io_toFixP_rnd_high),
		.io_toFixP_rnd_tail(_vIntMisc64b_io_toFixP_rnd_tail)
	);
	VFixPoint64b vFixPoint64b(
		.io_opcode_op(vFixPoint64b_io_opcode_r_op),
		.io_info_vxrm(vFixPoint64b_io_info_r_vxrm),
		.io_sew_oneHot(vFixPoint64b_io_sew_r_oneHot),
		.io_isSub(vFixPoint64b_io_isSub_r),
		.io_isSigned(vFixPoint64b_io_isSigned_r),
		.io_isNClip(vFixPoint64b_io_isNClip_r),
		.io_fromAdder_cout_0(vFixPoint64b_io_fromAdder_r_cout_0),
		.io_fromAdder_cout_1(vFixPoint64b_io_fromAdder_r_cout_1),
		.io_fromAdder_cout_2(vFixPoint64b_io_fromAdder_r_cout_2),
		.io_fromAdder_cout_3(vFixPoint64b_io_fromAdder_r_cout_3),
		.io_fromAdder_cout_4(vFixPoint64b_io_fromAdder_r_cout_4),
		.io_fromAdder_cout_5(vFixPoint64b_io_fromAdder_r_cout_5),
		.io_fromAdder_cout_6(vFixPoint64b_io_fromAdder_r_cout_6),
		.io_fromAdder_cout_7(vFixPoint64b_io_fromAdder_r_cout_7),
		.io_fromAdder_vd_0(vFixPoint64b_io_fromAdder_r_vd_0),
		.io_fromAdder_vd_1(vFixPoint64b_io_fromAdder_r_vd_1),
		.io_fromAdder_vd_2(vFixPoint64b_io_fromAdder_r_vd_2),
		.io_fromAdder_vd_3(vFixPoint64b_io_fromAdder_r_vd_3),
		.io_fromAdder_vd_4(vFixPoint64b_io_fromAdder_r_vd_4),
		.io_fromAdder_vd_5(vFixPoint64b_io_fromAdder_r_vd_5),
		.io_fromAdder_vd_6(vFixPoint64b_io_fromAdder_r_vd_6),
		.io_fromAdder_vd_7(vFixPoint64b_io_fromAdder_r_vd_7),
		.io_fromAdder_vs2H_0(vFixPoint64b_io_fromAdder_r_vs2H_0),
		.io_fromAdder_vs2H_1(vFixPoint64b_io_fromAdder_r_vs2H_1),
		.io_fromAdder_vs2H_2(vFixPoint64b_io_fromAdder_r_vs2H_2),
		.io_fromAdder_vs2H_3(vFixPoint64b_io_fromAdder_r_vs2H_3),
		.io_fromAdder_vs2H_4(vFixPoint64b_io_fromAdder_r_vs2H_4),
		.io_fromAdder_vs2H_5(vFixPoint64b_io_fromAdder_r_vs2H_5),
		.io_fromAdder_vs2H_6(vFixPoint64b_io_fromAdder_r_vs2H_6),
		.io_fromAdder_vs2H_7(vFixPoint64b_io_fromAdder_r_vs2H_7),
		.io_fromAdder_vs1H_0(vFixPoint64b_io_fromAdder_r_vs1H_0),
		.io_fromAdder_vs1H_1(vFixPoint64b_io_fromAdder_r_vs1H_1),
		.io_fromAdder_vs1H_2(vFixPoint64b_io_fromAdder_r_vs1H_2),
		.io_fromAdder_vs1H_3(vFixPoint64b_io_fromAdder_r_vs1H_3),
		.io_fromAdder_vs1H_4(vFixPoint64b_io_fromAdder_r_vs1H_4),
		.io_fromAdder_vs1H_5(vFixPoint64b_io_fromAdder_r_vs1H_5),
		.io_fromAdder_vs1H_6(vFixPoint64b_io_fromAdder_r_vs1H_6),
		.io_fromAdder_vs1H_7(vFixPoint64b_io_fromAdder_r_vs1H_7),
		.io_fromMisc_shiftOut(vFixPoint64b_io_fromMisc_r_shiftOut),
		.io_fromMisc_rnd_high(vFixPoint64b_io_fromMisc_r_rnd_high),
		.io_fromMisc_rnd_tail(vFixPoint64b_io_fromMisc_r_rnd_tail),
		.io_vd(_vFixPoint64b_io_vd),
		.io_narrowVd(_vFixPoint64b_io_narrowVd),
		.io_vxsat(io_vxsat)
	);
	assign io_vd = (isFixpS1 ? _vFixPoint64b_io_vd : (isMiscS1 ? vdMiscS1 : vdAdderS1));
	assign io_narrowVd = (isFixpS1 ? _vFixPoint64b_io_narrowVd : narrowVdMiscS1);
	assign io_cmpOut = cmpOutS1;
endmodule
module VIntMisc64b (
	io_opcode_op,
	io_info_vm,
	io_info_uopIdx,
	io_srcType_0,
	io_vdType,
	io_vs1,
	io_vs2,
	io_vmask,
	io_narrow,
	io_vd,
	io_narrowVd,
	io_toFixP_shiftOut,
	io_toFixP_rnd_high,
	io_toFixP_rnd_tail
);
	input [5:0] io_opcode_op;
	input io_info_vm;
	input [5:0] io_info_uopIdx;
	input [3:0] io_srcType_0;
	input [3:0] io_vdType;
	input [63:0] io_vs1;
	input [63:0] io_vs2;
	input [7:0] io_vmask;
	input io_narrow;
	output wire [63:0] io_vd;
	output wire [31:0] io_narrowVd;
	output wire [63:0] io_toFixP_shiftOut;
	output wire [7:0] io_toFixP_rnd_high;
	output wire [7:0] io_toFixP_rnd_tail;
	wire [3:0] _cnt8_3_clz_io_out;
	wire [3:0] _cnt8_2_clz_io_out;
	wire [3:0] _cnt8_1_clz_io_out;
	wire [3:0] _cnt8_0_clz_io_out;
	wire [6:0] _cnt64_tmp_clz_io_out;
	wire [5:0] _cnt32_tmp_clz_io_out;
	wire [4:0] _cnt16_1_tmp_clz_io_out;
	wire [4:0] _cnt16_0_tmp_clz_io_out;
	wire _eewVd_sew_oneHot_T = io_vdType[1:0] == 2'h0;
	wire _eewVd_sew_oneHot_T_1 = io_vdType[1:0] == 2'h1;
	wire _eewVd_sew_oneHot_T_2 = io_vdType[1:0] == 2'h2;
	wire signed_0 = io_srcType_0[3:2] == 2'h1;
	wire [1:0] _vd_sub_srcType_T_2 = io_vdType[1:0] - io_srcType_0[1:0];
	wire expdIdxOH_vf4_0 = io_info_uopIdx[1:0] == 2'h0;
	wire expdIdxOH_vf4_1 = io_info_uopIdx[1:0] == 2'h1;
	wire expdIdxOH_vf4_2 = io_info_uopIdx[1:0] == 2'h2;
	wire [31:0] _extResult_T_5 = (io_info_uopIdx[0] ? 32'h00000000 : io_vs2[31:0]) | (io_info_uopIdx[0] ? io_vs2[63:32] : 32'h00000000);
	wire [31:0] _extResult_T_32 = (io_info_uopIdx[0] ? 32'h00000000 : io_vs2[31:0]) | (io_info_uopIdx[0] ? io_vs2[63:32] : 32'h00000000);
	wire [31:0] _extResult_T_48 = (io_info_uopIdx[0] ? 32'h00000000 : io_vs2[31:0]) | (io_info_uopIdx[0] ? io_vs2[63:32] : 32'h00000000);
	wire [15:0] _extResult_T_67 = (((expdIdxOH_vf4_0 ? io_vs2[15:0] : 16'h0000) | (expdIdxOH_vf4_1 ? io_vs2[31:16] : 16'h0000)) | (expdIdxOH_vf4_2 ? io_vs2[47:32] : 16'h0000)) | (&io_info_uopIdx[1:0] ? io_vs2[63:48] : 16'h0000);
	wire [15:0] _extResult_T_89 = (((expdIdxOH_vf4_0 ? io_vs2[15:0] : 16'h0000) | (expdIdxOH_vf4_1 ? io_vs2[31:16] : 16'h0000)) | (expdIdxOH_vf4_2 ? io_vs2[47:32] : 16'h0000)) | (&io_info_uopIdx[1:0] ? io_vs2[63:48] : 16'h0000);
	wire [7:0] _extResult_T_118 = (((((((io_info_uopIdx[2:0] == 3'h0 ? io_vs2[7:0] : 8'h00) | (io_info_uopIdx[2:0] == 3'h1 ? io_vs2[15:8] : 8'h00)) | (io_info_uopIdx[2:0] == 3'h2 ? io_vs2[23:16] : 8'h00)) | (io_info_uopIdx[2:0] == 3'h3 ? io_vs2[31:24] : 8'h00)) | (io_info_uopIdx[2:0] == 3'h4 ? io_vs2[39:32] : 8'h00)) | (io_info_uopIdx[2:0] == 3'h5 ? io_vs2[47:40] : 8'h00)) | (io_info_uopIdx[2:0] == 3'h6 ? io_vs2[55:48] : 8'h00)) | (&io_info_uopIdx[2:0] ? io_vs2[63:56] : 8'h00);
	wire _io_vd_T_10 = io_opcode_op == 6'h07;
	wire [63:0] _bitLogical_T_3 = io_vs2 & io_vs1;
	wire _io_vd_T_11 = io_opcode_op == 6'h08;
	wire _io_vd_T_13 = io_opcode_op == 6'h09;
	wire _io_vd_T_15 = io_opcode_op == 6'h0a;
	wire [63:0] _bitLogical_T_19 = io_vs2 ^ io_vs1;
	wire _io_vd_T_17 = io_opcode_op == 6'h0b;
	wire [63:0] _bitLogical_T_13 = io_vs2 | io_vs1;
	wire _io_vd_T_19 = io_opcode_op == 6'h0c;
	wire _io_vd_T_21 = io_opcode_op == 6'h0d;
	wire _io_vd_T_23 = io_opcode_op == 6'h0e;
	wire _io_vd_T_5 = io_opcode_op == 6'h11;
	wire _io_vd_T_6 = io_opcode_op == 6'h20;
	wire signed_shift = _io_vd_T_5 | _io_vd_T_6;
	wire leftShift = io_opcode_op == 6'h0f;
	wire [63:0] vs2_adjust = (leftShift ? {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]} : io_vs2);
	wire [63:0] vs1_revsByElem = (leftShift & _eewVd_sew_oneHot_T_2 ? {io_vs1[31:0], io_vs1[63:32]} : (leftShift & _eewVd_sew_oneHot_T_1 ? {io_vs1[15:0], io_vs1[31:16], io_vs1[47:32], io_vs1[63:48]} : (leftShift & _eewVd_sew_oneHot_T ? {io_vs1[7:0], io_vs1[15:8], io_vs1[23:16], io_vs1[31:24], io_vs1[39:32], io_vs1[47:40], io_vs1[55:48], io_vs1[63:56]} : io_vs1)));
	wire [58:0] vs1_adjust = (io_narrow & ~io_info_uopIdx[0] ? {3'h0, vs1_revsByElem[31:24], 8'h00, vs1_revsByElem[23:16], 8'h00, vs1_revsByElem[15:8], 8'h00, vs1_revsByElem[7:0]} : (io_narrow & io_info_uopIdx[0] ? {3'h0, vs1_revsByElem[63:56], 8'h00, vs1_revsByElem[55:48], 8'h00, vs1_revsByElem[47:40], 8'h00, vs1_revsByElem[39:32]} : vs1_revsByElem[58:0]));
	wire [63:0] data_update = (vs1_adjust[0] ? {vs2_adjust[63] & signed_shift, vs2_adjust[63:1]} : vs2_adjust);
	wire rnd_high_update = vs1_adjust[0] & vs2_adjust[0];
	wire [63:0] data_update_1 = (vs1_adjust[1] ? {{2 {data_update[63] & signed_shift}}, data_update[63:2]} : data_update);
	wire rnd_high_update_1 = (vs1_adjust[1] ? data_update[1] : rnd_high_update);
	wire [63:0] data_update_2 = (vs1_adjust[2] ? {{4 {data_update_1[63] & signed_shift}}, data_update_1[63:4]} : data_update_1);
	wire rnd_high_update_2 = (vs1_adjust[2] ? data_update_1[3] : rnd_high_update_1);
	wire [63:0] data_update_3 = (vs1_adjust[3] ? {{8 {data_update_2[63] & signed_shift}}, data_update_2[63:8]} : data_update_2);
	wire rnd_high_update_3 = (vs1_adjust[3] ? data_update_2[7] : rnd_high_update_2);
	wire [63:0] data_update_4 = (vs1_adjust[4] ? {{16 {data_update_3[63] & signed_shift}}, data_update_3[63:16]} : data_update_3);
	wire rnd_high_update_4 = (vs1_adjust[4] ? data_update_3[15] : rnd_high_update_3);
	wire [31:0] data_update_5 = (vs1_adjust[0] ? {vs2_adjust[31] & signed_shift, vs2_adjust[31:1]} : vs2_adjust[31:0]);
	wire rnd_high_update_5 = vs1_adjust[0] & vs2_adjust[0];
	wire [31:0] data_update_6 = (vs1_adjust[1] ? {{2 {data_update_5[31] & signed_shift}}, data_update_5[31:2]} : data_update_5);
	wire rnd_high_update_6 = (vs1_adjust[1] ? data_update_5[1] : rnd_high_update_5);
	wire [31:0] data_update_7 = (vs1_adjust[2] ? {{4 {data_update_6[31] & signed_shift}}, data_update_6[31:4]} : data_update_6);
	wire rnd_high_update_7 = (vs1_adjust[2] ? data_update_6[3] : rnd_high_update_6);
	wire [31:0] data_update_8 = (vs1_adjust[3] ? {{8 {data_update_7[31] & signed_shift}}, data_update_7[31:8]} : data_update_7);
	wire rnd_high_update_8 = (vs1_adjust[3] ? data_update_7[7] : rnd_high_update_7);
	wire [31:0] data_update_9 = (vs1_adjust[32] ? {vs2_adjust[63] & signed_shift, vs2_adjust[63:33]} : vs2_adjust[63:32]);
	wire rnd_high_update_9 = vs1_adjust[32] & vs2_adjust[32];
	wire [31:0] data_update_10 = (vs1_adjust[33] ? {{2 {data_update_9[31] & signed_shift}}, data_update_9[31:2]} : data_update_9);
	wire rnd_high_update_10 = (vs1_adjust[33] ? data_update_9[1] : rnd_high_update_9);
	wire [31:0] data_update_11 = (vs1_adjust[34] ? {{4 {data_update_10[31] & signed_shift}}, data_update_10[31:4]} : data_update_10);
	wire rnd_high_update_11 = (vs1_adjust[34] ? data_update_10[3] : rnd_high_update_10);
	wire [31:0] data_update_12 = (vs1_adjust[35] ? {{8 {data_update_11[31] & signed_shift}}, data_update_11[31:8]} : data_update_11);
	wire rnd_high_update_12 = (vs1_adjust[35] ? data_update_11[7] : rnd_high_update_11);
	wire [15:0] data_update_13 = (vs1_adjust[0] ? {vs2_adjust[15] & signed_shift, vs2_adjust[15:1]} : vs2_adjust[15:0]);
	wire rnd_high_update_13 = vs1_adjust[0] & vs2_adjust[0];
	wire [15:0] data_update_14 = (vs1_adjust[1] ? {{2 {data_update_13[15] & signed_shift}}, data_update_13[15:2]} : data_update_13);
	wire rnd_high_update_14 = (vs1_adjust[1] ? data_update_13[1] : rnd_high_update_13);
	wire [15:0] data_update_15 = (vs1_adjust[2] ? {{4 {data_update_14[15] & signed_shift}}, data_update_14[15:4]} : data_update_14);
	wire rnd_high_update_15 = (vs1_adjust[2] ? data_update_14[3] : rnd_high_update_14);
	wire [15:0] data_update_16 = (vs1_adjust[16] ? {vs2_adjust[31] & signed_shift, vs2_adjust[31:17]} : vs2_adjust[31:16]);
	wire rnd_high_update_16 = vs1_adjust[16] & vs2_adjust[16];
	wire [15:0] data_update_17 = (vs1_adjust[17] ? {{2 {data_update_16[15] & signed_shift}}, data_update_16[15:2]} : data_update_16);
	wire rnd_high_update_17 = (vs1_adjust[17] ? data_update_16[1] : rnd_high_update_16);
	wire [15:0] data_update_18 = (vs1_adjust[18] ? {{4 {data_update_17[15] & signed_shift}}, data_update_17[15:4]} : data_update_17);
	wire rnd_high_update_18 = (vs1_adjust[18] ? data_update_17[3] : rnd_high_update_17);
	wire [15:0] data_update_19 = (vs1_adjust[32] ? {vs2_adjust[47] & signed_shift, vs2_adjust[47:33]} : vs2_adjust[47:32]);
	wire rnd_high_update_19 = vs1_adjust[32] & vs2_adjust[32];
	wire [15:0] data_update_20 = (vs1_adjust[33] ? {{2 {data_update_19[15] & signed_shift}}, data_update_19[15:2]} : data_update_19);
	wire rnd_high_update_20 = (vs1_adjust[33] ? data_update_19[1] : rnd_high_update_19);
	wire [15:0] data_update_21 = (vs1_adjust[34] ? {{4 {data_update_20[15] & signed_shift}}, data_update_20[15:4]} : data_update_20);
	wire rnd_high_update_21 = (vs1_adjust[34] ? data_update_20[3] : rnd_high_update_20);
	wire [15:0] data_update_22 = (vs1_adjust[48] ? {vs2_adjust[63] & signed_shift, vs2_adjust[63:49]} : vs2_adjust[63:48]);
	wire rnd_high_update_22 = vs1_adjust[48] & vs2_adjust[48];
	wire [15:0] data_update_23 = (vs1_adjust[49] ? {{2 {data_update_22[15] & signed_shift}}, data_update_22[15:2]} : data_update_22);
	wire rnd_high_update_23 = (vs1_adjust[49] ? data_update_22[1] : rnd_high_update_22);
	wire [15:0] data_update_24 = (vs1_adjust[50] ? {{4 {data_update_23[15] & signed_shift}}, data_update_23[15:4]} : data_update_23);
	wire rnd_high_update_24 = (vs1_adjust[50] ? data_update_23[3] : rnd_high_update_23);
	wire [7:0] data_update_25 = (vs1_adjust[0] ? {vs2_adjust[7] & signed_shift, vs2_adjust[7:1]} : vs2_adjust[7:0]);
	wire rnd_high_update_25 = vs1_adjust[0] & vs2_adjust[0];
	wire [7:0] data_update_26 = (vs1_adjust[1] ? {{2 {data_update_25[7] & signed_shift}}, data_update_25[7:2]} : data_update_25);
	wire rnd_high_update_26 = (vs1_adjust[1] ? data_update_25[1] : rnd_high_update_25);
	wire [7:0] data_update_27 = (vs1_adjust[8] ? {vs2_adjust[15] & signed_shift, vs2_adjust[15:9]} : vs2_adjust[15:8]);
	wire rnd_high_update_27 = vs1_adjust[8] & vs2_adjust[8];
	wire [7:0] data_update_28 = (vs1_adjust[9] ? {{2 {data_update_27[7] & signed_shift}}, data_update_27[7:2]} : data_update_27);
	wire rnd_high_update_28 = (vs1_adjust[9] ? data_update_27[1] : rnd_high_update_27);
	wire [7:0] data_update_29 = (vs1_adjust[16] ? {vs2_adjust[23] & signed_shift, vs2_adjust[23:17]} : vs2_adjust[23:16]);
	wire rnd_high_update_29 = vs1_adjust[16] & vs2_adjust[16];
	wire [7:0] data_update_30 = (vs1_adjust[17] ? {{2 {data_update_29[7] & signed_shift}}, data_update_29[7:2]} : data_update_29);
	wire rnd_high_update_30 = (vs1_adjust[17] ? data_update_29[1] : rnd_high_update_29);
	wire [7:0] data_update_31 = (vs1_adjust[24] ? {vs2_adjust[31] & signed_shift, vs2_adjust[31:25]} : vs2_adjust[31:24]);
	wire rnd_high_update_31 = vs1_adjust[24] & vs2_adjust[24];
	wire [7:0] data_update_32 = (vs1_adjust[25] ? {{2 {data_update_31[7] & signed_shift}}, data_update_31[7:2]} : data_update_31);
	wire rnd_high_update_32 = (vs1_adjust[25] ? data_update_31[1] : rnd_high_update_31);
	wire [7:0] data_update_33 = (vs1_adjust[32] ? {vs2_adjust[39] & signed_shift, vs2_adjust[39:33]} : vs2_adjust[39:32]);
	wire rnd_high_update_33 = vs1_adjust[32] & vs2_adjust[32];
	wire [7:0] data_update_34 = (vs1_adjust[33] ? {{2 {data_update_33[7] & signed_shift}}, data_update_33[7:2]} : data_update_33);
	wire rnd_high_update_34 = (vs1_adjust[33] ? data_update_33[1] : rnd_high_update_33);
	wire [7:0] data_update_35 = (vs1_adjust[40] ? {vs2_adjust[47] & signed_shift, vs2_adjust[47:41]} : vs2_adjust[47:40]);
	wire rnd_high_update_35 = vs1_adjust[40] & vs2_adjust[40];
	wire [7:0] data_update_36 = (vs1_adjust[41] ? {{2 {data_update_35[7] & signed_shift}}, data_update_35[7:2]} : data_update_35);
	wire rnd_high_update_36 = (vs1_adjust[41] ? data_update_35[1] : rnd_high_update_35);
	wire [7:0] data_update_37 = (vs1_adjust[48] ? {vs2_adjust[55] & signed_shift, vs2_adjust[55:49]} : vs2_adjust[55:48]);
	wire rnd_high_update_37 = vs1_adjust[48] & vs2_adjust[48];
	wire [7:0] data_update_38 = (vs1_adjust[49] ? {{2 {data_update_37[7] & signed_shift}}, data_update_37[7:2]} : data_update_37);
	wire rnd_high_update_38 = (vs1_adjust[49] ? data_update_37[1] : rnd_high_update_37);
	wire [7:0] data_update_39 = (vs1_adjust[56] ? {vs2_adjust[63] & signed_shift, vs2_adjust[63:57]} : vs2_adjust[63:56]);
	wire rnd_high_update_39 = vs1_adjust[56] & vs2_adjust[56];
	wire [7:0] data_update_40 = (vs1_adjust[57] ? {{2 {data_update_39[7] & signed_shift}}, data_update_39[7:2]} : data_update_39);
	wire rnd_high_update_40 = (vs1_adjust[57] ? data_update_39[1] : rnd_high_update_39);
	wire _GEN = (io_narrow ? _eewVd_sew_oneHot_T_1 : _eewVd_sew_oneHot_T_2);
	wire _GEN_0 = (io_narrow ? _eewVd_sew_oneHot_T : _eewVd_sew_oneHot_T_1);
	wire _GEN_1 = ~io_narrow & _eewVd_sew_oneHot_T;
	wire [63:0] shiftOut = (_GEN ? {(vs1_adjust[36] ? {{16 {data_update_12[31] & signed_shift}}, data_update_12[31:16]} : data_update_12), (vs1_adjust[4] ? {{16 {data_update_8[31] & signed_shift}}, data_update_8[31:16]} : data_update_8)} : (_GEN_0 ? {(vs1_adjust[51] ? {{8 {data_update_24[15] & signed_shift}}, data_update_24[15:8]} : data_update_24), (vs1_adjust[35] ? {{8 {data_update_21[15] & signed_shift}}, data_update_21[15:8]} : data_update_21), (vs1_adjust[19] ? {{8 {data_update_18[15] & signed_shift}}, data_update_18[15:8]} : data_update_18), (vs1_adjust[3] ? {{8 {data_update_15[15] & signed_shift}}, data_update_15[15:8]} : data_update_15)} : (_GEN_1 ? {(vs1_adjust[58] ? {{4 {data_update_40[7] & signed_shift}}, data_update_40[7:4]} : data_update_40), (vs1_adjust[50] ? {{4 {data_update_38[7] & signed_shift}}, data_update_38[7:4]} : data_update_38), (vs1_adjust[42] ? {{4 {data_update_36[7] & signed_shift}}, data_update_36[7:4]} : data_update_36), (vs1_adjust[34] ? {{4 {data_update_34[7] & signed_shift}}, data_update_34[7:4]} : data_update_34), (vs1_adjust[26] ? {{4 {data_update_32[7] & signed_shift}}, data_update_32[7:4]} : data_update_32), (vs1_adjust[18] ? {{4 {data_update_30[7] & signed_shift}}, data_update_30[7:4]} : data_update_30), (vs1_adjust[10] ? {{4 {data_update_28[7] & signed_shift}}, data_update_28[7:4]} : data_update_28), (vs1_adjust[2] ? {{4 {data_update_26[7] & signed_shift}}, data_update_26[7:4]} : data_update_26)} : (vs1_adjust[5] ? {{32 {data_update_4[63] & signed_shift}}, data_update_4[63:32]} : data_update_4))));
	wire [7:0] vmask_adjust = (((_eewVd_sew_oneHot_T ? io_vmask : 8'h00) | (_eewVd_sew_oneHot_T_1 ? {{2 {io_vmask[3]}}, {2 {io_vmask[2]}}, {2 {io_vmask[1]}}, {2 {io_vmask[0]}}} : 8'h00)) | (_eewVd_sew_oneHot_T_2 ? {{4 {io_vmask[1]}}, {4 {io_vmask[0]}}} : 8'h00)) | {8 {&io_vdType[1:0] & io_vmask[0]}};
	wire _io_vd_T_28 = io_opcode_op == 6'h2e;
	wire _io_vd_T_30 = io_opcode_op == 6'h30;
	wire _io_vd_T_31 = io_opcode_op == 6'h31;
	wire _io_vd_T_33 = io_opcode_op == 6'h32;
	wire [63:0] _GEN_2 = (((_io_vd_T_30 & _eewVd_sew_oneHot_T ? {io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7]} : 64'h0000000000000000) | (_io_vd_T_30 & _eewVd_sew_oneHot_T_1 ? {io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15]} : 64'h0000000000000000)) | (_io_vd_T_30 & _eewVd_sew_oneHot_T_2 ? {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63], io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]} : 64'h0000000000000000)) | (_io_vd_T_30 & (&io_vdType[1:0]) ? {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]} : 64'h0000000000000000);
	wire _io_vd_T_35 = io_opcode_op == 6'h33;
	wire _io_vd_T_38 = io_opcode_op == 6'h27;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	wire [3:0] _cnt8_0_T_23 = (_io_vd_T_38 ? sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[0]} + {1'h0, io_vs2[1]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[2]} + {1'h0, io_vs2[3]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[4]} + {1'h0, io_vs2[5]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[6]} + {1'h0, io_vs2[7]})})}) : _cnt8_0_clz_io_out);
	wire [3:0] _cnt8_1_T_23 = (_io_vd_T_38 ? sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[8]} + {1'h0, io_vs2[9]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[10]} + {1'h0, io_vs2[11]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[12]} + {1'h0, io_vs2[13]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[14]} + {1'h0, io_vs2[15]})})}) : _cnt8_1_clz_io_out);
	wire [3:0] _cnt8_2_T_23 = (_io_vd_T_38 ? sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[16]} + {1'h0, io_vs2[17]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[18]} + {1'h0, io_vs2[19]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[20]} + {1'h0, io_vs2[21]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[22]} + {1'h0, io_vs2[23]})})}) : _cnt8_2_clz_io_out);
	wire [3:0] _cnt8_3_T_23 = (_io_vd_T_38 ? sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[24]} + {1'h0, io_vs2[25]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[26]} + {1'h0, io_vs2[27]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[28]} + {1'h0, io_vs2[29]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[30]} + {1'h0, io_vs2[31]})})}) : _cnt8_3_clz_io_out);
	wire [4:0] _cnt8_4_T_23 = (_io_vd_T_38 ? {1'h0, sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[32]} + {1'h0, io_vs2[33]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[34]} + {1'h0, io_vs2[35]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[36]} + {1'h0, io_vs2[37]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[38]} + {1'h0, io_vs2[39]})})})} : _cnt16_0_tmp_clz_io_out);
	wire [4:0] _cnt8_5_T_23 = (_io_vd_T_38 ? {1'h0, sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[40]} + {1'h0, io_vs2[41]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[42]} + {1'h0, io_vs2[43]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[44]} + {1'h0, io_vs2[45]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[46]} + {1'h0, io_vs2[47]})})})} : _cnt16_1_tmp_clz_io_out);
	wire [5:0] _cnt8_6_T_23 = (_io_vd_T_38 ? {2'h0, sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[48]} + {1'h0, io_vs2[49]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[50]} + {1'h0, io_vs2[51]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[52]} + {1'h0, io_vs2[53]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[54]} + {1'h0, io_vs2[55]})})})} : _cnt32_tmp_clz_io_out);
	wire [6:0] _cnt8_7_T_23 = (_io_vd_T_38 ? {3'h0, sv2v_cast_4({1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[56]} + {1'h0, io_vs2[57]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[58]} + {1'h0, io_vs2[59]})})} + {1'h0, sv2v_cast_3({1'h0, sv2v_cast_2({1'h0, io_vs2[60]} + {1'h0, io_vs2[61]})} + {1'h0, sv2v_cast_2({1'h0, io_vs2[62]} + {1'h0, io_vs2[63]})})})} : _cnt64_tmp_clz_io_out);
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	wire [4:0] _pop_16_0_T = sv2v_cast_5({1'h0, _cnt8_0_T_23} + {1'h0, _cnt8_1_T_23});
	wire [4:0] _pop_16_1_T = sv2v_cast_5({1'h0, _cnt8_2_T_23} + {1'h0, _cnt8_3_T_23});
	wire [4:0] _pop_16_3_T = _cnt8_6_T_23[4:0] + _cnt8_7_T_23[4:0];
	function automatic [5:0] sv2v_cast_6;
		input reg [5:0] inp;
		sv2v_cast_6 = inp;
	endfunction
	wire [5:0] pop_32_0 = sv2v_cast_6({1'h0, _pop_16_0_T} + {1'h0, _pop_16_1_T});
	wire [5:0] _GEN_3 = {1'h0, _cnt8_4_T_23 + _cnt8_5_T_23};
	wire [6:0] _GEN_4 = {1'h0, sv2v_cast_6(_GEN_3 + {1'h0, _pop_16_3_T})};
	wire _io_vd_T_36 = io_opcode_op == 6'h34;
	wire [2:0] _vroShift8_neg_0_T_2 = sv2v_cast_3(~io_vs1[2:0] + 3'h1);
	wire [2:0] _vroShift8_neg_1_T_2 = sv2v_cast_3(~io_vs1[10:8] + 3'h1);
	wire [2:0] _vroShift8_neg_2_T_2 = sv2v_cast_3(~io_vs1[18:16] + 3'h1);
	wire [2:0] _vroShift8_neg_3_T_2 = sv2v_cast_3(~io_vs1[26:24] + 3'h1);
	wire [2:0] _vroShift8_neg_4_T_2 = sv2v_cast_3(~io_vs1[34:32] + 3'h1);
	wire [2:0] _vroShift8_neg_5_T_2 = sv2v_cast_3(~io_vs1[42:40] + 3'h1);
	wire [2:0] _vroShift8_neg_6_T_2 = sv2v_cast_3(~io_vs1[50:48] + 3'h1);
	wire [2:0] _vroShift8_neg_7_T_2 = sv2v_cast_3(~io_vs1[58:56] + 3'h1);
	wire [3:0] _vroShift16_neg_0_T_2 = sv2v_cast_4(~io_vs1[3:0] + 4'h1);
	wire [3:0] _vroShift16_neg_1_T_2 = sv2v_cast_4(~io_vs1[19:16] + 4'h1);
	wire [3:0] _vroShift16_neg_2_T_2 = sv2v_cast_4(~io_vs1[35:32] + 4'h1);
	wire [3:0] _vroShift16_neg_3_T_2 = sv2v_cast_4(~io_vs1[51:48] + 4'h1);
	wire [4:0] _vroShift32_neg_0_T_2 = sv2v_cast_5(~io_vs1[4:0] + 5'h01);
	wire [4:0] _vroShift32_neg_1_T_2 = sv2v_cast_5(~io_vs1[36:32] + 5'h01);
	wire [5:0] _vroShift64_neg_0_T_2 = sv2v_cast_6(~io_vs1[5:0] + 6'h01);
	wire _io_vd_T_40 = io_opcode_op == 6'h35;
	wire _io_vd_T_41 = io_opcode_op == 6'h36;
	wire [7:0] vroResult_8_tmp_0_data_update = (io_vs1[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7]});
	wire [7:0] vroResult_8_tmp_0_data_update_1 = (io_vs1[1] ? {{2 {vroResult_8_tmp_0_data_update[7] & signed_shift}}, vroResult_8_tmp_0_data_update[7:2]} : vroResult_8_tmp_0_data_update);
	wire [7:0] vroResult_8_tmp_0_data_update_2 = (io_vs1[2] ? {{4 {vroResult_8_tmp_0_data_update_1[7] & signed_shift}}, vroResult_8_tmp_0_data_update_1[7:4]} : vroResult_8_tmp_0_data_update_1);
	wire [7:0] vroResult_8_tmp_0_data_update_3 = (_vroShift8_neg_0_T_2[0] ? {io_vs2[7] & signed_shift, io_vs2[7:1]} : io_vs2[7:0]);
	wire [7:0] vroResult_8_tmp_0_data_update_4 = (_vroShift8_neg_0_T_2[1] ? {{2 {vroResult_8_tmp_0_data_update_3[7] & signed_shift}}, vroResult_8_tmp_0_data_update_3[7:2]} : vroResult_8_tmp_0_data_update_3);
	wire [7:0] vroResult_8_tmp_0_data_update_6 = (_vroShift8_neg_0_T_2[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7]});
	wire [7:0] vroResult_8_tmp_0_data_update_7 = (_vroShift8_neg_0_T_2[1] ? {{2 {vroResult_8_tmp_0_data_update_6[7] & signed_shift}}, vroResult_8_tmp_0_data_update_6[7:2]} : vroResult_8_tmp_0_data_update_6);
	wire [7:0] vroResult_8_tmp_0_data_update_8 = (_vroShift8_neg_0_T_2[2] ? {{4 {vroResult_8_tmp_0_data_update_7[7] & signed_shift}}, vroResult_8_tmp_0_data_update_7[7:4]} : vroResult_8_tmp_0_data_update_7);
	wire [7:0] vroResult_8_tmp_0_data_update_9 = (io_vs1[0] ? {io_vs2[7] & signed_shift, io_vs2[7:1]} : io_vs2[7:0]);
	wire [7:0] vroResult_8_tmp_0_data_update_10 = (io_vs1[1] ? {{2 {vroResult_8_tmp_0_data_update_9[7] & signed_shift}}, vroResult_8_tmp_0_data_update_9[7:2]} : vroResult_8_tmp_0_data_update_9);
	wire [7:0] vroResult_8_tmp_1_data_update = (io_vs1[8] ? {io_vs2[8] & signed_shift, io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14]} : {io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15]});
	wire [7:0] vroResult_8_tmp_1_data_update_1 = (io_vs1[9] ? {{2 {vroResult_8_tmp_1_data_update[7] & signed_shift}}, vroResult_8_tmp_1_data_update[7:2]} : vroResult_8_tmp_1_data_update);
	wire [7:0] vroResult_8_tmp_1_data_update_2 = (io_vs1[10] ? {{4 {vroResult_8_tmp_1_data_update_1[7] & signed_shift}}, vroResult_8_tmp_1_data_update_1[7:4]} : vroResult_8_tmp_1_data_update_1);
	wire [7:0] vroResult_8_tmp_1_data_update_3 = (_vroShift8_neg_1_T_2[0] ? {io_vs2[15] & signed_shift, io_vs2[15:9]} : io_vs2[15:8]);
	wire [7:0] vroResult_8_tmp_1_data_update_4 = (_vroShift8_neg_1_T_2[1] ? {{2 {vroResult_8_tmp_1_data_update_3[7] & signed_shift}}, vroResult_8_tmp_1_data_update_3[7:2]} : vroResult_8_tmp_1_data_update_3);
	wire [7:0] vroResult_8_tmp_1_data_update_6 = (_vroShift8_neg_1_T_2[0] ? {io_vs2[8] & signed_shift, io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14]} : {io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15]});
	wire [7:0] vroResult_8_tmp_1_data_update_7 = (_vroShift8_neg_1_T_2[1] ? {{2 {vroResult_8_tmp_1_data_update_6[7] & signed_shift}}, vroResult_8_tmp_1_data_update_6[7:2]} : vroResult_8_tmp_1_data_update_6);
	wire [7:0] vroResult_8_tmp_1_data_update_8 = (_vroShift8_neg_1_T_2[2] ? {{4 {vroResult_8_tmp_1_data_update_7[7] & signed_shift}}, vroResult_8_tmp_1_data_update_7[7:4]} : vroResult_8_tmp_1_data_update_7);
	wire [7:0] vroResult_8_tmp_1_data_update_9 = (io_vs1[8] ? {io_vs2[15] & signed_shift, io_vs2[15:9]} : io_vs2[15:8]);
	wire [7:0] vroResult_8_tmp_1_data_update_10 = (io_vs1[9] ? {{2 {vroResult_8_tmp_1_data_update_9[7] & signed_shift}}, vroResult_8_tmp_1_data_update_9[7:2]} : vroResult_8_tmp_1_data_update_9);
	wire [7:0] vroResult_8_tmp_2_data_update = (io_vs1[16] ? {io_vs2[16] & signed_shift, io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22]} : {io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23]});
	wire [7:0] vroResult_8_tmp_2_data_update_1 = (io_vs1[17] ? {{2 {vroResult_8_tmp_2_data_update[7] & signed_shift}}, vroResult_8_tmp_2_data_update[7:2]} : vroResult_8_tmp_2_data_update);
	wire [7:0] vroResult_8_tmp_2_data_update_2 = (io_vs1[18] ? {{4 {vroResult_8_tmp_2_data_update_1[7] & signed_shift}}, vroResult_8_tmp_2_data_update_1[7:4]} : vroResult_8_tmp_2_data_update_1);
	wire [7:0] vroResult_8_tmp_2_data_update_3 = (_vroShift8_neg_2_T_2[0] ? {io_vs2[23] & signed_shift, io_vs2[23:17]} : io_vs2[23:16]);
	wire [7:0] vroResult_8_tmp_2_data_update_4 = (_vroShift8_neg_2_T_2[1] ? {{2 {vroResult_8_tmp_2_data_update_3[7] & signed_shift}}, vroResult_8_tmp_2_data_update_3[7:2]} : vroResult_8_tmp_2_data_update_3);
	wire [7:0] vroResult_8_tmp_2_data_update_6 = (_vroShift8_neg_2_T_2[0] ? {io_vs2[16] & signed_shift, io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22]} : {io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23]});
	wire [7:0] vroResult_8_tmp_2_data_update_7 = (_vroShift8_neg_2_T_2[1] ? {{2 {vroResult_8_tmp_2_data_update_6[7] & signed_shift}}, vroResult_8_tmp_2_data_update_6[7:2]} : vroResult_8_tmp_2_data_update_6);
	wire [7:0] vroResult_8_tmp_2_data_update_8 = (_vroShift8_neg_2_T_2[2] ? {{4 {vroResult_8_tmp_2_data_update_7[7] & signed_shift}}, vroResult_8_tmp_2_data_update_7[7:4]} : vroResult_8_tmp_2_data_update_7);
	wire [7:0] vroResult_8_tmp_2_data_update_9 = (io_vs1[16] ? {io_vs2[23] & signed_shift, io_vs2[23:17]} : io_vs2[23:16]);
	wire [7:0] vroResult_8_tmp_2_data_update_10 = (io_vs1[17] ? {{2 {vroResult_8_tmp_2_data_update_9[7] & signed_shift}}, vroResult_8_tmp_2_data_update_9[7:2]} : vroResult_8_tmp_2_data_update_9);
	wire [7:0] vroResult_8_tmp_3_data_update = (io_vs1[24] ? {io_vs2[24] & signed_shift, io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30]} : {io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]});
	wire [7:0] vroResult_8_tmp_3_data_update_1 = (io_vs1[25] ? {{2 {vroResult_8_tmp_3_data_update[7] & signed_shift}}, vroResult_8_tmp_3_data_update[7:2]} : vroResult_8_tmp_3_data_update);
	wire [7:0] vroResult_8_tmp_3_data_update_2 = (io_vs1[26] ? {{4 {vroResult_8_tmp_3_data_update_1[7] & signed_shift}}, vroResult_8_tmp_3_data_update_1[7:4]} : vroResult_8_tmp_3_data_update_1);
	wire [7:0] vroResult_8_tmp_3_data_update_3 = (_vroShift8_neg_3_T_2[0] ? {io_vs2[31] & signed_shift, io_vs2[31:25]} : io_vs2[31:24]);
	wire [7:0] vroResult_8_tmp_3_data_update_4 = (_vroShift8_neg_3_T_2[1] ? {{2 {vroResult_8_tmp_3_data_update_3[7] & signed_shift}}, vroResult_8_tmp_3_data_update_3[7:2]} : vroResult_8_tmp_3_data_update_3);
	wire [7:0] vroResult_8_tmp_3_data_update_6 = (_vroShift8_neg_3_T_2[0] ? {io_vs2[24] & signed_shift, io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30]} : {io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]});
	wire [7:0] vroResult_8_tmp_3_data_update_7 = (_vroShift8_neg_3_T_2[1] ? {{2 {vroResult_8_tmp_3_data_update_6[7] & signed_shift}}, vroResult_8_tmp_3_data_update_6[7:2]} : vroResult_8_tmp_3_data_update_6);
	wire [7:0] vroResult_8_tmp_3_data_update_8 = (_vroShift8_neg_3_T_2[2] ? {{4 {vroResult_8_tmp_3_data_update_7[7] & signed_shift}}, vroResult_8_tmp_3_data_update_7[7:4]} : vroResult_8_tmp_3_data_update_7);
	wire [7:0] vroResult_8_tmp_3_data_update_9 = (io_vs1[24] ? {io_vs2[31] & signed_shift, io_vs2[31:25]} : io_vs2[31:24]);
	wire [7:0] vroResult_8_tmp_3_data_update_10 = (io_vs1[25] ? {{2 {vroResult_8_tmp_3_data_update_9[7] & signed_shift}}, vroResult_8_tmp_3_data_update_9[7:2]} : vroResult_8_tmp_3_data_update_9);
	wire [7:0] vroResult_8_tmp_4_data_update = (io_vs1[32] ? {io_vs2[32] & signed_shift, io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38]} : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39]});
	wire [7:0] vroResult_8_tmp_4_data_update_1 = (io_vs1[33] ? {{2 {vroResult_8_tmp_4_data_update[7] & signed_shift}}, vroResult_8_tmp_4_data_update[7:2]} : vroResult_8_tmp_4_data_update);
	wire [7:0] vroResult_8_tmp_4_data_update_2 = (io_vs1[34] ? {{4 {vroResult_8_tmp_4_data_update_1[7] & signed_shift}}, vroResult_8_tmp_4_data_update_1[7:4]} : vroResult_8_tmp_4_data_update_1);
	wire [7:0] vroResult_8_tmp_4_data_update_3 = (_vroShift8_neg_4_T_2[0] ? {io_vs2[39] & signed_shift, io_vs2[39:33]} : io_vs2[39:32]);
	wire [7:0] vroResult_8_tmp_4_data_update_4 = (_vroShift8_neg_4_T_2[1] ? {{2 {vroResult_8_tmp_4_data_update_3[7] & signed_shift}}, vroResult_8_tmp_4_data_update_3[7:2]} : vroResult_8_tmp_4_data_update_3);
	wire [7:0] vroResult_8_tmp_4_data_update_6 = (_vroShift8_neg_4_T_2[0] ? {io_vs2[32] & signed_shift, io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38]} : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39]});
	wire [7:0] vroResult_8_tmp_4_data_update_7 = (_vroShift8_neg_4_T_2[1] ? {{2 {vroResult_8_tmp_4_data_update_6[7] & signed_shift}}, vroResult_8_tmp_4_data_update_6[7:2]} : vroResult_8_tmp_4_data_update_6);
	wire [7:0] vroResult_8_tmp_4_data_update_8 = (_vroShift8_neg_4_T_2[2] ? {{4 {vroResult_8_tmp_4_data_update_7[7] & signed_shift}}, vroResult_8_tmp_4_data_update_7[7:4]} : vroResult_8_tmp_4_data_update_7);
	wire [7:0] vroResult_8_tmp_4_data_update_9 = (io_vs1[32] ? {io_vs2[39] & signed_shift, io_vs2[39:33]} : io_vs2[39:32]);
	wire [7:0] vroResult_8_tmp_4_data_update_10 = (io_vs1[33] ? {{2 {vroResult_8_tmp_4_data_update_9[7] & signed_shift}}, vroResult_8_tmp_4_data_update_9[7:2]} : vroResult_8_tmp_4_data_update_9);
	wire [7:0] vroResult_8_tmp_5_data_update = (io_vs1[40] ? {io_vs2[40] & signed_shift, io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46]} : {io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47]});
	wire [7:0] vroResult_8_tmp_5_data_update_1 = (io_vs1[41] ? {{2 {vroResult_8_tmp_5_data_update[7] & signed_shift}}, vroResult_8_tmp_5_data_update[7:2]} : vroResult_8_tmp_5_data_update);
	wire [7:0] vroResult_8_tmp_5_data_update_2 = (io_vs1[42] ? {{4 {vroResult_8_tmp_5_data_update_1[7] & signed_shift}}, vroResult_8_tmp_5_data_update_1[7:4]} : vroResult_8_tmp_5_data_update_1);
	wire [7:0] vroResult_8_tmp_5_data_update_3 = (_vroShift8_neg_5_T_2[0] ? {io_vs2[47] & signed_shift, io_vs2[47:41]} : io_vs2[47:40]);
	wire [7:0] vroResult_8_tmp_5_data_update_4 = (_vroShift8_neg_5_T_2[1] ? {{2 {vroResult_8_tmp_5_data_update_3[7] & signed_shift}}, vroResult_8_tmp_5_data_update_3[7:2]} : vroResult_8_tmp_5_data_update_3);
	wire [7:0] vroResult_8_tmp_5_data_update_6 = (_vroShift8_neg_5_T_2[0] ? {io_vs2[40] & signed_shift, io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46]} : {io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47]});
	wire [7:0] vroResult_8_tmp_5_data_update_7 = (_vroShift8_neg_5_T_2[1] ? {{2 {vroResult_8_tmp_5_data_update_6[7] & signed_shift}}, vroResult_8_tmp_5_data_update_6[7:2]} : vroResult_8_tmp_5_data_update_6);
	wire [7:0] vroResult_8_tmp_5_data_update_8 = (_vroShift8_neg_5_T_2[2] ? {{4 {vroResult_8_tmp_5_data_update_7[7] & signed_shift}}, vroResult_8_tmp_5_data_update_7[7:4]} : vroResult_8_tmp_5_data_update_7);
	wire [7:0] vroResult_8_tmp_5_data_update_9 = (io_vs1[40] ? {io_vs2[47] & signed_shift, io_vs2[47:41]} : io_vs2[47:40]);
	wire [7:0] vroResult_8_tmp_5_data_update_10 = (io_vs1[41] ? {{2 {vroResult_8_tmp_5_data_update_9[7] & signed_shift}}, vroResult_8_tmp_5_data_update_9[7:2]} : vroResult_8_tmp_5_data_update_9);
	wire [7:0] vroResult_8_tmp_6_data_update = (io_vs1[48] ? {io_vs2[48] & signed_shift, io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54]} : {io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55]});
	wire [7:0] vroResult_8_tmp_6_data_update_1 = (io_vs1[49] ? {{2 {vroResult_8_tmp_6_data_update[7] & signed_shift}}, vroResult_8_tmp_6_data_update[7:2]} : vroResult_8_tmp_6_data_update);
	wire [7:0] vroResult_8_tmp_6_data_update_2 = (io_vs1[50] ? {{4 {vroResult_8_tmp_6_data_update_1[7] & signed_shift}}, vroResult_8_tmp_6_data_update_1[7:4]} : vroResult_8_tmp_6_data_update_1);
	wire [7:0] vroResult_8_tmp_6_data_update_3 = (_vroShift8_neg_6_T_2[0] ? {io_vs2[55] & signed_shift, io_vs2[55:49]} : io_vs2[55:48]);
	wire [7:0] vroResult_8_tmp_6_data_update_4 = (_vroShift8_neg_6_T_2[1] ? {{2 {vroResult_8_tmp_6_data_update_3[7] & signed_shift}}, vroResult_8_tmp_6_data_update_3[7:2]} : vroResult_8_tmp_6_data_update_3);
	wire [7:0] vroResult_8_tmp_6_data_update_6 = (_vroShift8_neg_6_T_2[0] ? {io_vs2[48] & signed_shift, io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54]} : {io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55]});
	wire [7:0] vroResult_8_tmp_6_data_update_7 = (_vroShift8_neg_6_T_2[1] ? {{2 {vroResult_8_tmp_6_data_update_6[7] & signed_shift}}, vroResult_8_tmp_6_data_update_6[7:2]} : vroResult_8_tmp_6_data_update_6);
	wire [7:0] vroResult_8_tmp_6_data_update_8 = (_vroShift8_neg_6_T_2[2] ? {{4 {vroResult_8_tmp_6_data_update_7[7] & signed_shift}}, vroResult_8_tmp_6_data_update_7[7:4]} : vroResult_8_tmp_6_data_update_7);
	wire [7:0] vroResult_8_tmp_6_data_update_9 = (io_vs1[48] ? {io_vs2[55] & signed_shift, io_vs2[55:49]} : io_vs2[55:48]);
	wire [7:0] vroResult_8_tmp_6_data_update_10 = (io_vs1[49] ? {{2 {vroResult_8_tmp_6_data_update_9[7] & signed_shift}}, vroResult_8_tmp_6_data_update_9[7:2]} : vroResult_8_tmp_6_data_update_9);
	wire [7:0] vroResult_8_tmp_7_data_update = (io_vs1[56] ? {io_vs2[56] & signed_shift, io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [7:0] vroResult_8_tmp_7_data_update_1 = (io_vs1[57] ? {{2 {vroResult_8_tmp_7_data_update[7] & signed_shift}}, vroResult_8_tmp_7_data_update[7:2]} : vroResult_8_tmp_7_data_update);
	wire [7:0] vroResult_8_tmp_7_data_update_2 = (io_vs1[58] ? {{4 {vroResult_8_tmp_7_data_update_1[7] & signed_shift}}, vroResult_8_tmp_7_data_update_1[7:4]} : vroResult_8_tmp_7_data_update_1);
	wire [7:0] vroResult_8_tmp_7_data_update_3 = (_vroShift8_neg_7_T_2[0] ? {io_vs2[63] & signed_shift, io_vs2[63:57]} : io_vs2[63:56]);
	wire [7:0] vroResult_8_tmp_7_data_update_4 = (_vroShift8_neg_7_T_2[1] ? {{2 {vroResult_8_tmp_7_data_update_3[7] & signed_shift}}, vroResult_8_tmp_7_data_update_3[7:2]} : vroResult_8_tmp_7_data_update_3);
	wire [7:0] vroResult_8_tmp_7_data_update_6 = (_vroShift8_neg_7_T_2[0] ? {io_vs2[56] & signed_shift, io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [7:0] vroResult_8_tmp_7_data_update_7 = (_vroShift8_neg_7_T_2[1] ? {{2 {vroResult_8_tmp_7_data_update_6[7] & signed_shift}}, vroResult_8_tmp_7_data_update_6[7:2]} : vroResult_8_tmp_7_data_update_6);
	wire [7:0] vroResult_8_tmp_7_data_update_8 = (_vroShift8_neg_7_T_2[2] ? {{4 {vroResult_8_tmp_7_data_update_7[7] & signed_shift}}, vroResult_8_tmp_7_data_update_7[7:4]} : vroResult_8_tmp_7_data_update_7);
	wire [7:0] vroResult_8_tmp_7_data_update_9 = (io_vs1[56] ? {io_vs2[63] & signed_shift, io_vs2[63:57]} : io_vs2[63:56]);
	wire [7:0] vroResult_8_tmp_7_data_update_10 = (io_vs1[57] ? {{2 {vroResult_8_tmp_7_data_update_9[7] & signed_shift}}, vroResult_8_tmp_7_data_update_9[7:2]} : vroResult_8_tmp_7_data_update_9);
	wire [15:0] vroResult_16_tmp_0_data_update = (io_vs1[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15]});
	wire [15:0] vroResult_16_tmp_0_data_update_1 = (io_vs1[1] ? {{2 {vroResult_16_tmp_0_data_update[15] & signed_shift}}, vroResult_16_tmp_0_data_update[15:2]} : vroResult_16_tmp_0_data_update);
	wire [15:0] vroResult_16_tmp_0_data_update_2 = (io_vs1[2] ? {{4 {vroResult_16_tmp_0_data_update_1[15] & signed_shift}}, vroResult_16_tmp_0_data_update_1[15:4]} : vroResult_16_tmp_0_data_update_1);
	wire [15:0] vroResult_16_tmp_0_data_update_3 = (io_vs1[3] ? {{8 {vroResult_16_tmp_0_data_update_2[15] & signed_shift}}, vroResult_16_tmp_0_data_update_2[15:8]} : vroResult_16_tmp_0_data_update_2);
	wire [15:0] vroResult_16_tmp_0_data_update_4 = (_vroShift16_neg_0_T_2[0] ? {io_vs2[15] & signed_shift, io_vs2[15:1]} : io_vs2[15:0]);
	wire [15:0] vroResult_16_tmp_0_data_update_5 = (_vroShift16_neg_0_T_2[1] ? {{2 {vroResult_16_tmp_0_data_update_4[15] & signed_shift}}, vroResult_16_tmp_0_data_update_4[15:2]} : vroResult_16_tmp_0_data_update_4);
	wire [15:0] vroResult_16_tmp_0_data_update_6 = (_vroShift16_neg_0_T_2[2] ? {{4 {vroResult_16_tmp_0_data_update_5[15] & signed_shift}}, vroResult_16_tmp_0_data_update_5[15:4]} : vroResult_16_tmp_0_data_update_5);
	wire [15:0] vroResult_16_tmp_0_data_update_8 = (_vroShift16_neg_0_T_2[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15]});
	wire [15:0] vroResult_16_tmp_0_data_update_9 = (_vroShift16_neg_0_T_2[1] ? {{2 {vroResult_16_tmp_0_data_update_8[15] & signed_shift}}, vroResult_16_tmp_0_data_update_8[15:2]} : vroResult_16_tmp_0_data_update_8);
	wire [15:0] vroResult_16_tmp_0_data_update_10 = (_vroShift16_neg_0_T_2[2] ? {{4 {vroResult_16_tmp_0_data_update_9[15] & signed_shift}}, vroResult_16_tmp_0_data_update_9[15:4]} : vroResult_16_tmp_0_data_update_9);
	wire [15:0] vroResult_16_tmp_0_data_update_11 = (_vroShift16_neg_0_T_2[3] ? {{8 {vroResult_16_tmp_0_data_update_10[15] & signed_shift}}, vroResult_16_tmp_0_data_update_10[15:8]} : vroResult_16_tmp_0_data_update_10);
	wire [15:0] vroResult_16_tmp_0_data_update_12 = (io_vs1[0] ? {io_vs2[15] & signed_shift, io_vs2[15:1]} : io_vs2[15:0]);
	wire [15:0] vroResult_16_tmp_0_data_update_13 = (io_vs1[1] ? {{2 {vroResult_16_tmp_0_data_update_12[15] & signed_shift}}, vroResult_16_tmp_0_data_update_12[15:2]} : vroResult_16_tmp_0_data_update_12);
	wire [15:0] vroResult_16_tmp_0_data_update_14 = (io_vs1[2] ? {{4 {vroResult_16_tmp_0_data_update_13[15] & signed_shift}}, vroResult_16_tmp_0_data_update_13[15:4]} : vroResult_16_tmp_0_data_update_13);
	wire [15:0] vroResult_16_tmp_1_data_update = (io_vs1[16] ? {io_vs2[16] & signed_shift, io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30]} : {io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]});
	wire [15:0] vroResult_16_tmp_1_data_update_1 = (io_vs1[17] ? {{2 {vroResult_16_tmp_1_data_update[15] & signed_shift}}, vroResult_16_tmp_1_data_update[15:2]} : vroResult_16_tmp_1_data_update);
	wire [15:0] vroResult_16_tmp_1_data_update_2 = (io_vs1[18] ? {{4 {vroResult_16_tmp_1_data_update_1[15] & signed_shift}}, vroResult_16_tmp_1_data_update_1[15:4]} : vroResult_16_tmp_1_data_update_1);
	wire [15:0] vroResult_16_tmp_1_data_update_3 = (io_vs1[19] ? {{8 {vroResult_16_tmp_1_data_update_2[15] & signed_shift}}, vroResult_16_tmp_1_data_update_2[15:8]} : vroResult_16_tmp_1_data_update_2);
	wire [15:0] vroResult_16_tmp_1_data_update_4 = (_vroShift16_neg_1_T_2[0] ? {io_vs2[31] & signed_shift, io_vs2[31:17]} : io_vs2[31:16]);
	wire [15:0] vroResult_16_tmp_1_data_update_5 = (_vroShift16_neg_1_T_2[1] ? {{2 {vroResult_16_tmp_1_data_update_4[15] & signed_shift}}, vroResult_16_tmp_1_data_update_4[15:2]} : vroResult_16_tmp_1_data_update_4);
	wire [15:0] vroResult_16_tmp_1_data_update_6 = (_vroShift16_neg_1_T_2[2] ? {{4 {vroResult_16_tmp_1_data_update_5[15] & signed_shift}}, vroResult_16_tmp_1_data_update_5[15:4]} : vroResult_16_tmp_1_data_update_5);
	wire [15:0] vroResult_16_tmp_1_data_update_8 = (_vroShift16_neg_1_T_2[0] ? {io_vs2[16] & signed_shift, io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30]} : {io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]});
	wire [15:0] vroResult_16_tmp_1_data_update_9 = (_vroShift16_neg_1_T_2[1] ? {{2 {vroResult_16_tmp_1_data_update_8[15] & signed_shift}}, vroResult_16_tmp_1_data_update_8[15:2]} : vroResult_16_tmp_1_data_update_8);
	wire [15:0] vroResult_16_tmp_1_data_update_10 = (_vroShift16_neg_1_T_2[2] ? {{4 {vroResult_16_tmp_1_data_update_9[15] & signed_shift}}, vroResult_16_tmp_1_data_update_9[15:4]} : vroResult_16_tmp_1_data_update_9);
	wire [15:0] vroResult_16_tmp_1_data_update_11 = (_vroShift16_neg_1_T_2[3] ? {{8 {vroResult_16_tmp_1_data_update_10[15] & signed_shift}}, vroResult_16_tmp_1_data_update_10[15:8]} : vroResult_16_tmp_1_data_update_10);
	wire [15:0] vroResult_16_tmp_1_data_update_12 = (io_vs1[16] ? {io_vs2[31] & signed_shift, io_vs2[31:17]} : io_vs2[31:16]);
	wire [15:0] vroResult_16_tmp_1_data_update_13 = (io_vs1[17] ? {{2 {vroResult_16_tmp_1_data_update_12[15] & signed_shift}}, vroResult_16_tmp_1_data_update_12[15:2]} : vroResult_16_tmp_1_data_update_12);
	wire [15:0] vroResult_16_tmp_1_data_update_14 = (io_vs1[18] ? {{4 {vroResult_16_tmp_1_data_update_13[15] & signed_shift}}, vroResult_16_tmp_1_data_update_13[15:4]} : vroResult_16_tmp_1_data_update_13);
	wire [15:0] vroResult_16_tmp_2_data_update = (io_vs1[32] ? {io_vs2[32] & signed_shift, io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46]} : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47]});
	wire [15:0] vroResult_16_tmp_2_data_update_1 = (io_vs1[33] ? {{2 {vroResult_16_tmp_2_data_update[15] & signed_shift}}, vroResult_16_tmp_2_data_update[15:2]} : vroResult_16_tmp_2_data_update);
	wire [15:0] vroResult_16_tmp_2_data_update_2 = (io_vs1[34] ? {{4 {vroResult_16_tmp_2_data_update_1[15] & signed_shift}}, vroResult_16_tmp_2_data_update_1[15:4]} : vroResult_16_tmp_2_data_update_1);
	wire [15:0] vroResult_16_tmp_2_data_update_3 = (io_vs1[35] ? {{8 {vroResult_16_tmp_2_data_update_2[15] & signed_shift}}, vroResult_16_tmp_2_data_update_2[15:8]} : vroResult_16_tmp_2_data_update_2);
	wire [15:0] vroResult_16_tmp_2_data_update_4 = (_vroShift16_neg_2_T_2[0] ? {io_vs2[47] & signed_shift, io_vs2[47:33]} : io_vs2[47:32]);
	wire [15:0] vroResult_16_tmp_2_data_update_5 = (_vroShift16_neg_2_T_2[1] ? {{2 {vroResult_16_tmp_2_data_update_4[15] & signed_shift}}, vroResult_16_tmp_2_data_update_4[15:2]} : vroResult_16_tmp_2_data_update_4);
	wire [15:0] vroResult_16_tmp_2_data_update_6 = (_vroShift16_neg_2_T_2[2] ? {{4 {vroResult_16_tmp_2_data_update_5[15] & signed_shift}}, vroResult_16_tmp_2_data_update_5[15:4]} : vroResult_16_tmp_2_data_update_5);
	wire [15:0] vroResult_16_tmp_2_data_update_8 = (_vroShift16_neg_2_T_2[0] ? {io_vs2[32] & signed_shift, io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46]} : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47]});
	wire [15:0] vroResult_16_tmp_2_data_update_9 = (_vroShift16_neg_2_T_2[1] ? {{2 {vroResult_16_tmp_2_data_update_8[15] & signed_shift}}, vroResult_16_tmp_2_data_update_8[15:2]} : vroResult_16_tmp_2_data_update_8);
	wire [15:0] vroResult_16_tmp_2_data_update_10 = (_vroShift16_neg_2_T_2[2] ? {{4 {vroResult_16_tmp_2_data_update_9[15] & signed_shift}}, vroResult_16_tmp_2_data_update_9[15:4]} : vroResult_16_tmp_2_data_update_9);
	wire [15:0] vroResult_16_tmp_2_data_update_11 = (_vroShift16_neg_2_T_2[3] ? {{8 {vroResult_16_tmp_2_data_update_10[15] & signed_shift}}, vroResult_16_tmp_2_data_update_10[15:8]} : vroResult_16_tmp_2_data_update_10);
	wire [15:0] vroResult_16_tmp_2_data_update_12 = (io_vs1[32] ? {io_vs2[47] & signed_shift, io_vs2[47:33]} : io_vs2[47:32]);
	wire [15:0] vroResult_16_tmp_2_data_update_13 = (io_vs1[33] ? {{2 {vroResult_16_tmp_2_data_update_12[15] & signed_shift}}, vroResult_16_tmp_2_data_update_12[15:2]} : vroResult_16_tmp_2_data_update_12);
	wire [15:0] vroResult_16_tmp_2_data_update_14 = (io_vs1[34] ? {{4 {vroResult_16_tmp_2_data_update_13[15] & signed_shift}}, vroResult_16_tmp_2_data_update_13[15:4]} : vroResult_16_tmp_2_data_update_13);
	wire [15:0] vroResult_16_tmp_3_data_update = (io_vs1[48] ? {io_vs2[48] & signed_shift, io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [15:0] vroResult_16_tmp_3_data_update_1 = (io_vs1[49] ? {{2 {vroResult_16_tmp_3_data_update[15] & signed_shift}}, vroResult_16_tmp_3_data_update[15:2]} : vroResult_16_tmp_3_data_update);
	wire [15:0] vroResult_16_tmp_3_data_update_2 = (io_vs1[50] ? {{4 {vroResult_16_tmp_3_data_update_1[15] & signed_shift}}, vroResult_16_tmp_3_data_update_1[15:4]} : vroResult_16_tmp_3_data_update_1);
	wire [15:0] vroResult_16_tmp_3_data_update_3 = (io_vs1[51] ? {{8 {vroResult_16_tmp_3_data_update_2[15] & signed_shift}}, vroResult_16_tmp_3_data_update_2[15:8]} : vroResult_16_tmp_3_data_update_2);
	wire [15:0] vroResult_16_tmp_3_data_update_4 = (_vroShift16_neg_3_T_2[0] ? {io_vs2[63] & signed_shift, io_vs2[63:49]} : io_vs2[63:48]);
	wire [15:0] vroResult_16_tmp_3_data_update_5 = (_vroShift16_neg_3_T_2[1] ? {{2 {vroResult_16_tmp_3_data_update_4[15] & signed_shift}}, vroResult_16_tmp_3_data_update_4[15:2]} : vroResult_16_tmp_3_data_update_4);
	wire [15:0] vroResult_16_tmp_3_data_update_6 = (_vroShift16_neg_3_T_2[2] ? {{4 {vroResult_16_tmp_3_data_update_5[15] & signed_shift}}, vroResult_16_tmp_3_data_update_5[15:4]} : vroResult_16_tmp_3_data_update_5);
	wire [15:0] vroResult_16_tmp_3_data_update_8 = (_vroShift16_neg_3_T_2[0] ? {io_vs2[48] & signed_shift, io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [15:0] vroResult_16_tmp_3_data_update_9 = (_vroShift16_neg_3_T_2[1] ? {{2 {vroResult_16_tmp_3_data_update_8[15] & signed_shift}}, vroResult_16_tmp_3_data_update_8[15:2]} : vroResult_16_tmp_3_data_update_8);
	wire [15:0] vroResult_16_tmp_3_data_update_10 = (_vroShift16_neg_3_T_2[2] ? {{4 {vroResult_16_tmp_3_data_update_9[15] & signed_shift}}, vroResult_16_tmp_3_data_update_9[15:4]} : vroResult_16_tmp_3_data_update_9);
	wire [15:0] vroResult_16_tmp_3_data_update_11 = (_vroShift16_neg_3_T_2[3] ? {{8 {vroResult_16_tmp_3_data_update_10[15] & signed_shift}}, vroResult_16_tmp_3_data_update_10[15:8]} : vroResult_16_tmp_3_data_update_10);
	wire [15:0] vroResult_16_tmp_3_data_update_12 = (io_vs1[48] ? {io_vs2[63] & signed_shift, io_vs2[63:49]} : io_vs2[63:48]);
	wire [15:0] vroResult_16_tmp_3_data_update_13 = (io_vs1[49] ? {{2 {vroResult_16_tmp_3_data_update_12[15] & signed_shift}}, vroResult_16_tmp_3_data_update_12[15:2]} : vroResult_16_tmp_3_data_update_12);
	wire [15:0] vroResult_16_tmp_3_data_update_14 = (io_vs1[50] ? {{4 {vroResult_16_tmp_3_data_update_13[15] & signed_shift}}, vroResult_16_tmp_3_data_update_13[15:4]} : vroResult_16_tmp_3_data_update_13);
	wire [31:0] vroResult_32_tmp_0_data_update = (io_vs1[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]});
	wire [31:0] vroResult_32_tmp_0_data_update_1 = (io_vs1[1] ? {{2 {vroResult_32_tmp_0_data_update[31] & signed_shift}}, vroResult_32_tmp_0_data_update[31:2]} : vroResult_32_tmp_0_data_update);
	wire [31:0] vroResult_32_tmp_0_data_update_2 = (io_vs1[2] ? {{4 {vroResult_32_tmp_0_data_update_1[31] & signed_shift}}, vroResult_32_tmp_0_data_update_1[31:4]} : vroResult_32_tmp_0_data_update_1);
	wire [31:0] vroResult_32_tmp_0_data_update_3 = (io_vs1[3] ? {{8 {vroResult_32_tmp_0_data_update_2[31] & signed_shift}}, vroResult_32_tmp_0_data_update_2[31:8]} : vroResult_32_tmp_0_data_update_2);
	wire [31:0] vroResult_32_tmp_0_data_update_4 = (io_vs1[4] ? {{16 {vroResult_32_tmp_0_data_update_3[31] & signed_shift}}, vroResult_32_tmp_0_data_update_3[31:16]} : vroResult_32_tmp_0_data_update_3);
	wire [31:0] vroResult_32_tmp_0_data_update_5 = (_vroShift32_neg_0_T_2[0] ? {io_vs2[31] & signed_shift, io_vs2[31:1]} : io_vs2[31:0]);
	wire [31:0] vroResult_32_tmp_0_data_update_6 = (_vroShift32_neg_0_T_2[1] ? {{2 {vroResult_32_tmp_0_data_update_5[31] & signed_shift}}, vroResult_32_tmp_0_data_update_5[31:2]} : vroResult_32_tmp_0_data_update_5);
	wire [31:0] vroResult_32_tmp_0_data_update_7 = (_vroShift32_neg_0_T_2[2] ? {{4 {vroResult_32_tmp_0_data_update_6[31] & signed_shift}}, vroResult_32_tmp_0_data_update_6[31:4]} : vroResult_32_tmp_0_data_update_6);
	wire [31:0] vroResult_32_tmp_0_data_update_8 = (_vroShift32_neg_0_T_2[3] ? {{8 {vroResult_32_tmp_0_data_update_7[31] & signed_shift}}, vroResult_32_tmp_0_data_update_7[31:8]} : vroResult_32_tmp_0_data_update_7);
	wire [31:0] vroResult_32_tmp_0_data_update_10 = (_vroShift32_neg_0_T_2[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]});
	wire [31:0] vroResult_32_tmp_0_data_update_11 = (_vroShift32_neg_0_T_2[1] ? {{2 {vroResult_32_tmp_0_data_update_10[31] & signed_shift}}, vroResult_32_tmp_0_data_update_10[31:2]} : vroResult_32_tmp_0_data_update_10);
	wire [31:0] vroResult_32_tmp_0_data_update_12 = (_vroShift32_neg_0_T_2[2] ? {{4 {vroResult_32_tmp_0_data_update_11[31] & signed_shift}}, vroResult_32_tmp_0_data_update_11[31:4]} : vroResult_32_tmp_0_data_update_11);
	wire [31:0] vroResult_32_tmp_0_data_update_13 = (_vroShift32_neg_0_T_2[3] ? {{8 {vroResult_32_tmp_0_data_update_12[31] & signed_shift}}, vroResult_32_tmp_0_data_update_12[31:8]} : vroResult_32_tmp_0_data_update_12);
	wire [31:0] vroResult_32_tmp_0_data_update_14 = (_vroShift32_neg_0_T_2[4] ? {{16 {vroResult_32_tmp_0_data_update_13[31] & signed_shift}}, vroResult_32_tmp_0_data_update_13[31:16]} : vroResult_32_tmp_0_data_update_13);
	wire [31:0] vroResult_32_tmp_0_data_update_15 = (io_vs1[0] ? {io_vs2[31] & signed_shift, io_vs2[31:1]} : io_vs2[31:0]);
	wire [31:0] vroResult_32_tmp_0_data_update_16 = (io_vs1[1] ? {{2 {vroResult_32_tmp_0_data_update_15[31] & signed_shift}}, vroResult_32_tmp_0_data_update_15[31:2]} : vroResult_32_tmp_0_data_update_15);
	wire [31:0] vroResult_32_tmp_0_data_update_17 = (io_vs1[2] ? {{4 {vroResult_32_tmp_0_data_update_16[31] & signed_shift}}, vroResult_32_tmp_0_data_update_16[31:4]} : vroResult_32_tmp_0_data_update_16);
	wire [31:0] vroResult_32_tmp_0_data_update_18 = (io_vs1[3] ? {{8 {vroResult_32_tmp_0_data_update_17[31] & signed_shift}}, vroResult_32_tmp_0_data_update_17[31:8]} : vroResult_32_tmp_0_data_update_17);
	wire [31:0] vroResult_32_tmp_1_data_update = (io_vs1[32] ? {io_vs2[32] & signed_shift, io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [31:0] vroResult_32_tmp_1_data_update_1 = (io_vs1[33] ? {{2 {vroResult_32_tmp_1_data_update[31] & signed_shift}}, vroResult_32_tmp_1_data_update[31:2]} : vroResult_32_tmp_1_data_update);
	wire [31:0] vroResult_32_tmp_1_data_update_2 = (io_vs1[34] ? {{4 {vroResult_32_tmp_1_data_update_1[31] & signed_shift}}, vroResult_32_tmp_1_data_update_1[31:4]} : vroResult_32_tmp_1_data_update_1);
	wire [31:0] vroResult_32_tmp_1_data_update_3 = (io_vs1[35] ? {{8 {vroResult_32_tmp_1_data_update_2[31] & signed_shift}}, vroResult_32_tmp_1_data_update_2[31:8]} : vroResult_32_tmp_1_data_update_2);
	wire [31:0] vroResult_32_tmp_1_data_update_4 = (io_vs1[36] ? {{16 {vroResult_32_tmp_1_data_update_3[31] & signed_shift}}, vroResult_32_tmp_1_data_update_3[31:16]} : vroResult_32_tmp_1_data_update_3);
	wire [31:0] vroResult_32_tmp_1_data_update_5 = (_vroShift32_neg_1_T_2[0] ? {io_vs2[63] & signed_shift, io_vs2[63:33]} : io_vs2[63:32]);
	wire [31:0] vroResult_32_tmp_1_data_update_6 = (_vroShift32_neg_1_T_2[1] ? {{2 {vroResult_32_tmp_1_data_update_5[31] & signed_shift}}, vroResult_32_tmp_1_data_update_5[31:2]} : vroResult_32_tmp_1_data_update_5);
	wire [31:0] vroResult_32_tmp_1_data_update_7 = (_vroShift32_neg_1_T_2[2] ? {{4 {vroResult_32_tmp_1_data_update_6[31] & signed_shift}}, vroResult_32_tmp_1_data_update_6[31:4]} : vroResult_32_tmp_1_data_update_6);
	wire [31:0] vroResult_32_tmp_1_data_update_8 = (_vroShift32_neg_1_T_2[3] ? {{8 {vroResult_32_tmp_1_data_update_7[31] & signed_shift}}, vroResult_32_tmp_1_data_update_7[31:8]} : vroResult_32_tmp_1_data_update_7);
	wire [31:0] vroResult_32_tmp_1_data_update_10 = (_vroShift32_neg_1_T_2[0] ? {io_vs2[32] & signed_shift, io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [31:0] vroResult_32_tmp_1_data_update_11 = (_vroShift32_neg_1_T_2[1] ? {{2 {vroResult_32_tmp_1_data_update_10[31] & signed_shift}}, vroResult_32_tmp_1_data_update_10[31:2]} : vroResult_32_tmp_1_data_update_10);
	wire [31:0] vroResult_32_tmp_1_data_update_12 = (_vroShift32_neg_1_T_2[2] ? {{4 {vroResult_32_tmp_1_data_update_11[31] & signed_shift}}, vroResult_32_tmp_1_data_update_11[31:4]} : vroResult_32_tmp_1_data_update_11);
	wire [31:0] vroResult_32_tmp_1_data_update_13 = (_vroShift32_neg_1_T_2[3] ? {{8 {vroResult_32_tmp_1_data_update_12[31] & signed_shift}}, vroResult_32_tmp_1_data_update_12[31:8]} : vroResult_32_tmp_1_data_update_12);
	wire [31:0] vroResult_32_tmp_1_data_update_14 = (_vroShift32_neg_1_T_2[4] ? {{16 {vroResult_32_tmp_1_data_update_13[31] & signed_shift}}, vroResult_32_tmp_1_data_update_13[31:16]} : vroResult_32_tmp_1_data_update_13);
	wire [31:0] vroResult_32_tmp_1_data_update_15 = (io_vs1[32] ? {io_vs2[63] & signed_shift, io_vs2[63:33]} : io_vs2[63:32]);
	wire [31:0] vroResult_32_tmp_1_data_update_16 = (io_vs1[33] ? {{2 {vroResult_32_tmp_1_data_update_15[31] & signed_shift}}, vroResult_32_tmp_1_data_update_15[31:2]} : vroResult_32_tmp_1_data_update_15);
	wire [31:0] vroResult_32_tmp_1_data_update_17 = (io_vs1[34] ? {{4 {vroResult_32_tmp_1_data_update_16[31] & signed_shift}}, vroResult_32_tmp_1_data_update_16[31:4]} : vroResult_32_tmp_1_data_update_16);
	wire [31:0] vroResult_32_tmp_1_data_update_18 = (io_vs1[35] ? {{8 {vroResult_32_tmp_1_data_update_17[31] & signed_shift}}, vroResult_32_tmp_1_data_update_17[31:8]} : vroResult_32_tmp_1_data_update_17);
	wire [63:0] vroResult_64_tmp_0_data_update = (io_vs1[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [63:0] vroResult_64_tmp_0_data_update_1 = (io_vs1[1] ? {{2 {vroResult_64_tmp_0_data_update[63] & signed_shift}}, vroResult_64_tmp_0_data_update[63:2]} : vroResult_64_tmp_0_data_update);
	wire [63:0] vroResult_64_tmp_0_data_update_2 = (io_vs1[2] ? {{4 {vroResult_64_tmp_0_data_update_1[63] & signed_shift}}, vroResult_64_tmp_0_data_update_1[63:4]} : vroResult_64_tmp_0_data_update_1);
	wire [63:0] vroResult_64_tmp_0_data_update_3 = (io_vs1[3] ? {{8 {vroResult_64_tmp_0_data_update_2[63] & signed_shift}}, vroResult_64_tmp_0_data_update_2[63:8]} : vroResult_64_tmp_0_data_update_2);
	wire [63:0] vroResult_64_tmp_0_data_update_4 = (io_vs1[4] ? {{16 {vroResult_64_tmp_0_data_update_3[63] & signed_shift}}, vroResult_64_tmp_0_data_update_3[63:16]} : vroResult_64_tmp_0_data_update_3);
	wire [63:0] vroResult_64_tmp_0_data_update_5 = (io_vs1[5] ? {{32 {vroResult_64_tmp_0_data_update_4[63] & signed_shift}}, vroResult_64_tmp_0_data_update_4[63:32]} : vroResult_64_tmp_0_data_update_4);
	wire [63:0] vroResult_64_tmp_0_data_update_6 = (_vroShift64_neg_0_T_2[0] ? {io_vs2[63] & signed_shift, io_vs2[63:1]} : io_vs2);
	wire [63:0] vroResult_64_tmp_0_data_update_7 = (_vroShift64_neg_0_T_2[1] ? {{2 {vroResult_64_tmp_0_data_update_6[63] & signed_shift}}, vroResult_64_tmp_0_data_update_6[63:2]} : vroResult_64_tmp_0_data_update_6);
	wire [63:0] vroResult_64_tmp_0_data_update_8 = (_vroShift64_neg_0_T_2[2] ? {{4 {vroResult_64_tmp_0_data_update_7[63] & signed_shift}}, vroResult_64_tmp_0_data_update_7[63:4]} : vroResult_64_tmp_0_data_update_7);
	wire [63:0] vroResult_64_tmp_0_data_update_9 = (_vroShift64_neg_0_T_2[3] ? {{8 {vroResult_64_tmp_0_data_update_8[63] & signed_shift}}, vroResult_64_tmp_0_data_update_8[63:8]} : vroResult_64_tmp_0_data_update_8);
	wire [63:0] vroResult_64_tmp_0_data_update_10 = (_vroShift64_neg_0_T_2[4] ? {{16 {vroResult_64_tmp_0_data_update_9[63] & signed_shift}}, vroResult_64_tmp_0_data_update_9[63:16]} : vroResult_64_tmp_0_data_update_9);
	wire [63:0] vroResult_64_tmp_0_data_update_12 = (_vroShift64_neg_0_T_2[0] ? {io_vs2[0] & signed_shift, io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62]} : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]});
	wire [63:0] vroResult_64_tmp_0_data_update_13 = (_vroShift64_neg_0_T_2[1] ? {{2 {vroResult_64_tmp_0_data_update_12[63] & signed_shift}}, vroResult_64_tmp_0_data_update_12[63:2]} : vroResult_64_tmp_0_data_update_12);
	wire [63:0] vroResult_64_tmp_0_data_update_14 = (_vroShift64_neg_0_T_2[2] ? {{4 {vroResult_64_tmp_0_data_update_13[63] & signed_shift}}, vroResult_64_tmp_0_data_update_13[63:4]} : vroResult_64_tmp_0_data_update_13);
	wire [63:0] vroResult_64_tmp_0_data_update_15 = (_vroShift64_neg_0_T_2[3] ? {{8 {vroResult_64_tmp_0_data_update_14[63] & signed_shift}}, vroResult_64_tmp_0_data_update_14[63:8]} : vroResult_64_tmp_0_data_update_14);
	wire [63:0] vroResult_64_tmp_0_data_update_16 = (_vroShift64_neg_0_T_2[4] ? {{16 {vroResult_64_tmp_0_data_update_15[63] & signed_shift}}, vroResult_64_tmp_0_data_update_15[63:16]} : vroResult_64_tmp_0_data_update_15);
	wire [63:0] vroResult_64_tmp_0_data_update_17 = (_vroShift64_neg_0_T_2[5] ? {{32 {vroResult_64_tmp_0_data_update_16[63] & signed_shift}}, vroResult_64_tmp_0_data_update_16[63:32]} : vroResult_64_tmp_0_data_update_16);
	wire [63:0] vroResult_64_tmp_0_data_update_18 = (io_vs1[0] ? {io_vs2[63] & signed_shift, io_vs2[63:1]} : io_vs2);
	wire [63:0] vroResult_64_tmp_0_data_update_19 = (io_vs1[1] ? {{2 {vroResult_64_tmp_0_data_update_18[63] & signed_shift}}, vroResult_64_tmp_0_data_update_18[63:2]} : vroResult_64_tmp_0_data_update_18);
	wire [63:0] vroResult_64_tmp_0_data_update_20 = (io_vs1[2] ? {{4 {vroResult_64_tmp_0_data_update_19[63] & signed_shift}}, vroResult_64_tmp_0_data_update_19[63:4]} : vroResult_64_tmp_0_data_update_19);
	wire [63:0] vroResult_64_tmp_0_data_update_21 = (io_vs1[3] ? {{8 {vroResult_64_tmp_0_data_update_20[63] & signed_shift}}, vroResult_64_tmp_0_data_update_20[63:8]} : vroResult_64_tmp_0_data_update_20);
	wire [63:0] vroResult_64_tmp_0_data_update_22 = (io_vs1[4] ? {{16 {vroResult_64_tmp_0_data_update_21[63] & signed_shift}}, vroResult_64_tmp_0_data_update_21[63:16]} : vroResult_64_tmp_0_data_update_21);
	wire [63:0] _GEN_5 = (_eewVd_sew_oneHot_T ? {(_io_vd_T_40 ? {vroResult_8_tmp_7_data_update_2[0], vroResult_8_tmp_7_data_update_2[1], vroResult_8_tmp_7_data_update_2[2], vroResult_8_tmp_7_data_update_2[3], vroResult_8_tmp_7_data_update_2[4], vroResult_8_tmp_7_data_update_2[5], vroResult_8_tmp_7_data_update_2[6], vroResult_8_tmp_7_data_update_2[7]} | (_vroShift8_neg_7_T_2[2] ? {{4 {vroResult_8_tmp_7_data_update_4[7] & signed_shift}}, vroResult_8_tmp_7_data_update_4[7:4]} : vroResult_8_tmp_7_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_7_data_update_8[0], vroResult_8_tmp_7_data_update_8[1], vroResult_8_tmp_7_data_update_8[2], vroResult_8_tmp_7_data_update_8[3], vroResult_8_tmp_7_data_update_8[4], vroResult_8_tmp_7_data_update_8[5], vroResult_8_tmp_7_data_update_8[6], vroResult_8_tmp_7_data_update_8[7]} | (io_vs1[58] ? {{4 {vroResult_8_tmp_7_data_update_10[7] & signed_shift}}, vroResult_8_tmp_7_data_update_10[7:4]} : vroResult_8_tmp_7_data_update_10) : 8'h00), (_io_vd_T_40 ? {vroResult_8_tmp_6_data_update_2[0], vroResult_8_tmp_6_data_update_2[1], vroResult_8_tmp_6_data_update_2[2], vroResult_8_tmp_6_data_update_2[3], vroResult_8_tmp_6_data_update_2[4], vroResult_8_tmp_6_data_update_2[5], vroResult_8_tmp_6_data_update_2[6], vroResult_8_tmp_6_data_update_2[7]} | (_vroShift8_neg_6_T_2[2] ? {{4 {vroResult_8_tmp_6_data_update_4[7] & signed_shift}}, vroResult_8_tmp_6_data_update_4[7:4]} : vroResult_8_tmp_6_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_6_data_update_8[0], vroResult_8_tmp_6_data_update_8[1], vroResult_8_tmp_6_data_update_8[2], vroResult_8_tmp_6_data_update_8[3], vroResult_8_tmp_6_data_update_8[4], vroResult_8_tmp_6_data_update_8[5], vroResult_8_tmp_6_data_update_8[6], vroResult_8_tmp_6_data_update_8[7]} | (io_vs1[50] ? {{4 {vroResult_8_tmp_6_data_update_10[7] & signed_shift}}, vroResult_8_tmp_6_data_update_10[7:4]} : vroResult_8_tmp_6_data_update_10) : 8'h00), (_io_vd_T_40 ? {vroResult_8_tmp_5_data_update_2[0], vroResult_8_tmp_5_data_update_2[1], vroResult_8_tmp_5_data_update_2[2], vroResult_8_tmp_5_data_update_2[3], vroResult_8_tmp_5_data_update_2[4], vroResult_8_tmp_5_data_update_2[5], vroResult_8_tmp_5_data_update_2[6], vroResult_8_tmp_5_data_update_2[7]} | (_vroShift8_neg_5_T_2[2] ? {{4 {vroResult_8_tmp_5_data_update_4[7] & signed_shift}}, vroResult_8_tmp_5_data_update_4[7:4]} : vroResult_8_tmp_5_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_5_data_update_8[0], vroResult_8_tmp_5_data_update_8[1], vroResult_8_tmp_5_data_update_8[2], vroResult_8_tmp_5_data_update_8[3], vroResult_8_tmp_5_data_update_8[4], vroResult_8_tmp_5_data_update_8[5], vroResult_8_tmp_5_data_update_8[6], vroResult_8_tmp_5_data_update_8[7]} | (io_vs1[42] ? {{4 {vroResult_8_tmp_5_data_update_10[7] & signed_shift}}, vroResult_8_tmp_5_data_update_10[7:4]} : vroResult_8_tmp_5_data_update_10) : 8'h00), (_io_vd_T_40 ? {vroResult_8_tmp_4_data_update_2[0], vroResult_8_tmp_4_data_update_2[1], vroResult_8_tmp_4_data_update_2[2], vroResult_8_tmp_4_data_update_2[3], vroResult_8_tmp_4_data_update_2[4], vroResult_8_tmp_4_data_update_2[5], vroResult_8_tmp_4_data_update_2[6], vroResult_8_tmp_4_data_update_2[7]} | (_vroShift8_neg_4_T_2[2] ? {{4 {vroResult_8_tmp_4_data_update_4[7] & signed_shift}}, vroResult_8_tmp_4_data_update_4[7:4]} : vroResult_8_tmp_4_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_4_data_update_8[0], vroResult_8_tmp_4_data_update_8[1], vroResult_8_tmp_4_data_update_8[2], vroResult_8_tmp_4_data_update_8[3], vroResult_8_tmp_4_data_update_8[4], vroResult_8_tmp_4_data_update_8[5], vroResult_8_tmp_4_data_update_8[6], vroResult_8_tmp_4_data_update_8[7]} | (io_vs1[34] ? {{4 {vroResult_8_tmp_4_data_update_10[7] & signed_shift}}, vroResult_8_tmp_4_data_update_10[7:4]} : vroResult_8_tmp_4_data_update_10) : 8'h00), (_io_vd_T_40 ? {vroResult_8_tmp_3_data_update_2[0], vroResult_8_tmp_3_data_update_2[1], vroResult_8_tmp_3_data_update_2[2], vroResult_8_tmp_3_data_update_2[3], vroResult_8_tmp_3_data_update_2[4], vroResult_8_tmp_3_data_update_2[5], vroResult_8_tmp_3_data_update_2[6], vroResult_8_tmp_3_data_update_2[7]} | (_vroShift8_neg_3_T_2[2] ? {{4 {vroResult_8_tmp_3_data_update_4[7] & signed_shift}}, vroResult_8_tmp_3_data_update_4[7:4]} : vroResult_8_tmp_3_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_3_data_update_8[0], vroResult_8_tmp_3_data_update_8[1], vroResult_8_tmp_3_data_update_8[2], vroResult_8_tmp_3_data_update_8[3], vroResult_8_tmp_3_data_update_8[4], vroResult_8_tmp_3_data_update_8[5], vroResult_8_tmp_3_data_update_8[6], vroResult_8_tmp_3_data_update_8[7]} | (io_vs1[26] ? {{4 {vroResult_8_tmp_3_data_update_10[7] & signed_shift}}, vroResult_8_tmp_3_data_update_10[7:4]} : vroResult_8_tmp_3_data_update_10) : 8'h00), (_io_vd_T_40 ? {vroResult_8_tmp_2_data_update_2[0], vroResult_8_tmp_2_data_update_2[1], vroResult_8_tmp_2_data_update_2[2], vroResult_8_tmp_2_data_update_2[3], vroResult_8_tmp_2_data_update_2[4], vroResult_8_tmp_2_data_update_2[5], vroResult_8_tmp_2_data_update_2[6], vroResult_8_tmp_2_data_update_2[7]} | (_vroShift8_neg_2_T_2[2] ? {{4 {vroResult_8_tmp_2_data_update_4[7] & signed_shift}}, vroResult_8_tmp_2_data_update_4[7:4]} : vroResult_8_tmp_2_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_2_data_update_8[0], vroResult_8_tmp_2_data_update_8[1], vroResult_8_tmp_2_data_update_8[2], vroResult_8_tmp_2_data_update_8[3], vroResult_8_tmp_2_data_update_8[4], vroResult_8_tmp_2_data_update_8[5], vroResult_8_tmp_2_data_update_8[6], vroResult_8_tmp_2_data_update_8[7]} | (io_vs1[18] ? {{4 {vroResult_8_tmp_2_data_update_10[7] & signed_shift}}, vroResult_8_tmp_2_data_update_10[7:4]} : vroResult_8_tmp_2_data_update_10) : 8'h00), (_io_vd_T_40 ? {vroResult_8_tmp_1_data_update_2[0], vroResult_8_tmp_1_data_update_2[1], vroResult_8_tmp_1_data_update_2[2], vroResult_8_tmp_1_data_update_2[3], vroResult_8_tmp_1_data_update_2[4], vroResult_8_tmp_1_data_update_2[5], vroResult_8_tmp_1_data_update_2[6], vroResult_8_tmp_1_data_update_2[7]} | (_vroShift8_neg_1_T_2[2] ? {{4 {vroResult_8_tmp_1_data_update_4[7] & signed_shift}}, vroResult_8_tmp_1_data_update_4[7:4]} : vroResult_8_tmp_1_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_1_data_update_8[0], vroResult_8_tmp_1_data_update_8[1], vroResult_8_tmp_1_data_update_8[2], vroResult_8_tmp_1_data_update_8[3], vroResult_8_tmp_1_data_update_8[4], vroResult_8_tmp_1_data_update_8[5], vroResult_8_tmp_1_data_update_8[6], vroResult_8_tmp_1_data_update_8[7]} | (io_vs1[10] ? {{4 {vroResult_8_tmp_1_data_update_10[7] & signed_shift}}, vroResult_8_tmp_1_data_update_10[7:4]} : vroResult_8_tmp_1_data_update_10) : 8'h00), (_io_vd_T_40 ? {vroResult_8_tmp_0_data_update_2[0], vroResult_8_tmp_0_data_update_2[1], vroResult_8_tmp_0_data_update_2[2], vroResult_8_tmp_0_data_update_2[3], vroResult_8_tmp_0_data_update_2[4], vroResult_8_tmp_0_data_update_2[5], vroResult_8_tmp_0_data_update_2[6], vroResult_8_tmp_0_data_update_2[7]} | (_vroShift8_neg_0_T_2[2] ? {{4 {vroResult_8_tmp_0_data_update_4[7] & signed_shift}}, vroResult_8_tmp_0_data_update_4[7:4]} : vroResult_8_tmp_0_data_update_4) : 8'h00) | (_io_vd_T_41 ? {vroResult_8_tmp_0_data_update_8[0], vroResult_8_tmp_0_data_update_8[1], vroResult_8_tmp_0_data_update_8[2], vroResult_8_tmp_0_data_update_8[3], vroResult_8_tmp_0_data_update_8[4], vroResult_8_tmp_0_data_update_8[5], vroResult_8_tmp_0_data_update_8[6], vroResult_8_tmp_0_data_update_8[7]} | (io_vs1[2] ? {{4 {vroResult_8_tmp_0_data_update_10[7] & signed_shift}}, vroResult_8_tmp_0_data_update_10[7:4]} : vroResult_8_tmp_0_data_update_10) : 8'h00)} : 64'h0000000000000000) | (_eewVd_sew_oneHot_T_1 ? {(_io_vd_T_40 ? {vroResult_16_tmp_3_data_update_3[0], vroResult_16_tmp_3_data_update_3[1], vroResult_16_tmp_3_data_update_3[2], vroResult_16_tmp_3_data_update_3[3], vroResult_16_tmp_3_data_update_3[4], vroResult_16_tmp_3_data_update_3[5], vroResult_16_tmp_3_data_update_3[6], vroResult_16_tmp_3_data_update_3[7], vroResult_16_tmp_3_data_update_3[8], vroResult_16_tmp_3_data_update_3[9], vroResult_16_tmp_3_data_update_3[10], vroResult_16_tmp_3_data_update_3[11], vroResult_16_tmp_3_data_update_3[12], vroResult_16_tmp_3_data_update_3[13], vroResult_16_tmp_3_data_update_3[14], vroResult_16_tmp_3_data_update_3[15]} | (_vroShift16_neg_3_T_2[3] ? {{8 {vroResult_16_tmp_3_data_update_6[15] & signed_shift}}, vroResult_16_tmp_3_data_update_6[15:8]} : vroResult_16_tmp_3_data_update_6) : 16'h0000) | (_io_vd_T_41 ? {vroResult_16_tmp_3_data_update_11[0], vroResult_16_tmp_3_data_update_11[1], vroResult_16_tmp_3_data_update_11[2], vroResult_16_tmp_3_data_update_11[3], vroResult_16_tmp_3_data_update_11[4], vroResult_16_tmp_3_data_update_11[5], vroResult_16_tmp_3_data_update_11[6], vroResult_16_tmp_3_data_update_11[7], vroResult_16_tmp_3_data_update_11[8], vroResult_16_tmp_3_data_update_11[9], vroResult_16_tmp_3_data_update_11[10], vroResult_16_tmp_3_data_update_11[11], vroResult_16_tmp_3_data_update_11[12], vroResult_16_tmp_3_data_update_11[13], vroResult_16_tmp_3_data_update_11[14], vroResult_16_tmp_3_data_update_11[15]} | (io_vs1[51] ? {{8 {vroResult_16_tmp_3_data_update_14[15] & signed_shift}}, vroResult_16_tmp_3_data_update_14[15:8]} : vroResult_16_tmp_3_data_update_14) : 16'h0000), (_io_vd_T_40 ? {vroResult_16_tmp_2_data_update_3[0], vroResult_16_tmp_2_data_update_3[1], vroResult_16_tmp_2_data_update_3[2], vroResult_16_tmp_2_data_update_3[3], vroResult_16_tmp_2_data_update_3[4], vroResult_16_tmp_2_data_update_3[5], vroResult_16_tmp_2_data_update_3[6], vroResult_16_tmp_2_data_update_3[7], vroResult_16_tmp_2_data_update_3[8], vroResult_16_tmp_2_data_update_3[9], vroResult_16_tmp_2_data_update_3[10], vroResult_16_tmp_2_data_update_3[11], vroResult_16_tmp_2_data_update_3[12], vroResult_16_tmp_2_data_update_3[13], vroResult_16_tmp_2_data_update_3[14], vroResult_16_tmp_2_data_update_3[15]} | (_vroShift16_neg_2_T_2[3] ? {{8 {vroResult_16_tmp_2_data_update_6[15] & signed_shift}}, vroResult_16_tmp_2_data_update_6[15:8]} : vroResult_16_tmp_2_data_update_6) : 16'h0000) | (_io_vd_T_41 ? {vroResult_16_tmp_2_data_update_11[0], vroResult_16_tmp_2_data_update_11[1], vroResult_16_tmp_2_data_update_11[2], vroResult_16_tmp_2_data_update_11[3], vroResult_16_tmp_2_data_update_11[4], vroResult_16_tmp_2_data_update_11[5], vroResult_16_tmp_2_data_update_11[6], vroResult_16_tmp_2_data_update_11[7], vroResult_16_tmp_2_data_update_11[8], vroResult_16_tmp_2_data_update_11[9], vroResult_16_tmp_2_data_update_11[10], vroResult_16_tmp_2_data_update_11[11], vroResult_16_tmp_2_data_update_11[12], vroResult_16_tmp_2_data_update_11[13], vroResult_16_tmp_2_data_update_11[14], vroResult_16_tmp_2_data_update_11[15]} | (io_vs1[35] ? {{8 {vroResult_16_tmp_2_data_update_14[15] & signed_shift}}, vroResult_16_tmp_2_data_update_14[15:8]} : vroResult_16_tmp_2_data_update_14) : 16'h0000), (_io_vd_T_40 ? {vroResult_16_tmp_1_data_update_3[0], vroResult_16_tmp_1_data_update_3[1], vroResult_16_tmp_1_data_update_3[2], vroResult_16_tmp_1_data_update_3[3], vroResult_16_tmp_1_data_update_3[4], vroResult_16_tmp_1_data_update_3[5], vroResult_16_tmp_1_data_update_3[6], vroResult_16_tmp_1_data_update_3[7], vroResult_16_tmp_1_data_update_3[8], vroResult_16_tmp_1_data_update_3[9], vroResult_16_tmp_1_data_update_3[10], vroResult_16_tmp_1_data_update_3[11], vroResult_16_tmp_1_data_update_3[12], vroResult_16_tmp_1_data_update_3[13], vroResult_16_tmp_1_data_update_3[14], vroResult_16_tmp_1_data_update_3[15]} | (_vroShift16_neg_1_T_2[3] ? {{8 {vroResult_16_tmp_1_data_update_6[15] & signed_shift}}, vroResult_16_tmp_1_data_update_6[15:8]} : vroResult_16_tmp_1_data_update_6) : 16'h0000) | (_io_vd_T_41 ? {vroResult_16_tmp_1_data_update_11[0], vroResult_16_tmp_1_data_update_11[1], vroResult_16_tmp_1_data_update_11[2], vroResult_16_tmp_1_data_update_11[3], vroResult_16_tmp_1_data_update_11[4], vroResult_16_tmp_1_data_update_11[5], vroResult_16_tmp_1_data_update_11[6], vroResult_16_tmp_1_data_update_11[7], vroResult_16_tmp_1_data_update_11[8], vroResult_16_tmp_1_data_update_11[9], vroResult_16_tmp_1_data_update_11[10], vroResult_16_tmp_1_data_update_11[11], vroResult_16_tmp_1_data_update_11[12], vroResult_16_tmp_1_data_update_11[13], vroResult_16_tmp_1_data_update_11[14], vroResult_16_tmp_1_data_update_11[15]} | (io_vs1[19] ? {{8 {vroResult_16_tmp_1_data_update_14[15] & signed_shift}}, vroResult_16_tmp_1_data_update_14[15:8]} : vroResult_16_tmp_1_data_update_14) : 16'h0000), (_io_vd_T_40 ? {vroResult_16_tmp_0_data_update_3[0], vroResult_16_tmp_0_data_update_3[1], vroResult_16_tmp_0_data_update_3[2], vroResult_16_tmp_0_data_update_3[3], vroResult_16_tmp_0_data_update_3[4], vroResult_16_tmp_0_data_update_3[5], vroResult_16_tmp_0_data_update_3[6], vroResult_16_tmp_0_data_update_3[7], vroResult_16_tmp_0_data_update_3[8], vroResult_16_tmp_0_data_update_3[9], vroResult_16_tmp_0_data_update_3[10], vroResult_16_tmp_0_data_update_3[11], vroResult_16_tmp_0_data_update_3[12], vroResult_16_tmp_0_data_update_3[13], vroResult_16_tmp_0_data_update_3[14], vroResult_16_tmp_0_data_update_3[15]} | (_vroShift16_neg_0_T_2[3] ? {{8 {vroResult_16_tmp_0_data_update_6[15] & signed_shift}}, vroResult_16_tmp_0_data_update_6[15:8]} : vroResult_16_tmp_0_data_update_6) : 16'h0000) | (_io_vd_T_41 ? {vroResult_16_tmp_0_data_update_11[0], vroResult_16_tmp_0_data_update_11[1], vroResult_16_tmp_0_data_update_11[2], vroResult_16_tmp_0_data_update_11[3], vroResult_16_tmp_0_data_update_11[4], vroResult_16_tmp_0_data_update_11[5], vroResult_16_tmp_0_data_update_11[6], vroResult_16_tmp_0_data_update_11[7], vroResult_16_tmp_0_data_update_11[8], vroResult_16_tmp_0_data_update_11[9], vroResult_16_tmp_0_data_update_11[10], vroResult_16_tmp_0_data_update_11[11], vroResult_16_tmp_0_data_update_11[12], vroResult_16_tmp_0_data_update_11[13], vroResult_16_tmp_0_data_update_11[14], vroResult_16_tmp_0_data_update_11[15]} | (io_vs1[3] ? {{8 {vroResult_16_tmp_0_data_update_14[15] & signed_shift}}, vroResult_16_tmp_0_data_update_14[15:8]} : vroResult_16_tmp_0_data_update_14) : 16'h0000)} : 64'h0000000000000000);
	wire [63:0] _GEN_6 = (_eewVd_sew_oneHot_T_2 ? {(_io_vd_T_40 ? {vroResult_32_tmp_1_data_update_4[0], vroResult_32_tmp_1_data_update_4[1], vroResult_32_tmp_1_data_update_4[2], vroResult_32_tmp_1_data_update_4[3], vroResult_32_tmp_1_data_update_4[4], vroResult_32_tmp_1_data_update_4[5], vroResult_32_tmp_1_data_update_4[6], vroResult_32_tmp_1_data_update_4[7], vroResult_32_tmp_1_data_update_4[8], vroResult_32_tmp_1_data_update_4[9], vroResult_32_tmp_1_data_update_4[10], vroResult_32_tmp_1_data_update_4[11], vroResult_32_tmp_1_data_update_4[12], vroResult_32_tmp_1_data_update_4[13], vroResult_32_tmp_1_data_update_4[14], vroResult_32_tmp_1_data_update_4[15], vroResult_32_tmp_1_data_update_4[16], vroResult_32_tmp_1_data_update_4[17], vroResult_32_tmp_1_data_update_4[18], vroResult_32_tmp_1_data_update_4[19], vroResult_32_tmp_1_data_update_4[20], vroResult_32_tmp_1_data_update_4[21], vroResult_32_tmp_1_data_update_4[22], vroResult_32_tmp_1_data_update_4[23], vroResult_32_tmp_1_data_update_4[24], vroResult_32_tmp_1_data_update_4[25], vroResult_32_tmp_1_data_update_4[26], vroResult_32_tmp_1_data_update_4[27], vroResult_32_tmp_1_data_update_4[28], vroResult_32_tmp_1_data_update_4[29], vroResult_32_tmp_1_data_update_4[30], vroResult_32_tmp_1_data_update_4[31]} | (_vroShift32_neg_1_T_2[4] ? {{16 {vroResult_32_tmp_1_data_update_8[31] & signed_shift}}, vroResult_32_tmp_1_data_update_8[31:16]} : vroResult_32_tmp_1_data_update_8) : 32'h00000000) | (_io_vd_T_41 ? {vroResult_32_tmp_1_data_update_14[0], vroResult_32_tmp_1_data_update_14[1], vroResult_32_tmp_1_data_update_14[2], vroResult_32_tmp_1_data_update_14[3], vroResult_32_tmp_1_data_update_14[4], vroResult_32_tmp_1_data_update_14[5], vroResult_32_tmp_1_data_update_14[6], vroResult_32_tmp_1_data_update_14[7], vroResult_32_tmp_1_data_update_14[8], vroResult_32_tmp_1_data_update_14[9], vroResult_32_tmp_1_data_update_14[10], vroResult_32_tmp_1_data_update_14[11], vroResult_32_tmp_1_data_update_14[12], vroResult_32_tmp_1_data_update_14[13], vroResult_32_tmp_1_data_update_14[14], vroResult_32_tmp_1_data_update_14[15], vroResult_32_tmp_1_data_update_14[16], vroResult_32_tmp_1_data_update_14[17], vroResult_32_tmp_1_data_update_14[18], vroResult_32_tmp_1_data_update_14[19], vroResult_32_tmp_1_data_update_14[20], vroResult_32_tmp_1_data_update_14[21], vroResult_32_tmp_1_data_update_14[22], vroResult_32_tmp_1_data_update_14[23], vroResult_32_tmp_1_data_update_14[24], vroResult_32_tmp_1_data_update_14[25], vroResult_32_tmp_1_data_update_14[26], vroResult_32_tmp_1_data_update_14[27], vroResult_32_tmp_1_data_update_14[28], vroResult_32_tmp_1_data_update_14[29], vroResult_32_tmp_1_data_update_14[30], vroResult_32_tmp_1_data_update_14[31]} | (io_vs1[36] ? {{16 {vroResult_32_tmp_1_data_update_18[31] & signed_shift}}, vroResult_32_tmp_1_data_update_18[31:16]} : vroResult_32_tmp_1_data_update_18) : 32'h00000000), (_io_vd_T_40 ? {vroResult_32_tmp_0_data_update_4[0], vroResult_32_tmp_0_data_update_4[1], vroResult_32_tmp_0_data_update_4[2], vroResult_32_tmp_0_data_update_4[3], vroResult_32_tmp_0_data_update_4[4], vroResult_32_tmp_0_data_update_4[5], vroResult_32_tmp_0_data_update_4[6], vroResult_32_tmp_0_data_update_4[7], vroResult_32_tmp_0_data_update_4[8], vroResult_32_tmp_0_data_update_4[9], vroResult_32_tmp_0_data_update_4[10], vroResult_32_tmp_0_data_update_4[11], vroResult_32_tmp_0_data_update_4[12], vroResult_32_tmp_0_data_update_4[13], vroResult_32_tmp_0_data_update_4[14], vroResult_32_tmp_0_data_update_4[15], vroResult_32_tmp_0_data_update_4[16], vroResult_32_tmp_0_data_update_4[17], vroResult_32_tmp_0_data_update_4[18], vroResult_32_tmp_0_data_update_4[19], vroResult_32_tmp_0_data_update_4[20], vroResult_32_tmp_0_data_update_4[21], vroResult_32_tmp_0_data_update_4[22], vroResult_32_tmp_0_data_update_4[23], vroResult_32_tmp_0_data_update_4[24], vroResult_32_tmp_0_data_update_4[25], vroResult_32_tmp_0_data_update_4[26], vroResult_32_tmp_0_data_update_4[27], vroResult_32_tmp_0_data_update_4[28], vroResult_32_tmp_0_data_update_4[29], vroResult_32_tmp_0_data_update_4[30], vroResult_32_tmp_0_data_update_4[31]} | (_vroShift32_neg_0_T_2[4] ? {{16 {vroResult_32_tmp_0_data_update_8[31] & signed_shift}}, vroResult_32_tmp_0_data_update_8[31:16]} : vroResult_32_tmp_0_data_update_8) : 32'h00000000) | (_io_vd_T_41 ? {vroResult_32_tmp_0_data_update_14[0], vroResult_32_tmp_0_data_update_14[1], vroResult_32_tmp_0_data_update_14[2], vroResult_32_tmp_0_data_update_14[3], vroResult_32_tmp_0_data_update_14[4], vroResult_32_tmp_0_data_update_14[5], vroResult_32_tmp_0_data_update_14[6], vroResult_32_tmp_0_data_update_14[7], vroResult_32_tmp_0_data_update_14[8], vroResult_32_tmp_0_data_update_14[9], vroResult_32_tmp_0_data_update_14[10], vroResult_32_tmp_0_data_update_14[11], vroResult_32_tmp_0_data_update_14[12], vroResult_32_tmp_0_data_update_14[13], vroResult_32_tmp_0_data_update_14[14], vroResult_32_tmp_0_data_update_14[15], vroResult_32_tmp_0_data_update_14[16], vroResult_32_tmp_0_data_update_14[17], vroResult_32_tmp_0_data_update_14[18], vroResult_32_tmp_0_data_update_14[19], vroResult_32_tmp_0_data_update_14[20], vroResult_32_tmp_0_data_update_14[21], vroResult_32_tmp_0_data_update_14[22], vroResult_32_tmp_0_data_update_14[23], vroResult_32_tmp_0_data_update_14[24], vroResult_32_tmp_0_data_update_14[25], vroResult_32_tmp_0_data_update_14[26], vroResult_32_tmp_0_data_update_14[27], vroResult_32_tmp_0_data_update_14[28], vroResult_32_tmp_0_data_update_14[29], vroResult_32_tmp_0_data_update_14[30], vroResult_32_tmp_0_data_update_14[31]} | (io_vs1[4] ? {{16 {vroResult_32_tmp_0_data_update_18[31] & signed_shift}}, vroResult_32_tmp_0_data_update_18[31:16]} : vroResult_32_tmp_0_data_update_18) : 32'h00000000)} : 64'h0000000000000000) | (&io_vdType[1:0] ? (_io_vd_T_40 ? {vroResult_64_tmp_0_data_update_5[0], vroResult_64_tmp_0_data_update_5[1], vroResult_64_tmp_0_data_update_5[2], vroResult_64_tmp_0_data_update_5[3], vroResult_64_tmp_0_data_update_5[4], vroResult_64_tmp_0_data_update_5[5], vroResult_64_tmp_0_data_update_5[6], vroResult_64_tmp_0_data_update_5[7], vroResult_64_tmp_0_data_update_5[8], vroResult_64_tmp_0_data_update_5[9], vroResult_64_tmp_0_data_update_5[10], vroResult_64_tmp_0_data_update_5[11], vroResult_64_tmp_0_data_update_5[12], vroResult_64_tmp_0_data_update_5[13], vroResult_64_tmp_0_data_update_5[14], vroResult_64_tmp_0_data_update_5[15], vroResult_64_tmp_0_data_update_5[16], vroResult_64_tmp_0_data_update_5[17], vroResult_64_tmp_0_data_update_5[18], vroResult_64_tmp_0_data_update_5[19], vroResult_64_tmp_0_data_update_5[20], vroResult_64_tmp_0_data_update_5[21], vroResult_64_tmp_0_data_update_5[22], vroResult_64_tmp_0_data_update_5[23], vroResult_64_tmp_0_data_update_5[24], vroResult_64_tmp_0_data_update_5[25], vroResult_64_tmp_0_data_update_5[26], vroResult_64_tmp_0_data_update_5[27], vroResult_64_tmp_0_data_update_5[28], vroResult_64_tmp_0_data_update_5[29], vroResult_64_tmp_0_data_update_5[30], vroResult_64_tmp_0_data_update_5[31], vroResult_64_tmp_0_data_update_5[32], vroResult_64_tmp_0_data_update_5[33], vroResult_64_tmp_0_data_update_5[34], vroResult_64_tmp_0_data_update_5[35], vroResult_64_tmp_0_data_update_5[36], vroResult_64_tmp_0_data_update_5[37], vroResult_64_tmp_0_data_update_5[38], vroResult_64_tmp_0_data_update_5[39], vroResult_64_tmp_0_data_update_5[40], vroResult_64_tmp_0_data_update_5[41], vroResult_64_tmp_0_data_update_5[42], vroResult_64_tmp_0_data_update_5[43], vroResult_64_tmp_0_data_update_5[44], vroResult_64_tmp_0_data_update_5[45], vroResult_64_tmp_0_data_update_5[46], vroResult_64_tmp_0_data_update_5[47], vroResult_64_tmp_0_data_update_5[48], vroResult_64_tmp_0_data_update_5[49], vroResult_64_tmp_0_data_update_5[50], vroResult_64_tmp_0_data_update_5[51], vroResult_64_tmp_0_data_update_5[52], vroResult_64_tmp_0_data_update_5[53], vroResult_64_tmp_0_data_update_5[54], vroResult_64_tmp_0_data_update_5[55], vroResult_64_tmp_0_data_update_5[56], vroResult_64_tmp_0_data_update_5[57], vroResult_64_tmp_0_data_update_5[58], vroResult_64_tmp_0_data_update_5[59], vroResult_64_tmp_0_data_update_5[60], vroResult_64_tmp_0_data_update_5[61], vroResult_64_tmp_0_data_update_5[62], vroResult_64_tmp_0_data_update_5[63]} | (_vroShift64_neg_0_T_2[5] ? {{32 {vroResult_64_tmp_0_data_update_10[63] & signed_shift}}, vroResult_64_tmp_0_data_update_10[63:32]} : vroResult_64_tmp_0_data_update_10) : 64'h0000000000000000) | (_io_vd_T_41 ? {vroResult_64_tmp_0_data_update_17[0], vroResult_64_tmp_0_data_update_17[1], vroResult_64_tmp_0_data_update_17[2], vroResult_64_tmp_0_data_update_17[3], vroResult_64_tmp_0_data_update_17[4], vroResult_64_tmp_0_data_update_17[5], vroResult_64_tmp_0_data_update_17[6], vroResult_64_tmp_0_data_update_17[7], vroResult_64_tmp_0_data_update_17[8], vroResult_64_tmp_0_data_update_17[9], vroResult_64_tmp_0_data_update_17[10], vroResult_64_tmp_0_data_update_17[11], vroResult_64_tmp_0_data_update_17[12], vroResult_64_tmp_0_data_update_17[13], vroResult_64_tmp_0_data_update_17[14], vroResult_64_tmp_0_data_update_17[15], vroResult_64_tmp_0_data_update_17[16], vroResult_64_tmp_0_data_update_17[17], vroResult_64_tmp_0_data_update_17[18], vroResult_64_tmp_0_data_update_17[19], vroResult_64_tmp_0_data_update_17[20], vroResult_64_tmp_0_data_update_17[21], vroResult_64_tmp_0_data_update_17[22], vroResult_64_tmp_0_data_update_17[23], vroResult_64_tmp_0_data_update_17[24], vroResult_64_tmp_0_data_update_17[25], vroResult_64_tmp_0_data_update_17[26], vroResult_64_tmp_0_data_update_17[27], vroResult_64_tmp_0_data_update_17[28], vroResult_64_tmp_0_data_update_17[29], vroResult_64_tmp_0_data_update_17[30], vroResult_64_tmp_0_data_update_17[31], vroResult_64_tmp_0_data_update_17[32], vroResult_64_tmp_0_data_update_17[33], vroResult_64_tmp_0_data_update_17[34], vroResult_64_tmp_0_data_update_17[35], vroResult_64_tmp_0_data_update_17[36], vroResult_64_tmp_0_data_update_17[37], vroResult_64_tmp_0_data_update_17[38], vroResult_64_tmp_0_data_update_17[39], vroResult_64_tmp_0_data_update_17[40], vroResult_64_tmp_0_data_update_17[41], vroResult_64_tmp_0_data_update_17[42], vroResult_64_tmp_0_data_update_17[43], vroResult_64_tmp_0_data_update_17[44], vroResult_64_tmp_0_data_update_17[45], vroResult_64_tmp_0_data_update_17[46], vroResult_64_tmp_0_data_update_17[47], vroResult_64_tmp_0_data_update_17[48], vroResult_64_tmp_0_data_update_17[49], vroResult_64_tmp_0_data_update_17[50], vroResult_64_tmp_0_data_update_17[51], vroResult_64_tmp_0_data_update_17[52], vroResult_64_tmp_0_data_update_17[53], vroResult_64_tmp_0_data_update_17[54], vroResult_64_tmp_0_data_update_17[55], vroResult_64_tmp_0_data_update_17[56], vroResult_64_tmp_0_data_update_17[57], vroResult_64_tmp_0_data_update_17[58], vroResult_64_tmp_0_data_update_17[59], vroResult_64_tmp_0_data_update_17[60], vroResult_64_tmp_0_data_update_17[61], vroResult_64_tmp_0_data_update_17[62], vroResult_64_tmp_0_data_update_17[63]} | (io_vs1[5] ? {{32 {vroResult_64_tmp_0_data_update_22[63] & signed_shift}}, vroResult_64_tmp_0_data_update_22[63:32]} : vroResult_64_tmp_0_data_update_22) : 64'h0000000000000000) : 64'h0000000000000000);
	wire [27:0] vs1_tmp = (io_info_uopIdx[0] ? io_vs1[59:32] : io_vs1[27:0]);
	wire [31:0] vs2_tmp = (io_info_uopIdx[0] ? io_vs2[63:32] : io_vs2[31:0]);
	wire [15:0] wsllResult_8_tmp_0_data_update = (vs1_tmp[0] ? {vs2_tmp[0] & signed_shift, vs2_tmp[0], vs2_tmp[1], vs2_tmp[2], vs2_tmp[3], vs2_tmp[4], vs2_tmp[5], vs2_tmp[6], vs2_tmp[7], 7'h00} : {vs2_tmp[0], vs2_tmp[1], vs2_tmp[2], vs2_tmp[3], vs2_tmp[4], vs2_tmp[5], vs2_tmp[6], vs2_tmp[7], 8'h00});
	wire [15:0] wsllResult_8_tmp_0_data_update_1 = (vs1_tmp[1] ? {{2 {wsllResult_8_tmp_0_data_update[15] & signed_shift}}, wsllResult_8_tmp_0_data_update[15:2]} : wsllResult_8_tmp_0_data_update);
	wire [15:0] wsllResult_8_tmp_0_data_update_2 = (vs1_tmp[2] ? {{4 {wsllResult_8_tmp_0_data_update_1[15] & signed_shift}}, wsllResult_8_tmp_0_data_update_1[15:4]} : wsllResult_8_tmp_0_data_update_1);
	wire [15:0] wsllResult_8_tmp_0_data_update_3 = (vs1_tmp[3] ? {{8 {wsllResult_8_tmp_0_data_update_2[15] & signed_shift}}, wsllResult_8_tmp_0_data_update_2[15:8]} : wsllResult_8_tmp_0_data_update_2);
	wire [15:0] wsllResult_8_tmp_1_data_update = (vs1_tmp[8] ? {vs2_tmp[8] & signed_shift, vs2_tmp[8], vs2_tmp[9], vs2_tmp[10], vs2_tmp[11], vs2_tmp[12], vs2_tmp[13], vs2_tmp[14], vs2_tmp[15], 7'h00} : {vs2_tmp[8], vs2_tmp[9], vs2_tmp[10], vs2_tmp[11], vs2_tmp[12], vs2_tmp[13], vs2_tmp[14], vs2_tmp[15], 8'h00});
	wire [15:0] wsllResult_8_tmp_1_data_update_1 = (vs1_tmp[9] ? {{2 {wsllResult_8_tmp_1_data_update[15] & signed_shift}}, wsllResult_8_tmp_1_data_update[15:2]} : wsllResult_8_tmp_1_data_update);
	wire [15:0] wsllResult_8_tmp_1_data_update_2 = (vs1_tmp[10] ? {{4 {wsllResult_8_tmp_1_data_update_1[15] & signed_shift}}, wsllResult_8_tmp_1_data_update_1[15:4]} : wsllResult_8_tmp_1_data_update_1);
	wire [15:0] wsllResult_8_tmp_1_data_update_3 = (vs1_tmp[11] ? {{8 {wsllResult_8_tmp_1_data_update_2[15] & signed_shift}}, wsllResult_8_tmp_1_data_update_2[15:8]} : wsllResult_8_tmp_1_data_update_2);
	wire [15:0] wsllResult_8_tmp_2_data_update = (vs1_tmp[16] ? {vs2_tmp[16] & signed_shift, vs2_tmp[16], vs2_tmp[17], vs2_tmp[18], vs2_tmp[19], vs2_tmp[20], vs2_tmp[21], vs2_tmp[22], vs2_tmp[23], 7'h00} : {vs2_tmp[16], vs2_tmp[17], vs2_tmp[18], vs2_tmp[19], vs2_tmp[20], vs2_tmp[21], vs2_tmp[22], vs2_tmp[23], 8'h00});
	wire [15:0] wsllResult_8_tmp_2_data_update_1 = (vs1_tmp[17] ? {{2 {wsllResult_8_tmp_2_data_update[15] & signed_shift}}, wsllResult_8_tmp_2_data_update[15:2]} : wsllResult_8_tmp_2_data_update);
	wire [15:0] wsllResult_8_tmp_2_data_update_2 = (vs1_tmp[18] ? {{4 {wsllResult_8_tmp_2_data_update_1[15] & signed_shift}}, wsllResult_8_tmp_2_data_update_1[15:4]} : wsllResult_8_tmp_2_data_update_1);
	wire [15:0] wsllResult_8_tmp_2_data_update_3 = (vs1_tmp[19] ? {{8 {wsllResult_8_tmp_2_data_update_2[15] & signed_shift}}, wsllResult_8_tmp_2_data_update_2[15:8]} : wsllResult_8_tmp_2_data_update_2);
	wire [15:0] wsllResult_8_tmp_3_data_update = (vs1_tmp[24] ? {vs2_tmp[24] & signed_shift, vs2_tmp[24], vs2_tmp[25], vs2_tmp[26], vs2_tmp[27], vs2_tmp[28], vs2_tmp[29], vs2_tmp[30], vs2_tmp[31], 7'h00} : {vs2_tmp[24], vs2_tmp[25], vs2_tmp[26], vs2_tmp[27], vs2_tmp[28], vs2_tmp[29], vs2_tmp[30], vs2_tmp[31], 8'h00});
	wire [15:0] wsllResult_8_tmp_3_data_update_1 = (vs1_tmp[25] ? {{2 {wsllResult_8_tmp_3_data_update[15] & signed_shift}}, wsllResult_8_tmp_3_data_update[15:2]} : wsllResult_8_tmp_3_data_update);
	wire [15:0] wsllResult_8_tmp_3_data_update_2 = (vs1_tmp[26] ? {{4 {wsllResult_8_tmp_3_data_update_1[15] & signed_shift}}, wsllResult_8_tmp_3_data_update_1[15:4]} : wsllResult_8_tmp_3_data_update_1);
	wire [15:0] wsllResult_8_tmp_3_data_update_3 = (vs1_tmp[27] ? {{8 {wsllResult_8_tmp_3_data_update_2[15] & signed_shift}}, wsllResult_8_tmp_3_data_update_2[15:8]} : wsllResult_8_tmp_3_data_update_2);
	wire [31:0] wsllResult_16_tmp_0_data_update = (vs1_tmp[0] ? {vs2_tmp[0] & signed_shift, vs2_tmp[0], vs2_tmp[1], vs2_tmp[2], vs2_tmp[3], vs2_tmp[4], vs2_tmp[5], vs2_tmp[6], vs2_tmp[7], vs2_tmp[8], vs2_tmp[9], vs2_tmp[10], vs2_tmp[11], vs2_tmp[12], vs2_tmp[13], vs2_tmp[14], vs2_tmp[15], 15'h0000} : {vs2_tmp[0], vs2_tmp[1], vs2_tmp[2], vs2_tmp[3], vs2_tmp[4], vs2_tmp[5], vs2_tmp[6], vs2_tmp[7], vs2_tmp[8], vs2_tmp[9], vs2_tmp[10], vs2_tmp[11], vs2_tmp[12], vs2_tmp[13], vs2_tmp[14], vs2_tmp[15], 16'h0000});
	wire [31:0] wsllResult_16_tmp_0_data_update_1 = (vs1_tmp[1] ? {{2 {wsllResult_16_tmp_0_data_update[31] & signed_shift}}, wsllResult_16_tmp_0_data_update[31:2]} : wsllResult_16_tmp_0_data_update);
	wire [31:0] wsllResult_16_tmp_0_data_update_2 = (vs1_tmp[2] ? {{4 {wsllResult_16_tmp_0_data_update_1[31] & signed_shift}}, wsllResult_16_tmp_0_data_update_1[31:4]} : wsllResult_16_tmp_0_data_update_1);
	wire [31:0] wsllResult_16_tmp_0_data_update_3 = (vs1_tmp[3] ? {{8 {wsllResult_16_tmp_0_data_update_2[31] & signed_shift}}, wsllResult_16_tmp_0_data_update_2[31:8]} : wsllResult_16_tmp_0_data_update_2);
	wire [31:0] wsllResult_16_tmp_0_data_update_4 = (vs1_tmp[4] ? {{16 {wsllResult_16_tmp_0_data_update_3[31] & signed_shift}}, wsllResult_16_tmp_0_data_update_3[31:16]} : wsllResult_16_tmp_0_data_update_3);
	wire [31:0] wsllResult_16_tmp_1_data_update = (vs1_tmp[16] ? {vs2_tmp[16] & signed_shift, vs2_tmp[16], vs2_tmp[17], vs2_tmp[18], vs2_tmp[19], vs2_tmp[20], vs2_tmp[21], vs2_tmp[22], vs2_tmp[23], vs2_tmp[24], vs2_tmp[25], vs2_tmp[26], vs2_tmp[27], vs2_tmp[28], vs2_tmp[29], vs2_tmp[30], vs2_tmp[31], 15'h0000} : {vs2_tmp[16], vs2_tmp[17], vs2_tmp[18], vs2_tmp[19], vs2_tmp[20], vs2_tmp[21], vs2_tmp[22], vs2_tmp[23], vs2_tmp[24], vs2_tmp[25], vs2_tmp[26], vs2_tmp[27], vs2_tmp[28], vs2_tmp[29], vs2_tmp[30], vs2_tmp[31], 16'h0000});
	wire [31:0] wsllResult_16_tmp_1_data_update_1 = (vs1_tmp[17] ? {{2 {wsllResult_16_tmp_1_data_update[31] & signed_shift}}, wsllResult_16_tmp_1_data_update[31:2]} : wsllResult_16_tmp_1_data_update);
	wire [31:0] wsllResult_16_tmp_1_data_update_2 = (vs1_tmp[18] ? {{4 {wsllResult_16_tmp_1_data_update_1[31] & signed_shift}}, wsllResult_16_tmp_1_data_update_1[31:4]} : wsllResult_16_tmp_1_data_update_1);
	wire [31:0] wsllResult_16_tmp_1_data_update_3 = (vs1_tmp[19] ? {{8 {wsllResult_16_tmp_1_data_update_2[31] & signed_shift}}, wsllResult_16_tmp_1_data_update_2[31:8]} : wsllResult_16_tmp_1_data_update_2);
	wire [31:0] wsllResult_16_tmp_1_data_update_4 = (vs1_tmp[20] ? {{16 {wsllResult_16_tmp_1_data_update_3[31] & signed_shift}}, wsllResult_16_tmp_1_data_update_3[31:16]} : wsllResult_16_tmp_1_data_update_3);
	wire [63:0] wsllResult_32_tmp_0_data_update = (vs1_tmp[0] ? {vs2_tmp[0] & signed_shift, vs2_tmp[0], vs2_tmp[1], vs2_tmp[2], vs2_tmp[3], vs2_tmp[4], vs2_tmp[5], vs2_tmp[6], vs2_tmp[7], vs2_tmp[8], vs2_tmp[9], vs2_tmp[10], vs2_tmp[11], vs2_tmp[12], vs2_tmp[13], vs2_tmp[14], vs2_tmp[15], vs2_tmp[16], vs2_tmp[17], vs2_tmp[18], vs2_tmp[19], vs2_tmp[20], vs2_tmp[21], vs2_tmp[22], vs2_tmp[23], vs2_tmp[24], vs2_tmp[25], vs2_tmp[26], vs2_tmp[27], vs2_tmp[28], vs2_tmp[29], vs2_tmp[30], vs2_tmp[31], 31'h00000000} : {vs2_tmp[0], vs2_tmp[1], vs2_tmp[2], vs2_tmp[3], vs2_tmp[4], vs2_tmp[5], vs2_tmp[6], vs2_tmp[7], vs2_tmp[8], vs2_tmp[9], vs2_tmp[10], vs2_tmp[11], vs2_tmp[12], vs2_tmp[13], vs2_tmp[14], vs2_tmp[15], vs2_tmp[16], vs2_tmp[17], vs2_tmp[18], vs2_tmp[19], vs2_tmp[20], vs2_tmp[21], vs2_tmp[22], vs2_tmp[23], vs2_tmp[24], vs2_tmp[25], vs2_tmp[26], vs2_tmp[27], vs2_tmp[28], vs2_tmp[29], vs2_tmp[30], vs2_tmp[31], 32'h00000000});
	wire [63:0] wsllResult_32_tmp_0_data_update_1 = (vs1_tmp[1] ? {{2 {wsllResult_32_tmp_0_data_update[63] & signed_shift}}, wsllResult_32_tmp_0_data_update[63:2]} : wsllResult_32_tmp_0_data_update);
	wire [63:0] wsllResult_32_tmp_0_data_update_2 = (vs1_tmp[2] ? {{4 {wsllResult_32_tmp_0_data_update_1[63] & signed_shift}}, wsllResult_32_tmp_0_data_update_1[63:4]} : wsllResult_32_tmp_0_data_update_1);
	wire [63:0] wsllResult_32_tmp_0_data_update_3 = (vs1_tmp[3] ? {{8 {wsllResult_32_tmp_0_data_update_2[63] & signed_shift}}, wsllResult_32_tmp_0_data_update_2[63:8]} : wsllResult_32_tmp_0_data_update_2);
	wire [63:0] wsllResult_32_tmp_0_data_update_4 = (vs1_tmp[4] ? {{16 {wsllResult_32_tmp_0_data_update_3[63] & signed_shift}}, wsllResult_32_tmp_0_data_update_3[63:16]} : wsllResult_32_tmp_0_data_update_3);
	wire [63:0] wsllResult_32_tmp_0_data_update_5 = (vs1_tmp[5] ? {{32 {wsllResult_32_tmp_0_data_update_4[63] & signed_shift}}, wsllResult_32_tmp_0_data_update_4[63:32]} : wsllResult_32_tmp_0_data_update_4);
	wire _io_vd_T_43 = io_opcode_op == 6'h37;
	function automatic [6:0] sv2v_cast_7;
		input reg [6:0] inp;
		sv2v_cast_7 = inp;
	endfunction
	wire [63:0] _GEN_7 = ((((_io_vd_T_30 | _io_vd_T_31) | _io_vd_T_33 ? ((((_GEN_2 | (_io_vd_T_31 ? {io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7]} : 64'h0000000000000000)) | (_io_vd_T_33 & _eewVd_sew_oneHot_T ? io_vs2 : 64'h0000000000000000)) | (_io_vd_T_33 & _eewVd_sew_oneHot_T_1 ? {io_vs2[55:48], io_vs2[63:56], io_vs2[39:32], io_vs2[47:40], io_vs2[23:16], io_vs2[31:24], io_vs2[7:0], io_vs2[15:8]} : 64'h0000000000000000)) | (_io_vd_T_33 & _eewVd_sew_oneHot_T_2 ? {io_vs2[39:32], io_vs2[47:40], io_vs2[55:48], io_vs2[63:56], io_vs2[7:0], io_vs2[15:8], io_vs2[23:16], io_vs2[31:24]} : 64'h0000000000000000)) | (_io_vd_T_33 & (&io_vdType[1:0]) ? {io_vs2[7:0], io_vs2[15:8], io_vs2[23:16], io_vs2[31:24], io_vs2[39:32], io_vs2[47:40], io_vs2[55:48], io_vs2[63:56]} : 64'h0000000000000000) : 64'h0000000000000000) | ((_io_vd_T_35 | _io_vd_T_36) | _io_vd_T_38 ? (((((_io_vd_T_35 | _io_vd_T_36) | _io_vd_T_38) & _eewVd_sew_oneHot_T ? {1'h0, _cnt8_7_T_23, 2'h0, _cnt8_6_T_23, 3'h0, _cnt8_5_T_23, 3'h0, _cnt8_4_T_23, 4'h0, _cnt8_3_T_23, 4'h0, _cnt8_2_T_23, 4'h0, _cnt8_1_T_23, 4'h0, _cnt8_0_T_23} : 64'h0000000000000000) | (((_io_vd_T_35 | _io_vd_T_36) | _io_vd_T_38) & _eewVd_sew_oneHot_T_1 ? {9'h000, (_io_vd_T_38 ? {2'h0, _pop_16_3_T} : _cnt64_tmp_clz_io_out), 10'h000, (_io_vd_T_38 ? _GEN_3 : _cnt32_tmp_clz_io_out), 11'h000, (_io_vd_T_38 ? _pop_16_1_T : _cnt16_1_tmp_clz_io_out), 11'h000, (_io_vd_T_38 ? _pop_16_0_T : _cnt16_0_tmp_clz_io_out)} : 64'h0000000000000000)) | (((_io_vd_T_35 | _io_vd_T_36) | _io_vd_T_38) & _eewVd_sew_oneHot_T_2 ? {25'h0000000, (_io_vd_T_38 ? _GEN_4 : _cnt64_tmp_clz_io_out), 26'h0000000, (_io_vd_T_38 ? pop_32_0 : _cnt32_tmp_clz_io_out)} : 64'h0000000000000000)) | (((_io_vd_T_35 | _io_vd_T_36) | _io_vd_T_38) & (&io_vdType[1:0]) ? {57'h000000000000000, (_io_vd_T_38 ? sv2v_cast_7({1'h0, pop_32_0} + _GEN_4) : _cnt64_tmp_clz_io_out)} : 64'h0000000000000000) : 64'h0000000000000000)) | (_io_vd_T_40 | _io_vd_T_41 ? _GEN_5 | _GEN_6 : 64'h0000000000000000)) | (_io_vd_T_43 ? ((_io_vd_T_43 & _eewVd_sew_oneHot_T_1 ? {wsllResult_8_tmp_3_data_update_3[0], wsllResult_8_tmp_3_data_update_3[1], wsllResult_8_tmp_3_data_update_3[2], wsllResult_8_tmp_3_data_update_3[3], wsllResult_8_tmp_3_data_update_3[4], wsllResult_8_tmp_3_data_update_3[5], wsllResult_8_tmp_3_data_update_3[6], wsllResult_8_tmp_3_data_update_3[7], wsllResult_8_tmp_3_data_update_3[8], wsllResult_8_tmp_3_data_update_3[9], wsllResult_8_tmp_3_data_update_3[10], wsllResult_8_tmp_3_data_update_3[11], wsllResult_8_tmp_3_data_update_3[12], wsllResult_8_tmp_3_data_update_3[13], wsllResult_8_tmp_3_data_update_3[14], wsllResult_8_tmp_3_data_update_3[15], wsllResult_8_tmp_2_data_update_3[0], wsllResult_8_tmp_2_data_update_3[1], wsllResult_8_tmp_2_data_update_3[2], wsllResult_8_tmp_2_data_update_3[3], wsllResult_8_tmp_2_data_update_3[4], wsllResult_8_tmp_2_data_update_3[5], wsllResult_8_tmp_2_data_update_3[6], wsllResult_8_tmp_2_data_update_3[7], wsllResult_8_tmp_2_data_update_3[8], wsllResult_8_tmp_2_data_update_3[9], wsllResult_8_tmp_2_data_update_3[10], wsllResult_8_tmp_2_data_update_3[11], wsllResult_8_tmp_2_data_update_3[12], wsllResult_8_tmp_2_data_update_3[13], wsllResult_8_tmp_2_data_update_3[14], wsllResult_8_tmp_2_data_update_3[15], wsllResult_8_tmp_1_data_update_3[0], wsllResult_8_tmp_1_data_update_3[1], wsllResult_8_tmp_1_data_update_3[2], wsllResult_8_tmp_1_data_update_3[3], wsllResult_8_tmp_1_data_update_3[4], wsllResult_8_tmp_1_data_update_3[5], wsllResult_8_tmp_1_data_update_3[6], wsllResult_8_tmp_1_data_update_3[7], wsllResult_8_tmp_1_data_update_3[8], wsllResult_8_tmp_1_data_update_3[9], wsllResult_8_tmp_1_data_update_3[10], wsllResult_8_tmp_1_data_update_3[11], wsllResult_8_tmp_1_data_update_3[12], wsllResult_8_tmp_1_data_update_3[13], wsllResult_8_tmp_1_data_update_3[14], wsllResult_8_tmp_1_data_update_3[15], wsllResult_8_tmp_0_data_update_3[0], wsllResult_8_tmp_0_data_update_3[1], wsllResult_8_tmp_0_data_update_3[2], wsllResult_8_tmp_0_data_update_3[3], wsllResult_8_tmp_0_data_update_3[4], wsllResult_8_tmp_0_data_update_3[5], wsllResult_8_tmp_0_data_update_3[6], wsllResult_8_tmp_0_data_update_3[7], wsllResult_8_tmp_0_data_update_3[8], wsllResult_8_tmp_0_data_update_3[9], wsllResult_8_tmp_0_data_update_3[10], wsllResult_8_tmp_0_data_update_3[11], wsllResult_8_tmp_0_data_update_3[12], wsllResult_8_tmp_0_data_update_3[13], wsllResult_8_tmp_0_data_update_3[14], wsllResult_8_tmp_0_data_update_3[15]} : 64'h0000000000000000) | (_io_vd_T_43 & _eewVd_sew_oneHot_T_2 ? {wsllResult_16_tmp_1_data_update_4[0], wsllResult_16_tmp_1_data_update_4[1], wsllResult_16_tmp_1_data_update_4[2], wsllResult_16_tmp_1_data_update_4[3], wsllResult_16_tmp_1_data_update_4[4], wsllResult_16_tmp_1_data_update_4[5], wsllResult_16_tmp_1_data_update_4[6], wsllResult_16_tmp_1_data_update_4[7], wsllResult_16_tmp_1_data_update_4[8], wsllResult_16_tmp_1_data_update_4[9], wsllResult_16_tmp_1_data_update_4[10], wsllResult_16_tmp_1_data_update_4[11], wsllResult_16_tmp_1_data_update_4[12], wsllResult_16_tmp_1_data_update_4[13], wsllResult_16_tmp_1_data_update_4[14], wsllResult_16_tmp_1_data_update_4[15], wsllResult_16_tmp_1_data_update_4[16], wsllResult_16_tmp_1_data_update_4[17], wsllResult_16_tmp_1_data_update_4[18], wsllResult_16_tmp_1_data_update_4[19], wsllResult_16_tmp_1_data_update_4[20], wsllResult_16_tmp_1_data_update_4[21], wsllResult_16_tmp_1_data_update_4[22], wsllResult_16_tmp_1_data_update_4[23], wsllResult_16_tmp_1_data_update_4[24], wsllResult_16_tmp_1_data_update_4[25], wsllResult_16_tmp_1_data_update_4[26], wsllResult_16_tmp_1_data_update_4[27], wsllResult_16_tmp_1_data_update_4[28], wsllResult_16_tmp_1_data_update_4[29], wsllResult_16_tmp_1_data_update_4[30], wsllResult_16_tmp_1_data_update_4[31], wsllResult_16_tmp_0_data_update_4[0], wsllResult_16_tmp_0_data_update_4[1], wsllResult_16_tmp_0_data_update_4[2], wsllResult_16_tmp_0_data_update_4[3], wsllResult_16_tmp_0_data_update_4[4], wsllResult_16_tmp_0_data_update_4[5], wsllResult_16_tmp_0_data_update_4[6], wsllResult_16_tmp_0_data_update_4[7], wsllResult_16_tmp_0_data_update_4[8], wsllResult_16_tmp_0_data_update_4[9], wsllResult_16_tmp_0_data_update_4[10], wsllResult_16_tmp_0_data_update_4[11], wsllResult_16_tmp_0_data_update_4[12], wsllResult_16_tmp_0_data_update_4[13], wsllResult_16_tmp_0_data_update_4[14], wsllResult_16_tmp_0_data_update_4[15], wsllResult_16_tmp_0_data_update_4[16], wsllResult_16_tmp_0_data_update_4[17], wsllResult_16_tmp_0_data_update_4[18], wsllResult_16_tmp_0_data_update_4[19], wsllResult_16_tmp_0_data_update_4[20], wsllResult_16_tmp_0_data_update_4[21], wsllResult_16_tmp_0_data_update_4[22], wsllResult_16_tmp_0_data_update_4[23], wsllResult_16_tmp_0_data_update_4[24], wsllResult_16_tmp_0_data_update_4[25], wsllResult_16_tmp_0_data_update_4[26], wsllResult_16_tmp_0_data_update_4[27], wsllResult_16_tmp_0_data_update_4[28], wsllResult_16_tmp_0_data_update_4[29], wsllResult_16_tmp_0_data_update_4[30], wsllResult_16_tmp_0_data_update_4[31]} : 64'h0000000000000000)) | (_io_vd_T_43 & (&io_vdType[1:0]) ? {wsllResult_32_tmp_0_data_update_5[0], wsllResult_32_tmp_0_data_update_5[1], wsllResult_32_tmp_0_data_update_5[2], wsllResult_32_tmp_0_data_update_5[3], wsllResult_32_tmp_0_data_update_5[4], wsllResult_32_tmp_0_data_update_5[5], wsllResult_32_tmp_0_data_update_5[6], wsllResult_32_tmp_0_data_update_5[7], wsllResult_32_tmp_0_data_update_5[8], wsllResult_32_tmp_0_data_update_5[9], wsllResult_32_tmp_0_data_update_5[10], wsllResult_32_tmp_0_data_update_5[11], wsllResult_32_tmp_0_data_update_5[12], wsllResult_32_tmp_0_data_update_5[13], wsllResult_32_tmp_0_data_update_5[14], wsllResult_32_tmp_0_data_update_5[15], wsllResult_32_tmp_0_data_update_5[16], wsllResult_32_tmp_0_data_update_5[17], wsllResult_32_tmp_0_data_update_5[18], wsllResult_32_tmp_0_data_update_5[19], wsllResult_32_tmp_0_data_update_5[20], wsllResult_32_tmp_0_data_update_5[21], wsllResult_32_tmp_0_data_update_5[22], wsllResult_32_tmp_0_data_update_5[23], wsllResult_32_tmp_0_data_update_5[24], wsllResult_32_tmp_0_data_update_5[25], wsllResult_32_tmp_0_data_update_5[26], wsllResult_32_tmp_0_data_update_5[27], wsllResult_32_tmp_0_data_update_5[28], wsllResult_32_tmp_0_data_update_5[29], wsllResult_32_tmp_0_data_update_5[30], wsllResult_32_tmp_0_data_update_5[31], wsllResult_32_tmp_0_data_update_5[32], wsllResult_32_tmp_0_data_update_5[33], wsllResult_32_tmp_0_data_update_5[34], wsllResult_32_tmp_0_data_update_5[35], wsllResult_32_tmp_0_data_update_5[36], wsllResult_32_tmp_0_data_update_5[37], wsllResult_32_tmp_0_data_update_5[38], wsllResult_32_tmp_0_data_update_5[39], wsllResult_32_tmp_0_data_update_5[40], wsllResult_32_tmp_0_data_update_5[41], wsllResult_32_tmp_0_data_update_5[42], wsllResult_32_tmp_0_data_update_5[43], wsllResult_32_tmp_0_data_update_5[44], wsllResult_32_tmp_0_data_update_5[45], wsllResult_32_tmp_0_data_update_5[46], wsllResult_32_tmp_0_data_update_5[47], wsllResult_32_tmp_0_data_update_5[48], wsllResult_32_tmp_0_data_update_5[49], wsllResult_32_tmp_0_data_update_5[50], wsllResult_32_tmp_0_data_update_5[51], wsllResult_32_tmp_0_data_update_5[52], wsllResult_32_tmp_0_data_update_5[53], wsllResult_32_tmp_0_data_update_5[54], wsllResult_32_tmp_0_data_update_5[55], wsllResult_32_tmp_0_data_update_5[56], wsllResult_32_tmp_0_data_update_5[57], wsllResult_32_tmp_0_data_update_5[58], wsllResult_32_tmp_0_data_update_5[59], wsllResult_32_tmp_0_data_update_5[60], wsllResult_32_tmp_0_data_update_5[61], wsllResult_32_tmp_0_data_update_5[62], wsllResult_32_tmp_0_data_update_5[63]} : 64'h0000000000000000) : 64'h0000000000000000);
	CLZ_7 cnt16_0_tmp_clz(
		.io_in((_eewVd_sew_oneHot_T ? {(_io_vd_T_35 ? io_vs2[39:32] : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39]}), 8'h80} : 16'h0000) | (_eewVd_sew_oneHot_T_1 ? (_io_vd_T_35 ? io_vs2[15:0] : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15]}) : 16'h0000)),
		.io_out(_cnt16_0_tmp_clz_io_out)
	);
	CLZ_7 cnt16_1_tmp_clz(
		.io_in((_eewVd_sew_oneHot_T ? {(_io_vd_T_35 ? io_vs2[47:40] : {io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47]}), 8'h80} : 16'h0000) | (_eewVd_sew_oneHot_T_1 ? (_io_vd_T_35 ? io_vs2[31:16] : {io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]}) : 16'h0000)),
		.io_out(_cnt16_1_tmp_clz_io_out)
	);
	CLZ_9 cnt32_tmp_clz(
		.io_in(((_eewVd_sew_oneHot_T ? {(_io_vd_T_35 ? io_vs2[55:48] : {io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55]}), 24'h800000} : 32'h00000000) | (_eewVd_sew_oneHot_T_1 ? {(_io_vd_T_35 ? io_vs2[47:32] : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47]}), 16'h8000} : 32'h00000000)) | (_eewVd_sew_oneHot_T_2 ? (_io_vd_T_35 ? io_vs2[31:0] : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]}) : 32'h00000000)),
		.io_out(_cnt32_tmp_clz_io_out)
	);
	CLZ_6 cnt64_tmp_clz(
		.io_in((((_eewVd_sew_oneHot_T ? {(_io_vd_T_35 ? io_vs2[63:56] : {io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]}), 56'h80000000000000} : 64'h0000000000000000) | (_eewVd_sew_oneHot_T_1 ? {(_io_vd_T_35 ? io_vs2[63:48] : {io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]}), 48'h800000000000} : 64'h0000000000000000)) | (_eewVd_sew_oneHot_T_2 ? {(_io_vd_T_35 ? io_vs2[63:32] : {io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]}), 32'h80000000} : 64'h0000000000000000)) | (&io_vdType[1:0] ? (_io_vd_T_35 ? io_vs2 : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7], io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15], io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23], io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31], io_vs2[32], io_vs2[33], io_vs2[34], io_vs2[35], io_vs2[36], io_vs2[37], io_vs2[38], io_vs2[39], io_vs2[40], io_vs2[41], io_vs2[42], io_vs2[43], io_vs2[44], io_vs2[45], io_vs2[46], io_vs2[47], io_vs2[48], io_vs2[49], io_vs2[50], io_vs2[51], io_vs2[52], io_vs2[53], io_vs2[54], io_vs2[55], io_vs2[56], io_vs2[57], io_vs2[58], io_vs2[59], io_vs2[60], io_vs2[61], io_vs2[62], io_vs2[63]}) : 64'h0000000000000000)),
		.io_out(_cnt64_tmp_clz_io_out)
	);
	CLZ_11 cnt8_0_clz(
		.io_in((_io_vd_T_35 ? io_vs2[7:0] : {io_vs2[0], io_vs2[1], io_vs2[2], io_vs2[3], io_vs2[4], io_vs2[5], io_vs2[6], io_vs2[7]})),
		.io_out(_cnt8_0_clz_io_out)
	);
	CLZ_11 cnt8_1_clz(
		.io_in((_io_vd_T_35 ? io_vs2[15:8] : {io_vs2[8], io_vs2[9], io_vs2[10], io_vs2[11], io_vs2[12], io_vs2[13], io_vs2[14], io_vs2[15]})),
		.io_out(_cnt8_1_clz_io_out)
	);
	CLZ_11 cnt8_2_clz(
		.io_in((_io_vd_T_35 ? io_vs2[23:16] : {io_vs2[16], io_vs2[17], io_vs2[18], io_vs2[19], io_vs2[20], io_vs2[21], io_vs2[22], io_vs2[23]})),
		.io_out(_cnt8_2_clz_io_out)
	);
	CLZ_11 cnt8_3_clz(
		.io_in((_io_vd_T_35 ? io_vs2[31:24] : {io_vs2[24], io_vs2[25], io_vs2[26], io_vs2[27], io_vs2[28], io_vs2[29], io_vs2[30], io_vs2[31]})),
		.io_out(_cnt8_3_clz_io_out)
	);
	assign io_vd = (((((((leftShift | (io_opcode_op == 6'h10)) | (io_opcode_op == 6'h1f)) | _io_vd_T_5) | _io_vd_T_6 ? (leftShift ? {shiftOut[0], shiftOut[1], shiftOut[2], shiftOut[3], shiftOut[4], shiftOut[5], shiftOut[6], shiftOut[7], shiftOut[8], shiftOut[9], shiftOut[10], shiftOut[11], shiftOut[12], shiftOut[13], shiftOut[14], shiftOut[15], shiftOut[16], shiftOut[17], shiftOut[18], shiftOut[19], shiftOut[20], shiftOut[21], shiftOut[22], shiftOut[23], shiftOut[24], shiftOut[25], shiftOut[26], shiftOut[27], shiftOut[28], shiftOut[29], shiftOut[30], shiftOut[31], shiftOut[32], shiftOut[33], shiftOut[34], shiftOut[35], shiftOut[36], shiftOut[37], shiftOut[38], shiftOut[39], shiftOut[40], shiftOut[41], shiftOut[42], shiftOut[43], shiftOut[44], shiftOut[45], shiftOut[46], shiftOut[47], shiftOut[48], shiftOut[49], shiftOut[50], shiftOut[51], shiftOut[52], shiftOut[53], shiftOut[54], shiftOut[55], shiftOut[56], shiftOut[57], shiftOut[58], shiftOut[59], shiftOut[60], shiftOut[61], shiftOut[62], shiftOut[63]} : shiftOut) : 64'h0000000000000000) | (io_opcode_op == 6'h02 ? (_vd_sub_srcType_T_2 == 2'h1 ? (_eewVd_sew_oneHot_T_1 ? {{8 {_extResult_T_5[31] & signed_0}}, _extResult_T_5[31:24], {8 {_extResult_T_5[23] & signed_0}}, _extResult_T_5[23:16], {8 {_extResult_T_5[15] & signed_0}}, _extResult_T_5[15:8], {8 {_extResult_T_5[7] & signed_0}}, _extResult_T_5[7:0]} : (_eewVd_sew_oneHot_T_2 ? {{16 {_extResult_T_32[31] & signed_0}}, _extResult_T_32[31:16], {16 {_extResult_T_32[15] & signed_0}}, _extResult_T_32[15:0]} : {{32 {_extResult_T_48[31] & signed_0}}, _extResult_T_48})) : (_vd_sub_srcType_T_2 == 2'h2 ? (_eewVd_sew_oneHot_T_2 ? {{24 {_extResult_T_67[15] & signed_0}}, _extResult_T_67[15:8], {24 {_extResult_T_67[7] & signed_0}}, _extResult_T_67[7:0]} : {{48 {_extResult_T_89[15] & signed_0}}, _extResult_T_89}) : {{56 {_extResult_T_118[7] & signed_0}}, _extResult_T_118})) : 64'h0000000000000000)) | (((((((_io_vd_T_10 | _io_vd_T_11) | _io_vd_T_13) | _io_vd_T_15) | _io_vd_T_17) | _io_vd_T_19) | _io_vd_T_21) | _io_vd_T_23 ? (((((((_io_vd_T_10 ? _bitLogical_T_3 : 64'h0000000000000000) | (_io_vd_T_11 ? ~_bitLogical_T_3 : 64'h0000000000000000)) | (_io_vd_T_13 ? io_vs2 & ~io_vs1 : 64'h0000000000000000)) | (_io_vd_T_15 ? _bitLogical_T_19 : 64'h0000000000000000)) | (_io_vd_T_17 ? _bitLogical_T_13 : 64'h0000000000000000)) | (_io_vd_T_19 ? ~_bitLogical_T_13 : 64'h0000000000000000)) | (_io_vd_T_21 ? io_vs2 | ~io_vs1 : 64'h0000000000000000)) | (_io_vd_T_23 ? ~_bitLogical_T_19 : 64'h0000000000000000) : 64'h0000000000000000)) | (((io_opcode_op == 6'h19) | (io_opcode_op == 6'h1a)) | _io_vd_T_28 ? (io_info_vm | _io_vd_T_28 ? io_vs1 : {(vmask_adjust[7] ? io_vs1[63:56] : io_vs2[63:56]), (vmask_adjust[6] ? io_vs1[55:48] : io_vs2[55:48]), (vmask_adjust[5] ? io_vs1[47:40] : io_vs2[47:40]), (vmask_adjust[4] ? io_vs1[39:32] : io_vs2[39:32]), (vmask_adjust[3] ? io_vs1[31:24] : io_vs2[31:24]), (vmask_adjust[2] ? io_vs1[23:16] : io_vs2[23:16]), (vmask_adjust[1] ? io_vs1[15:8] : io_vs2[15:8]), (vmask_adjust[0] ? io_vs1[7:0] : io_vs2[7:0])}) : 64'h0000000000000000)) | _GEN_7;
	assign io_narrowVd = ((_eewVd_sew_oneHot_T_2 ? shiftOut[31:0] : 32'h00000000) | (_eewVd_sew_oneHot_T_1 ? {shiftOut[47:32], shiftOut[15:0]} : 32'h00000000)) | (_eewVd_sew_oneHot_T ? {shiftOut[55:48], shiftOut[39:32], shiftOut[23:16], shiftOut[7:0]} : 32'h00000000);
	assign io_toFixP_shiftOut = shiftOut;
	assign io_toFixP_rnd_high = (_GEN ? {{4 {(vs1_adjust[36] ? data_update_12[15] : rnd_high_update_12)}}, {4 {(vs1_adjust[4] ? data_update_8[15] : rnd_high_update_8)}}} : (_GEN_0 ? {{2 {(vs1_adjust[51] ? data_update_24[7] : rnd_high_update_24)}}, {2 {(vs1_adjust[35] ? data_update_21[7] : rnd_high_update_21)}}, {2 {(vs1_adjust[19] ? data_update_18[7] : rnd_high_update_18)}}, {2 {(vs1_adjust[3] ? data_update_15[7] : rnd_high_update_15)}}} : (_GEN_1 ? {(vs1_adjust[58] ? data_update_40[3] : rnd_high_update_40), (vs1_adjust[50] ? data_update_38[3] : rnd_high_update_38), (vs1_adjust[42] ? data_update_36[3] : rnd_high_update_36), (vs1_adjust[34] ? data_update_34[3] : rnd_high_update_34), (vs1_adjust[26] ? data_update_32[3] : rnd_high_update_32), (vs1_adjust[18] ? data_update_30[3] : rnd_high_update_30), (vs1_adjust[10] ? data_update_28[3] : rnd_high_update_28), (vs1_adjust[2] ? data_update_26[3] : rnd_high_update_26)} : {8 {(vs1_adjust[5] ? data_update_4[31] : rnd_high_update_4)}})));
	assign io_toFixP_rnd_tail = (_GEN ? {{4 {(((~vs1_adjust[36] | ((data_update_12[14:0] == 15'h0000) & ~rnd_high_update_12)) & (~vs1_adjust[35] | ((data_update_11[6:0] == 7'h00) & ~rnd_high_update_11))) & (~vs1_adjust[34] | ((data_update_10[2:0] == 3'h0) & ~rnd_high_update_10))) & (~vs1_adjust[33] | (~data_update_9[0] & ~rnd_high_update_9))}}, {4 {(((~vs1_adjust[4] | ((data_update_8[14:0] == 15'h0000) & ~rnd_high_update_8)) & (~vs1_adjust[3] | ((data_update_7[6:0] == 7'h00) & ~rnd_high_update_7))) & (~vs1_adjust[2] | ((data_update_6[2:0] == 3'h0) & ~rnd_high_update_6))) & (~vs1_adjust[1] | (~data_update_5[0] & ~rnd_high_update_5))}}} : (_GEN_0 ? {{2 {((~vs1_adjust[51] | ((data_update_24[6:0] == 7'h00) & ~rnd_high_update_24)) & (~vs1_adjust[50] | ((data_update_23[2:0] == 3'h0) & ~rnd_high_update_23))) & (~vs1_adjust[49] | (~data_update_22[0] & ~rnd_high_update_22))}}, {2 {((~vs1_adjust[35] | ((data_update_21[6:0] == 7'h00) & ~rnd_high_update_21)) & (~vs1_adjust[34] | ((data_update_20[2:0] == 3'h0) & ~rnd_high_update_20))) & (~vs1_adjust[33] | (~data_update_19[0] & ~rnd_high_update_19))}}, {2 {((~vs1_adjust[19] | ((data_update_18[6:0] == 7'h00) & ~rnd_high_update_18)) & (~vs1_adjust[18] | ((data_update_17[2:0] == 3'h0) & ~rnd_high_update_17))) & (~vs1_adjust[17] | (~data_update_16[0] & ~rnd_high_update_16))}}, {2 {((~vs1_adjust[3] | ((data_update_15[6:0] == 7'h00) & ~rnd_high_update_15)) & (~vs1_adjust[2] | ((data_update_14[2:0] == 3'h0) & ~rnd_high_update_14))) & (~vs1_adjust[1] | (~data_update_13[0] & ~rnd_high_update_13))}}} : (_GEN_1 ? {(~vs1_adjust[58] | ((data_update_40[2:0] == 3'h0) & ~rnd_high_update_40)) & (~vs1_adjust[57] | (~data_update_39[0] & ~rnd_high_update_39)), (~vs1_adjust[50] | ((data_update_38[2:0] == 3'h0) & ~rnd_high_update_38)) & (~vs1_adjust[49] | (~data_update_37[0] & ~rnd_high_update_37)), (~vs1_adjust[42] | ((data_update_36[2:0] == 3'h0) & ~rnd_high_update_36)) & (~vs1_adjust[41] | (~data_update_35[0] & ~rnd_high_update_35)), (~vs1_adjust[34] | ((data_update_34[2:0] == 3'h0) & ~rnd_high_update_34)) & (~vs1_adjust[33] | (~data_update_33[0] & ~rnd_high_update_33)), (~vs1_adjust[26] | ((data_update_32[2:0] == 3'h0) & ~rnd_high_update_32)) & (~vs1_adjust[25] | (~data_update_31[0] & ~rnd_high_update_31)), (~vs1_adjust[18] | ((data_update_30[2:0] == 3'h0) & ~rnd_high_update_30)) & (~vs1_adjust[17] | (~data_update_29[0] & ~rnd_high_update_29)), (~vs1_adjust[10] | ((data_update_28[2:0] == 3'h0) & ~rnd_high_update_28)) & (~vs1_adjust[9] | (~data_update_27[0] & ~rnd_high_update_27)), (~vs1_adjust[2] | ((data_update_26[2:0] == 3'h0) & ~rnd_high_update_26)) & (~vs1_adjust[1] | (~data_update_25[0] & ~rnd_high_update_25))} : {8 {((((~vs1_adjust[5] | ((data_update_4[30:0] == 31'h00000000) & ~rnd_high_update_4)) & (~vs1_adjust[4] | ((data_update_3[14:0] == 15'h0000) & ~rnd_high_update_3))) & (~vs1_adjust[3] | ((data_update_2[6:0] == 7'h00) & ~rnd_high_update_2))) & (~vs1_adjust[2] | ((data_update_1[2:0] == 3'h0) & ~rnd_high_update_1))) & (~vs1_adjust[1] | (~data_update[0] & ~rnd_high_update))}})));
endmodule
module VecDataSplitModule (
	io_inVecData,
	io_outVec8b_0,
	io_outVec8b_1,
	io_outVec8b_2,
	io_outVec8b_3,
	io_outVec8b_4,
	io_outVec8b_5,
	io_outVec8b_6,
	io_outVec8b_7,
	io_outVec8b_8,
	io_outVec8b_9,
	io_outVec8b_10,
	io_outVec8b_11,
	io_outVec8b_12,
	io_outVec8b_13,
	io_outVec8b_14,
	io_outVec8b_15,
	io_outVec16b_0,
	io_outVec16b_1,
	io_outVec16b_2,
	io_outVec16b_3,
	io_outVec16b_4,
	io_outVec16b_5,
	io_outVec16b_6,
	io_outVec16b_7,
	io_outVec32b_0,
	io_outVec32b_1,
	io_outVec32b_2,
	io_outVec32b_3,
	io_outVec64b_0,
	io_outVec64b_1
);
	input [127:0] io_inVecData;
	output wire [7:0] io_outVec8b_0;
	output wire [7:0] io_outVec8b_1;
	output wire [7:0] io_outVec8b_2;
	output wire [7:0] io_outVec8b_3;
	output wire [7:0] io_outVec8b_4;
	output wire [7:0] io_outVec8b_5;
	output wire [7:0] io_outVec8b_6;
	output wire [7:0] io_outVec8b_7;
	output wire [7:0] io_outVec8b_8;
	output wire [7:0] io_outVec8b_9;
	output wire [7:0] io_outVec8b_10;
	output wire [7:0] io_outVec8b_11;
	output wire [7:0] io_outVec8b_12;
	output wire [7:0] io_outVec8b_13;
	output wire [7:0] io_outVec8b_14;
	output wire [7:0] io_outVec8b_15;
	output wire [15:0] io_outVec16b_0;
	output wire [15:0] io_outVec16b_1;
	output wire [15:0] io_outVec16b_2;
	output wire [15:0] io_outVec16b_3;
	output wire [15:0] io_outVec16b_4;
	output wire [15:0] io_outVec16b_5;
	output wire [15:0] io_outVec16b_6;
	output wire [15:0] io_outVec16b_7;
	output wire [31:0] io_outVec32b_0;
	output wire [31:0] io_outVec32b_1;
	output wire [31:0] io_outVec32b_2;
	output wire [31:0] io_outVec32b_3;
	output wire [63:0] io_outVec64b_0;
	output wire [63:0] io_outVec64b_1;
	assign io_outVec8b_0 = io_inVecData[7:0];
	assign io_outVec8b_1 = io_inVecData[15:8];
	assign io_outVec8b_2 = io_inVecData[23:16];
	assign io_outVec8b_3 = io_inVecData[31:24];
	assign io_outVec8b_4 = io_inVecData[39:32];
	assign io_outVec8b_5 = io_inVecData[47:40];
	assign io_outVec8b_6 = io_inVecData[55:48];
	assign io_outVec8b_7 = io_inVecData[63:56];
	assign io_outVec8b_8 = io_inVecData[71:64];
	assign io_outVec8b_9 = io_inVecData[79:72];
	assign io_outVec8b_10 = io_inVecData[87:80];
	assign io_outVec8b_11 = io_inVecData[95:88];
	assign io_outVec8b_12 = io_inVecData[103:96];
	assign io_outVec8b_13 = io_inVecData[111:104];
	assign io_outVec8b_14 = io_inVecData[119:112];
	assign io_outVec8b_15 = io_inVecData[127:120];
	assign io_outVec16b_0 = io_inVecData[15:0];
	assign io_outVec16b_1 = io_inVecData[31:16];
	assign io_outVec16b_2 = io_inVecData[47:32];
	assign io_outVec16b_3 = io_inVecData[63:48];
	assign io_outVec16b_4 = io_inVecData[79:64];
	assign io_outVec16b_5 = io_inVecData[95:80];
	assign io_outVec16b_6 = io_inVecData[111:96];
	assign io_outVec16b_7 = io_inVecData[127:112];
	assign io_outVec32b_0 = io_inVecData[31:0];
	assign io_outVec32b_1 = io_inVecData[63:32];
	assign io_outVec32b_2 = io_inVecData[95:64];
	assign io_outVec32b_3 = io_inVecData[127:96];
	assign io_outVec64b_0 = io_inVecData[63:0];
	assign io_outVec64b_1 = io_inVecData[127:64];
endmodule
