package hdmioutexample

import circt.stage._
import hdmi.source._

object HDMIGenerator extends App {
    ChiselStage.emitSystemVerilog(new HDMISource(4), Array.empty, args)
}
