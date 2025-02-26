package hdmi.source

import chisel3._
import chisel3.util._
import hdmi.common._
import hdmi.tmds._

class HDMISourceState extends Bundle {
    val x = UInt(16.W)
    val y = UInt(16.W)
    val hdata = Bool()
    val vdata = Bool()
    val hsync = Bool()
    val vsync = Bool()
}

class HDMISourceUnit extends Module {
    val io = FlatIO(new Bundle {
        val video_timing = Input(new HDMIVideoTiming)
        val scrambler_enable = Input(Bool())
        val data_island_data = Input(Vec(32, UInt(9.W)))

        val input_state = Input(new HDMISourceState)
        val input = Input(Vec(3, UInt(8.W)))
        val output_state = Output(new HDMISourceState)
        val output = Output(Vec(3, new HDMITMDSScramblerInput))
    })

    val h_active = io.video_timing.h_active
    val h_sync_start = h_active + io.video_timing.h_front_porch
    val h_sync_end = h_sync_start + io.video_timing.h_sync
    val h_total = h_sync_end + io.video_timing.h_back_porch
    val v_active = io.video_timing.v_active
    val v_sync_start = v_active + io.video_timing.v_front_porch
    val v_sync_end = v_sync_start + io.video_timing.v_sync
    val v_total = v_sync_end + io.video_timing.v_back_porch

    val x = io.input_state.x
    val y = io.input_state.y
    val data_enable = io.input_state.hdata & io.input_state.vdata
    val hsync = io.output_state.hsync ^ ~io.video_timing.h_sync_polarity
    val vsync = io.output_state.vsync ^ ~io.video_timing.v_sync_polarity

    io.output_state.x := Mux(x + 1.U =/= h_total, x + 1.U, x + 1.U - h_total)
    io.output_state.y := Mux(x + 1.U =/= h_total, y, Mux(y + 1.U =/= v_total, y + 1.U, 0.U))

    val hdata_start = x === h_total - 1.U
    val hdata_end = x === h_active - 1.U
    val vdata_start = hdata_start & y === v_total - 1.U
    val vdata_end = hdata_end & y === v_active - 1.U
    io.output_state.hdata := Mux(io.input_state.hdata, ~hdata_end, hdata_start)
    io.output_state.vdata := Mux(io.input_state.vdata, ~vdata_end, vdata_start)

    val hsync_start = x === h_sync_start - 1.U
    val hsync_end = x === h_sync_end - 1.U
    val vsync_start = hsync_start & y === v_sync_start - 1.U
    val vsync_end = hsync_start & y === v_sync_end - 1.U
    io.output_state.hsync := Mux(io.input_state.hsync, ~hsync_end, hsync_start)
    io.output_state.vsync := Mux(io.input_state.vsync, ~vsync_end, vsync_start)

    val scrambler_reset = y === v_active - 1.U & (x >= h_active & x < h_active + 8.U)

    val video_data_preamble = (y === v_total - 1.U | y < v_active - 1.U) & ((x >= h_total - 10.U) & (x < h_total - 2.U))
    val video_data_guard_band = (y === v_total - 1.U | y < v_active - 1.U) & (x >= h_total - 2.U)

    val data_island_preamble = y === v_active & (x < 8.U)
    val data_island_guard_band = y === v_active & ((x >= 8.U & x < 10.U) | (x >= 42.U & x < 44.U))
    val data_island = y === v_active & (x >= 10.U & x < 42.U)
    val data_island_first = y === v_active & x === 10.U
    val data_island_index = (x - 10.U)(4, 0)

    val ctl = Wire(UInt(4.W))
    when (video_data_preamble) {
        ctl := "b0001".U
    } .elsewhen (data_island_preamble) {
        ctl := "b0101".U
    } .otherwise {
        ctl := 0.U
    }

