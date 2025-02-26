package hdmi.common

import chisel3._

object HDMIScramblerLFSR {
    // G(x) = 1 + x^11 + x^12 + x^13 + x^16
    def advance(value: UInt): UInt = {
        (value(14, 0) << 1) ^ Mux(value(15), "b0011100000000001".U, 0.U)
    }
    def advance(value: UInt, steps: Int): UInt = {
        (0 until steps).foldLeft(value)((v, _) => advance(v))
    }
}
