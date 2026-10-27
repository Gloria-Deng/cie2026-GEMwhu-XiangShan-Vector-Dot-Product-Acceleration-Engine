














`timescale 1ns / 1ps

`ifndef VLEN_V
  `define VLEN_V 256
`endif
`ifndef NLANES_V
  `define NLANES_V 8
`endif
`ifndef OUTW_V
  `define OUTW_V 32
`endif
`ifndef ACCW_V
  `define ACCW_V 19
`endif
`ifndef TREE_V
  `define TREE_V 0
`endif
`ifndef SEW_V
  `define SEW_V 8
`endif
`ifndef CASE_FILE
  `define CASE_FILE "cases.txt"
`endif

module tb_vlen;

  localparam int VLEN = `VLEN_V;
  localparam int SEW  = `SEW_V;
  localparam int EPL  = VLEN / SEW;
  localparam int MAXC = 4096;

  reg               clock;
  reg               reset;
  reg               fire;
  reg   [VLEN-1:0]  vs1;
  reg   [VLEN-1:0]  vs2;
  wire  [VLEN-1:0]  vd;
  wire              valid;

  xs_vdot_unit #(
    .VLEN   (VLEN),
    .SEW    (`SEW_V),
    .NLANES (`NLANES_V),
    .ACCW   (`ACCW_V),
    .OUTW   (`OUTW_V),
    .TREE   (`TREE_V)
  ) dut (
    .clock (clock),
    .reset (reset),
    .fire  (fire),
    .vs1   (vs1),
    .vs2   (vs2),
    .vd    (vd),
    .valid (valid)
  );

  always #1 clock = ~clock;

  integer fd, nread, k, total, pass_n, fail_n, more;
  integer c_idx   [0:MAXC-1];
  reg [VLEN-1:0]  c_vs1 [0:MAXC-1];
  reg [VLEN-1:0]  c_vs2 [0:MAXC-1];
  reg [VLEN-1:0]  c_exp [0:MAXC-1];

  initial begin
    clock = 1'b0;
    reset = 1'b0;
    fire  = 1'b0;
    vs1   = {VLEN{1'b0}};
    vs2   = {VLEN{1'b0}};

    $display("TB-INFO vlen=%0d sew=%0d nlanes=%0d outw=%0d accw=%0d tree=%0d elems=%0d",
             VLEN, SEW, `NLANES_V, `OUTW_V, `ACCW_V, `TREE_V, EPL);

    fd = $fopen(`CASE_FILE, "r");
    if (fd == 0) begin
      $display("TB-RESULT FAIL (cannot open case file %s)", `CASE_FILE);
      $finish;
    end
    total = 0;
    more = 1;
    while (more && (total < MAXC)) begin
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

    repeat (3) @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    @(posedge clock);
    reset = 1'b0;

    pass_n = 0;
    fail_n = 0;
    for (k = 0; k < total; k = k + 1) begin
      @(posedge clock);
      vs1  <= c_vs1[k];
      vs2  <= c_vs2[k];
      fire <= 1'b1;
      @(posedge clock);
      fire <= 1'b0;
      @(posedge clock);
      @(posedge clock);
      if (valid !== 1'b1) begin
        $display("CASE %0d FAIL valid=%b (pipeline never marked a result)", c_idx[k], valid);
        fail_n = fail_n + 1;
      end else if (vd !== c_exp[k]) begin
        $display("CASE %0d FAIL got=%h exp=%h", c_idx[k], vd, c_exp[k]);
        fail_n = fail_n + 1;
      end else begin
        pass_n = pass_n + 1;
      end
      @(posedge clock);
    end

    $display("SUMMARY file=%s vlen=%0d sew=%0d nlanes=%0d total=%0d pass=%0d fail=%0d",
             `CASE_FILE, VLEN, SEW, `NLANES_V, total, pass_n, fail_n);
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
