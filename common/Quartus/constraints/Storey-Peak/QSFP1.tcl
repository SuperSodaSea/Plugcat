set QSFP1_TX_P_PINS { J4 G4 E4 C4 }
set QSFP1_TX_N_PINS { J3 G3 E3 C3 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP1_TX_P_PINS $i] -to qsfp1_tx[$i]
    set_location_assignment PIN_[lindex $QSFP1_TX_N_PINS $i] -to qsfp1_tx[$i](n)
    set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to qsfp1_tx[$i]
}
set QSFP1_RX_P_PINS { K2 H2 F2 D2 }
set QSFP1_RX_N_PINS { K1 H1 F1 D1 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP1_RX_P_PINS $i] -to qsfp1_rx[$i]
    set_location_assignment PIN_[lindex $QSFP1_RX_N_PINS $i] -to qsfp1_rx[$i](n)
    set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to qsfp1_rx[$i]
}

set_location_assignment PIN_AA25 -to qsfp1_scl
set_instance_assignment -name IO_STANDARD "2.5 V" -to qsfp1_scl
set_location_assignment PIN_AB25 -to qsfp1_sda
set_instance_assignment -name IO_STANDARD "2.5 V" -to qsfp1_sda
