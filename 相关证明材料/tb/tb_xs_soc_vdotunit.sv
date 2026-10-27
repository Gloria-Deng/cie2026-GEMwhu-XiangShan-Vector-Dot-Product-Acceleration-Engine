




















`timescale 1ns / 1ps

`ifndef CASE_FILE
  `define CASE_FILE "cases.txt"
`endif

module tb_xs_soc_vdotunit;

  localparam int VLEN = 128;
  localparam int MAXC = 8192;

  reg              clock;
  reg              reset;
  reg              fire;
  reg  [VLEN-1:0]  vs1;
  reg  [VLEN-1:0]  vs2;
  wire [VLEN-1:0]  vd;

  VDotUnit dut (
    .clock (clock),
    .reset (reset),
    .io_fire (fire),
    .io_vs1  (vs1),
    .io_vs2  (vs2),
    .io_vd   (vd)
  );

  always #1 clock = ~clock;

  integer fd, nread, k, total, pass_n, fail_n, more, unstable;
  integer c_idx   [0:MAXC-1];
  reg [VLEN-1:0] c_vs1 [0:MAXC-1];
  reg [VLEN-1:0] c_vs2 [0:MAXC-1];
  reg [VLEN-1:0] c_exp [0:MAXC-1];
  reg [VLEN-1:0] got_a;
  reg [VLEN-1:0] got_b;

  initial begin
    clock = 1'b0;
    reset = 1'b0;
    fire  = 1'b0;
    vs1   = {VLEN{1'b0}};
    vs2   = {VLEN{1'b0}};

    if ($test$plusargs("DUMP")) begin
      $dumpfile("wave_xs_soc_vdotunit.vcd");
      $dumpvars(0, tb_xs_soc_vdotunit);
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
    $display("TB-INFO cases=%0d dut=rtl/xs_soc_generated/VDotUnit.sv", total);

    repeat (3) @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);
    reset = 1'b0;

    pass_n = 0; fail_n = 0; unstable = 0;
    for (k = 0; k < total; k = k + 1) begin
      @(posedge clock);
      vs1  <= c_vs1[k];
      vs2  <= c_vs2[k];
      fire <= 1'b1;
      @(posedge clock);
      fire <= 1'b0;
      @(posedge clock);
      @(posedge clock);
      got_a = vd;
      @(posedge clock);
      got_b = vd;
      if (got_a !== got_b) begin
        unstable = unstable + 1;
        $display("CASE %0d FAIL 结果在相邻两拍不稳定 %h != %h", c_idx[k], got_a, got_b);
        fail_n = fail_n + 1;
      end else if (got_a !== c_exp[k]) begin
        $display("CASE %0d FAIL got=%h exp=%h", c_idx[k], got_a, c_exp[k]);
        fail_n = fail_n + 1;
      end else begin
        pass_n = pass_n + 1;
      end
      @(posedge clock);
    end

    $display("SUMMARY file=%s total=%0d pass=%0d fail=%0d unstable=%0d",
             `CASE_FILE, total, pass_n, fail_n, unstable);
    if ((fail_n == 0) && (pass_n == total))
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
