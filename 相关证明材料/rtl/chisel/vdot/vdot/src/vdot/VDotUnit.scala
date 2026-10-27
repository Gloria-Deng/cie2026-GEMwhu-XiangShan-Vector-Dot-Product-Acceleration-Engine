// See LICENSE for license details.
package vdot

import chisel3._
import chisel3.util._



















case class VDotParams(
    vlen:   Int = 128,
    sew:    Int = 8,
    nlanes: Int = 8,
    lanes:  Int = 16,
    accw:   Int = 19,
    outw:   Int = 32,
    tree:   Int = 0
)

object VDotAccWidth {







  def range(nlanes: Int): (Int, Int) = {
    val per = for {a <- Seq(-128, 127); b <- Seq(-128, 127)} yield a * b
    (per.min * nlanes, per.max * nlanes)
  }


  def required(nlanes: Int): Int = {
    val (lo, hi) = range(nlanes)
    val mag = math.max(Integer.toBinaryString(hi).length, Integer.toBinaryString(-lo).length)
    mag + 1
  }

  require(required(8) == 19, s"8-lane dot product should need 19 bits, got ${required(8)}")
  require(required(16) == 20, s"16-lane dot product should need 20 bits, got ${required(16)}")
}

class VDotUnit(val p: VDotParams = VDotParams()) extends Module {
  val io = IO(new Bundle {
    val fire  = Input(Bool())
    val vs1   = Input(UInt(p.vlen.W))
    val vs2   = Input(UInt(p.vlen.W))
    val vd    = Output(UInt(p.vlen.W))
    val valid = Output(Bool())
  })

  private def lanesOf(u: UInt): Vec[UInt] = u.asTypeOf(Vec(p.vlen / 8, UInt(8.W)))
  private val vs1L = lanesOf(io.vs1)
  private val vs2L = lanesOf(io.vs2)




  private val vs1g = VecInit(Seq.tabulate(p.lanes)(i =>
    if (i < p.nlanes) vs1L(i) else 0.U(8.W)))
  private val vs2g = VecInit(Seq.tabulate(p.lanes)(i =>
    if (i < p.nlanes) vs2L(i) else 0.U(8.W)))




  private val prodComb = VecInit(Seq.tabulate(p.lanes) { i =>
    val prod = vs1g(i).asSInt * vs2g(i).asSInt
    prod.pad(p.accw).asUInt
  })

  private val prod = RegInit(VecInit(Seq.fill(p.lanes)(0.U(p.accw.W))))
  private val fireS1 = RegInit(false.B)
  when(io.fire) { prod := prodComb }
  fireS1 := io.fire






  private def wrap(u: UInt): UInt = u(p.accw - 1, 0)

  private def cpa(a: UInt, b: UInt): UInt = wrap(a + b)


  private def csa(a: UInt, b: UInt, c: UInt): (UInt, UInt) = {
    val sum = a ^ b ^ c
    val maj = (a & b) | (b & c) | (a & c)
    (sum, wrap(Cat(maj(p.accw - 2, 0), 0.U(1.W))))
  }



  private def balanced(ops: Seq[UInt]): UInt =
    if (ops.size == 1) ops.head
    else balanced(ops.grouped(2).map(g => if (g.size == 1) g.head else cpa(g(0), g(1))).toSeq)



  private def wallace(ops: Seq[UInt]): Seq[UInt] = {
    if (ops.size <= 2) ops
    else {
      val nTriples = ops.size / 3
      val triples = ops.take(nTriples * 3).grouped(3).toSeq
      val rest = ops.drop(nTriples * 3)
      val out = triples.flatMap { t =>
        val (s, c) = csa(t(0), t(1), t(2))
        Seq(s, c)
      }
      wallace(out ++ rest)
    }
  }

  private val redCpa = balanced(prod.toSeq)
  private val redCsa = { val r = wallace(prod.toSeq); wrap(r(0) + r(1)) }
  private val redComb = if (p.tree == 0) redCpa else redCsa

  private val red = RegInit(0.U(p.accw.W))
  private val validS1 = RegInit(false.B)
  red := redComb
  validS1 := fireS1




  private val outField: UInt =
    if (p.outw > p.accw)
      Cat(Fill(p.outw - p.accw, red(p.accw - 1)), red).asUInt
    else
      red(p.outw - 1, 0)

  io.vd := Cat(0.U((p.vlen - p.outw).W), outField).asUInt
  io.valid := Mux(reset.asBool, false.B, validS1)
}
