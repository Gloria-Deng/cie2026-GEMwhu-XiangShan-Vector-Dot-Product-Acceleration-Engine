#!/usr/bin/env python3
# -*- coding: utf-8 -*-


from __future__ import annotations

import argparse
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.normpath(os.path.join(HERE, os.pardir))
OUT = os.path.normpath(os.path.join(HERE, os.pardir, "rtl", "xs_vdot_unit.sv"))


GATE_VS1 = ("assign vs1g[gl*SEW +: SEW] = (gl < NLANES) ? "
            "vs1x[gl*SEW +: SEW] : {SEW{1'b0}};")
GATE_VS2 = ("assign vs2g[gl*SEW +: SEW] = (gl < NLANES) ? "
            "vs2w[gl*SEW +: SEW] : {SEW{1'b0}};")


ZEXT_VS1 = "wire [2*SEW-1:0] ae = {{SEW{av[SEW-1]}}, av};"
ZEXT_VS2 = "wire [2*SEW-1:0] be = {{SEW{bv[SEW-1]}}, bv};"
PROD_SLICE = "assign prod_comb[gp] = pe[ACCW-1:0];"

LANES = 16
SEW = 8
BC = 0
ACCW = 19
VLEN = 128
OUTW = 32


def csa(L, name, a, b, c):

    gv = "gv_" + name
    L.append("  wire [ACCW-1:0] %s_s, %s_cw, %s;" % (name, name, name))
    L.append("  genvar %s;" % gv)
    L.append("  generate")
    L.append("    for (%s = 0; %s < ACCW; %s = %s + 1) begin : g_%s" % (gv, gv, gv, gv, name))
    L.append("      wire x = %s[%s] ^ %s[%s] ^ %s[%s];" % (a, gv, b, gv, c, gv))
    L.append("      wire cy = (%s[%s] & %s[%s]) | (%s[%s] & %s[%s]) | (%s[%s] & %s[%s]);"
             % (a, gv, b, gv, b, gv, c, gv, a, gv, c, gv))
    L.append("      assign %s_s[%s] = x;" % (name, gv))
    L.append("      assign %s_cw[%s] = cy;" % (name, gv))
    L.append("    end")
    L.append("  endgenerate")


    L.append("  assign %s = {%s_cw[ACCW-2:0], 1'b0};" % (name, name))


def wallace(ops, tag, L):

    cur = list(ops)
    lvl = 0
    while len(cur) > 2:
        nxt = []
        i = g = 0
        while len(cur) - i >= 3:
            name = "%s_l%d_g%d" % (tag, lvl, g)
            csa(L, name, cur[i], cur[i + 1], cur[i + 2])
            nxt += ["%s_s" % name, name]
            i += 3
            g += 1
        nxt += cur[i:]

        cur = nxt
        lvl += 1
    return cur