    val input_type_reg = RegInit(VecInit.fill(3)(HDMITMDSScramblerInputType.IDLE))
    suppressEnumCastWarning {
        input_type_reg(0) := Mux1H(Seq(
            data_enable -> HDMITMDSScramblerInputType.VIDEO_DATA,
            video_data_guard_band -> HDMITMDSScramblerInputType.VIDEO_DATA_GUARD_BAND,
            (data_island_guard_band | data_island) -> HDMITMDSScramblerInputType.DATA_ISLAND,
            ~(data_enable | video_data_guard_band | data_island | data_island_guard_band) -> HDMITMDSScramblerInputType.CONTROL,
        ))
        input_type_reg(1) := Mux1H(Seq(
            data_enable -> HDMITMDSScramblerInputType.VIDEO_DATA,
            video_data_guard_band -> HDMITMDSScramblerInputType.VIDEO_DATA_GUARD_BAND,
            data_island -> HDMITMDSScramblerInputType.DATA_ISLAND,
            data_island_guard_band -> HDMITMDSScramblerInputType.DATA_ISLAND_GUARD_BAND,
            ~(data_enable | video_data_guard_band | data_island | data_island_guard_band) -> HDMITMDSScramblerInputType.CONTROL,
        ))
        input_type_reg(2) := Mux1H(Seq(
            data_enable -> HDMITMDSScramblerInputType.VIDEO_DATA,
            video_data_guard_band -> HDMITMDSScramblerInputType.VIDEO_DATA_GUARD_BAND,
            data_island -> HDMITMDSScramblerInputType.DATA_ISLAND,
            data_island_guard_band -> HDMITMDSScramblerInputType.DATA_ISLAND_GUARD_BAND,
            ~(data_enable | video_data_guard_band | data_island | data_island_guard_band) -> HDMITMDSScramblerInputType.CONTROL,
        ))
    }

    val scrambler_enable_reg = RegInit(false.B)
    scrambler_enable_reg := io.scrambler_enable & ~scrambler_reset

    val video_data_reg = RegInit(VecInit.fill(3)(0.U(8.W)))
    video_data_reg := io.input

    val data_island_reg = RegInit(VecInit.fill(3)(0.U(4.W)))
    when (data_island_guard_band) {
        data_island_reg(0) := Cat(1.B, 1.B, vsync, hsync)
    } .elsewhen(data_island) {
        data_island_reg(0) := Cat(~data_island_first, io.data_island_data(data_island_index)(8), vsync, hsync)
        data_island_reg(1) := io.data_island_data(data_island_index)(3, 0)
        data_island_reg(2) := io.data_island_data(data_island_index)(7, 4)
    }

    val control_reg = RegInit(VecInit.fill(3)(0.U(2.W)))
    control_reg(0) := Cat(vsync, hsync)
    control_reg(1) := ctl(1, 0)
    control_reg(2) := ctl(3, 2)

    io.output(0).input_type := input_type_reg(0)
    io.output(0).scrambler_enable := scrambler_enable_reg
    io.output(0).video_data := video_data_reg(0)
    io.output(0).data_island := data_island_reg(0)
    io.output(0).control := control_reg(0)

    io.output(1).input_type := input_type_reg(1)
    io.output(1).scrambler_enable := scrambler_enable_reg
    io.output(1).video_data := video_data_reg(1)
    io.output(1).data_island := data_island_reg(1)
    io.output(1).control := control_reg(1)

    io.output(2).input_type := input_type_reg(2)
    io.output(2).scrambler_enable := scrambler_enable_reg
    io.output(2).video_data := video_data_reg(2)
    io.output(2).data_island := data_island_reg(2)
    io.output(2).control := control_reg(2)
}

class HDMISource(characters: Int) extends Module {
    assert(characters >= 1)

    val io = FlatIO(new Bundle {
        val video_timing = Input(new HDMIVideoTiming)
        val scrambler_enable = Input(Bool())
        val tmds_bit_clock_ratio = Input(Bool())

        val start_frame = Output(Bool())

        val input = Flipped(Irrevocable(Vec(characters, UInt((8 * 8).W))))

        val lane0, lane1, lane2, lane3 = Output(Vec(characters, UInt(10.W)))
    })

    val h_active = io.video_timing.h_active
    val v_active = io.video_timing.v_active

    val packet = Wire(new HDMIDataIslandPacket)
    packet := HDMIAVIInfoFrame()

    val packet_header_ecc = Wire(UInt(8.W))
    val packet_body_ecc = Wire(Vec(4, UInt(8.W)))
    packet_header_ecc := (0 until 3).foldLeft(0.U)((ecc, i) => HDMIDataIslandPacketECC.advance(ecc, packet.header(i)))
    for (i <- 0 until 4)
        packet_body_ecc(i) := (0 until 7).foldLeft(0.U)((ecc, j) => HDMIDataIslandPacketECC.advance(ecc, packet.body(i * 7 + j)))

