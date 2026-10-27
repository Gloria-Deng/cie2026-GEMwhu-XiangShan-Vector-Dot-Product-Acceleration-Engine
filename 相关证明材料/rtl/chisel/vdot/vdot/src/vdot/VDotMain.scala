







package vdot

import chisel3._
import circt.stage.ChiselStage

object VDotMain {

  private def opt(args: Array[String], key: String, default: String): String = {
    val i = args.indexOf(key)
    if (i >= 0 && i + 1 < args.length) args(i + 1) else default
  }

  def main(args: Array[String]): Unit = {
    val dir = opt(args, "--target-dir", "generated")
    val nlanes = opt(args, "--nlanes", "8").toInt
    val lanes = opt(args, "--lanes", "16").toInt
    val outw = opt(args, "--outw", "32").toInt
    val tree = opt(args, "--tree", "0").toInt
    val accwArg = opt(args, "--accw", "")
    val accw = if (accwArg.nonEmpty) accwArg.toInt else VDotAccWidth.required(nlanes)

    if (accwArg.nonEmpty) {
      val need = VDotAccWidth.required(nlanes)
      println(s"VDot-INFO accw given=$accw derived-for-$nlanes-lanes=$need" +
        (if (accw < need) "  !! UNDER-WIDTH, expect the +2**(w-1) corner to be wrong" else ""))
    }

    val p = VDotParams(nlanes = nlanes, lanes = lanes, outw = outw, accw = accw, tree = tree)
    val name = "VDotUnit_t%d_n%d_o%d_a%d".format(tree, nlanes, outw, accw)
    java.nio.file.Files.createDirectories(java.nio.file.Paths.get(dir))





    val sv = ChiselStage.emitSystemVerilog(
      new VDotUnit(p),
      firtoolOpts = Array("--lowering-options=disallowLocalVariables,disallowPackedArrays")
    )
    val out = new java.io.File(dir, name + ".sv")
    java.nio.file.Files.write(out.toPath, sv.getBytes("UTF-8"))
    println(s"VDot-OK wrote ${out.getPath}  bytes=${sv.length}  params=$p")
  }
}
