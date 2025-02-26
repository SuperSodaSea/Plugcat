package hdmi.tmds

import chisel3._
import chisel3.experimental.BundleLiterals._
import chisel3.util._
import hdmi.common._

object HDMITMDSScramblerInputType extends ChiselEnum {
    val IDLE, VIDEO_DATA, VIDEO_DATA_GUARD_BAND, DATA_ISLAND, DATA_ISLAND_GUARD_BAND, CONTROL = Value
}

class HDMITMDSScramblerInput extends Bundle {
    val input_type = HDMITMDSScramblerInputType()
    val scrambler_enable = Bool()
    val video_data = UInt(8.W)
    val data_island = UInt(4.W)
    val control = UInt(2.W)
}

class HDMITMDSScramblerState extends Bundle {
    // LFSR value
    val lfsr = UInt(16.W)
    // Control period scrambling counter
    val count = SInt(2.W)
}

object HDMITMDSScrambler {
    def seed(channel: Int) = (channel match {
        case 0 => 0xFFFF
        case 1 => 0xFFFE
        case 2 => 0xFFFD
    }).asUInt(16.W)
}

class HDMITMDSScramblerUnit(channel: Int) extends Module {
    val io = FlatIO(new Bundle {
        val input_state = Input(new HDMITMDSScramblerState)
        val input = Input(new HDMITMDSScramblerInput)
        val output_state = Output(new HDMITMDSScramblerState)
        val output = Output(new HDMITMDSEncoderInput)
    })

    io.output.input_type := HDMITMDSEncoderInputType.BYPASS
    io.output.counter_reset := true.B
    io.output.tmds := 0.U
    io.output.terc4 := 0.U
    io.output.bypass := 0.U

    when (~io.input.scrambler_enable) {
        io.output_state.lfsr := HDMITMDSScrambler.seed(channel)
        io.output_state.count := 0.S

        switch (io.input.input_type) {
        is (HDMITMDSScramblerInputType.VIDEO_DATA) {
            io.output.input_type := HDMITMDSEncoderInputType.TMDS
            io.output.counter_reset := false.B
            io.output.tmds := io.input.video_data
        }
        is (HDMITMDSScramblerInputType.VIDEO_DATA_GUARD_BAND) {
            io.output.input_type := HDMITMDSEncoderInputType.BYPASS
            io.output.counter_reset := true.B
            io.output.bypass := (channel match {
                case 0 => "b1011001100".U
                case 1 => "b0100110011".U
                case 2 => "b1011001100".U
            })
        }
        is (HDMITMDSScramblerInputType.DATA_ISLAND) {
            io.output.input_type := HDMITMDSEncoderInputType.TERC4
            io.output.counter_reset := true.B
            io.output.terc4 := io.input.data_island
        }
        is (HDMITMDSScramblerInputType.DATA_ISLAND_GUARD_BAND) {
            io.output.input_type := HDMITMDSEncoderInputType.BYPASS
            io.output.counter_reset := true.B
            io.output.bypass := "b0100110011".U
        }
        is (HDMITMDSScramblerInputType.CONTROL) {
            val CONTROL_ENCODING = VecInit(
                "b1101010100".U,
                "b0010101011".U,
                "b0101010100".U,
                "b1010101011".U,
            )

            io.output.input_type := HDMITMDSEncoderInputType.BYPASS
            io.output.counter_reset := true.B
            io.output.bypass := CONTROL_ENCODING(io.input.control)
        }
        }
    } .otherwise {
        io.output_state.lfsr := HDMIScramblerLFSR.advance(io.input_state.lfsr, 8)
        io.output_state.count := io.input_state.count

        val lfsr = io.input_state.lfsr

        switch (io.input.input_type) {
        is (HDMITMDSScramblerInputType.VIDEO_DATA) {
            io.output.input_type := HDMITMDSEncoderInputType.TMDS
            io.output.counter_reset := false.B
            io.output.tmds := io.input.video_data ^ Reverse(lfsr(15, 8))
        }
        is (HDMITMDSScramblerInputType.VIDEO_DATA_GUARD_BAND) {
            io.output.input_type := HDMITMDSEncoderInputType.TMDS
            io.output.counter_reset := false.B
            io.output.tmds := (channel match {
                case 0 => "b10101011".U
                case 1 => "b01010101".U
                case 2 => "b10101011".U
            }) ^ Reverse(lfsr(15, 8))
        }
        is (HDMITMDSScramblerInputType.DATA_ISLAND) {
            io.output.input_type := HDMITMDSEncoderInputType.TERC4
            io.output.counter_reset := false.B
            io.output.terc4 := io.input.data_island ^ Reverse(lfsr(15, 12))
        }
        is (HDMITMDSScramblerInputType.DATA_ISLAND_GUARD_BAND) {
            io.output.input_type := HDMITMDSEncoderInputType.TMDS
            io.output.counter_reset := false.B
            io.output.tmds := "b01010101".U ^ Reverse(lfsr(15, 8))
        }
        is (HDMITMDSScramblerInputType.CONTROL) {
            val SCRAMBLED_CONTROL_ENCODING = VecInit(
                "b0000010111".U,
                "b0000011011".U,
                "b0000011101".U,
                "b0000011110".U,
                "b0000100111".U,
                "b0000110011".U,
                "b0000111001".U,
                "b0000111100".U,
                "b0001000111".U,
                "b0001100011".U,
                "b0001110001".U,
                "b0001111000".U,
                "b0010000111".U,
                "b0011000011".U,
                "b0011100001".U,
                "b0011110000".U,
            )

            val itoggle = Wire(Bool())
            when (io.input_state.count === 1.S) {
                itoggle := 0.B
                io.output_state.count := 0.S
            } .elsewhen (io.input_state.count === -1.S) {
                itoggle := 1.B
                io.output_state.count := 0.S
            } .otherwise {
                itoggle := lfsr(15)
                io.output_state.count := Mux(lfsr(15), 1.S, -1.S)
            }

            val control_vector = Cat(io.input.control, channel.U(2.W))
            val scv = Cat(control_vector ^ Reverse(lfsr(14, 11)), itoggle)

            io.output.input_type := HDMITMDSEncoderInputType.BYPASS
            io.output.counter_reset := true.B
            io.output.bypass := SCRAMBLED_CONTROL_ENCODING(scv(4, 1)) ^ Fill(10, scv(0))
        }
        }
    }
}

class HDMITMDSScrambler(characters: Int, channel: Int) extends Module {
    val io = FlatIO(new Bundle {
        val input = Input(Vec(characters, new HDMITMDSScramblerInput))
        val output = Output(Vec(characters, new HDMITMDSEncoderInput))
    })

    val units = (0 until characters).map(_ => Module(new HDMITMDSScramblerUnit(channel)))

    val state = RegInit((new HDMITMDSScramblerState).Lit(
        _.lfsr -> HDMITMDSScrambler.seed(channel),
        _.count -> 0.S,
    ))
    val states = Wire(Vec(characters + 1, new HDMITMDSScramblerState))
    states(0) := state
    state := states(characters)

    for (i <- 0 until characters) {
        units(i).io.input := io.input(i)
        units(i).io.input_state := states(i)
        io.output(i) := units(i).io.output
        states(i + 1) := units(i).io.output_state
    }
}
