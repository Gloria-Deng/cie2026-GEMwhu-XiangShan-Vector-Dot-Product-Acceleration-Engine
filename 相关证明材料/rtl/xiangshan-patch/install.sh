#!/usr/bin/env bash
set -euo pipefail

DRY=0; CHECK=0; COPY=1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
VDOT_UNIT_SRC="${VDOT_UNIT:-$SCRIPT_DIR/../chisel/vdot/vdot/src/vdot/VDotUnit.scala}"
XS_ROOT_ARG="${XS_ROOT:-}"

usage() {
  cat <<'EOF'
Usage: apply.sh [options] [XS_ROOT]
  XS_ROOT          XiangShan source directory, or set XS_ROOT.
  --dry            Show the changes without writing files.
  --check          Verify an already patched directory.
  --no-copy        Apply source edits without copying Scala files.
  --vdot-unit PATH Use the specified VDotUnit.scala.
  -h, --help       Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry)      DRY=1 ;;
    --check)    CHECK=1 ;;
    --no-copy)  COPY=0 ;;
    --vdot-unit) shift; VDOT_UNIT_SRC="${1:?--vdot-unit needs a path}" ;;
    -h|--help)  usage; exit 0 ;;
    *)          XS_ROOT_ARG="$1" ;;
  esac
  shift
done

log()  { printf '[vdot-patch] %s\n' "$*"; }
warn() { printf '[vdot-patch][WARN] %s\n' "$*" >&2; }
die()  { printf '\n[vdot-patch][FAIL] %s\n' "$*" >&2; exit 1; }

if [ -z "$XS_ROOT_ARG" ]; then
  guess="$(cd "$SCRIPT_DIR/../../.." 2>/dev/null && pwd -P)" || guess=""
  if [ -n "$guess" ]; then
    for cand in "$guess"/工作区/upstream/src/XiangShan-42f87803d10*; do
      [ -f "$cand/src/main/scala/xiangshan/backend/fu/FuConfig.scala" ] && XS_ROOT_ARG="$cand" && break
    done
  fi
fi
[ -n "$XS_ROOT_ARG" ] || die "no XiangShan tree: pass it as an argument or set XS_ROOT.
  e.g.  ./apply.sh /d/Desktop/RSIC-V香山/工作区/upstream/src/XiangShan-42f87803d10bc21bbc5df2807a2fc07db6c9dc89"

XS_ROOT="$(cd "$XS_ROOT_ARG" && pwd -P)" || die "XS_ROOT not a directory: $XS_ROOT_ARG"
[ -f "$XS_ROOT/src/main/scala/xiangshan/backend/fu/FuType.scala" ] || die "not an XiangShan tree: $XS_ROOT (no backend/fu/FuType.scala)"
[ -f "$XS_ROOT/src/main/scala/xiangshan/backend/decode/VecDecoder.scala" ] || die "not an XiangShan tree: $XS_ROOT (no decode/VecDecoder.scala)"

FU_TYPE="$XS_ROOT/src/main/scala/xiangshan/backend/fu/FuType.scala"
FU_CFG="$XS_ROOT/src/main/scala/xiangshan/backend/fu/FuConfig.scala"
PARAMS="$XS_ROOT/src/main/scala/xiangshan/Parameters.scala"
VECDEC="$XS_ROOT/src/main/scala/xiangshan/backend/decode/VecDecoder.scala"
VECEX="$XS_ROOT/src/main/scala/xiangshan/backend/decode/VecExceptionGen.scala"
INSTS="$XS_ROOT/src/main/scala/xiangshan/backend/decode/Instructions.scala"
DECUNIT="$XS_ROOT/src/main/scala/xiangshan/backend/decode/DecodeUnit.scala"
WRAP_DIR="$XS_ROOT/src/main/scala/xiangshan/backend/fu/wrapper"
VDOT_DIR="$XS_ROOT/src/main/scala/vdot"

