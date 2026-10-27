import xiangshan.backend.decode.XVdot._
import xiangshan.backend.fu.wrapper.VdotType

    VDOT_VV      -> OPMVV(T, FuType.vdot, VdotType.vdot_vv, F, T, F, UopSplitType.VEC_VVV),

object XVdot {
  def VDOT_VV = BitPat("b101100???????????010?????1010111")
}
