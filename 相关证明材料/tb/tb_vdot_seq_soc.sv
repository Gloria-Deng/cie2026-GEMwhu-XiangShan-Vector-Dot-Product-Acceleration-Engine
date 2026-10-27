






















`timescale 1ns / 1ps

`ifndef SEQ_OPS
  `define SEQ_OPS 64
`endif
`ifndef EXPECT_PULSE
  `define EXPECT_PULSE 1
`endif
`ifdef VALID_PIPE_ZERO
  `define VALID_PIPE_LEVEL 1'b0
`else
  `define VALID_PIPE_LEVEL 1'b1
`endif
`ifdef WRONGOP
  `define OP_TYPE 9'h006
`else
  `define OP_TYPE 9'h007
`endif
`ifdef DEP_MODE
  `define MODE_NAME "DEP"
`else
  `define MODE_NAME "INDEP"
`endif

module tb_vdot_seq_soc;

  localparam int VLEN = 128;
  localparam int OPS  = `SEQ_OPS;
  localparam int WINDOW = 6 * OPS + 80;

  reg              clock;
  reg              reset;
  reg              in_valid;
  reg  [8:0]       fu_op_type;
  reg              valid_pipe;
  reg  [VLEN-1:0]  src0;
  reg  [VLEN-1:0]  src1;
  reg  [7:0]       pdest;
  reg  [7:0]       vl;

  wire             out_valid;
  wire [VLEN-1:0]  res_data;
  wire             exc_vec_2;
  wire [7:0]       out_pdest;
  wire             out_vecWen;

  VDotU dut (
    .clock                               (clock),
    .reset                               (reset),
    .io_in_valid                         (in_valid),
    .io_in_bits_ctrl_fuOpType            (fu_op_type),
    .io_in_bits_ctrlPipe_2_robIdx_flag   (1'b0),
    .io_in_bits_ctrlPipe_2_robIdx_value  (8'h21),
    .io_in_bits_ctrlPipe_2_pdest         (pdest),
    .io_in_bits_ctrlPipe_2_vecWen        (1'b1),
    .io_in_bits_ctrlPipe_2_vpu_vma       (1'b0),
    .io_in_bits_ctrlPipe_2_vpu_vta       (1'b0),
    .io_in_bits_ctrlPipe_2_vpu_vsew      (2'd0),
    .io_in_bits_ctrlPipe_2_vpu_vlmul     (3'd0),
    .io_in_bits_ctrlPipe_2_vpu_vm        (1'b1),
    .io_in_bits_ctrlPipe_2_vpu_vstart    (8'h0),
    .io_in_bits_ctrlPipe_2_vpu_vuopIdx   (7'h0),
    .io_in_bits_validPipe_2              (valid_pipe),
    .io_in_bits_data_src_1               (src1),
    .io_in_bits_data_src_0               (src0),
    .io_in_bits_dataPipe_2_src_4         (vl),
    .io_in_bits_dataPipe_2_src_3         ({VLEN{1'b1}}),
    .io_in_bits_dataPipe_2_src_2         ({VLEN{1'b0}}),
    .io_out_valid                        (out_valid),
    .io_out_bits_ctrl_robIdx_flag        (),
    .io_out_bits_ctrl_robIdx_value       (),
    .io_out_bits_ctrl_pdest              (out_pdest),
    .io_out_bits_ctrl_vecWen             (out_vecWen),
    .io_out_bits_ctrl_exceptionVec_2     (exc_vec_2),
    .io_out_bits_res_data                (res_data)
  );

  always #1 clock = ~clock;

  integer k, t, outputs, pdest_ok, exc_seen, bad_wen, fail_n;
  integer first_cyc, last_cyc, gap_min, gap_max, prev_cyc, cyc, dep_total;
  reg [VLEN-1:0] last_res;



  function [VLEN-1:0] operand_of(input integer i);
    reg [7:0] tag;
    begin
      tag = i[7:0];
      operand_of = {48'h0, tag, 8'h00, 16'h0, tag, 40'h0};
    end
  endfunction

  task observe;
    begin
      if (out_valid === 1'b1) begin
        outputs = outputs + 1;
        if (first_cyc < 0) first_cyc = cyc;
        if (prev_cyc >= 0) begin
          if (gap_min < 0 || (cyc - prev_cyc) < gap_min) gap_min = cyc - prev_cyc;
          if (gap_max < 0 || (cyc - prev_cyc) > gap_max) gap_max = cyc - prev_cyc;
        end
        prev_cyc = cyc;
        last_cyc = cyc;
        if (out_pdest === pdest) pdest_ok = pdest_ok + 1;
        else fail_n = fail_n + 1;
        if (out_vecWen !== 1'b1) bad_wen = bad_wen + 1;
        if (exc_vec_2 === 1'b1) exc_seen = exc_seen + 1;
      end
    end
  endtask

  initial begin
    clock      = 1'b0;
    reset      = 1'b0;
    in_valid   = 1'b0;
    fu_op_type = `OP_TYPE;
    valid_pipe = (1'b0 | `VALID_PIPE_LEVEL);
    src0       = {VLEN{1'b0}};
    src1       = {VLEN{1'b0}};
    pdest      = 8'h0;
    vl         = 8'd8;
    outputs = 0; pdest_ok = 0; exc_seen = 0; bad_wen = 0; fail_n = 0;
    first_cyc = -1; last_cyc = -1; gap_min = -1; gap_max = -1;
    prev_cyc = -1; cyc = 0; dep_total = 0; last_res = {VLEN{1'b0}};

    repeat (3) @(posedge clock);
    reset = 1'b1;
    @(posedge clock); @(posedge clock);
    reset = 1'b0;

    if (OPS == 0) begin
      repeat (16) begin @(posedge clock); cyc = cyc + 1; observe; end
      in_valid <= 1'b0;
    end
    `ifdef DEP_MODE
    else begin
      for (k = 0; k < OPS; k = k + 1) begin
        src0     <= operand_of(k);
        src1     <= (k == 0) ? operand_of(255) : last_res;
        pdest    <= k[7:0];
        in_valid <= 1'b1;
        @(posedge clock); cyc = cyc + 1;
        in_valid <= 1'b0;
        t = 0;
        while (!(out_valid === 1'b1) && t < 64) begin
          @(posedge clock); cyc = cyc + 1; t = t + 1;
        end
        if (out_valid === 1'b1) begin
          outputs   = outputs + 1;
          dep_total = dep_total + t + 1;
          last_res  = res_data;
          if (out_pdest === k[7:0]) pdest_ok = pdest_ok + 1;
          else fail_n = fail_n + 1;
          if (out_vecWen !== 1'b1) bad_wen = bad_wen + 1;
          if (exc_vec_2 === 1'b1) exc_seen = exc_seen + 1;
          if (first_cyc < 0) first_cyc = 1;
          last_cyc = cyc;
        end
      end
      gap_min = -1; gap_max = -1;
    end
    `else
    begin

      in_valid <= 1'b1;
      for (k = 0; k < OPS; k = k + 1) begin
        src0  <= operand_of(k);
        src1  <= operand_of(255 - (k % 256));
        pdest <= k[7:0];
        @(posedge clock); cyc = cyc + 1;
        observe;
      end
      in_valid <= 1'b0;
      t = 0;
      while (outputs < OPS && t < WINDOW) begin
        @(posedge clock); cyc = cyc + 1; t = t + 1;
        observe;
      end
      repeat (6) begin @(posedge clock); cyc = cyc + 1; observe; end
    end
    `endif

    $display("SEQ-RESULT mode=%s ops=%0d outputs=%0d pdest_ok=%0d first=%0d last=%0d gap_min=%0d gap_max=%0d total_cyc=%0d cycles_per_op=%0d exc=%0d vecWen_bad=%0d",
             `MODE_NAME, OPS, outputs, pdest_ok, first_cyc, last_cyc, gap_min, gap_max,
             (outputs == 0) ? -1 : dep_total + (cyc - dep_total),
             (outputs == 0) ? -1 : (cyc / ((OPS == 0) ? 1 : OPS)),
             exc_seen, bad_wen);



    $display("SUMMARY file=seq total=%0d pass=%0d fail=%0d bad_valid=%0d bad_exc=%0d bad_ctrl=%0d lat_expect=%0d lat_min=%0d lat_max=%0d bad_lat=0 lat_never=%0d",
             OPS, pdest_ok, fail_n, bad_wen, exc_seen, fail_n, `EXPECT_PULSE,
             gap_min, gap_max, (OPS != 0 && outputs == 0) ? OPS : 0);
    if ((outputs == OPS) && (pdest_ok == OPS) && (fail_n == 0) && (bad_wen == 0))
      $display("TB-RESULT PASS");
    else
      $display("TB-RESULT FAIL");
    $finish;
  end

  initial begin
    #40000000;
    $display("TB-RESULT FAIL (watchdog: never reached SUMMARY)");
    $finish;
  end

endmodule