log "XS_ROOT = $XS_ROOT"
log "mode    = dry=$DRY check=$CHECK copy=$COPY"

WORK="$(mktemp -d)"
if ! : > "$WORK/.writable" 2>/dev/null; then
  die "mktemp -d returned '$WORK' but this bash cannot write into it.
  Cause: the 'mktemp' resolved off PATH belongs to a different MSYS root than the bash
  running this script, and the two map /tmp to different directories.  Nothing about the
  patch is wrong.  Fix by making the child tools resolve from the same root as this
  interpreter (\$BASH is its own path):
      PATH=\"\$(dirname \"\$BASH\"):\$PATH\" bash apply.sh \"\$XS_ROOT\"
  Use the tools installed alongside this bash interpreter."
fi
rm -f "$WORK/.writable"
trap 'rm -rf "$WORK"' EXIT

count_of() {
  [ -f "$1" ] || { echo 0; return 0; }
  ( set +o pipefail; grep -o -F -- "$2" "$1" 2>/dev/null | wc -l | tr -d ' ' )
}

backup() {
  [ "$DRY" -eq 1 ] && return 0
  if [ ! -f "$1.vdotbak" ]; then cp -p "$1" "$1.vdotbak"; log "backup  -> $1.vdotbak"; fi
}

insert_after() {
  local desc="$1" file="$2" anchor="$3" pay="$4" n
  n="$(count_of "$file" "$anchor")"
  [ "$n" -eq 1 ] || die "$desc: anchor occurred $n times (must be exactly 1) in $(basename "$file")
  anchor: $anchor"
  if [ "$DRY" -eq 1 ]; then log "plan    $desc  (insert after 1 line)"; return 0; fi
  backup "$file"
  awk -v a="$anchor" '
    NR==FNR { pay[++np] = $0; next }
    { print; if (index($0, a) > 0) for (k = 1; k <= np; k++) print pay[k] }
  ' "$pay" "$file" > "$WORK/o" || die "$desc: awk failed"
  mv "$WORK/o" "$file"
  log "applied $desc"
}

insert_before() {
  local desc="$1" file="$2" anchor="$3" pay="$4" n
  n="$(count_of "$file" "$anchor")"
  [ "$n" -eq 1 ] || die "$desc: anchor occurred $n times (must be exactly 1) in $(basename "$file")
  anchor: $anchor"
  if [ "$DRY" -eq 1 ]; then log "plan    $desc  (insert before 1 line)"; return 0; fi
  backup "$file"
  awk -v a="$anchor" '
    NR==FNR { pay[++np] = $0; next }
    { if (index($0, a) > 0) for (k = 1; k <= np; k++) print pay[k]; print }
  ' "$pay" "$file" > "$WORK/o" || die "$desc: awk failed"
  mv "$WORK/o" "$file"
  log "applied $desc"
}

sub_once() {
  local desc="$1" file="$2" old="$3" new="$4" n
  n="$(count_of "$file" "$new")"
  if [ "$n" -ge 1 ]; then log "skip    $desc (new text already present $n time(s))"; return 0; fi
  n="$(count_of "$file" "$old")"
  [ "$n" -eq 1 ] || die "$desc: old text occurred $n times (must be exactly 1) in $(basename "$file")
  old: $old"
  if [ "$DRY" -eq 1 ]; then log "plan    $desc  (replace 1 occurrence)"; return 0; fi
  backup "$file"
  awk -v old="$old" -v new="$new" '
    { i = index($0, old)
      if (i > 0 && !done) { $0 = substr($0, 1, i - 1) new substr($0, i + length(old)); done = 1 }
      print }
  ' "$file" > "$WORK/o" || die "$desc: awk failed"
  mv "$WORK/o" "$file"
  log "applied $desc"
}

