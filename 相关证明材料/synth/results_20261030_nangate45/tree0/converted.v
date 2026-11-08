module VDotUnit (
	clock,
	reset,
	io_fire,
	io_vs1,
	io_vs2,
	io_vd,
	io_valid
);
	input clock;
	input reset;
	input io_fire;
	input [127:0] io_vs1;
	input [127:0] io_vs2;
	output wire [127:0] io_vd;
	output wire io_valid;
	reg [18:0] prod_0;
	reg [18:0] prod_1;
	reg [18:0] prod_2;
	reg [18:0] prod_3;
	reg [18:0] prod_4;
	reg [18:0] prod_5;
	reg [18:0] prod_6;
	reg [18:0] prod_7;
	reg fireS1;
	reg [18:0] red;
	reg validS1;
	wire [15:0] prodComb_prod = {{8 {io_vs1[7]}}, io_vs1[7:0]} * {{8 {io_vs2[7]}}, io_vs2[7:0]};
	wire [15:0] prodComb_prod_1 = {{8 {io_vs1[15]}}, io_vs1[15:8]} * {{8 {io_vs2[15]}}, io_vs2[15:8]};
	wire [15:0] prodComb_prod_2 = {{8 {io_vs1[23]}}, io_vs1[23:16]} * {{8 {io_vs2[23]}}, io_vs2[23:16]};
	wire [15:0] prodComb_prod_3 = {{8 {io_vs1[31]}}, io_vs1[31:24]} * {{8 {io_vs2[31]}}, io_vs2[31:24]};
	wire [15:0] prodComb_prod_4 = {{8 {io_vs1[39]}}, io_vs1[39:32]} * {{8 {io_vs2[39]}}, io_vs2[39:32]};
	wire [15:0] prodComb_prod_5 = {{8 {io_vs1[47]}}, io_vs1[47:40]} * {{8 {io_vs2[47]}}, io_vs2[47:40]};
	wire [15:0] prodComb_prod_6 = {{8 {io_vs1[55]}}, io_vs1[55:48]} * {{8 {io_vs2[55]}}, io_vs2[55:48]};
	wire [15:0] prodComb_prod_7 = {{8 {io_vs1[63]}}, io_vs1[63:56]} * {{8 {io_vs2[63]}}, io_vs2[63:56]};
	always @(posedge clock)
		if (reset) begin
			prod_0 <= 19'h00000;
			prod_1 <= 19'h00000;
			prod_2 <= 19'h00000;
			prod_3 <= 19'h00000;
			prod_4 <= 19'h00000;
			prod_5 <= 19'h00000;
			prod_6 <= 19'h00000;
			prod_7 <= 19'h00000;
			fireS1 <= 1'h0;
			red <= 19'h00000;
			validS1 <= 1'h0;
		end
		else begin
			if (io_fire) begin
				prod_0 <= {{3 {prodComb_prod[15]}}, prodComb_prod};
				prod_1 <= {{3 {prodComb_prod_1[15]}}, prodComb_prod_1};
				prod_2 <= {{3 {prodComb_prod_2[15]}}, prodComb_prod_2};
				prod_3 <= {{3 {prodComb_prod_3[15]}}, prodComb_prod_3};
				prod_4 <= {{3 {prodComb_prod_4[15]}}, prodComb_prod_4};
				prod_5 <= {{3 {prodComb_prod_5[15]}}, prodComb_prod_5};
				prod_6 <= {{3 {prodComb_prod_6[15]}}, prodComb_prod_6};
				prod_7 <= {{3 {prodComb_prod_7[15]}}, prodComb_prod_7};
			end
			fireS1 <= io_fire;
			red <= ((((((prod_0 + prod_1) + prod_2) + prod_3) + prod_4) + prod_5) + prod_6) + prod_7;
			validS1 <= fireS1;
		end
	assign io_vd = {96'h000000000000000000000000, {13 {red[18]}}, red};
	assign io_valid = ~reset & validS1;
endmodule