    val bch_block_0 = Cat(packet_body_ecc(0), Cat((6 to 0 by -1).map(i => packet.body(i))))
    val bch_block_1 = Cat(packet_body_ecc(1), Cat((13 to 7 by -1).map(i => packet.body(i))))
    val bch_block_2 = Cat(packet_body_ecc(2), Cat((20 to 14 by -1).map(i => packet.body(i))))
    val bch_block_3 = Cat(packet_body_ecc(3), Cat((27 to 21 by -1).map(i => packet.body(i))))
    val bch_block_4 = Cat(packet_header_ecc, packet.header.asUInt)

    val data_island_data = Wire(Vec(32, UInt(9.W)))
    for (i <- 0 until 32)
        data_island_data(i) := Cat(
            bch_block_4(i),
            bch_block_3(2 * i + 1),
            bch_block_2(2 * i + 1),
            bch_block_1(2 * i + 1),
            bch_block_0(2 * i + 1),
            bch_block_3(2 * i),
            bch_block_2(2 * i),
            bch_block_1(2 * i),
            bch_block_0(2 * i),
        )

    val units = (0 until characters).map(_ => Module(new HDMISourceUnit))

    val tmds_scramblers = (0 until 3).map(i => Module(new HDMITMDSScrambler(characters, i)))
    val tmds_encoders = (0 until 3).map(_ => Module(new HDMITMDSEncoder(characters)))
    for (i <- 0 until 3)
        tmds_encoders(i).io.input := RegNext(tmds_scramblers(i).io.output)

    val state_init = Wire(new HDMISourceState)
    state_init.x := h_active
    state_init.y := v_active - 1.U
    state_init.hdata := false.B
    state_init.vdata := false.B
    state_init.hsync := false.B
    state_init.vsync := false.B
    val state = RegInit(state_init)
    val states = Wire(Vec(characters + 1, new HDMISourceState))
    states(0) := state
    state := states(characters)

    val input_offset = Wire(UInt(log2Ceil(characters).W))
    val input_offset_reg = RegInit(0.U(input_offset.getWidth.W))
    input_offset := input_offset_reg
    input_offset_reg := input_offset

    io.input.ready := false.B
    val input_prev = RegNext(io.input.bits)

    io.start_frame := false.B

    for (i <- 0 until characters) {
        when (states(i).x === 0.U) {
            input_offset := i.U
        }
        val input_src = Mux(i.U < input_offset, input_prev, io.input.bits)
        val input = VecInit(
            Seq((23, 16), (15, 8), (7, 0)).map {
                case (high, low) => input_src(i.U - input_offset)(high, low)
            }
        )

        when (states(i).hdata & states(i).vdata & (i.U >= input_offset)) {
            io.input.ready := ~reset.asBool
        }

        val unit = units(i)
        unit.io.video_timing := io.video_timing
        unit.io.scrambler_enable := io.scrambler_enable
        unit.io.data_island_data := data_island_data
        unit.io.input_state := states(i)
        unit.io.input := input
        states(i + 1) := unit.io.output_state
        for (j <- 0 until 3)
            tmds_scramblers(j).io.input(i) := unit.io.output(j)

        io.lane0(i) := tmds_encoders(0).io.output(i)
        io.lane1(i) := tmds_encoders(1).io.output(i)
        io.lane2(i) := tmds_encoders(2).io.output(i)

        when (states(i).x === h_active & states(i).y === v_active - 1.U) {
            io.start_frame := true.B
        }
    }

    when (~io.tmds_bit_clock_ratio) {
        io.lane3 := VecInit.fill(characters)("b1111100000".U)
    } .otherwise {
        val pixel_clock_prev = RegInit(3.U(2.W))
        val pixel_clock_wire = Wire(Vec(characters + 1, UInt(2.W)))
        pixel_clock_wire(0) := pixel_clock_prev
        pixel_clock_prev := pixel_clock_wire(characters)

        for (i <- 0 until characters) {
            val pixel_clock = pixel_clock_wire(i + 1)
            pixel_clock := pixel_clock_wire(i) + 1.U
            io.lane3(i) := Fill(10, pixel_clock(1))
        }
    }
}