insert_if_absent() {
  local desc="$1" file="$2" marker="$3" anchor="$4" pay="$5"
  if [ "$(count_of "$file" "$marker")" -ge 1 ]; then log "skip    $desc (marker already present)"; return 0; fi
  insert_after "$desc" "$file" "$anchor" "$pay"
}

insert_before_if_absent() {
  local desc="$1" file="$2" marker="$3" anchor="$4" pay="$5"
  if [ "$(count_of "$file" "$marker")" -ge 1 ]; then log "skip    $desc (marker already present)"; return 0; fi
  insert_before "$desc" "$file" "$anchor" "$pay"
}

precheck_removed() {
  local label="$1" file="$2" old="$3" got
  got="$(count_of "$file" "VDOT_VX")"
  [ "$got" -le 1 ] || die "$label: multiple VDOT_VX entries in $file"
  if [ "$got" -eq 1 ]; then
    grep -Fxq -- "$old" "$file" || die "$label: unrecognized VDOT_VX entry in $file; review it before installing vdot.vv"
  fi
}

remove_if_present() {
  local desc="$1" file="$2" old="$3"
  if [ "$(count_of "$file" "VDOT_VX")" -eq 0 ]; then return 0; fi
  if [ "$DRY" -eq 1 ]; then log "plan    $desc (remove former VX entry)"; return 0; fi
  backup "$file"
  awk -v old="$old" '$0 != old { print }' "$file" > "$WORK/o" || die "$desc: awk failed"
  mv "$WORK/o" "$file"
  log "applied $desc"
}

append_block() {
  local desc="$1" file="$2" marker="$3" pay="$4"
  if [ "$(count_of "$file" "$marker")" -ge 1 ]; then log "skip    $desc (marker already present)"; return 0; fi
  if [ "$DRY" -eq 1 ]; then log "plan    $desc  (append to end)"; return 0; fi
  backup "$file"
  [ -z "$(tail -c 1 "$file")" ] || printf '\n' >> "$file"
  printf '\n' >> "$file"
  cat "$pay" >> "$file"
  log "applied $desc"
}

copy_in() {
  local src="$1" dst="$2"
  [ -f "$src" ] || die "missing source file: $src
  pass --vdot-unit PATH or set VDOT_UNIT for VDotUnit.scala"
  if [ -f "$dst" ]; then
    if cmp -s "$src" "$dst"; then log "skip    copy $(basename "$dst") (byte-identical)"; return 0; fi
    die "$(basename "$dst") already exists in the tree and DIFFERS from the patch payload.
  Refusing to clobber your edit. Remove/rename $dst and re-run, or diff them yourself:
    diff '$dst' '$src'"
  fi
  if [ "$DRY" -eq 1 ]; then log "plan    copy $(basename "$src") -> $dst"; return 0; fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  log "copied  -> $dst"
}

drift() {
  local doc="$1"; shift
  [ -f "$doc" ] || die "doc file for the drift check is missing: $doc"
  local pf line t
  for pf in "$@"; do
    while IFS= read -r line; do
      t="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      [ -z "$t" ] && continue
      grep -Fq -- "$t" "$doc" || die "DRIFT: apply.sh payload is not present verbatim in $(basename "$doc"):
  $t
  Fix apply.sh or the doc so the two agree, then re-run."
    done < "$pf"
  done
  log "drift   ok: payloads found verbatim in $(basename "$doc")"
}

cat > "$WORK/fu_type.scla" <<'EOF'
  val vdot = addType(name = "vdot")
EOF

cat > "$WORK/fu_name.scla" <<'EOF'
    vdot -> "vdot",
EOF

cat > "$WORK/vdot_cfg.scla" <<'EOF'
  val VdotCfg = FuConfig (
    name = "vdot",
    fuType = FuType.vdot,
    fuGen = (p: Parameters, cfg: FuConfig) => Module(new VDotU(cfg)(p).suggestName("Vdot")),
    srcData = Seq(
      Seq(VecData(), VecData(), VecData(), V0Data(), VlData()),
    ),
    piped = true,
    writeVecRf = true,
    writeV0Rf = true,
    latency = CertainLatency(2),
    vconfigWakeUp = true,
    maskWakeUp = true,
    destDataBits = 128,
    exceptionOut = Seq(illegalInstr),
  )

