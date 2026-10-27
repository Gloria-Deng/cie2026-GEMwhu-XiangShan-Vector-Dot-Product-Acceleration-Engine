

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

module VDotU(
  input          clock,
  input          reset,
  input          io_in_valid,
  input  [8:0]   io_in_bits_ctrl_fuOpType,
  input          io_in_bits_ctrlPipe_2_robIdx_flag,
  input  [7:0]   io_in_bits_ctrlPipe_2_robIdx_value,
  input  [7:0]   io_in_bits_ctrlPipe_2_pdest,
  input          io_in_bits_ctrlPipe_2_vecWen,
  input          io_in_bits_ctrlPipe_2_vpu_vma,
  input          io_in_bits_ctrlPipe_2_vpu_vta,
  input  [1:0]   io_in_bits_ctrlPipe_2_vpu_vsew,
  input  [2:0]   io_in_bits_ctrlPipe_2_vpu_vlmul,
  input          io_in_bits_ctrlPipe_2_vpu_vm,
  input  [7:0]   io_in_bits_ctrlPipe_2_vpu_vstart,
  input  [6:0]   io_in_bits_ctrlPipe_2_vpu_vuopIdx,
  input          io_in_bits_validPipe_2,
  input  [127:0] io_in_bits_data_src_1,
  input  [127:0] io_in_bits_data_src_0,
  input  [7:0]   io_in_bits_dataPipe_2_src_4,
  input  [127:0] io_in_bits_dataPipe_2_src_3,
  input  [127:0] io_in_bits_dataPipe_2_src_2,
  output         io_out_valid,
  output         io_out_bits_ctrl_robIdx_flag,
  output [7:0]   io_out_bits_ctrl_robIdx_value,
  output [7:0]   io_out_bits_ctrl_pdest,
  output         io_out_bits_ctrl_vecWen,
  output         io_out_bits_ctrl_exceptionVec_2,
  output [127:0] io_out_bits_res_data
);

  wire [127:0] _VDotDatapath_io_vd;
  reg          validVecThisFu_1;
  reg          validVecThisFu_2;
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
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      validVecThisFu_1 <= 1'h0;
      validVecThisFu_2 <= 1'h0;
    end
    else begin
      validVecThisFu_1 <= io_in_valid;
      validVecThisFu_2 <= validVecThisFu_1;
    end
  end
  `ifdef ENABLE_INITIAL_REG_
    `ifdef FIRRTL_BEFORE_INITIAL
      `FIRRTL_BEFORE_INITIAL
    `endif
    logic [31:0] _RANDOM[0:0];
    initial begin
      `ifdef INIT_RANDOM_PROLOG_
        `INIT_RANDOM_PROLOG_
      `endif
      `ifdef RANDOMIZE_REG_INIT
        _RANDOM[               1'b0] = `RANDOM;
        validVecThisFu_1 = _RANDOM[               1'b0][0];
        validVecThisFu_2 = _RANDOM[               1'b0][1];
      `endif
      if (reset) begin
        validVecThisFu_1 = 1'h0;
        validVecThisFu_2 = 1'h0;
      end
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
    .io_vd   (_VDotDatapath_io_vd)
  );
  Mgu mgu (
    .io_in_vd           (_VDotDatapath_io_vd),
    .io_in_oldVd        (io_in_bits_dataPipe_2_src_2),
    .io_in_mask
      (io_in_bits_ctrlPipe_2_vpu_vm
         ? 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
         : io_in_bits_dataPipe_2_src_3),
    .io_in_info_ta      (io_in_bits_ctrlPipe_2_vpu_vta),
    .io_in_info_ma      (io_in_bits_ctrlPipe_2_vpu_vma),
    .io_in_info_vl      (io_in_bits_dataPipe_2_src_4),
    .io_in_info_vstart  (io_in_bits_ctrlPipe_2_vpu_vstart),
    .io_in_info_eew     (2'h0),
    .io_in_info_vdIdx   (io_in_bits_ctrlPipe_2_vpu_vuopIdx[2:0]),
    .io_in_info_narrow  (1'h0),
    .io_in_info_dstMask (1'h0),
    .io_out_vd          (io_out_bits_res_data),
    .io_out_active      (            )
  );
  assign io_out_valid = io_in_bits_validPipe_2 & validVecThisFu_2;
  assign io_out_bits_ctrl_robIdx_flag = io_in_bits_ctrlPipe_2_robIdx_flag;
  assign io_out_bits_ctrl_robIdx_value = io_in_bits_ctrlPipe_2_robIdx_value;
  assign io_out_bits_ctrl_pdest = io_in_bits_ctrlPipe_2_pdest;
  assign io_out_bits_ctrl_vecWen = io_in_bits_ctrlPipe_2_vecWen;
  assign io_out_bits_ctrl_exceptionVec_2 =
    (|io_in_bits_ctrlPipe_2_vpu_vsew) | ~(io_in_bits_ctrlPipe_2_vpu_vlmul[2])
    & (|io_in_bits_ctrlPipe_2_vpu_vlmul);
endmodule

