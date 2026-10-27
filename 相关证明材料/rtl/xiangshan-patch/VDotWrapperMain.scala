

package top

import chisel3._
import circt.stage.ChiselStage
import xiangshan.{XSCoreParamsKey, XSTileKey}
import xiangshan.backend.fu.FuConfig
import xiangshan.backend.fu.wrapper.VDotU
import java.nio.file.{Files, Paths}

object VDotWrapperMain {
  def main(args: Array[String]): Unit = {
    require(args.length == 1, "VDotWrapperMain <output-directory>")
    val base = ArgParser.parse(Array("--config", "KunminghuV2Config", "--disable-perf"))._1
    implicit val p = base.alterPartial {
      case XSCoreParamsKey => base(XSTileKey).head
    }
    val text = ChiselStage.emitSystemVerilog(
      new VDotU(FuConfig.VdotCfg),
      firtoolOpts = Array("--lowering-options=explicitBitcast,disallowLocalVariables,disallowPortDeclSharing,locationInfoStyle=none")
    )
    val dir = Paths.get(args(0))
    Files.createDirectories(dir)
    Files.write(dir.resolve("VDotU.sv"), text.getBytes("UTF-8"))
    println("VDOT-WRAPPER-EMIT PASS " + dir.resolve("VDotU.sv"))
  }
}