EOF

cat > "$WORK/dec_imports.scla" <<'EOF'
import xiangshan.backend.decode.XVdot._
import xiangshan.backend.fu.wrapper.VdotType
EOF

cat > "$WORK/old_vd.scla" <<'EOF'
  when (decodedInst.fuType === FuType.vdot.U) {
    decodedInst.srcType(2) := SrcType.no
    decodedInst.vpu.isDependOldVd := false.B
    decodedInst.vpu.isWritePartVd := false.B
  }

EOF

cat > "$WORK/vdot_exception.scla" <<'EOF'
  private val vdotIllegal = io.decodedInst.fuType === FuType.vdot.U && (io.vtype.illegal || io.vtype.vsew =/= 0.U || io.vtype.vlmul =/= 0.U || inst.VM === 0.U || io.vstart =/= 0.U)
EOF

cat > "$WORK/dec_row.scla" <<'EOF'
    VDOT_VV      -> OPMVV(T, FuType.vdot, VdotType.vdot_vv, F, T, F, UopSplitType.VEC_VVV),
EOF

cat > "$WORK/enc_obj.scla" <<'EOF'
object XVdot {
  def VDOT_VV = BitPat("b101100???????????010?????1010111")
}
EOF

A_VSEGSTU='  val vsegstu = addType(name = "vsegstu")'
A_VIMAC_NAME='    vimac -> "vimac",'
A_VECOPI_OLD='Seq(vipu, vialuF, vppu, vimac, vidiv)'
A_VECOPI_NEW='Seq(vipu, vialuF, vppu, vimac, vidiv, vdot)'
A_VIDIVCFG='  val VidivCfg = FuConfig ('
A_VECFGS_OLD='    VialuCfg, VimacCfg, VppuCfg, VipuCfg, VfaluCfg, VfmaCfg, VfcvtCfg'
A_VECFGS_NEW='    VialuCfg, VimacCfg, VppuCfg, VipuCfg, VfaluCfg, VfmaCfg, VfcvtCfg, VdotCfg'
A_VECCTRL_OLD='vfcvt, vldu, vstu, vsetfwf'
A_VECCTRL_NEW='vfcvt, vdot, vldu, vstu, vsetfwf'
A_ISVEC_OLD='fuType == FuType.vidiv'
A_ISVEC_NEW='fuType == FuType.vidiv || fuType == FuType.vdot'
A_VFEX0_OLD='Seq(VfmaCfg, VialuCfg, VimacCfg, VppuCfg)'
A_VFEX0_NEW='Seq(VfmaCfg, VialuCfg, VimacCfg, VppuCfg, VdotCfg)'
A_ZVBB_IMP='import xiangshan.backend.decode.Zvbb._'
A_VPOPV='    VCPOP_V      -> OPMVV(T, FuType.vialuF, VialuFixType.vcpop_v,  F, T, F, UopSplitType.VEC_VVV, src1 = SrcType.no),'
A_VDOTVX_BP='  def VDOT_VX = BitPat("b101100???????????110?????1010111")'
A_VDOTVX_ROW='    VDOT_VX        -> OPMVX(T, FuType.vdot, VdotType.vdot_vv, F, T, F, UopSplitType.VEC_VXV),'
A_VECEX_OLD='  io.illegalInst := instIllegal || villIllegal || eewIllegal || emulIllegal || regNumIllegal || regOverlapIllegal || vstartIllegal'
A_VECEX_DECL='  private val vdotIllegal = io.decodedInst.fuType === FuType.vdot.U && (io.vtype.illegal || io.vtype.vsew =/= 0.U || io.vtype.vlmul =/= 0.U || inst.VM === 0.U || io.vstart =/= 0.U)'
A_VECEX_NEW='  io.illegalInst := instIllegal || villIllegal || eewIllegal || emulIllegal || regNumIllegal || regOverlapIllegal || vstartIllegal || vdotIllegal'

