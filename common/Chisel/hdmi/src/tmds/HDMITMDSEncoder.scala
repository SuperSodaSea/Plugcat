package hdmi.tmds

import chisel3._
import chisel3.experimental.BundleLiterals._
import chisel3.util._

object HDMITMDSEncoderInputType extends ChiselEnum {
    val TMDS, TERC4, BYPASS = Value
}

class HDMITMDSEncoderInput extends Bundle {
    val input_type = HDMITMDSEncoderInputType()
    val counter_reset = Bool()
    val tmds = UInt(8.W)
    val terc4 = UInt(4.W)
    val bypass = UInt(10.W)
}

class HDMITMDSEncoderState extends Bundle {
    // TMDS dispairty counter
    val count = SInt(5.W)
}

class HDMITMDSEncoderUnit extends Module {
    val io = FlatIO(new Bundle {
        val input_state = Input(new HDMITMDSEncoderState)
        val input = Input(new HDMITMDSEncoderInput)
        val output_state = Output(new HDMITMDSEncoderState)
        val output = Output(UInt(10.W))
    })

    io.output_state.count := Mux(io.input.counter_reset, 0.S, io.input_state.count)
    io.output := 0.U

    switch (io.input.input_type) {
    is (HDMITMDSEncoderInputType.TMDS) {
        val d = io.input.tmds
        val n1_d = PopCount(d)

        val b0 = n1_d > 4.U | (n1_d === 4.U & d(0) === 0.U)
        val q_m_b = Wire(Vec(9, Bool()))
        q_m_b(0) := d(0)
        for (j <- 1 to 7)
            q_m_b(j) := q_m_b(j - 1) ^ d(j) ^ b0
        q_m_b(8) := ~b0
        val q_m = q_m_b.asUInt

        val n1_q_m = PopCount(q_m(7, 0))

        val output = io.output
        val delta = 2.S * n1_q_m - 8.S
        val count = io.input_state.count
        when (count === 0.S | n1_q_m === 4.U) {
            output := Cat(~q_m(8), q_m(8), Mux(q_m(8), q_m(7, 0), ~q_m(7, 0)))
            when (q_m(8)) {
                io.output_state.count := count + delta
            } .otherwise {
                io.output_state.count := count - delta
            }
        } .elsewhen ((count > 0.S & n1_q_m > 4.U) | (count < 0.S & n1_q_m < 4.U)) {
            output := Cat(1.B, q_m(8), ~q_m(7, 0))
            io.output_state.count := count + 2.S * q_m(8) - delta
        } .otherwise {
            output := Cat(0.B, q_m(8), q_m(7, 0))
            io.output_state.count := count - 2.S * ~q_m(8) + delta
        }
    }
    is (HDMITMDSEncoderInputType.TERC4) {
        val TERC4_ENCODING = VecInit(
            "b1010011100".U,
            "b1001100011".U,
            "b1011100100".U,
            "b1011100010".U,
            "b0101110001".U,
            "b0100011110".U,
            "b0110001110".U,
            "b0100111100".U,
            "b1011001100".U,
            "b0100111001".U,
            "b0110011100".U,
            "b1011000110".U,
            "b1010001110".U,
            "b1001110001".U,
            "b0101100011".U,
            "b1011000011".U,
        )

        io.output := TERC4_ENCODING(io.input.terc4)
    }
    is (HDMITMDSEncoderInputType.BYPASS) {
        io.output := io.input.bypass
    }
    }
}

class HDMITMDSEncoder(characters: Int) extends Module {
    val io = FlatIO(new Bundle {
        val input = Input(Vec(characters, new HDMITMDSEncoderInput))
        val output = Output(Vec(characters, UInt(10.W)))
    })

    val units = (0 until characters).map(_ => Module(new HDMITMDSEncoderUnit))

    val state = RegInit((new HDMITMDSEncoderState).Lit(
        _.count -> 0.S,
    ))
    val states = Wire(Vec(characters + 1, new HDMITMDSEncoderState))
    states(0) := state
    state := states(characters)

    for (i <- 0 until characters) {
        units(i).io.input := io.input(i)
        units(i).io.input_state := states(i)
        io.output(i) := units(i).io.output
        states(i + 1) := units(i).io.output_state
    }
}
