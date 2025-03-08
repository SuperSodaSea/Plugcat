# SLR3, Bank 233, X1Y52~X1Y55

# 161.132MHz
set_property PACKAGE_PIN D11 [get_ports qsfp1_refclk_p]
set_property PACKAGE_PIN D10 [get_ports qsfp1_refclk_n]

set_property PACKAGE_PIN E4 [get_ports qsfp1_rxp[0]]
set_property PACKAGE_PIN E3 [get_ports qsfp1_rxn[0]]
set_property PACKAGE_PIN D2 [get_ports qsfp1_rxp[1]]
set_property PACKAGE_PIN D1 [get_ports qsfp1_rxn[1]]
set_property PACKAGE_PIN C4 [get_ports qsfp1_rxp[2]]
set_property PACKAGE_PIN C3 [get_ports qsfp1_rxn[2]]
set_property PACKAGE_PIN A5 [get_ports qsfp1_rxp[3]]
set_property PACKAGE_PIN A4 [get_ports qsfp1_rxn[3]]

set_property PACKAGE_PIN E9 [get_ports qsfp1_txp[0]]
set_property PACKAGE_PIN E8 [get_ports qsfp1_txn[0]]
set_property PACKAGE_PIN D7 [get_ports qsfp1_txp[1]]
set_property PACKAGE_PIN D6 [get_ports qsfp1_txn[1]]
set_property PACKAGE_PIN C9 [get_ports qsfp1_txp[2]]
set_property PACKAGE_PIN C8 [get_ports qsfp1_txn[2]]
set_property PACKAGE_PIN A9 [get_ports qsfp1_txp[3]]
set_property PACKAGE_PIN A8 [get_ports qsfp1_txn[3]]

set_property -dict { PACKAGE_PIN BC7 IOSTANDARD LVCMOS12 } [get_ports qsfp1_modprsl]
set_property -dict { PACKAGE_PIN BC8 IOSTANDARD LVCMOS12 } [get_ports qsfp1_intl]
set_property -dict { PACKAGE_PIN BB9 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp1_lpmode]
set_property -dict { PACKAGE_PIN BA7 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp1_resetl]
set_property -dict { PACKAGE_PIN BD8 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp1_scl]
set_property -dict { PACKAGE_PIN BC12 IOSTANDARD LVCMOS12 DRIVE 8 PULLTYPE PULLUP } [get_ports qsfp1_sda]

set_property -dict { PACKAGE_PIN BE21 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports qsfp1_led_y]
set_property -dict { PACKAGE_PIN BF22 IOSTANDARD LVCMOS12 DRIVE 8 } [get_ports qsfp1_led_g]
