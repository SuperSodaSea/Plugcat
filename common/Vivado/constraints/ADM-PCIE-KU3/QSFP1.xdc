# Bank 228, X1Y16~X1Y19

# 156.25MHz, Reconfigurable with Si5338
set_property PACKAGE_PIN K6 [get_ports qsfp1_refclk_p]
set_property PACKAGE_PIN K5 [get_ports qsfp1_refclk_n]

create_clock -name qsfp1_refclk -period 6.4 [get_ports qsfp1_refclk_p]

set_property PACKAGE_PIN F6 [get_ports qsfp1_txp[0]]
set_property PACKAGE_PIN F5 [get_ports qsfp1_txn[0]]
set_property PACKAGE_PIN D6 [get_ports qsfp1_txp[1]]
set_property PACKAGE_PIN D5 [get_ports qsfp1_txn[1]]
set_property PACKAGE_PIN C4 [get_ports qsfp1_txp[2]]
set_property PACKAGE_PIN C3 [get_ports qsfp1_txn[2]]
set_property PACKAGE_PIN B6 [get_ports qsfp1_txp[3]]
set_property PACKAGE_PIN B5 [get_ports qsfp1_txn[3]]

set_property PACKAGE_PIN E4 [get_ports qsfp1_rxp[0]]
set_property PACKAGE_PIN E3 [get_ports qsfp1_rxn[0]]
set_property PACKAGE_PIN D2 [get_ports qsfp1_rxp[1]]
set_property PACKAGE_PIN D1 [get_ports qsfp1_rxn[1]]
set_property PACKAGE_PIN B2 [get_ports qsfp1_rxp[2]]
set_property PACKAGE_PIN B1 [get_ports qsfp1_rxn[2]]
set_property PACKAGE_PIN A4 [get_ports qsfp1_rxp[3]]
set_property PACKAGE_PIN A3 [get_ports qsfp1_rxn[3]]

set_property -dict { PACKAGE_PIN AP10 IOSTANDARD LVCMOS33 } [get_ports qsfp1_modprsl]
set_property -dict { PACKAGE_PIN AN11 IOSTANDARD LVCMOS33 } [get_ports qsfp1_intl]
set_property -dict { PACKAGE_PIN AP11 IOSTANDARD LVCMOS33 } [get_ports qsfp1_resetl]
set_property -dict { PACKAGE_PIN AN13 IOSTANDARD LVCMOS33 } [get_ports qsfp1_lpmode]
set_property -dict { PACKAGE_PIN AP13 IOSTANDARD LVCMOS33 } [get_ports qsfp1_scl]
set_property -dict { PACKAGE_PIN AM11 IOSTANDARD LVCMOS33 } [get_ports qsfp1_sda]
