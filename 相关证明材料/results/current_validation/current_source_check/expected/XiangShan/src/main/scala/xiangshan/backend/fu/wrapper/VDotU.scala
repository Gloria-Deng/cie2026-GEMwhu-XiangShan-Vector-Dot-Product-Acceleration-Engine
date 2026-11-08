/****************************************************************************************
 * Copyright (c) 2020-2021 Institute of Computing Technology, Chinese Academy of Sciences
 * Copyright (c) 2020-2021 Peng Cheng Laboratory
 *
 * XiangShan is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ****************************************************************************************
 */

// Fixed eight-byte dot product; design document 2.1, datapath and integration.
package xiangshan.backend.fu.wrapper

import org.chipsalliance.cde.config.Parameters
import chisel3._
import chisel3.util._
import utility.XSError
import xiangshan.ExceptionNO
import xiangshan.backend.fu.FuConfig
import xiangshan.backend.fu.vector.Bundles.VSew
import xiangshan.backend.fu.vector.VecPipedFuncUnit
import vdot.{VDotParams, VDotUnit}

object VdotType {

  // FuOpType: vector arithmetic class with the private low-three-bit opcode 111.
  def vdot_vv      = "b00_110_0_111".U
  def getOpcode(fuOpType: UInt): UInt = fuOpType(2, 0)
  def vdotOpcode: UInt = "b111".U(3.W)
  def isVdot(fuOpType: UInt): Bool = getOpcode(fuOpType) === vdotOpcode
}

class VDotU(cfg: FuConfig)(implicit p: Parameters) extends VecPipedFuncUnit(cfg) {
  XSError(io.in.valid && !VdotType.isVdot(fuOpType), "VDotU OpType not supported")

  private val dataWidth = cfg.destDataBits

  require(dataWidth == VLEN, s"VDotU: destDataBits($dataWidth) must equal VLEN($VLEN)")

  private val elementBits = 8
  private val dotLanes    = 8
  require(dotLanes * elementBits == 64, s"vdot.vv consumes the low 64 bits, got ${dotLanes * elementBits}")

  private val vdotParams = VDotParams(
    vlen   = dataWidth,
    sew    = elementBits,
    nlanes = dotLanes,
    lanes  = dataWidth / elementBits,
    // Eight (-128 * -128) products reach +131072, requiring signed width 19.
    accw   = 19,
    outw   = 32,
    tree   = 0
  )

  private val dot = Module(new VDotUnit(vdotParams).suggestName("VDotDatapath"))

  // VecPipedFuncUnit aligns output controls through HasPipelineReg.
  // Match its io.in.valid enable; the datapath captures products on the same edge.
  dot.io.fire := io.in.valid
  dot.io.vs1  := vs1
  dot.io.vs2  := vs2

  io.out.bits.res.data := dot.io.vd

  // Use output-stage controls so exceptions stay aligned with delayed results.
  // DecodeUnit disables old-vd dependency: all 128 destination bits are overwritten.
  private val sewIllegal = outVecCtrl.vsew =/= VSew.e8
  private val lmulIllegal = outVecCtrl.vlmul =/= 0.U
  private val maskIllegal = !outVm
  private val restartIllegal = outVstart =/= 0.U
  io.out.bits.ctrl.exceptionVec.get(ExceptionNO.illegalInstr) :=
    outVecCtrl.vill || sewIllegal || lmulIllegal || maskIllegal || restartIllegal
}