for f in "$FU_TYPE" "$FU_CFG" "$PARAMS" "$VECDEC" "$VECEX" "$INSTS"; do
  [ -w "$f" ] || [ "$CHECK" -eq 1 ] || die "$f is not writable"
done

log "pre-flight per-patch state audit"
precheck_removed "VX decode removal" "$VECDEC" "$A_VDOTVX_ROW"
precheck_removed "VX encoding removal" "$INSTS" "$A_VDOTVX_BP"
precheck() {
  local label="$1" file="$2" old="$3" new="$4" got
  got="$(count_of "$file" "$new")"
  if [ "$got" -ge 1 ]; then printf '  already-applied  %-32s (%s)\n' "$label" "$(basename "$file")"; return 0; fi
  got="$(count_of "$file" "$old")"
  [ "$got" -eq 1 ] || die "$label: neither the new text nor exactly one occurrence of its anchor is present
  in $(basename "$file") (anchor occurrences = $got).  anchor was:
    $old
  The tree does not match XiangShan 42f87803d10bc21bbc5df2807a2fc07db6c9dc89. Restore it
  (rm the file, or mv <file>.vdotbak <file>) and re-run, or re-derive the anchors."
  printf '  ready            %-32s (%s)\n' "$label" "$(basename "$file")"
}
precheck_append() {
  local label="$1" file="$2" marker="$3" got
  got="$(count_of "$file" "$marker")"
  [ "$got" -le 1 ] || die "$label: the marker '$marker' occurs $got times in $(basename "$file"); the tree already has a duplicated or partial copy of this patch -- inspect it by hand before applying."
  if [ "$got" -eq 1 ]; then printf '  already-applied  %-32s (%s)\n' "$label" "$(basename "$file")"
  else printf '  ready            %-32s (%s)\n' "$label" "$(basename "$file")"; fi
}
if [ "$CHECK" -eq 0 ]; then
  precheck "S1a FuType.vdot"      "$FU_TYPE" "$A_VSEGSTU"     "val vdot = addType"
  precheck "S1b vecOPI"           "$FU_TYPE" "$A_VECOPI_OLD"  "$A_VECOPI_NEW"
  precheck "S1c functionNameMap"  "$FU_TYPE" "$A_VIMAC_NAME"  "vdot -> \"vdot\""
  precheck "S2a VdotCfg"          "$FU_CFG"  "$A_VIDIVCFG"    "val VdotCfg = FuConfig"
  precheck "S2b VecArithFuCfgs"   "$FU_CFG"  "$A_VECFGS_OLD"  "$A_VECFGS_NEW"
  precheck "S2c needVecCtrl"      "$FU_CFG"  "$A_VECCTRL_OLD" "$A_VECCTRL_NEW"
  precheck "S2d isVecArith"       "$FU_CFG"  "$A_ISVEC_OLD"   "$A_ISVEC_NEW"
  precheck "S3a VFEX0"            "$PARAMS"  "$A_VFEX0_OLD"   "$A_VFEX0_NEW"
  precheck "D1 VecDecoder import" "$VECDEC"  "$A_ZVBB_IMP"    "import xiangshan.backend.decode.XVdot._"
  precheck "D2 opmvv row"         "$VECDEC"  "$A_VPOPV"       "VDOT_VV      -> OPMVV("
  precheck_append "D3 object XVdot"    "$INSTS"   "object XVdot"
  precheck "D6 no old vd operand" "$DECUNIT" "  decodedInst.vlsInstr := isVls" "when (decodedInst.fuType === FuType.vdot.U) {"
  precheck "D7 VecExceptionGen vdot legality" "$VECEX" "$A_VECEX_OLD" "private val vdotIllegal"
  log "pre-flight ok: every patch is either ready or already applied"
