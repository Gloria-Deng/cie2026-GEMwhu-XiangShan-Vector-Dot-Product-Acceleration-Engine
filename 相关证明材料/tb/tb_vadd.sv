






`timescale 1ns / 1ps

module tb_vadd;

  localparam int VLEN = 128;
  localparam int MAXC = 64;

  reg              clock;
  reg              reset;
  reg              valid;
  reg  [1:0]       sew;
  reg  [4:0]       vs1_idx, vs2_idx, vd_idx;
  reg              vm;
  reg  [VLEN-1:0]  v0;
  reg  [7:0]       vl;
  reg              vta, vma;
  wire [VLEN-1:0]  vd_out;
  wire             wb_valid;
  wire [4:0]       wb_idx;

  vadd_vv_path #(.VLEN(VLEN)) dut (
    .clock(clock), .reset(reset), .valid(valid),
    .sew(sew), .vs1_idx(vs1_idx), .vs2_idx(vs2_idx), .vd_idx(vd_idx),
    .vm(vm), .v0(v0), .vl(vl), .vta(vta), .vma(vma),
    .vd_out(vd_out), .wb_valid(wb_valid), .wb_idx(wb_idx)
  );

  always #1 clock = ~clock;

  integer fd, nread, k, total, pass_n, fail_n, more;
  integer c_sew [0:MAXC-1], c_vl [0:MAXC-1], c_vm [0:MAXC-1],
          c_vta [0:MAXC-1], c_vma [0:MAXC-1], c_idx [0:MAXC-1];
  reg [VLEN-1:0] c_vs1 [0:MAXC-1], c_vs2 [0:MAXC-1], c_old [0:MAXC-1],
                 c_v0 [0:MAXC-1], c_exp [0:MAXC-1];

  initial begin
    clock = 1'b0; reset = 1'b1; valid = 1'b0;
    sew = 2'd0; vs1_idx = 5'd1; vs2_idx = 5'd2; vd_idx = 5'd3;
    vm = 1'b1; v0 = {VLEN{1'b0}}; vl = 8'd0; vta = 1'b0; vma = 1'b0;

    if ($test$plusargs("DUMP")) begin
      $dumpfile("wave_vadd.vcd");
      $dumpvars(0, tb_vadd);
    end

    fd = $fopen(`CASE_FILE, "r");
    if (fd == 0) begin
      $display("TB-RESULT FAIL (cannot open %s)", `CASE_FILE);
      $finish;
    end
    total = 0; more = 1;
    while (more && (total < MAXC)) begin
      nread = $fscanf(fd, "%d %d %h %h %h %h %d %d %d %d %h",
                      c_idx[total], c_sew[total], c_vs1[total], c_vs2[total],
                      c_old[total], c_v0[total], c_vl[total], c_vm[total],
                      c_vta[total], c_vma[total], c_exp[total]);
      if (nread != 11) more = 0; else total = total + 1;
    end
    $fclose(fd);
    if (total == 0) begin
      $display("TB-RESULT FAIL (%s yielded 0 parsed cases)", `CASE_FILE);
      $finish;
    end

    repeat (4) @(posedge clock);
    reset = 1'b0;
    repeat (2) @(posedge clock);

    pass_n = 0; fail_n = 0;
    for (k = 0; k < total; k = k + 1) begin

      dut.preload(5'd1, c_vs1[k]);
      dut.preload(5'd2, c_vs2[k]);
      dut.preload(5'd3, c_old[k]);
      @(posedge clock);
      sew     <= c_sew[k][1:0];
      vl      <= c_vl[k][7:0];
      vm      <= c_vm[k];
      vta     <= c_vta[k];
      vma     <= c_vma[k];
      v0      <= c_v0[k];
      valid   <= 1'b1;
      @(posedge clock);
      valid   <= 1'b0;




      @(posedge clock);
      @(posedge clock);
      @(posedge clock);
      if (dut.fpr[3] !== c_exp[k]) begin
        $display("CASE %0d FAIL got=%h exp=%h", c_idx[k], dut.fpr[3], c_exp[k]);
        fail_n = fail_n + 1;
      end else begin
        $display("CASE %0d PASS sew=%0d vl=%0d vm=%0d vta=%0d vma=%0d f=%h",
                 c_idx[k], c_sew[k], c_vl[k], c_vm[k], c_vta[k], c_vma[k], dut.fpr[3]);
        pass_n = pass_n + 1;
      end
      @(posedge clock);
    end

    $display("SUMMARY vadd total=%0d pass=%0d fail=%0d", total, pass_n, fail_n);
    if ((fail_n == 0) && (pass_n == total)) $display("TB-RESULT PASS");
    else $display("TB-RESULT FAIL");
    $finish;
  end

  initial begin
    #2000000;
    $display("TB-RESULT FAIL (watchdog)");
    $finish;
  end

endmodule