def balanced(ops, tag, L):

    cur = list(ops)
    lvl = 0
    while len(cur) > 1:
        nxt = []
        for i in range(0, len(cur), 2):
            if i + 1 < len(cur):
                name = "%s_l%d_%d" % (tag, lvl, i // 2)
                L.append("  wire [ACCW-1:0] %s = %s + %s;" % (name, cur[i], cur[i + 1]))
                nxt.append(name)
            else:
                nxt.append(cur[i])

        cur = nxt
        lvl += 1
    return cur[0]


def serial(ops, tag, L):

    acc = ops[0]
    for i, o in enumerate(ops[1:]):
        name = "%s_%d" % (tag, i)
        L.append("  wire [ACCW-1:0] %s = %s + %s;" % (name, acc, o))
        acc = name
    return acc


def main():
    global LANES, SEW, BC
    ap = argparse.ArgumentParser()
    ap.add_argument("--lanes", type=int, default=LANES,
                    help="width of the emitted product/reduction network. The "
                         "deliverable RTL uses 16 (= VLEN/SEW at the pinned VLEN=128); "
                         "a HISTORICAL wider-VLEN probe emitted a wider one to put the "
                         "high-VLEN extension claim to the run rather than to prose.")
    ap.add_argument("--sew", type=int, default=SEW,
                    help="element width in bits. The deliverable RTL uses 8, which "
                         "is what the statement pins; sim/run_matrix.py emits a "
                         "16-wide one purely to prove the parameter is threaded.")
    ap.add_argument("--bcast", action="store_true",
                    help="feed operand 1's lane 0 to every lane -- the vdot.vx "
                         "shape. A HISTORICAL wider-VLEN probe emitted this variant to test "
                         "whether the reduction structure really carries over to a "
                         "neighbouring instruction; the deliverable RTL does not "
                         "use it.")
    ap.add_argument("--out", default=OUT)
    args = ap.parse_args()
    if args.lanes < 8 or args.lanes > 128 or (args.lanes & (args.lanes - 1)):
        raise SystemExit("[GEN] --lanes must be a power of two in [8,128]: the "
                         "reduction tree is built pairwise over this count")
    LANES = args.lanes
    if args.sew not in (8, 16, 32, 64):
        raise SystemExit("[GEN] --sew must be one of 8/16/32/64 (an RVV element "
                         "width); refusing to emit a datapath nobody can interpret")
    SEW = args.sew
    BC = 1 if args.bcast else 0
    out = args.out if os.path.isabs(args.out) else os.path.join(ROOT_DIR, args.out)
    out = os.path.normpath(out)
    L = []
    A = L.append


    A("")
    A("module xs_vdot_unit #(")
    A("    parameter int VLEN   = %d," % VLEN)
    A('    parameter int SEW    = %d,   ' % SEW)
    A('    parameter int NLANES = %d,   ' % 8)
    A('    parameter int ACCW   = %d,   ' % ACCW)
    A('    parameter int OUTW   = %d,   ' % OUTW)
    A('    parameter int TREE   = 0    ')
    A(") (")
    A("    input  wire            clock,")
    A("    input  wire            reset,")
    A("    input  wire            fire,")
    A("    input  wire [VLEN-1:0] vs1,")
    A("    input  wire [VLEN-1:0] vs2,")
    A("    output wire [VLEN-1:0] vd,")
    A("    output wire            valid")
    A(");")
    A("")
    A("  localparam int LANES = %d;" % LANES)
    A('  localparam int DW    = LANES * SEW;  ')
    A("")


    A("  wire [DW-1:0] vs1w, vs2w;")
    A("  assign vs1w = vs1;")
    A("  assign vs2w = vs2;")
    A("")


    A("  wire [DW-1:0] vs1x;")
    if BC:
        A("  generate")
        A("    for (genvar gb = 0; gb < LANES; gb = gb + 1) begin : g_bcast")
        A("      assign vs1x[gb*SEW +: SEW] = vs1w[SEW-1:0];")
        A("    end")
        A("  endgenerate")
    else:
        A('  assign vs1x = vs1w;   ')
    A("")

    A("  wire [DW-1:0] vs1g, vs2g;")
    A("  generate")
    A("    for (genvar gl = 0; gl < LANES; gl = gl + 1) begin : g_gate")
    A("      " + GATE_VS1)
    A("      " + GATE_VS2)
    A("    end")
    A("  endgenerate")
    A("")

    A("  wire [ACCW-1:0] prod_comb [0:LANES-1];")
    A("  generate")
    A("    for (genvar gp = 0; gp < LANES; gp = gp + 1) begin : g_prod")
    A("      wire [SEW-1:0]   av = vs1g[gp*SEW +: SEW];")
    A("      wire [SEW-1:0]   bv = vs2g[gp*SEW +: SEW];")

    A("      " + ZEXT_VS1)
    A("      " + ZEXT_VS2)
    A('      wire [4*SEW-1:0] pe = $signed(ae) * $signed(be);  ')
    A("      " + PROD_SLICE)
    A("    end")
    A("  endgenerate")
    A("")
    A("  reg [ACCW-1:0] prod_r [0:LANES-1];")
    A("  reg fire_r;")
    A("  always @(posedge clock) begin")
    A("    if (reset) begin")
    A("      fire_r <= 1'b0;")
    A("      for (int i = 0; i < LANES; i++) prod_r[i] <= {ACCW{1'b0}};")
    A("    end else begin")
    A("      fire_r <= fire;")
    A("      if (fire)")
    A("        for (int i = 0; i < LANES; i++) prod_r[i] <= prod_comb[i];")
    A("    end")
    A("  end")
    A("")

    ops = ["prod_r[%d]" % i for i in range(LANES)]
    body = []
    cpa_top = balanced(ops, "cpa", body)
    pair = wallace(ops, "csa", body)
    ser_top = serial(ops, "ser", body)
    L.extend(body)
    A("  wire [ACCW-1:0] red_cpa = %s;" % cpa_top)
    A("  wire [ACCW-1:0] red_csa = %s + %s;" % (pair[0], pair[1]))
    A("  wire [ACCW-1:0] red_ser = %s;" % ser_top)
    A("")
    A("  wire [ACCW-1:0] red_comb;")
    A("  generate")
    A("    if (TREE == 0)      assign red_comb = red_cpa;")
    A("    else if (TREE == 1) assign red_comb = red_csa;")
    A("    else                assign red_comb = red_ser;")
    A("  endgenerate")
    A("")
    A("  reg [ACCW-1:0] red_r;")
    A("  reg valid_r;")
    A("  always @(posedge clock) begin")
    A("    if (reset) begin")
    A("      red_r   <= {ACCW{1'b0}};")
    A("      valid_r <= 1'b0;")
    A("    end else begin")
    A("      red_r   <= red_comb;")
    A("      valid_r <= fire_r;")
    A("    end")
    A("  end")
    A("")


    A("  wire [OUTW-1:0] out_field;")
    A("  generate")
    A("    if (OUTW > ACCW) begin : g_sext")
    A("      assign out_field = {{(OUTW-ACCW){red_r[ACCW-1]}}, red_r};")
    A("    end else begin : g_trunc")
    A("      assign out_field = red_r[OUTW-1:0];")
    A("    end")
    A("  endgenerate")
    A("")


    A("  assign vd    = { {(VLEN-OUTW){1'b0}}, out_field };")
    A("  assign valid = reset ? 1'b0 : valid_r;")
    A("")
    A("endmodule")

    text = "\n".join(L) + "\n"


    bad = [ln for ln in text.splitlines() if "[18:0]" in ln]
    if bad:
        raise SystemExit("gen_vdot_rtl: %d literal [18:0] width(s) leaked, "
                         "ACCW would not be a real parameter:\n  %s"
                         % (len(bad), "\n  ".join(bad[:5])))
    if "[ACCW-1:0]" not in text:
        raise SystemExit("gen_vdot_rtl: no parameterised width found at all")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("wrote %s  %d lines  lanes=%d  sew=%d  bcast=%d"
          % (out, text.count("\n"), LANES, SEW, BC))


if __name__ == "__main__":
    main()
