



































`timescale 1ns / 1ps

`ifndef CASE_FILE
  `define CASE_FILE "tests/cases_vwmul.txt"
`endif
`ifndef EXPECT_LAT
  `define EXPECT_LAT 2
`endif

module tb_vimac_soc;

  localparam int VLEN = 128;
  localparam int MAXC = 64;

  reg          clock;
  reg          reset;
  reg          in_valid;
  reg  [8:0]   op_s0;
  reg  [1:0]   sew_s0;
  reg          vm_s0, ta_s0, ma_s0;
  reg  [6:0]   vuop_s0;
  reg  [7:0]   vl_s0;
  reg  [VLEN-1:0] src0, src1, src2, src3;
  reg  [1:0]   vxrm;


  reg          vpipe1, vpipe2;
  reg  [8:0]   op_s1, op_s2;
  reg  [1:0]   sew_s1, sew_s2;
  reg          vm_s1, ta_s1, ma_s1, vm_s2, ta_s2, ma_s2;
  reg  [6:0]   vuop_s1, vuop_s2;
  reg  [7:0]   vl_s1, vl_s2;
  reg  [VLEN-1:0] src2_s1, src3_s1, src2_s2, src3_s2;
  reg  [7:0]   vstart_s2;

  wire         out_valid;
  wire [VLEN-1:0] res_data;
  wire         out_vxsat;







  VIMacU dut (
    .clock                              (clock),
    .reset                              (reset),
    .io_in_valid                        (in_valid),
    .io_in_bits_ctrl_fuOpType           (op_s0),
    .io_in_bits_ctrl_vpu_vsew           (sew_s0),
    .io_in_bits_ctrl_vpu_vuopIdx        (vuop_s0),
    .io_in_bits_ctrlPipe_2_fuOpType     (op_s2),
    .io_in_bits_ctrlPipe_2_robIdx_flag  (1'b0),
    .io_in_bits_ctrlPipe_2_robIdx_value (8'h21),
    .io_in_bits_ctrlPipe_2_pdest        (8'h11),
    .io_in_bits_ctrlPipe_2_vecWen       (1'b1),
    .io_in_bits_ctrlPipe_2_v0Wen        (1'b0),
    .io_in_bits_ctrlPipe_2_vpu_vma      (ma_s2),
    .io_in_bits_ctrlPipe_2_vpu_vta      (ta_s2),
    .io_in_bits_ctrlPipe_2_vpu_vsew     (sew_s2),
    .io_in_bits_ctrlPipe_2_vpu_vm       (vm_s2),
    .io_in_bits_ctrlPipe_2_vpu_vstart   (vstart_s2),
    .io_in_bits_ctrlPipe_2_vpu_vuopIdx  (vuop_s2),
    .io_in_bits_validPipe_2             (vpipe2),
    .io_in_bits_data_src_2              (src2),
    .io_in_bits_data_src_1              (src1),
    .io_in_bits_data_src_0              (src0),
    .io_in_bits_dataPipe_2_src_4        (vl_s2),
    .io_in_bits_dataPipe_2_src_3        (src3_s2),
    .io_in_bits_dataPipe_2_src_2        (src2_s2),
    .io_out_valid                       (out_valid),
    .io_out_bits_ctrl_robIdx_flag       (),
    .io_out_bits_ctrl_robIdx_value      (),
    .io_out_bits_ctrl_pdest             (),
    .io_out_bits_ctrl_vecWen            (),
    .io_out_bits_ctrl_v0Wen             (),
    .io_out_bits_res_data               (res_data),
    .io_out_bits_res_vxsat              (out_vxsat),
    .io_vxrm                            (vxrm)
  );

  always #1 clock = ~clock;


  always @(posedge clock or posedge reset) begin
    if (reset) begin
      vpipe1  <= 1'b0;  vpipe2  <= 1'b0;
      op_s1   <= 9'h0;  op_s2   <= 9'h0;
      sew_s1  <= 2'h0;  sew_s2  <= 2'h0;
      vm_s1   <= 1'b1;  vm_s2   <= 1'b1;
      ta_s1   <= 1'b0;  ta_s2   <= 1'b0;
      ma_s1   <= 1'b0;  ma_s2   <= 1'b0;
      vuop_s1 <= 7'h0;  vuop_s2 <= 7'h0;
      vl_s1   <= 8'h0;  vl_s2   <= 8'h0;
      src2_s1 <= {VLEN{1'b0}}; src3_s1 <= {VLEN{1'b0}};
      src2_s2 <= {VLEN{1'b0}}; src3_s2 <= {VLEN{1'b0}};
      vstart_s2 <= 8'h0;
    end else begin
      vpipe1  <= in_valid;   vpipe2  <= vpipe1;
      op_s1   <= op_s0;      op_s2   <= op_s1;
      sew_s1  <= sew_s0;     sew_s2  <= sew_s1;
      vm_s1   <= vm_s0;      vm_s2   <= vm_s1;
      ta_s1   <= ta_s0;      ta_s2   <= ta_s1;
      ma_s1   <= ma_s0;      ma_s2   <= ma_s1;
      vuop_s1 <= vuop_s0;    vuop_s2 <= vuop_s1;
      vl_s1   <= vl_s0;      vl_s2   <= vl_s1;
      src2_s1 <= src2;       src2_s2 <= src2_s1;
      src3_s1 <= src3;       src3_s2 <= src3_s1;
    end
  end

  integer fd, nread, k, total, pass_n, fail_n, more;
  integer bad_valid, bad_lat, lat_never, run_n;
  integer t, first_cyc, lat_min, lat_max;
  integer only_case, dump_case;
  reg     wrongop, dumped;
  integer c_idx  [0:MAXC-1];
  reg [VLEN-1:0] c_vs1 [0:MAXC-1];
  reg [VLEN-1:0] c_vs2 [0:MAXC-1];
  reg [VLEN-1:0] c_exp [0:MAXC-1];
  reg [VLEN-1:0] res_at_first;

  initial begin
    clock = 1'b0; reset = 1'b1;
    in_valid = 1'b0;
    op_s0    = 9'h0;
    sew_s0   = 2'h0;
    vm_s0    = 1'b1;
    ta_s0    = 1'b1; ma_s0 = 1'b1;
    vuop_s0  = 7'h0;
    vl_s0    = 8'd8;
    src0 = {VLEN{1'b0}}; src1 = {VLEN{1'b0}};
    src2 = {VLEN{1'b0}}; src3 = {VLEN{1'b1}};
    vxrm = 2'h0;
    only_case = -1; dump_case = -1; wrongop = 1'b0; dumped = 1'b0;
    if ($value$plusargs("ONLYCASE=%d", only_case)) begin
    end else begin
      only_case = -1;
    end
    if ($test$plusargs("WRONGOP")) wrongop = 1'b1;

    fd = $fopen(`CASE_FILE, "r");
    if (fd == 0) begin
      $display("TB-RESULT FAIL (cannot open case file %s)", `CASE_FILE);
      $finish;
    end
    total = 0; more = 1;
    while ((more != 0) && (total < MAXC)) begin
      nread = $fscanf(fd, "%d %h %h %h\n",
                      c_idx[total], c_vs1[total], c_vs2[total], c_exp[total]);
      if (nread != 4) more = 0; else total = total + 1;
    end
    $fclose(fd);
    if (total == 0) begin
      $display("TB-RESULT FAIL (%s yielded 0 parsed cases)", `CASE_FILE);
      $finish;
    end
    $display("TB-INFO file=%s cases=%0d fuOpType=%h expect_lat=%0d only_case=%0d wrongop=%b",
             `CASE_FILE, total, wrongop ? 9'h08 : 9'h68, `EXPECT_LAT, only_case, wrongop);

    repeat (3) @(posedge clock);
    reset = 1'b0;
    repeat (2) @(posedge clock);

    pass_n = 0; fail_n = 0; bad_valid = 0; bad_lat = 0; lat_never = 0; run_n = 0;
    lat_min = -1; lat_max = -1;

    for (k = 0; k < total; k = k + 1) begin
      if ((only_case >= 0) && (c_idx[k] != only_case)) begin

      end else begin
        run_n = run_n + 1;
        if ($test$plusargs("DUMP") && (dumped == 1'b0)) begin
          dump_case = c_idx[k];
          $dumpfile("build/vwmul_wave.vcd");
          $dumpvars(1, tb_vimac_soc);
          $dumpvars(1, tb_vimac_soc.dut);
          dumped = 1'b1;
        end
        @(posedge clock);
        src0   <= c_vs1[k];
        src1   <= c_vs2[k];
        src2   <= {VLEN{1'b0}};
        src3   <= {VLEN{1'b1}};
        sew_s0 <= 2'h0;
        vm_s0  <= 1'b1; ta_s0 <= 1'b1; ma_s0 <= 1'b1;
        vl_s0  <= 8'd8;
        vuop_s0 <= 7'h0;
        op_s0  <= wrongop ? 9'h08 : 9'h68;
        in_valid <= 1'b1;
        first_cyc = -1;






        for (t = 1; t <= (`EXPECT_LAT + 4); t = t + 1) begin
          @(posedge clock);
          if (t == 1) in_valid <= 1'b0;
          if ((first_cyc < 0) && (out_valid === 1'b1)) begin
            first_cyc = t;
            res_at_first = res_data;
          end
        end
        if (first_cyc < 0) begin
          lat_never = lat_never + 1;
          fail_n = fail_n + 1;
          $display("CASE %0d FAIL out_valid never rose within %0d edges", c_idx[k],
                   `EXPECT_LAT + 4);
        end else begin
          if (lat_min < 0 || (first_cyc - 1) < lat_min) lat_min = first_cyc - 1;
          if (lat_max < 0 || (first_cyc - 1) > lat_max) lat_max = first_cyc - 1;
          if ((first_cyc - 1) != `EXPECT_LAT) begin
            bad_lat = bad_lat + 1;
            $display("CASE %0d FAIL out_valid lands on edge %0d (latency %0d), declared latency is %0d",
                     c_idx[k], first_cyc, first_cyc - 1, `EXPECT_LAT);
          end
          if (res_at_first !== c_exp[k]) begin
            fail_n = fail_n + 1;
            $display("CASE %0d FAIL got=%h exp=%h", c_idx[k], res_at_first, c_exp[k]);
          end else if ((first_cyc - 1) == `EXPECT_LAT) begin
            pass_n = pass_n + 1;
            $display("CASE %0d OK fuOpType=%h got=%h lat=%0d", c_idx[k],
                     wrongop ? 9'h08 : 9'h68, res_at_first, first_cyc - 1);
          end else begin
            fail_n = fail_n + 1;
          end
        end
        @(posedge clock);
      end
    end

    $display("SUMMARY file=%s total=%0d run=%0d pass=%0d fail=%0d bad_valid=%0d lat_expect=%0d lat_min=%0d lat_max=%0d bad_lat=%0d lat_never=%0d",
             `CASE_FILE, total, run_n, pass_n, fail_n, bad_valid, `EXPECT_LAT,
             lat_min, lat_max, bad_lat, lat_never);
    if ((fail_n == 0) && (bad_lat == 0) && (lat_never == 0) && (run_n > 0))
      $display("TB-RESULT PASS");
    else
      $display("TB-RESULT FAIL fail=%0d bad_lat=%0d lat_never=%0d run=%0d",
               fail_n, bad_lat, lat_never, run_n);
    $finish;
  end

  initial begin
    #4000000;
    $display("TB-RESULT FAIL (watchdog: never reached SUMMARY)");
    $finish;
  end

endmodule
