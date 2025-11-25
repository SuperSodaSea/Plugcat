# QSFP 0
# Bank 1F, Channel 0/4/3/1

# REFCLK_GXBL1F_CHTp/n, 644.53125MHz
set_location_assignment PIN_AD34 -to qsfp0_refclk
set_location_assignment PIN_AD33 -to qsfp0_refclk(n)
set_instance_assignment -name IO_STANDARD HCSL -to qsfp0_refclk

set QSFP0_TX_P { AG40 AC40 AD42 AF42 }
set QSFP0_TX_N { AG39 AC39 AD41 AF41 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP0_TX_P $i] -to qsfp0_tx[$i]
    set_location_assignment PIN_[lindex $QSFP0_TX_N $i] -to qsfp0_tx[$i](n)
}
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to qsfp0_tx[*]

set QSFP0_RX_P { AG36 AC36 AB38 AD38 }
set QSFP0_RX_N { AG35 AC35 AB37 AD37 }
for { set i 0 } { $i < 4 } { incr i } {
    set_location_assignment PIN_[lindex $QSFP0_RX_P $i] -to qsfp0_rx[$i]
    set_location_assignment PIN_[lindex $QSFP0_RX_N $i] -to qsfp0_rx[$i](n)
}
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to qsfp0_rx[*]
