# QSFP 1
# Bank 1N, Channel 0/4/3/1

# REFCLK_GXBL1N_CHTp/n, 644.53125MHz
set_location_assignment PIN_H34 -to qsfp1_refclk
set_location_assignment PIN_H33 -to qsfp1_refclk(n)
set_instance_assignment -name IO_STANDARD HCSL -to qsfp1_refclk

set QSFP1_TX_P { F38 A36 B38 C40 }
set QSFP1_TX_N { F37 A35 B37 C39 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP1_TX_P $i] -to qsfp1_tx[$i]
    set_location_assignment PIN_[lindex $QSFP1_TX_N $i] -to qsfp1_tx[$i](n)
}
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to qsfp1_tx[*]

set QSFP1_RX_P { C32 D30 A28 B30 }
set QSFP1_RX_N { C31 D29 A27 B29 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP1_RX_P $i] -to qsfp1_rx[$i]
    set_location_assignment PIN_[lindex $QSFP1_RX_N $i] -to qsfp1_rx[$i](n)
}
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to qsfp1_rx[*]
