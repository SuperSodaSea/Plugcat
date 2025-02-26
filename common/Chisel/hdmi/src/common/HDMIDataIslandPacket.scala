package hdmi.common

import chisel3._

class HDMIDataIslandPacket extends Bundle {
    val header = Vec(3, UInt(8.W))
    val body = Vec(28, UInt(8.W))
}

object HDMIDataIslandPacketECC {
    // G(x) = 1 + x^6 + x^7 + x^8
    def advance(ecc: UInt, input: Bool): UInt = {
        (ecc >> 1) ^ Mux(ecc(0) ^ input, "b10000011".U, 0.U)
    }
    def advance(ecc: UInt, input: UInt): UInt = {
        (0 until 8).foldLeft(ecc)((ecc, i) => advance(ecc, input(i)))
    }
}


object HDMIAVIInfoFrame {
    def apply(): HDMIDataIslandPacket = {
        val packet = Wire(new HDMIDataIslandPacket)
        packet.header(0) := 0x82.U // AVI InfoFrame
        packet.header(1) := 0x02.U // Version
        packet.header(2) := 0x0D.U // Length
        packet.body := VecInit.fill(28)(0.U)

        // RGB 4:4:4
        packet.body(1) := "b00000000".U // Y = 00, A = 0, B = 00, S = 00
        packet.body(2) := "b00000000".U // C = 00, M = 00, R = 0000
        packet.body(3) := "b00000000".U // ITC = 0, EC = 000, Q = 00, SC = 00
        packet.body(4) := "b00000000".U // VIC = 0
        packet.body(5) := "b00000000".U // YQ = 00, CN = 00, PR = 0000

        // YCbCr 4:4:4
        // packet.body(1) := "b01000000".U // Y = 10, A = 0, B = 00, S = 00
        // packet.body(2) := "b00000000".U // C = 00, M = 00, R = 0000
        // packet.body(3) := "b00000000".U // ITC = 0, EC = 000, Q = 00, SC = 00
        // packet.body(4) := "b00000000".U // VIC = 0
        // packet.body(5) := "b00000000".U // YQ = 00, CN = 00, PR = 0000

        var checksum = 0.U(8.W)
        for (i <- 0 until 3) checksum = checksum - packet.header(i)
        for (i <- 1 to 13) checksum = checksum - packet.body(i)
        packet.body(0) := checksum

        packet
    }
}
