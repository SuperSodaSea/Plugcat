set QSFP0_TX_P_PINS { U4 R4 N4 L4 }
set QSFP0_TX_N_PINS { U3 R3 N3 L3 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP0_TX_P_PINS $i] -to qsfp0_tx[$i]
    set_location_assignment PIN_[lindex $QSFP0_TX_N_PINS $i] -to qsfp0_tx[$i](n)
    set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to qsfp0_tx[$i]
}
set QSFP0_RX_P_PINS { V2 T2 P2 M2 }
set QSFP0_RX_N_PINS { V1 T1 P1 M1 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP0_RX_P_PINS $i] -to qsfp0_rx[$i]
    set_location_assignment PIN_[lindex $QSFP0_RX_N_PINS $i] -to qsfp0_rx[$i](n)
    set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to qsfp0_rx[$i]
}

set_location_assignment PIN_AB24 -to qsfp0_scl
set_instance_assignment -name IO_STANDARD "2.5 V" -to qsfp0_scl
set_location_assignment PIN_AC24 -to qsfp0_sda
set_instance_assignment -name IO_STANDARD "2.5 V" -to qsfp0_sda