fi

log "drift check against the delivery docs"
drift "$SCRIPT_DIR/decode-payload.scala" "$WORK/dec_imports.scla" "$WORK/dec_row.scla" "$WORK/enc_obj.scla"

if [ "$CHECK" -eq 1 ]; then
  :
else
  if [ "$COPY" -eq 1 ]; then
    copy_in "$SCRIPT_DIR/VDotU.scala"   "$WRAP_DIR/VDotU.scala"
    copy_in "$SCRIPT_DIR/VdotCfg.scala" "$WRAP_DIR/VdotCfg.scala"
    copy_in "$VDOT_UNIT_SRC"            "$VDOT_DIR/VDotUnit.scala"
  fi

  insert_if_absent "S1a FuType.vdot addType"        "$FU_TYPE" "val vdot = addType"        "$A_VSEGSTU"  "$WORK/fu_type.scla"
  sub_once       "S1b FuType.vecOPI += vdot"      "$FU_TYPE" "$A_VECOPI_OLD" "$A_VECOPI_NEW"
  insert_if_absent "S1c functionNameMap += vdot"      "$FU_TYPE" "vdot -> \"vdot\""        "$A_VIMAC_NAME" "$WORK/fu_name.scla"

  insert_before_if_absent "S2a FuConfig.VdotCfg"          "$FU_CFG"  "val VdotCfg = FuConfig"  "$A_VIDIVCFG"   "$WORK/vdot_cfg.scla"
  insert_before_if_absent "D6 no old vd operand" "$DECUNIT" "when (decodedInst.fuType === FuType.vdot.U) {" "  decodedInst.vlsInstr := isVls" "$WORK/old_vd.scla"
  sub_once       "S2b VecArithFuConfigs += VdotCfg" "$FU_CFG"  "$A_VECFGS_OLD" "$A_VECFGS_NEW"
  sub_once       "S2c needVecCtrl += vdot"          "$FU_CFG"  "$A_VECCTRL_OLD" "$A_VECCTRL_NEW"
  sub_once       "S2d isVecArith += vdot"           "$FU_CFG"  "$A_ISVEC_OLD" "$A_ISVEC_NEW"
  insert_before_if_absent "D7a VecExceptionGen vdot predicate" "$VECEX" "private val vdotIllegal" "$A_VECEX_OLD" "$WORK/vdot_exception.scla"
  sub_once       "D7b VecExceptionGen vdot legality" "$VECEX" "$A_VECEX_OLD" "$A_VECEX_NEW"

  sub_once       "S3a VFEX0 += VdotCfg"             "$PARAMS"  "$A_VFEX0_OLD" "$A_VFEX0_NEW"

  insert_if_absent "D1 VecDecoder imports"              "$VECDEC" "import xiangshan.backend.decode.XVdot._" "$A_ZVBB_IMP" "$WORK/dec_imports.scla"
  insert_if_absent "D2 VecDecoder opmvv row"             "$VECDEC" "VDOT_VV      -> OPMVV("                  "$A_VPOPV"    "$WORK/dec_row.scla"
  append_block     "D3 Instructions.scala object XVdot" "$INSTS"  "object XVdot"                             "$WORK/enc_obj.scla"
  remove_if_present "VX decode removal" "$VECDEC" "$A_VDOTVX_ROW"
  remove_if_present "VX encoding removal" "$INSTS" "$A_VDOTVX_BP"
fi

if [ "$DRY" -eq 1 ]; then
  log "DRY RUN: nothing was written; post-conditions skipped."
  log "Positive control instead: run './apply.sh --check <UNPATCHED tree>' -- it reports"
  log "  OK=0 with every check below BAD, and exits 1, so none of them is permanently green."
  exit 0
fi

