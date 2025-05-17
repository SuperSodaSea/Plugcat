# Bank 225, X0Y4~X0Y7

# 156.25MHz
set_property PACKAGE_PIN V7 [get_ports qsfp_refclk_p]
set_property PACKAGE_PIN V6 [get_ports qsfp_refclk_n]

create_clock -name qsfp_refclk -period 6.4 [get_ports qsfp_refclk_p]

set_property PACKAGE_PIN Y2 [get_ports qsfp_rxp[0]]
set_property PACKAGE_PIN Y1 [get_ports qsfp_rxn[0]]
set_property PACKAGE_PIN V2 [get_ports qsfp_rxp[1]]
set_property PACKAGE_PIN V1 [get_ports qsfp_rxn[1]]
set_property PACKAGE_PIN T2 [get_ports qsfp_rxp[2]]
set_property PACKAGE_PIN T1 [get_ports qsfp_rxn[2]]
set_property PACKAGE_PIN P2 [get_ports qsfp_rxp[3]]
set_property PACKAGE_PIN P1 [get_ports qsfp_rxn[3]]

set_property PACKAGE_PIN AA5 [get_ports qsfp_txp[0]]
set_property PACKAGE_PIN AA4 [get_ports qsfp_txn[0]]
set_property PACKAGE_PIN W5 [get_ports qsfp_txp[1]]
set_property PACKAGE_PIN W4 [get_ports qsfp_txn[1]]
set_property PACKAGE_PIN U5 [get_ports qsfp_txp[2]]
set_property PACKAGE_PIN U4 [get_ports qsfp_txn[2]]
set_property PACKAGE_PIN R5 [get_ports qsfp_txp[3]]
set_property PACKAGE_PIN R4 [get_ports qsfp_txn[3]]

set_property -dict { PACKAGE_PIN AA13 IOSTANDARD LVCMOS33 } [get_ports qsfp_modprsl]
set_property -dict { PACKAGE_PIN Y13 IOSTANDARD LVCMOS33 } [get_ports qsfp_intl]
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports qsfp_modsell]
set_property -dict { PACKAGE_PIN W12 IOSTANDARD LVCMOS33 } [get_ports qsfp_resetl]
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports qsfp_lpmode]
set_property -dict { PACKAGE_PIN AE15 IOSTANDARD LVCMOS33 } [get_ports qsfp_scl]
set_property -dict { PACKAGE_PIN AE13 IOSTANDARD LVCMOS33 } [get_ports qsfp_sda]
