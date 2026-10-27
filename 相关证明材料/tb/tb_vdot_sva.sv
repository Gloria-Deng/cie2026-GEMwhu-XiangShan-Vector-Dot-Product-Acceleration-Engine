








`default_nettype none
module tb_vdot_sva;
   localparam int VLEN = 128;
   localparam int OUTW = 32;

   reg               clock = 1'b0;
   reg               reset = 1'b1;
   reg               fire  = 1'b0;
   reg  [VLEN-1:0]   vs1   = {VLEN{1'b0}};
   reg  [VLEN-1:0]   vs2   = {VLEN{1'b0}};
   wire [VLEN-1:0]   vd;
   wire              valid;

   xs_vdot_unit #(.VLEN(VLEN), .SEW(8), .NLANES(8), .ACCW(19), .OUTW(OUTW), .TREE(0))
     dut (.clock(clock), .reset(reset), .fire(fire),
          .vs1(vs1), .vs2(vs2), .vd(vd), .valid(valid));


   prop_fire_lat2 : assert property (@(posedge clock) disable iff (reset)
                                      fire |-> ##2 valid)
     else $display("SVA-FAIL prop_fire_lat2 fire did not produce valid exactly 2 cycles later");


   prop_hi_zero : assert property (@(posedge clock) disable iff (reset)
                                   valid |-> (vd[VLEN-1:OUTW] == {VLEN-OUTW{1'b0}}))
     else $display("SVA-FAIL prop_hi_zero valid without the lanes above OUTW cleared");


   prop_reset_quiet : assert property (@(posedge clock)
                                       reset |=> !valid)
     else $display("SVA-FAIL prop_reset_quiet valid asserted while/after reset");


   prop_ctl_depth3 : assert property (@(posedge clock) disable iff (reset)
                                      fire |-> ##3 valid)
     else $display("SVA-CONTROL-OK prop_ctl_depth3 fired as it must (depth is not 3)");

   int i;


   int valid_cycles = 0;
   always @(posedge clock) if (valid === 1'b1) valid_cycles = valid_cycles + 1;

   localparam [VLEN-1:0] A0 = 128'h0000000000000000_0102030405060708,
                         B0 = 128'h0000000000000000_0102030405060708,



                         A1 = 128'h0000000000000000_7f7f7f7f7f7f7f7f,
                         B1 = 128'h0000000000000000_7f7f7f7f7f7f7f7f,
                         A2 = 128'h0000000000000000_7f017f017f017f01,
                         B2 = 128'h0000000000000000_017f017f017f017f;

   initial begin

      @(negedge clock); reset = 1'b0;
      for (i = 0; i < 3; i = i + 1) begin
         case (i)
           0: begin vs1 = A0; vs2 = B0; end
           1: begin vs1 = A1; vs2 = B1; end
           2: begin vs1 = A2; vs2 = B2; end
         endcase
         @(negedge clock); fire = 1'b1;
         @(negedge clock); fire = 1'b0;
         repeat (5) @(negedge clock);
      end
      @(negedge clock); reset = 1'b1;
      repeat (3) @(negedge clock);
      $display("SVA-TB-DONE fires=3 valid_cycles=%0d", valid_cycles);
      $finish;
   end

   always #1 clock = ~clock;
endmodule
`default_nettype wire
