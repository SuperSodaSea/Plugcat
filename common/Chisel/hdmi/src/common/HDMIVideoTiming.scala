package hdmi.common

import chisel3._

class HDMIVideoTiming extends Bundle {
    var h_active = UInt(16.W)
    var h_front_porch = UInt(16.W)
    var h_sync = UInt(16.W)
    var h_back_porch = UInt(16.W)
    var v_active = UInt(16.W)
    var v_front_porch = UInt(16.W)
    var v_sync = UInt(16.W)
    var v_back_porch = UInt(16.W)
    var h_sync_polarity = Bool()
    var v_sync_polarity = Bool()
}
