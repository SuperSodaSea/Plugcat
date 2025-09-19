package hdmioutexample

import circt.stage._
import hdmi.source._

object HDMIGenerator extends App {
    val firtoolOpts = Array("-disable-all-randomization", "-disable-layers=Verification")
    ChiselStage.emitSystemVerilogFile(new HDMISource(4), args, firtoolOpts)
}