log "post-conditions"
fail=0
expect() {
  local want="$1" file="$2" str="$3" label="$4" got
  got="$(count_of "$file" "$str")"
  if [ "$got" = "$want" ]; then
    printf '  OK   %-34s %s x%s\n' "$label" "$(basename "$file")" "$got"
  else
    printf '  BAD  %-34s %s wants %s got %s\n' "$label" "$(basename "$file")" "$want" "$got"; fail=1
  fi
}
expect 1 "$FU_TYPE" "val vdot = addType(name = \"vdot\")"        "S1a FuType.vdot"
expect 1 "$FU_TYPE" "$A_VECOPI_NEW"                              "S1b vecOPI"
expect 1 "$FU_TYPE" "    vdot -> \"vdot\","                      "S1c functionNameMap"
expect 1 "$FU_CFG"  "  val VdotCfg = FuConfig ("                 "S2a VdotCfg"
if ! awk '/^  val VdotCfg = FuConfig \(/ {active=1} active && /writeV0Rf = true/ {ok=1} active && /^  \)/ {exit} END {exit !ok}' "$FU_CFG"; then
  die "VdotCfg has no v0 writeback. This is an older patch; apply the current patch to a fresh upstream tree."
fi
expect 1 "$FU_CFG"  "$A_VECFGS_NEW"                              "S2b VecArithFuConfigs"
expect 1 "$FU_CFG"  "$A_VECCTRL_NEW"                             "S2c needVecCtrl"
expect 1 "$FU_CFG"  "$A_ISVEC_NEW"                               "S2d isVecArith"
expect 1 "$PARAMS"  "$A_VFEX0_NEW"                               "S3a VFEX0"
expect 1 "$DECUNIT" "when (decodedInst.fuType === FuType.vdot.U) {" "D6 no old vd operand"
expect 1 "$VECEX" "private val vdotIllegal" "D7 vdot legality predicate"
expect 1 "$VECEX" "$A_VECEX_NEW" "D7 vdot legality output"
expect 1 "$VECDEC"  "import xiangshan.backend.decode.XVdot._"  "D1 import XVdot"
expect 1 "$VECDEC"  "import xiangshan.backend.fu.wrapper.VdotType" "D1 import VdotType"
expect 1 "$VECDEC"  "VDOT_VV      -> OPMVV(T, FuType.vdot"        "D2 opmvv row"
expect 1 "$INSTS"   "  def VDOT_VV = BitPat(\"b101100???????????010?????1010111\")" "D3 BitPat"
expect 0 "$VECDEC"  "VDOT_VX" "VV-only decoding"
expect 0 "$INSTS"   "VDOT_VX" "VV-only encoding"
if [ "$COPY" -eq 1 ]; then
  for f in "$WRAP_DIR/VDotU.scala" "$WRAP_DIR/VdotCfg.scala" "$VDOT_DIR/VDotUnit.scala"; do
    if [ -f "$f" ]; then printf '  OK   copied %s\n' "$f"
    else printf '  BAD  missing %s\n' "$f"; fail=1; fi
  done
fi

[ "$fail" -eq 0 ] || die "post-conditions failed -- the tree is in a mixed state.
  Restate it from the .vdotbak copies (mv file.vdotbak file) and re-run, or fix the
  offending patch. Do not proceed to 'make verilog' with a half-patched tree."

log "all post-conditions hold."
cat <<EOF

Next steps (NOT run by this script, and NOT verified by it):
  cd $XS_ROOT
  make verilog CONFIG=KunminghuV2Config

Two things outside this tree still have to happen before vdot.vv can be *executed*
end to end -- see README.md:
  * the toolchain must be able to assemble funct6=101100 funct3=010 (either patch
    the assembler's opcode table, or emit the word with .insn/.word in the test)
  * NEMU's vopmvv table (src/isa/riscv64/instr/rvv/decode.h) must gain a vdot entry,
    otherwise difftest flags the instruction as invalid on the first execution

EOF
