`timescale 1ns/1ps
`ifndef CASE_FILE
`define CASE_FILE "cases.txt"
`endif
`ifndef MODE
`define MODE 0
`endif
`ifndef LANE_A
`define LANE_A 0
`endif
`ifndef LANE_B
`define LANE_B 1
`endif
`ifndef NLANES
`define NLANES 8
`endif
`ifndef ACCW
`define ACCW 19
`endif

module check_datapath;
  reg clock = 0;
  reg reset = 1;
  reg fire = 0;
  reg [127:0] input_a = 0;
  reg [127:0] input_b = 0;
  reg [127:0] driven_a;
  reg [127:0] driven_b;
  wire [127:0] result;
  wire valid;
  wire [127:0] observed;
  integer stream;
  integer parsed;
  integer index;
  integer cases = 0;
  integer failures = 0;
  reg [127:0] expected;

  always #1 clock = ~clock;

  always @* begin
    driven_a = input_a;
    driven_b = input_b;
    if (`MODE == 1) driven_a[`LANE_A * 8 +: 8] = 0;
    if (`MODE == 2 || `MODE == 3) begin
      driven_a[`LANE_A * 8 +: 8] = input_a[`LANE_B * 8 +: 8];
      driven_a[`LANE_B * 8 +: 8] = input_a[`LANE_A * 8 +: 8];
    end
    if (`MODE == 3) begin
      driven_b[`LANE_A * 8 +: 8] = input_b[`LANE_B * 8 +: 8];
      driven_b[`LANE_B * 8 +: 8] = input_b[`LANE_A * 8 +: 8];
    end
  end

  generate
    if (`MODE == 4) assign observed = result | (128'd1 << 32);
    else if (`MODE == 5) assign observed = {109'd0, result[18:0]};
    else assign observed = result;
  endgenerate

`ifdef CHISEL
  VDotUnit dut(.clock(clock), .reset(reset), .io_fire(fire),
               .io_vs1(driven_a), .io_vs2(driven_b),
               .io_vd(result), .io_valid(valid));
`else
  xs_vdot_unit #(.NLANES(`NLANES), .ACCW(`ACCW)) dut(
    .clock(clock), .reset(reset), .fire(fire),
    .vs1(driven_a), .vs2(driven_b), .vd(result), .valid(valid));
`endif

  initial begin
    repeat (3) @(negedge clock);
    reset = 0;
    stream = $fopen(`CASE_FILE, "r");
    if (stream == 0) $fatal(1, "cannot read inputs");
    parsed = $fscanf(stream, "%d %h %h %h", index, input_a, input_b, expected);
    while (parsed == 4) begin
      fire = 1;
      @(negedge clock);
      fire = 0;
      @(negedge clock);
      if (valid !== 1 || observed !== expected) begin
        failures = failures + 1;
        $display("DIFFERENT case=%0d got=%032h expected=%032h valid=%b", index, observed, expected, valid);
      end
      cases = cases + 1;
      @(negedge clock);
      parsed = $fscanf(stream, "%d %h %h %h", index, input_a, input_b, expected);
    end
    if (!$feof(stream)) $fatal(1, "invalid input row");
    $fclose(stream);
    if (cases == 0) $fatal(1, "no inputs");
    $display("DATAPATH cases=%0d passed=%0d failed=%0d", cases, cases-failures, failures);
    $finish;
  end

  initial begin
    #1000000;
    $fatal(1, "timeout");
  end
endmodule
