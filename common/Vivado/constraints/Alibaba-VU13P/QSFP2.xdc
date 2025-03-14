# SLR2, Bank 229, X1Y36~X1Y39

# 161.132MHz
set_property PACKAGE_PIN Y11 [get_ports qsfp2_refclk_p]
set_property PACKAGE_PIN Y10 [get_ports qsfp2_refclk_n]

create_clock -name qsfp2_refclk -period 6.206 [get_ports qsfp2_refclk_p]

set_property PACKAGE_PIN AA4 [get_ports qsfp2_rxp[0]]
set_property PACKAGE_PIN AA3 [get_ports qsfp2_rxn[0]]
set_property PACKAGE_PIN Y2 [get_ports qsfp2_rxp[1]]
set_property PACKAGE_PIN Y1 [get_ports qsfp2_rxn[1]]
set_property PACKAGE_PIN W4 [get_ports qsfp2_rxp[2]]
set_property PACKAGE_PIN W3 [get_ports qsfp2_rxn[2]]
set_property PACKAGE_PIN V2 [get_ports qsfp2_rxp[3]]
set_property PACKAGE_PIN V1 [get_ports qsfp2_rxn[3]]

set_property PACKAGE_PIN AA9 [get_ports qsfp2_txp[0]]
set_property PACKAGE_PIN AA8 [get_ports qsfp2_txn[0]]
set_property PACKAGE_PIN Y7 [get_ports qsfp2_txp[1]]
set_property PACKAGE_PIN Y6 [get_ports qsfp2_txn[1]]
set_property PACKAGE_PIN W9 [get_ports qsfp2_txp[2]]
set_property PACKAGE_PIN W8 [get_ports qsfp2_txn[2]]
set_property PACKAGE_PIN V7 [get_ports qsfp2_txp[3]]
set_property PACKAGE_PIN V6 [get_ports qsfp2_txn[3]]

set_property -dict { PACKAGE_PIN BB11 IOSTANDARD LVCMOS12 } [get_ports qsfp2_modprsl]
set_property -dict { PACKAGE_PIN BC11 IOSTANDARD LVCMOS12 } [get_ports qsfp2_intl]
set_property -dict { PACKAGE_PIN BB10 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp2_resetl]
set_property -dict { PACKAGE_PIN BB7 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp2_lpmode]
set_property -dict { PACKAGE_PIN BF12 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp2_scl]
set_property -dict { PACKAGE_PIN BD9 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp2_sda]

set_property -dict { PACKAGE_PIN BD21 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports qsfp2_led_y]
set_property -dict { PACKAGE_PIN BE22 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports qsfp2_led_g]
