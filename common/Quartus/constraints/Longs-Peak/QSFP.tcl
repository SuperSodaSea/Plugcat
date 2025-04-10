set QSFP_TX_P_PINS { R37 T39 U37 V39 }
set QSFP_TX_N_PINS { R36 T38 U36 V38 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP_TX_P_PINS $i] -to qsfp_tx[$i]
    set_location_assignment PIN_[lindex $QSFP_TX_N_PINS $i] -to qsfp_tx[$i](n)
    set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to qsfp_tx[$i]
}
set QSFP_RX_P_PINS { U33 V31 V35 W33 }
set QSFP_RX_N_PINS { U32 V30 V34 W32 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP_RX_P_PINS $i] -to qsfp_rx[$i]
    set_location_assignment PIN_[lindex $QSFP_RX_N_PINS $i] -to qsfp_rx[$i](n)
    set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to qsfp_rx[$i]
}

set_location_assignment PIN_K20 -to qsfp_scl
set_instance_assignment -name IO_STANDARD "1.8 V" -to qsfp_scl
set_location_assignment PIN_L20 -to qsfp_sda
set_instance_assignment -name IO_STANDARD "1.8 V" -to qsfp_sda
set_location_assignment PIN_AG15 -to qsfp_modprsl
set_instance_assignment -name IO_STANDARD "1.8 V" -to qsfp_modprsl
