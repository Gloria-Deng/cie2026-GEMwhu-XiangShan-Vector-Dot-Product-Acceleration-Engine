






















`timescale 1ns / 1ps

`ifndef CASE_FILE
  `define CASE_FILE "cases.txt"
`endif
`ifndef VL_V
  `define VL_V 8
`endif
`ifndef VM_V
  `define VM_V 1
`endif
`ifndef SEW_V
  `define SEW_V 0
`endif
`ifndef LMUL_V
  `define LMUL_V 0
`endif
`ifndef VUOP_V
  `define VUOP_V 0
`endif
`ifndef OLDVD_V
  `define OLDVD_V 128'h0
`endif
`ifndef MASK_V
  `define MASK_V {128{1'b1}}
`endif
`ifndef EXPECT_EXC
  `define EXPECT_EXC 0
`endif




`ifndef VTA_V
  `define VTA_V 0
`endif
`ifndef VMA_V
  `define VMA_V 0
`endif



`ifndef START_V
  `define START_V 0
`endif






`ifndef CHECK_DATA
  `define CHECK_DATA 1
`endif




`ifndef EXPECT_LAT
  `define EXPECT_LAT 2
`endif






`ifdef VALID_PIPE_ZERO
  `define VALID_PIPE_LEVEL 1'b0
`else
  `define VALID_PIPE_LEVEL 1'b1
`endif

module tb_vdotu_soc;

  localparam int VLEN = 128;
  localparam int MAXC = 8192;

  reg               clock;
  reg               reset;
  reg               in_valid;
  reg   [8:0]       fu_op_type;
  reg               valid_pipe;
  reg               vpu_vm;
  reg   [1:0]       vpu_sew;
  reg   [2:0]       vpu_lmul;
  reg   [7:0]       vpu_vstart;
  reg   [6:0]       vpu_vuop;
  reg   [7:0]       vl;
  reg   [VLEN-1:0]  src0;
  reg   [VLEN-1:0]  src1;
  reg   [VLEN-1:0]  mask_bits;
  reg   [VLEN-1:0]  old_vd;
  reg   [7:0]       pdest;

  wire              out_valid;
  wire  [VLEN-1:0]  res_data;
  wire              exc_vec_2;
  wire  [7:0]       out_pdest;
  wire              out_vecWen;

  VDotU dut (
    .clock                               (clock),
    .reset                               (reset),
    .io_in_valid                         (in_valid),
    .io_in_bits_ctrl_fuOpType            (fu_op_type),
    .io_in_bits_ctrlPipe_2_robIdx_flag   (1'b0),
    .io_in_bits_ctrlPipe_2_robIdx_value  (8'h21),
    .io_in_bits_ctrlPipe_2_pdest         (pdest),
    .io_in_bits_ctrlPipe_2_vecWen        (1'b1),
    .io_in_bits_ctrlPipe_2_vpu_vma       (1'b0 | `VMA_V),
    .io_in_bits_ctrlPipe_2_vpu_vta       (1'b0 | `VTA_V),
    .io_in_bits_ctrlPipe_2_vpu_vsew      (vpu_sew),
    .io_in_bits_ctrlPipe_2_vpu_vlmul     (vpu_lmul),
    .io_in_bits_ctrlPipe_2_vpu_vm        (vpu_vm),
    .io_in_bits_ctrlPipe_2_vpu_vstart    (vpu_vstart),
    .io_in_bits_ctrlPipe_2_vpu_vuopIdx   (vpu_vuop),
    .io_in_bits_validPipe_2              (valid_pipe),
    .io_in_bits_data_src_1               (src1),
    .io_in_bits_data_src_0               (src0),
    .io_in_bits_dataPipe_2_src_4         (vl),
    .io_in_bits_dataPipe_2_src_3         (mask_bits),
    .io_in_bits_dataPipe_2_src_2         (old_vd),
    .io_out_valid                        (out_valid),
    .io_out_bits_ctrl_robIdx_flag        (),
    .io_out_bits_ctrl_robIdx_value       (),
    .io_out_bits_ctrl_pdest              (out_pdest),
    .io_out_bits_ctrl_vecWen             (out_vecWen),
    .io_out_bits_ctrl_exceptionVec_2     (exc_vec_2),
    .io_out_bits_res_data                (res_data)
  );

  always #1 clock = ~clock;

  integer fd, nread, k, total, pass_n, fail_n, more;
  integer bad_valid, bad_pdest, bad_wen, bad_exc;
  integer t, first_cyc, lat_min, lat_max, bad_lat, lat_never;
  integer c_idx   [0:MAXC-1];
  reg [VLEN-1:0] c_vs1 [0:MAXC-1];
  reg [VLEN-1:0] c_vs2 [0:MAXC-1];
  reg [VLEN-1:0] c_exp [0:MAXC-1];

  initial begin
    clock     = 1'b0;
    reset     = 1'b0;
    in_valid  = 1'b0;
    fu_op_type = 9'h007;
    valid_pipe = (1'b0 | `VALID_PIPE_LEVEL);

    vpu_vm    = (1'b0 | `VM_V);
    vpu_sew   = `SEW_V;
    vpu_lmul  = `LMUL_V;
    vpu_vstart = 8'h0 | (`START_V);
    vpu_vuop  = `VUOP_V;
    vl        = `VL_V;
    mask_bits = `MASK_V;
    old_vd    = `OLDVD_V;
    pdest     = 8'h0;
    src0      = {VLEN{1'b0}};
    src1      = {VLEN{1'b0}};

    if ($test$plusargs("DUMP")) begin
      $dumpfile("wave_vdotu.vcd");
      $dumpvars(0, tb_vdotu_soc);
    end

    fd = $fopen(`CASE_FILE, "r");
    if (fd == 0) begin
      $display("TB-RESULT FAIL (cannot open case file %s)", `CASE_FILE);
      $finish;
    end
    total = 0;
    more = 1;
    while ((more != 0) && (total < MAXC)) begin
      nread = $fscanf(fd, "%d %h %h %h", c_idx[total], c_vs1[total],
                      c_vs2[total], c_exp[total]);
      if (nread != 4)
        more = 0;
      else
        total = total + 1;
    end
    $fclose(fd);
    if (total == 0) begin
      $display("TB-RESULT FAIL (%s yielded 0 parsed cases)", `CASE_FILE);
      $finish;
    end
    $display("TB-INFO cases=%0d VL=%0d VM=%0d SEW=%0d LMUL=%0d VUOP=%0d EXPECT_EXC=%0d VTA=%0d VMA=%0d START_V=%0d CHECK_DATA=%0d",
             total, `VL_V, `VM_V, `SEW_V, `LMUL_V, `VUOP_V, `EXPECT_EXC, `VTA_V, `VMA_V,
             `START_V, `CHECK_DATA);

    repeat (3) @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);
    reset = 1'b0;

    pass_n = 0; fail_n = 0;
    bad_valid = 0; bad_pdest = 0; bad_wen = 0; bad_exc = 0;
    bad_lat = 0; lat_never = 0; lat_min = -1; lat_max = -1;
    for (k = 0; k < total; k = k + 1) begin
      @(posedge clock);
      src0    <= c_vs1[k];
      src1    <= c_vs2[k];
      pdest   <= k[7:0];
      in_valid <= 1'b1;
      first_cyc = -1;



      for (t = 1; t <= (`EXPECT_LAT + 3); t = t + 1) begin
        @(posedge clock);
        if (t == 1)
          in_valid <= 1'b0;
        if ((first_cyc < 0) && (out_valid === 1'b1))
          first_cyc = t;
        if (t == (`EXPECT_LAT + 1)) begin

          if (out_valid !== 1'b1) begin
            bad_valid = bad_valid + 1;
            $display("CASE %0d FAIL out_valid=%b（包装层两级移位没给出结果）", c_idx[k], out_valid);
            fail_n = fail_n + 1;
          end else if (exc_vec_2 !== (1'b0 | `EXPECT_EXC)) begin
            bad_exc = bad_exc + 1;
            $display("CASE %0d FAIL exceptionVec[2]=%b，本档要求 expect_exc=%0d（SEW=%0d LMUL=%0d vstart=%0d）",
                     c_idx[k], exc_vec_2, `EXPECT_EXC, `SEW_V, `LMUL_V, `START_V);
            fail_n = fail_n + 1;
          end else if (out_pdest !== pdest || out_vecWen !== 1'b1) begin
            bad_pdest = bad_pdest + 1;
            $display("CASE %0d FAIL 控制旁路不对 pdest=%h vecWen=%b", c_idx[k], out_pdest, out_vecWen);
            fail_n = fail_n + 1;
          end else if ((`CHECK_DATA != 0) && (res_data !== c_exp[k])) begin
            $display("CASE %0d FAIL got=%h exp=%h", c_idx[k], res_data, c_exp[k]);
            fail_n = fail_n + 1;
          end else begin
            pass_n = pass_n + 1;
          end
        end
      end
      if (first_cyc < 0) begin
        lat_never = lat_never + 1;
      end else begin
        if (lat_min < 0 || (first_cyc - 1) < lat_min) lat_min = first_cyc - 1;
        if (lat_max < 0 || (first_cyc - 1) > lat_max) lat_max = first_cyc - 1;
        if ((first_cyc - 1) != `EXPECT_LAT) begin



          bad_lat = bad_lat + 1;
          $display("CASE %0d FAIL out_valid 落在第 %0d 拍（相对捕获 %0d），声明延迟是 %0d",
                   c_idx[k], first_cyc, first_cyc - 1, `EXPECT_LAT);
        end
      end
      @(posedge clock);
    end

    $display("SUMMARY file=%s total=%0d pass=%0d fail=%0d bad_valid=%0d bad_exc=%0d bad_ctrl=%0d lat_expect=%0d lat_min=%0d lat_max=%0d bad_lat=%0d lat_never=%0d",
             `CASE_FILE, total, pass_n, fail_n, bad_valid, bad_exc, bad_pdest,
             `EXPECT_LAT, lat_min, lat_max, bad_lat, lat_never);
    if ((fail_n == 0) && (pass_n == total) && (bad_lat == 0) && (lat_never == 0))
      $display("TB-RESULT PASS");
    else
      $display("TB-RESULT FAIL");
    $finish;
  end

  initial begin
    #20000000;
    $display("TB-RESULT FAIL (watchdog: never reached SUMMARY)");
    $finish;
  end

endmodule
